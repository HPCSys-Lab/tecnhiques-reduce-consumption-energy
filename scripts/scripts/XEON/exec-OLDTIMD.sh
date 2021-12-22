#!/bin/bash
if [ "$#" -ne 3 ]; then
	# echo "$# $*"
  echo "Usage: $0 PATH FILE_SUFFIX RATE" >&2
  exit 1
fi
./timed-chunk.sh $1 $2 $3
./timed-runper.sh $1 $2 $3
#./timed-seq-chunk.sh $1 $2 $3
./timed-sequential.sh $1 $2 $3
