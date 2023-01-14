#!/usr/bin/bash

nproc="24"

for wfn in *.wfn
do
  fname=`echo $wfn | sed "s/.wfn//"`
  N=("1" "2" "3" "7")
  for i in ${N[@]}
  do
    outfile=${fname}_${i}.txt
    if [ -f $outfile ]; then
      continue
    fi
    echo "1000 10 ${nproc} 5 $i 2 3" | tr " " "\n" | ./gMultiwfn_noGUI ${wfn}
    mv output.txt $outfile
  done

  outfile=${fname}_999.txt
  if [ ! -f $outfile ]; then
    echo "1000 10 ${nproc} 1000 2 999 5 100 2 3" | tr " " "\n" | ./Multiwfn_noGUI ${wfn}
    mv output.txt $outfile
  fi

  # Alpha;p
  AB=("-1.0;1" "-0.9;1" "-0.8;1" "-0.7;1" "-0.6;1" "-0.5;1" "-0.4;1" "-0.3;1" "-0.2;1" "-0.1;1" "0.0;1" "0.1;1" "0.2;1" "0.3;1" "0.4;1" "0.5;1" "0.6;1" "0.7;1" "0.8;1" "0.9;1" "1.0;1" \
      "-2.0;0" "-1.9;0" "-1.8;0" "-1.7;0" "-1.6;0" "-1.5;0" "-1.4;0" "-1.3;0" "-1.2;0" "-1.1;0" "-1.0;0" "-0.9;0" "-0.8;0" "-0.7;0" "-0.6;0" "-0.5;0" "-0.4;0" "-0.3;0" "-0.2;0" "-0.1;0" "0.0;0")
  for i in ${AB[@]}
  do
    log=`echo $i | sed "s/;/_/"`
    outfile=${fname}_24_${log}.txt
    if [ -f $outfile ]; then
      continue
    fi
    inp=`echo $i | sed "s/;/ /"`
    echo "$i"
    echo "1000 10 ${nproc} 1000 2 1303 1000 1303 set_p ${inp} approx 5 100 2 3" | tr " " "\n" | ./gMultiwfn_noGUI ${wfn}
    mv output.txt $outfile
  done
done

for i in *.txt
do
  echo $i
  out=`echo $i | sed "s/txt/out/"`
  sed "s/ \+/;/g; s/^;//" $i > $out
done
