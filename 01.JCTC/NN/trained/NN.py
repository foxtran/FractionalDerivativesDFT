#!/usr/bin/env python3

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
import sklearn

import torch
import torch.nn as nn

import os.path
import time
import random
import uuid
import argparse


class Features(torch.utils.data.Dataset):

    def __init__(self, dataframe, inputs, output, device):
        x = dataframe[inputs].values
        y = dataframe[output].values

        self.x_train = torch.tensor(x, dtype=torch.float32).to(device)
        self.y_train = torch.tensor(y, dtype=torch.float32).to(device)

    def __len__(self):
        return len(self.y_train)

    def __getitem__(self, idx):
        return self.x_train[idx], self.y_train[idx]


class MLP(nn.Module):
    def __init__(self, input_size, num_hidden_layers, num_hidden_neurons, output_size):
        super(MLP, self).__init__()

        self.ELU = nn.ELU()
        self.input_l = nn.ModuleList()
        self.input_l.append(nn.Sequential(nn.Linear(input_size, num_hidden_neurons), nn.ELU()))
        self.hidden = nn.ModuleList()
        for i in range(num_hidden_layers - 1):
            self.hidden.append(nn.Linear(num_hidden_neurons, num_hidden_neurons))

        self.output = nn.Linear(num_hidden_neurons, output_size)

    def forward(self, x):
        for layer in self.input_l:
            x = layer(x)
        for layer in self.hidden:
            x = x + self.ELU(layer(x))
        x = self.output(x)
        return x


class FastTensorDataLoader:
    """
    A DataLoader-like object for a set of tensors that can be much faster than
    TensorDataset + DataLoader because dataloader grabs individual indices of
    the dataset and calls cat (slow).
    Source: https://discuss.pytorch.org/t/dataloader-much-slower-than-manual-batching/27014/6
    """

    def __init__(self, *tensors, batch_size=32, shuffle=False):
        """
        Initialize a FastTensorDataLoader.
        :param *tensors: tensors to store. Must have the same length @ dim 0.
        :param batch_size: batch size to load.
        :param shuffle: if True, shuffle the data *in-place* whenever an
            iterator is created out of this object.
        :returns: A FastTensorDataLoader.
        """
        assert all(t.shape[0] == tensors[0].shape[0] for t in tensors)
        self.tensors = tensors

        self.dataset_len = self.tensors[0].shape[0]
        self.batch_size = batch_size
        self.shuffle = shuffle

        # Calculate # batches
        n_batches, remainder = divmod(self.dataset_len, self.batch_size)
        if remainder > 0:
            n_batches += 1
        self.n_batches = n_batches

    def __iter__(self):
        if self.shuffle:
            r = torch.randperm(self.dataset_len)
            self.tensors = [t[r] for t in self.tensors]
        self.i = 0
        return self

    def __next__(self):
        if self.i >= self.dataset_len:
            raise StopIteration
        batch = tuple(t[self.i:self.i+self.batch_size] for t in self.tensors)
        self.i += self.batch_size
        return batch

    def __len__(self):
        return self.n_batches


# read and clean data
def read_data(filename, norm, eps=1e-4, drop=True):
    data = pd.read_csv(filename, sep=";")
    data = data.reindex(sorted(data.columns), axis=1)
    #data = data.drop(columns=['X', 'Y', 'Z'])
    data = data[data["1"] > 1e-8]
    if norm:
        data = data[np.abs(data["3"]) > 1e-10] # for norming

    if drop:
        perc = 100-0.00025
        perc_data = {}
        for i in ["1", "2", "3", "7", "999"]:
            perc_data[i] = np.percentile(data[i], perc)

        for i in ["1", "2", "3", "7", "999"]:
            data = data[data[i] < perc_data[i]]

        perc = 0.00025
        perc_data = {}
        for i in ["1", "2", "3", "7", "999"]:
            perc_data[i] = np.percentile(data[i], perc)

        for i in ["1", "2", "3", "7", "999"]:
            data = data[data[i] > perc_data[i]]

    if norm:
        data['999'] = -data['999']
        for i in data.columns:
            if i == '3':
                T = np.log(np.abs(data[i]))
                data[i] = np.sign(data[i]) * (T - np.log(1e-10))
                del T
            if i in ["X", "Y", "Z"]:
                pass
            else:
                data[i] = np.log(data[i])

    return data


# train the model
def train_model(fd, model_id, model, train_loader, train_full_loader, valid_loader, criterion, lr, max_epoch, max_notrain, min_loss=np.inf, min_valid_loss=np.inf):
    last_min = 0
    success = 0

    optimizer = torch.optim.AdamW(model.parameters(), lr=lr)

    # Train the model
    epoch = 0
    max_epoch_init = max_epoch
    while epoch < max_epoch:
        # train
        model.train()
        for inputs, targets in train_loader:
            #inputs = inputs.to(device)
            #targets = targets.to(device)

            # Clear gradients
            # optimizer.zero_grad()
            for param in model.parameters():
                param.grad = None

            # Forward pass
            outputs = model(inputs)
            loss = criterion(outputs, targets)

            # Backward pass and optimization
            loss.backward()
            optimizer.step()

        # validation
        with torch.no_grad():
            model.eval()
            for inputs, targets in train_full_loader:
                #inputs = inputs.to(device)
                #targets = targets.to(device)
                outputs = model(inputs)
                loss = criterion(outputs, targets)
            for inputs, targets in valid_loader:
                #inputs = inputs.to(device)
                #targets = targets.to(device)
                outputs = model(inputs)
                valid_loss = criterion(outputs, targets)

        fd.write(f"{epoch+1};{lr};{loss.item()};{valid_loss.item()}\n")
        if loss.item() < min_loss:
            min_loss = loss.item()
            torch.save(model.state_dict(), f"{model_id}-train.model")
            last_min = 0
            if max_epoch - epoch < int(0.10 * max_epoch_init):
                max_epoch += max_epoch_init
        if valid_loss.item() < min_valid_loss:
            min_valid_loss = valid_loss.item()
            torch.save(model.state_dict(), f"{model_id}-valid.model")
        # Print the loss for every 10th epoch
        if (epoch + 1) % 10 == 0:
            fd.flush()
            if (epoch + 1) % 1000 == 0:
                torch.save(model.state_dict(), f"tmp-models/{model_id}-{epoch+1}.model")
        last_min += 1
        epoch += 1
        if last_min > max_notrain:
            print(f"No more training after {epoch} epochs!")
            break

    return (min_loss, min_valid_loss)

def parse_args():
    parser = argparse.ArgumentParser(description='NN overfitting', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument(
        '--input_features',
        help="Input features; splitted via comma",
        default="1,2,7",
        type=str)
    parser.add_argument(
        '--output_features',
        help="Output features; splitted via comma",
        default="24_05_1",
        type=str)
    parser.add_argument(
        '--hidden_layers',
        help="Number of hidden layers",
        default=1,
        type=int)
    parser.add_argument(
        '--hidden_neurons',
        help="Number of hidden neurons",
        default=128,
        type=int)
    parser.add_argument(
        '--cuda_device',
        help="CUDA device id",
        default=0,
        type=int)
    parser.add_argument(
        '--seed',
        help="Seed for torch and train/validation separation",
        default=506,
        type=int)
    parser.add_argument(
        '--no_norm',
        help="Disable norming of features",
        action='store_false')
    parser.add_argument(
        '--batch_size',
        help="Batch size",
        default=2000,
        type=int)
    parser.add_argument(
        '--epochs',
        help="Max number of epochs",
        default=100000,
        type=int)
    parser.add_argument(
        '--scale',
        help="Scale number of epochs for first and last lr's",
        default=5,
        type=float)
    parser.add_argument(
        '--notrain_rate',
        help="Scale how many steps optimization may raise loss",
        default=0.05,
        type=float)
    #lrs = [1e-2, 1e-3, 1e-4, 9e-5, 8e-5, 7e-5, 6e-5, 5e-5, 4e-5, 3e-5, 2e-5, 1e-5]
    parser.add_argument(
        '--lrs',
        help="lrs for optimizers; splitted via comma",
        default="1e-3,1e-4,7e-5,4e-5,2e-5,1e-5",
        type=str)
    args = parser.parse_args()

    args.input_features = args.input_features.split(",")
    args.output_features = args.output_features.split(",")
    args.lrs = [ float(x) for x in args.lrs.split(",") ]
    args.cuda_device = str(args.cuda_device)

    return args

if __name__ == '__main__':
    print(f'The scikit-learn version is {sklearn.__version__}.')
    print(f'The torch version is {torch.__version__}.')

    args = parse_args()

    input_features = args.input_features
    output_features = args.output_features
    input_size = len(input_features)
    output_size = len(output_features)
    num_hidden_layers = args.hidden_layers
    num_hidden_neurons = args.hidden_neurons

    # setup for training
    cuda_device_id = args.cuda_device
    seed = args.seed
    norming = args.no_norm
    batch_size = args.batch_size
    lrs = args.lrs
    scale = args.scale
    epochs = args.epochs
    max_notrain_rate = args.notrain_rate

    if seed != None:
        print(f"Seed was set to {seed}!")
        torch.manual_seed(seed)

    device = torch.device(f"cuda:{cuda_device_id}" if torch.cuda.is_available() else "cpu")

    print(f"{device} will be used for training!")

    model = MLP(input_size, num_hidden_layers,
                num_hidden_neurons, output_size)

    model_id = str(uuid.uuid4())

    # load input -> output
    data = read_data("whole_sort_data.csv", norming)
    if seed != None:
        train, valid = train_test_split(data, test_size=0.8, random_state=seed)
    else:
        train, valid = train_test_split(data, test_size=0.8)

    train_dataset = Features(train, input_features, output_features, device)
    valid_dataset = Features(valid, input_features, output_features, device)
    train_loader = FastTensorDataLoader(train_dataset.x_train, train_dataset.y_train, batch_size=batch_size, shuffle=False)
    train_full_loader = FastTensorDataLoader(train_dataset.x_train, train_dataset.y_train, batch_size=len(train_dataset), shuffle=False)
    valid_loader = FastTensorDataLoader(valid_dataset.x_train, valid_dataset.y_train, batch_size=len(valid_dataset), shuffle=False)

    model = model.to(device)
    criterion = nn.MSELoss()

    fd = open(f"{model_id}.res", "w")
    fd.write("#;{seed};{norming};{input_features};{input_size};{num_hidden_layers};{num_hidden_neurons};{output_features};{output_size};{batch_size};{lrs};{epochs};{max_notrain_rate}\n")
    fd.write(f"#;{seed};{norming};{input_features};{input_size};{num_hidden_layers};{num_hidden_neurons};{output_features};{output_size};{batch_size};{lrs};{epochs};{max_notrain_rate}\n")
    fd.write("Epoch;lr;Train;Validation\n")
    min_loss = np.inf
    # train the model
    # note, state is shared via {model_id}-train.model
    for lr in lrs:
        print(f"Training with lr={lr}")
        modelfile = f"{model_id}-train.model"
        if os.path.isfile(modelfile):
            model.load_state_dict(torch.load(modelfile))
            model = model.to(device)
        # rescale number of steps for avoiding unnecessary optimization steps
        if lr == lrs[0]:
            epochs //= scale
        elif lr == lrs[1]: # return number of epochs back
            epochs *= scale
        elif lr == lrs[-1]:
            epochs *= scale
            max_notrain_rate = 2 * 0.05 / scale
        max_notrain = int(epochs * max_notrain_rate)
        # train
        min_loss, _ = train_model(fd, model_id, model, train_loader, train_full_loader, valid_loader, criterion, lr, epochs, max_notrain, min_loss = min_loss)
    print(model_id)
    fd.close()
