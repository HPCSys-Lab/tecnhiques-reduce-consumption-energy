
## rasp
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/dynamic-batch/11/
export REMOTE_DIR=/home/gcassales/bases
export LOCAL_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets
export EXPER_ORDER_FILE=$RESULT_DIR/exper_order.log
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-dynamic-batch

function Y {
  #Usage: $0 FILE ALGORITHM RATE
  Memory=700M
  echo "file: $1 algorithm: $2 rate: $3"

  declare -a esize=(25)
  mkdir -p $RESULT_DIR
  faux=${1##*\/}
  onlyname=${faux%%.*}
  nCores=4
  rate={$3}
  date +"%d/%m/%y %T"
  date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE
  echo "ssh-${onlyname}-${2##*.}" >> ${RESULT_DIR}/ssh-log

  ssh gcassales@192.168.0.11 java SocketJavaDynamicMbFixed 192.168.0.11 9004 ${REMOTE_DIR}/$1 $3 >> ${RESULT_DIR}/ssh-log &
  #ssh gcassales@192.168.0.11 python socket-python-dynamic-batch.py 192.168.0.11 9004 ${REMOTE_DIR}/$1 >> ${RESULT_DIR}/ssh-log &

  sleep 5

  echo "/usr/bin/java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask \"ChannelChunksTIMEDOptimized -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f ${LOCAL_DIR}/$1) -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}\" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}"
  IDENT="timedchunk"
  echo "$RESULT_DIR/${onlyname}-${2##*.}" >> ${EXPER_ORDER_FILE}
  /usr/bin/java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelChunksTIMEDOptimized -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f ${LOCAL_DIR}/$1) -t 600 -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}

  sleep 5
  echo ""
  date +"%d/%m/%y %T"
  date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE
}

function X {
  #Usage: $0 FILE ID RS RP RC
  # 1 -> sequential, 2 -> mb sem loop fusion, 3 -> mb com loop fusion
  declare -a algs=(
    "meta.AdaptiveRandomForestSequential" "meta.AdaptiveRandomForestExecutorMAXChunk"
    "meta.OzaBag" "meta.OzaBagExecutorMAXChunk"
    "meta.OzaBagAdwin" "meta.OzaBagAdwinExecutorMAXChunk"
    "meta.LeveragingBag" "meta.LBagExecutorMAXChunk"
    "meta.OzaBagASHT" "meta.OzaBagASHTExecutorMAXChunk"
    "meta.StreamingRandomPatches" "meta.StreamingRandomPatchesExecutorMAXChunk"
  )
  if [[ $2 == *"ARF"* ]]; then
    ID=0
  elif [[ $2 == "OBag" ]]; then
    ID=2
  elif [[ $2 == "OBagAd" ]]; then
    ID=4
  elif [[ $2 == "LBag" ]]; then
    ID=6
  elif [[ $2 == "OBagASHT" ]]; then
    ID=8
  elif [[ $2 == "SRP" ]]; then
    ID=10
  fi
  # Y $1 ${algs[${ID}]} "1" $4 "1"
  # Y $1 ${algs[$(( ID+1 ))]} $3 $5 "2"
  Y $1 ${algs[$(( ID+1 ))]} $3 $6 "3"
}

# alterar para o caminho do HD/scratch
mkdir -p $RESULT_DIR

X covtypeNorm.arff ARF 1080
X covtypeNorm.arff LBag 702
X covtypeNorm.arff SRP 291
X covtypeNorm.arff OBagAd 1149
X covtypeNorm.arff OBagASHT 3314
X covtypeNorm.arff OBag 3557

X airlines.arff ARF 292
X airlines.arff LBag 440
X airlines.arff SRP 277
X airlines.arff OBagAd 970
X airlines.arff OBagASHT 4989
X airlines.arff OBag 6220

X elecNormNew.arff ARF 875
X elecNormNew.arff LBag 1402
X elecNormNew.arff SRP 519
X elecNormNew.arff OBagAd 2528
X elecNormNew.arff OBagASHT 4202
X elecNormNew.arff OBag 4042

X GMSC.arff ARF 1801
X GMSC.arff LBag 2224
X GMSC.arff SRP 974
X GMSC.arff OBagAd 4540
X GMSC.arff OBagASHT 8906
X GMSC.arff OBag 8410

date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE