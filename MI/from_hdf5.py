#!/usr/bin/python3

import pandas as pd

data = pd.read_hdf("whole_data.h5", 'data', mode='r')
data.to_csv("whole_data.csv", sep=";", index=False)