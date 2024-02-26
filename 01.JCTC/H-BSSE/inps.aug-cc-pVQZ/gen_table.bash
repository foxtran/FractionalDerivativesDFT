#!/usr/bin/bash

export LD_LIBRARY_PATH=/bighome/ger/FD/FractionalDerivativesDFT/flint-install/lib64:$LD_LIBRARY_PATH

alpha_p=("1.0_1"  "0.9_1"  "0.8_1"  "0.7_1"  "0.6_1"  "0.5_1"  "0.4_1"  "0.3_1"  "0.2_1"  "0.1_1"  "0.0_1"
         "0.0_0" "-0.1_0" "-0.2_0" "-0.3_0" "-0.4_0" "-0.5_0" "-0.6_0" "-0.7_0" "-0.8_0" "-0.9_0" "-1.0_0" "-1.1_0" "-1.2_0" "-1.3_0" "-1.4_0" "-1.5_0")

echo -n "" > data.tab

for wfn in H-X*wfn
do
  for ap in ${alpha_p[@]}; do
    ap=`echo $ap | tr "_" " "`
    res=`echo "1000 10 24 1000 2 1303 1000 1303 set_p $ap approx 100 -4 100 ${wfn} 0" | tr " " "\n" | ./gMultiwfn_noGUI H.wfn 2>/dev/null | grep "Final result"`
    echo ${wfn} ${ap} ${res} >> data.tab
  done
done