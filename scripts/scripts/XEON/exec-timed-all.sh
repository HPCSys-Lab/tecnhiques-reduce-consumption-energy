#bin/bin/bash
if [ "$#" -ne 1 ]; then
	# echo "$# $*"
  echo "Usage: $0 PATH" >&2
  exit 1
fi

#execute all the other executions with 90% rate
bin/generic-timed.sh $1
#bin/timed-chunk.sh $1 s.arff $3
#bin/timed-runper.sh $1 s.arff $3
#bin/timed-seq-chunk.sh $1 s.arff $3
#bin/timed-sequential.sh $1 s.arff $3

#execute the extra runs with 50 and 15% rate with LBag on airlines.arff
#bin/3rates-chunk.sh $1 s.arff 871 - running on generic
bin/3rates-chunk.sh $1 s.arff 484
bin/3rates-chunk.sh $1 s.arff 145
#bin/3rates-runper.sh $1 s.arff $3 328 - running on generic
bin/3rates-runper.sh $1 s.arff $3 182
bin/3rates-runper.sh $1 s.arff $3 54
#bin/3rates-sequential.sh $1 s.arff $3 126 - running on generic
bin/3rates-sequential.sh $1 s.arff $3 70
bin/3rates-sequential.sh $1 s.arff $3 21
#bin/3rates-seq-chunk.sh $1 s.arff $3 - sequential-chunk not used

