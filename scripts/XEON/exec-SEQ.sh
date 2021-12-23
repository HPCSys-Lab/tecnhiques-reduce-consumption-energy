#!/bin/bash
if [ "$#" -ne 2 ]; then
	# echo "$# $*"
  echo "Usage: $0 PATH FILE_SUFFIX" >&2
  exit 1
fi
Memory=50G
declare -a algs=("meta.AdaptiveRandomForestSequential")
#"meta.OzaBag" "meta.OzaBagAdwin" "meta.LeveragingBag" 
declare -a ensemble_size=(100)
#150)
declare -a paths=("")
# "-second" "-third")
#mkdir /opt/data/SEQUENCIAL-second
#mkdir /opt/data/SEQUENCIAL-third
export RESULT_DIR=/opt/data/dryrunteste
export MOA_HOME=/opt/data/moa-LAST
# ---------------------------------------------------- CODE ----------------------------------------------------
for p in "${paths[@]}"
do
  export RESULT_DIR=/opt/data/dryrunteste$p
  for i in $1*$2
  do
    for k in "${ensemble_size[@]}"
    do
      for j in "${algs[@]}"
      do
        i2=${i%%.*}
        onlyname=${i2##*\/}
        echo "Using EITTTExperiments with alg $j on file ${i##*\/} with ensemble_size $k and 1 cores."
        echo "Saving results in $RESULT_DIR/${i2##*\/}-${j##*.}-${k}-1"
        sleep 3s
        echo ""
        #echo "numactl --physcpubind=0 java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask \"EvaluateInterleavedParallelChunks -l ($j -s $k -c $l) -s (ArffFileStream -f $i) -c $m -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${j##*.}-${k}-${l}-${m}\" > ${RESULT_DIR}/term-Chunks-${onlyname}-${j##*.}-${k}-${l}-${m}"
        numactl --physcpubind=0 java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l ($j -s $k) -s (ArffFileStream -f $i) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${j##*.}-${k}-1-1" > ${RESULT_DIR}/term-Interleaved-${onlyname}-${j##*.}-${k}-1-1
        echo ""
      done
    done
  done
done

