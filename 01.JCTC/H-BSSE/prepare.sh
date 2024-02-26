#!/usr/bin/env bash

echo "Basis;System;Alpha;P;Value" > ref.csv
echo "Basis;System;Distance;Alpha;P;Value" > data.csv

for inpsdir in inps*;
do
  basis=`echo $inpsdir | sed "s/inps.//"`
  cat ${inpsdir}/ref.tab  | cut -d" " -f1,2,3,6 | tr " " ";" | sed "s/^/$basis;/; s/.wfn//"           >> ref.csv
  cat ${inpsdir}/data.tab | cut -d" " -f1,2,3,6 | tr " " ";" | sed "s/^/$basis;/; s/.wfn//; s/-X./;/" >> data.csv
done
