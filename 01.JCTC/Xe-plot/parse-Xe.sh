#!/usr/bin/bash

#AB=("0.0,1.0" "0.1,1.0" "0.2,1.0" "0.3,1.0" "0.4,1.0" "0.5,1.0" "0.6,1.0" "0.7,1.0" "0.8,1.0" "0.9,1.0" "1.0,1.0" "1.1,1.0" "1.2,1.0" "1.3,1.0" "1.4,1.0" "1.5,1.0" "1.6,1.0" "1.7,1.0" "1.8,1.0" "1.9,1.0" "2.0,1.0")

AB=("-2.0,0"
    "-1.0,0" "-0.9,0" "-0.8,0" "-0.7,0" "-0.6,0" "-0.5,0" "-0.4,0" "-0.3,0" "-0.2,0" "-0.1,0"
    "0.0,0"
    "-1.0,1" "-0.9,1" "-0.8,1" "-0.7,1" "-0.6,1" "-0.5,1" "-0.4,1" "-0.3,1" "-0.2,1" "-0.1,1"
    "0.0,1"
    "0.1,1" "0.2,1" "0.3,1" "0.4,1" "0.5,1" "0.6,1" "0.7,1" "0.8,1" "0.9,1" "1.0,1")
for i in ${AB[@]}
do
  log=`echo $i | sed "s/,/l/"`
  echo $i
  alpha=`echo $i | cut -d"," -f1`
  p=`echo $i | cut -d"," -f2`
  echo $alpha
  echo $p
  if [ -f Xe_R_$log.txt ]; then
    continue
  fi
  echo "1000 24 set_p $alpha $p approx 200 5 3 0.0,5.0 4 302 5 2501 1 24 0 5" | tr " " "\n" | ./gMultiwfn_noGUI Xe.wfn
  mv RDF.txt Xe_R_$log.txt
done

echo "Alpha;p;Point;R;Value" > Xe_R_out.log
for i in Xe_R_*.txt
do
  cat $i | sed "s/ \+/ /g; s/^ //; s/^/$i;/; s/.txt//; s/Xe_R_//" | tr " l" ";;"
done >> Xe_R_out.log

./R-Xe.R