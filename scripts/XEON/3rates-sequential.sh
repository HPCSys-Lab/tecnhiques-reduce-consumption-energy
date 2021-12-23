#!/bin/bash
if [ "$#" -ne 3 ]; then
	# echo "$# $*"
  echo "Usage: $0 PATH FILE_SUFFIX RATE" >&2
  exit 1
fi
Memory=50G
declare -a algs=("meta.LeveragingBag")
declare -a ensemble_size=(100)
declare -a cpus=("" "0" "0,1" "" "0,1,2,3" "" "" "" "0,1,2,3,4,5,6,7")
export MOA_HOME=/opt/data/moa-LAST
export RESULT_DIR=/opt/data/timed-all-included
export REMOTE_DIR=/home/gcassales/bases/
# ---------------------------------------------------- CODE ----------------------------------------------------
for i in $1*$2
do
  for k in "${ensemble_size[@]}"
  do
    for j in "${algs[@]}"
    do
      i2=${i%%.*}
      onlyname=${i2##*\/}
      date +"%d/%m/%y %T" >> exper_order.log
      echo "$RESULT_DIR/timedinterleaved-${i2##*\/}-${j##*.}-${k}-1-1-${3}"
      echo "$RESULT_DIR/timedinterleaved-${i2##*\/}-${j##*.}-${k}-1-1-${3}" >> exper_order.log
      echo ""
      ssh gcassales@192.168.0.11 java ServerProducer 192.168.0.11 9004 ${REMOTE_DIR}${i##*\/} $3 0 &
      sleep 1
      numactl --physcpubind=0 java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "SocketExperTIMED -l ($j -s $k) -s (ArffFileStream -f $i) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-timedinterleaved-${onlyname}-${j##*.}-${k}-1-1-${3}" > ${RESULT_DIR}/term-timedinterleaved-${onlyname}-${j##*.}-${k}-1-1-${3}
      echo ""
    done
  done
done
date +"%d/%m/%y %T" >> exper_order.log
