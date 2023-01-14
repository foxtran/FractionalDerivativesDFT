#!/usr/bin/python3

import numpy
import numpy as np
import pandas
from sklearn.feature_selection import mutual_info_regression
import multiprocessing as mp

def norm(a):
  return a / max(a)

def MIR(datas):
  global df_mi
  i = datas[0]
  j = datas[1]
  a = datas[2]
  b = datas[3]
  bt = numpy.ravel(b)
  val = mutual_info_regression(a, bt)[0]
  return([i, j, val])

if __name__ == '__main__':

  print("Number of processors: ", mp.cpu_count())
  nproc = max(1, mp.cpu_count() - 4) # at least 1 proc will be used
  print("Number of used threads: ", nproc)

  data = pandas.read_csv("whole_data.csv", sep=";")
  data = data.reindex(sorted(data.columns), axis=1)
  data = data.drop(columns=['X', 'Y', 'Z'])
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

  # for testing
  #data = data[["1","3"]]
  #data["2rho"] = data[["1"]] * 2
  #data["sqrt_rho"] = numpy.sqrt(data[["1"]])
  #data["rho+1"] = data[["1"]] + 1
  #data["rho2"] = data[["1"]]*data[["1"]]

  print(data)

  indep_vars = [] # set independent vars
  dep_vars = data.columns.difference(indep_vars).tolist()

  pandas.set_option('display.max_rows', len(dep_vars))
  pandas.set_option('display.max_columns', len(dep_vars))
  pandas.set_option('display.width', 1000)

  df_mi = pandas.DataFrame(0.0, index=dep_vars, columns = dep_vars)

  pool = mp.Pool(nproc)

  for i in df_mi:
    vals = pool.map(MIR, [[i, j, data[[i]], data[[j]]] for j in df_mi])
    for val in vals:
      it = val[0]
      jt = val[1]
      vt = val[2]
      print(it, jt, vt)
      df_mi[it][jt] = vt

  print(df_mi)

  df_Dist = pandas.DataFrame.copy(df_mi)
  for i in df_Dist:
    for j in df_Dist:
      #d = df_mi[i][i]+df_mi[j][j]-df_mi[j][i]-df_mi[i][j]
      #D = d / (d + (df_mi[j][i]+df_mi[i][j])/2)
      h = df_mi[j][j] - df_mi[j][i]
      df_Dist[j][i] = h

  print(df_Dist)

  out = []
  out.append("Var1;Var2;MIDist;Jaccard")
  for i in df_mi:
    for j in df_mi:
      d = df_mi[i][i]+df_mi[j][j]-df_mi[j][i]-df_mi[i][j]
      D = d / (d + (df_mi[j][i]+df_mi[i][j])/2)
      out.append("{};{};{};{}".format(i, j, d, D))
  open("dist_parallel.csv","w").write("\n".join(out))

