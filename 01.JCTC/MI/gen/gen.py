#!/usr/bin/python3

import glob
import pandas as pd

pd.set_option('display.max_rows', 40)
pd.set_option('display.max_columns', 40)
pd.set_option('display.width', 10000)

files = glob.glob("*.out")

systems_data = {}

for f in files:
  print("")
  print(f)
  fn = f.replace(".out","").replace("-","m").replace(".","")
  system = fn.split("_")[0]
  colname = "_".join(fn.split("_")[1:])
  head = [ "X", "Y", "Z", colname ]
  tab = pd.read_csv(f, sep=";", header=None)
  print(head)
  tab.columns = head
  print(fn)
  if system not in systems_data:
    systems_data[system] = tab
  else:
    systems_data[system] = pd.merge(systems_data[system], tab, on=[ "X", "Y", "Z" ])

out = pd.concat([systems_data["H2O"], systems_data["C6H6"],systems_data["Be"],systems_data["H2"],systems_data["He"],systems_data["Li2"]])
out.to_csv("../whole_data.csv", sep=";", index=False)
