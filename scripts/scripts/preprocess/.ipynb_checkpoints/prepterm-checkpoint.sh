#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <Folder>" >&2
  echo "Example: $0 MC-results/ Xeon <header>\nHeader: 1 or 0" >&2
  exit 1
fi

if [ $3 = "1" ]; then
    echo "arch,eval,dataset,algorithm,ensemble_size,cores,chunk_size,time,accuracy,precision,recall"
fi

for i in $1term*
do
  other=${i##*\/}
  name=${other#*-}
  # echo $name
  python3 preprocess/get_metrics.py $i $2
  #cat $i | grep mxbtime | tail -n 1
  #cut -d, -f 2,4
  #head -n 1 $i # | cut -d, -f 2,4
  #tail -n 1 $i
  #head -n 2 $i | tail -n 1 | cut -d, -f 2,4,11,14
  #tail -n 1 $i | cut -d, -f 2,4,11,14
  # cut -d, -f 2,4 $i
  #i2=$1time-$name
  #head -n 1 $i2 | cut -d' ' -f 1,2,3,4,6
  #head -n 2 $i2 | tail -n 1 | cut -d' ' -f 2,3
  # echo ""
done
