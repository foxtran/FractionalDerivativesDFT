#!/usr/bin/python3

import numpy as np
import pandas

data = pandas.read_csv("whole_data.csv", sep=";")

# to decrease number of data saved in repo
data = data[data["1"] > 1e-8]

perc = 100-0.00025
perc_data = {}
for i in ["1", "2", "3", "7", "999"]:
  perc_data[i] = np.percentile(data[i], perc)
  print(f"{i} 100-0.00025: ", perc_data[i])

for i in ["1", "2", "3", "7", "999"]:
  data = data[data[i] < perc_data[i]]

perc = 0.00025
perc_data = {}
for i in ["1", "2", "3", "7", "999"]:
  perc_data[i] = np.percentile(data[i], perc)
  print(f"{i} 0.00025: ", perc_data[i])

for i in ["1", "2", "3", "7", "999"]:
  data = data[data[i] > perc_data[i]]

# reduce required memory twice by conversion float64 -> float32
# I hope it will not have strong impact on MI_parallel.py's results
for i in list(data.columns):
  data[i] = data[i].astype('float32')

data.to_hdf("whole_data.h5", 'data', mode='w', format='fixed')
