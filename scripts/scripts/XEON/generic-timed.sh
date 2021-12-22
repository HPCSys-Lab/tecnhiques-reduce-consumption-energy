#!/bin/bash
function Y {
  #Usage: $0 FILE ALGORITHM RATE
  Memory=50G
  CORES="0,1,2,3,4,5,6,7"
  export MOA_HOME=/opt/data/moa-LAST
  export RESULT_DIR=/opt/data/timed-all-included
  export REMOTE_DIR=/home/gcassales/bases/
  faux=${1##*\/}
  onlyname=${faux%%.*}
  date +"%d/%m/%y %T"
  date +"%d/%m/%y %T" >> exper_order.log
  echo "$2 $1 $3"
  ssh gcassales@192.168.0.11 java ServerProducer 192.168.0.11 9004 ${REMOTE_DIR}${1##*\/} $3 0 &
  sleep 1
  if [[ $2 == *"MAX"* ]]; then
    #CHUNK
    IDENT="timedchunk"
    echo "$RESULT_DIR/${IDENT}-${onlyname}-${2##*.}-100-8-500-${3}" >> exper_order.log
    echo "$RESULT_DIR/${IDENT}-${onlyname}-${2##*.}-100-8-500-${3}"
    numactl --physcpubind=${CORES} java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "SocketExperChunksTIMED -l ($2 -s 100 -c 8) -s (ArffFileStream -f $1) -c 500 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${IDENT}-${onlyname}-${2##*.}-100-8-500-${3}" > ${RESULT_DIR}/term-${IDENT}-${onlyname}-${2##*.}-100-8-500-${3}
  elif [[ ${2} == *"RUNPER"* ]]; then
    #PARALLEL
    IDENT="timedinterleaved"
    echo "$RESULT_DIR/${IDENT}-${onlyname}-${2##*.}-100-8-1-${3}" >> exper_order.log
    echo "$RESULT_DIR/${IDENT}-${onlyname}-${2##*.}-100-8-1-${3}"
    numactl --physcpubind=${CORES} java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "SocketExperTIMED -l ($2 -s 100 -c 8) -s (ArffFileStream -f $1) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${IDENT}-${onlyname}-${2##*.}-100-8-1-${3}" > ${RESULT_DIR}/term-${IDENT}-${onlyname}-${2##*.}-100-8-1-${3}
  else
    #SEQUENTIAL OR PARALLEL
    IDENT="timedinterleaved"
    echo "$RESULT_DIR/${IDENT}-${onlyname}-${2##*.}-100-1-1-${3}" >> exper_order.log
    echo "$RESULT_DIR/${IDENT}-${onlyname}-${2##*.}-100-1-1-${3}"
    numactl --physcpubind=0 java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "SocketExperTIMED -l ($2 -s 100) -s (ArffFileStream -f $1) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${IDENT}-${onlyname}-${2##*.}-100-1-1-${3}" > ${RESULT_DIR}/term-${IDENT}-${onlyname}-${2##*.}-100-1-1-${3}
  fi
  echo ""
  date +"%d/%m/%y %T"
  date +"%d/%m/%y %T" >> exper_order.log
}

function X {
  #Usage: $0 FILE ID RS RP RC
  declare -a algs=(
  "meta.AdaptiveRandomForestSequential" "meta.AdaptiveRandomForestExecutorRUNPER" "meta.AdaptiveRandomForestExecutorMAXChunk"
  "meta.OzaBag" "meta.OzaBagExecutorRUNPER" "meta.OzaBagExecutorMAXChunk"
  "meta.OzaBagAdwin" "meta.OzaBagAdwinExecutorRUNPER" "meta.OzaBagAdwinExecutorMAXChunk"
  "meta.LeveragingBag" "meta.LBagExecutorRUNPER" "meta.LBagExecutorMAXChunk"
  )
  if [[ $2 == *"ARF"* ]]; then
    ID=0
  elif [[ $2 == "OBag" ]]; then
    ID=3
  elif [[ $2 == "OBagAd" ]]; then
    ID=6
  elif [[ $2 == "LBag" ]]; then
    ID=9
  fi
  Y $1 ${algs[${ID}]} $3
  Y $1 ${algs[$(( ID+1 ))]} $4
  Y $1 ${algs[$(( ID+2 ))]} $5
}

#Usage: $0 PATH 
X $1elecNormNew.arff ARF 546 1089 1921
X $1elecNormNew.arff OBag 3089 3842 5869
X $1elecNormNew.arff OBagAd 2142 2781 5126
X $1elecNormNew.arff LBag 888 1378 2806

X $1airlines.arff ARF 155 333 561
X $1airlines.arff OBag 1018 1447 3314
X $1airlines.arff OBagAd 413 768 1679
X $1airlines.arff LBag 126 328 871

X $1covtypeNorm.arff ARF 373 825 1677
X $1covtypeNorm.arff OBag 857 1193 1626
X $1covtypeNorm.arff OBagAd 530 877 1221
X $1covtypeNorm.arff LBag 343 522 1626

X $1GMSC.arff ARF 789 1248 2564
X $1GMSC.arff OBag 3432 4990 8958
X $1GMSC.arff OBagAd 2479 3908 8088
X $1GMSC.arff LBag 998 1409 3366
date +"%d/%m/%y %T" >> exper_order.log
