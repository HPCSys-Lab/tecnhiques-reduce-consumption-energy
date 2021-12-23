#!/bin/bash
if [ "$#" -ne 2 ]; then
	# echo "$# $*"
  echo "Usage: $0 PATH FILE_SUFFIX" >&2
  exit 1
fi
Memory=50G
declare -a algs=("meta.AdaptiveRandomForestExecutorMAXChunk")
declare -a ensemble_size=(100)
declare -a cores=(1 2  4  8)
declare -a cpus=("" "0" "0,1" "" "0,1,2,3" "" "" "" "0,1,2,3,4,5,6,7")
declare -a chunks=(500)
declare -a path=("")
# "-second" "-third")
#mkdir /opt/data/CHUNK-LAST-second
#mkdir /opt/data/CHUNK-LAST-third
mkdir /opt/data/dryrunteste


export MOA_HOME=/opt/data/moa-LAST
# ---------------------------------------------------- CODE ----------------------------------------------------
for p in "${path[@]}"
do
  export RESULT_DIR=/opt/data/dryrunteste$p
  for i in $1*$2
  do
    for k in "${ensemble_size[@]}"
    do
      for j in "${algs[@]}"
      do
        for l in "${cores[@]}"
        do
          for m in "${chunks[@]}"
          do
            i2=${i%%.*}
            onlyname=${i2##*\/}
            echo "Using EvaluateInterleavedParallelChunks with alg $j on file ${i##*\/} with ensemble_size $k and $l cores."
            echo "Saving results in $RESULT_DIR/${i2##*\/}-${j##*.}-${k}-${l}-${m}"
            sleep 3s
            echo ""
            #echo "numactl --physcpubind=${cpus[l]} java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask \"EvaluateInterleavedParallelChunks -l ($j -s $k -c $l) -s (ArffFileStream -f $i) -c $m -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${j##*.}-${k}-${l}-${m}\" > ${RESULT_DIR}/term-Chunks-${onlyname}-${j##*.}-${k}-${l}-${m}"
	    numactl --physcpubind=${cpus[l]} java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($j -s $k -c $l) -s (ArffFileStream -f $i) -c $m -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${j##*.}-${k}-${l}-${m}" > ${RESULT_DIR}/term-Chunks-${onlyname}-${j##*.}-${k}-${l}-${m}
            echo ""
          done
	done
      done
    done
  done
done

