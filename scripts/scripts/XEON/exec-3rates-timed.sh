#!/bin/bash
if [ "$#" -ne 2 ]; then
	# echo "$# $*"
  echo "Usage: $0 PATH FILE_SUFFIX" >&2
  exit 1
fi
#./3rates-chunk.sh $1 $2 871
./3rates-chunk.sh $1 $2 484
./3rates-chunk.sh $1 $2 145
#./3rates-runper.sh $1 $2 $3 328
./3rates-runper.sh $1 $2 $3 182
./3rates-runper.sh $1 $2 $3 54
#./3rates-seq-chunk.sh $1 $2 $3
#./3rates-sequential.sh $1 $2 $3 126
./3rates-sequential.sh $1 $2 $3 70
./3rates-sequential.sh $1 $2 $3 21
