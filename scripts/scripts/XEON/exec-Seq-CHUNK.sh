#!/bin/bash
if [ "$#" -ne 2 ]; then
	# echo "$# $*"
  echo "Usage: $0 PATH FILE_SUFFIX" >&2
  exit 1
fi
Memory=50G
declare -a algs=("meta.OzaBagSequentialChunk" "meta.OzaBagAdwinSequentialChunk" "meta.LBagSequentialChunk" "meta.AdaptiveRandomForestSequentialChunk")
declare -a ensemble_size=(100 150)
declare -a cpus=("" "0" "0,1" "" "0,1,2,3" "" "" "" "0,1,2,3,4,5,6,7")
declare -a chunks=(50 500 2000)
mkdir /opt/data/CHUNK-LAST
export RESULT_DIR=/opt/data/CHUNK-LAST
export MOA_HOME=/opt/data/moa-LAST
# ---------------------------------------------------- CODE ----------------------------------------------------
for i in $1*$2
do
  for k in "${ensemble_size[@]}"
  do
    for j in "${algs[@]}"
    do
      for m in "${chunks[@]}"
      do
        i2=${i%%.*}
        onlyname=${i2##*\/}
        echo "Using EvaluateInterleavedParallelChunks with alg $j on file ${i##*\/} with ensemble_size $k and 1 cores."
        echo "Saving results in $RESULT_DIR/${i2##*\/}-${j##*.}-${k}-1-${m}"
        sleep 3s
        echo ""
	#echo "numactl --physcpubind=${cpus[l]} java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask \"EvaluateInterleavedParallelChunks -l ($j -s $k -c $l) -s (ArffFileStream -f $i) -c $m -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${j##*.}-${k}-${l}-${m}\" > ${RESULT_DIR}/term-Chunks-${onlyname}-${j##*.}-${k}-${l}-${m}"
	numactl --physcpubind=0 java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($j -s $k) -s (ArffFileStream -f $i) -c $m -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${j##*.}-${k}-1-${m}" > ${RESULT_DIR}/term-Chunks-${onlyname}-${j##*.}-${k}-1-${m}
        echo ""
      done
    done
  done
done

