#!/usr/bin/bash

#AB=("0.0,1.0" "0.1,1.0" "0.2,1.0" "0.3,1.0" "0.4,1.0" "0.5,1.0" "0.6,1.0" "0.7,1.0" "0.8,1.0" "0.9,1.0" "1.0,1.0" "1.1,1.0" "1.2,1.0" "1.3,1.0" "1.4,1.0" "1.5,1.0" "1.6,1.0" "1.7,1.0" "1.8,1.0" "1.9,1.0" "2.0,1.0")

AB=("-2.0,0"
    "-1.0,0" "-0.5,0"
    "0.0,0"
    "-1.0,1" "-0.5,1"
    "0.0,1"
     "0.5,1" "1.0,1")
for i in ${AB[@]}
do
  for wfn in *.wfn
  do
    log=`echo $i | sed "s/,/l/"`
    out=`echo $wfn | sed "s/.wfn//"`
    echo $i
    alpha=`echo $i | cut -d"," -f1`
    p=`echo $i | cut -d"," -f2`
    echo $alpha
    echo $p
    if [ -f ${out}_${log}.txt ]; then
      continue
    fi
    echo "1000 10 24 1000 1303 set_p $alpha $p approx 1000 2 1303 3 100 0 5.641398 1 1,2 2" | tr " " "\n" | ./gMultiwfn_noGUI $wfn
    mv line.txt ${out}_${log}.txt
  done
done

echo "System;Basis;Alpha;p;X;Y;Z;R;Value" > Cl2_data.csv
grep . *.txt | sed "s/ \+/;/g; s/.txt://" | tr "_l" ";;" | sed "s/C;2/Cl2/" >> Cl2_data.csv

./R-Cl2.R
