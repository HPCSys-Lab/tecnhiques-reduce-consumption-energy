#!/bin/bash


if [[ "$#" -eq 0 ]]; then
  echo "This program requires inputs. Type -h for help." >&2
  exit 1
fi

while getopts ":f:F:h" opt;
do
    case $opt in
        h)
            echo "f: Frequencia Minima."
            echo "F: Frequencia Máxima."
            echo "h: Help Opções disponiveis."
        ;;
    f)
      if [[ -n $FREQUENCIA_MINIMA ]]; then
        echo "Invalid input: option -f has already been used!" >&2
        exit 1
      else
        FREQUENCIA_MINIMA="${OPTARG//,/ }"
      fi
    ;;
        F)
            if [[ -n $FREQUENCIA_MAXIMA ]]; then
        echo "Invalid input: option -F has already been used!" >&2
        exit 1
      else
        FREQUENCIA_MAXIMA="$OPTARG"
      fi
        ;;
    esac
done

#Critical checks
if [[ -z $FREQUENCIA_MINIMA && -z $FREQUENCIA_MINIMA ]]; then
    echo "Nothing to run. Expected -f!" >&2
    exit 1
fi

if [[ -z $FREQUENCIA_MAXIMA && -z $FREQUENCIA_MAXIMA ]]; then
    echo "Nothing to run. Expected -f!" >&2
    exit 1
fi

function Y {
  #Usage: $0 FILE ALGORITHM RATE
  Memory=700M
  echo "file: $1 algorithm: $2 batch_size: $3 rate: $4"

  declare -a esize=(25)
  mkdir -p $RESULT_DIR
  faux=${1##*\/}
  onlyname=${faux%%.*}
  bsize=${3}
  rate=${4}
  nCores=4
  date +"%d/%m/%y %T"
  date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE
  echo "ssh-${onlyname}-${2##*.}-${bsize}-${rate}" >> ${RESULT_DIR}/ssh-log
  ssh gcassales@192.168.0.11 java ChannelServer 192.168.0.11 9004 ${REMOTE_DIR}${faux} ${rate} >> ${RESULT_DIR}/ssh-log &
  
  sleep 3

  if [[ $2 == *"MAX"* ]]; then
    export MOA_HOME=/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT
    export RESULT_DIR=/home/pi/reginaldojunior/experimentos/socket/loop-fusion/loop-fusion

    #CHUNK
    IDENT="timedchunk"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}" >> ${EXPER_ORDER_FILE}
    numactl --physcpubind="0,1,2,3" java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelChunksTIMEDOptimized -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -t 120 -c ${bsize} -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}
  else
    export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
    export RESULT_DIR=/home/pi/reginaldojunior/experimentos/socket/loop-fusion/loop-fusion-sequential

    #SEQUENTIAL OR PARALLEL
    IDENT="timedinterleaved"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-1-1-${rate}" >> ${EXPER_ORDER_FILE}
    numactl --physcpubind="0" java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelTIMED -l ($2 -s ${esize}) -s (ArffFileStream -f $1) -t 120 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-1-1-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-1-1-${rate}
  fi
  echo ""
  date +"%d/%m/%y %T"
  date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE
}

function YWithoutLoopFusion {
  #Usage: $0 FILE ALGORITHM RATE
  Memory=700M
  echo "file: $1 algorithm: $2 batch_size: $3 rate: $4"

  declare -a esize=(25)
  mkdir -p $RESULT_DIR
  faux=${1##*\/}
  onlyname=${faux%%.*}
  bsize=${3}
  rate=${4}
  nCores=4
  date +"%d/%m/%y %T"
  date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE
  echo "ssh-${onlyname}-${2##*.}-${bsize}-${rate}" >> ${RESULT_DIR}/ssh-log
  ssh gcassales@192.168.0.11 java ChannelServer 192.168.0.11 9004 ${REMOTE_DIR}${faux} ${rate} >> ${RESULT_DIR}/ssh-log &
  
  sleep 3
  if [[ $2 == *"MAX"* ]]; then
    export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
    export RESULT_DIR=/home/pi/reginaldojunior/experimentos/socket/loop-fusion/without-loop-fusion

    #CHUNK
    IDENT="timedchunk"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}" >> ${EXPER_ORDER_FILE}
    numactl --physcpubind="0,1,2,3" java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelChunksTIMED -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -t 120 -c ${bsize} -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}
  else
    export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
    export RESULT_DIR=/home/pi/reginaldojunior/experimentos/socket/loop-fusion/loop-fusion-sequential

    #SEQUENTIAL OR PARALLEL
    IDENT="timedinterleaved"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-1-1-${rate}" >> ${EXPER_ORDER_FILE}
    numactl --physcpubind="0" java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelTIMED -l ($2 -s ${esize}) -s (ArffFileStream -f $1) -t 120 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-1-1-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-1-1-${rate}
  fi
  echo ""
  date +"%d/%m/%y %T"
  date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE
}

function X {
  #Usage: $0 FILE ID RS RP RC
  declare -a algs=(
  "meta.AdaptiveRandomForestSequential" "meta.AdaptiveRandomForestExecutorRUNPER" "meta.AdaptiveRandomForestExecutorMAXChunk"
  "meta.OzaBag" "meta.OzaBagExecutorRUNPER" "meta.OzaBagExecutorMAXChunk"
  "meta.OzaBagAdwin" "meta.OzaBagAdwinExecutorRUNPER" "meta.OzaBagAdwinExecutorMAXChunk"
  "meta.LeveragingBag" "meta.LBagExecutorRUNPER" "meta.LBagExecutorMAXChunk"
  "meta.OzaBagASHT" "meta.OzaBagASHTExecutorRUNPER" "meta.OzaBagASHTExecutorMAXChunk"
  "meta.StreamingRandomPatches" "meta.StreamingRandomPatchesExecutorRUNPER" "meta.StreamingRandomPatchesExecutorMAXChunk"
  )
  if [[ $2 == *"ARF"* ]]; then
    ID=0
  elif [[ $2 == "OBag" ]]; then
    ID=3
  elif [[ $2 == "OBagAd" ]]; then
    ID=6
  elif [[ $2 == "LBag" ]]; then
    ID=9
  elif [[ $2 == "OBagASHT" ]]; then
    ID=12
  elif [[ $2 == "SRP" ]]; then
    ID=15
  fi
  Y $1 ${algs[${ID}]} $3 $4
  # Y $1 ${algs[$(( ID+1 ))]} $3 $5
  Y $1 ${algs[$(( ID+2 ))]} $3 $6
}

function XWithoutLoopFusion {
  #Usage: $0 FILE ID RS RP RC
  declare -a algs=(
  "meta.AdaptiveRandomForestSequential" "meta.AdaptiveRandomForestExecutorRUNPER" "meta.AdaptiveRandomForestExecutorMAXChunk"
  "meta.OzaBag" "meta.OzaBagExecutorRUNPER" "meta.OzaBagExecutorMAXChunk"
  "meta.OzaBagAdwin" "meta.OzaBagAdwinExecutorRUNPER" "meta.OzaBagAdwinExecutorMAXChunk"
  "meta.LeveragingBag" "meta.LBagExecutorRUNPER" "meta.LBagExecutorMAXChunk"
  "meta.OzaBagASHT" "meta.OzaBagASHTExecutorRUNPER" "meta.OzaBagASHTExecutorMAXChunk"
  "meta.StreamingRandomPatches" "meta.StreamingRandomPatchesExecutorRUNPER" "meta.StreamingRandomPatchesExecutorMAXChunk"
  )
  if [[ $2 == *"ARF"* ]]; then
    ID=0
  elif [[ $2 == "OBag" ]]; then
    ID=3
  elif [[ $2 == "OBagAd" ]]; then
    ID=6
  elif [[ $2 == "LBag" ]]; then
    ID=9
  elif [[ $2 == "OBagASHT" ]]; then
    ID=12
  elif [[ $2 == "SRP" ]]; then
    ID=15
  fi
  # Y $1 ${algs[${ID}]} $3 $4
  # Y $1 ${algs[$(( ID+1 ))]} $3 $5
  YWithoutLoopFusion $1 ${algs[$(( ID+2 ))]} $3 $6
}

## rasp
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/socket/loop-fusion/
export REMOTE_DIR=/home/gcassales/bases/
export EXPER_ORDER_FILE=$RESULT_DIR/exper_order.log

# alterar para o caminho do HD/scratch
mkdir -p $RESULT_DIR
mkdir -p $RESULT_DIR/loop-fusion
mkdir -p $RESULT_DIR/without-loop-fusion
mkdir -p $RESULT_DIR/loop-fusion-sequential

# --------------------
# sequential
# esize 25
# bsize 50
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 44 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 223 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 401 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 64 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 320 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 576 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 25 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 125 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 226 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 153 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 766 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 1380 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 189 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 945 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 1701 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 191 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 956 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 1721 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 26 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 134 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 242 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 44 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 222 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 400 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 14 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 72 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 131 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 91 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 457 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 824 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 110 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 550 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 991 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 119 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 595 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 1072 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 5 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 26 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 48 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 3 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 19 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 34 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 5 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 28 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 50 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 14 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 71 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 128 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 15 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 75 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 135 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 14 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 70 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 127 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 17 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 88 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 159 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 12 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 64 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 115 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 5 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 28 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 52 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 21 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 108 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 195 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 23 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 118 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 213 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 27 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 135 0 0
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 244 0 0


# --------------------
# without-loop-fusion
# esize 25
# bsize 50
# with incremental: True

XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 0 0 91
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 0 0 457
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 0 0 823
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 0 0 131
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 0 0 659
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 0 0 1186
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 0 0 47
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 0 0 237
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 0 0 428
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 0 0 255
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 0 0 1277
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 0 0 2299
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 0 0 424
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 0 0 2122
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 0 0 3820
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 0 0 417
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 0 0 2086
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 0 0 3755
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 0 0 22
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 0 0 112
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 0 0 202
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 0 0 19
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 0 0 97
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 0 0 175
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 0 0 20
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 0 0 101
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 0 0 182
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 0 0 60
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 0 0 303
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 0 0 546
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 0 0 348
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 0 0 1740
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 0 0 3133
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 0 0 475
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 0 0 2375
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 0 0 4275
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 0 0 173
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 0 0 865
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 0 0 1558
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 0 0 201
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 0 0 1006
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 0 0 1810
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 0 0 91
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 0 0 456
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 0 0 821
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 0 0 400
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 0 0 2000
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 0 0 3600
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 0 0 743
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 0 0 3716
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 0 0 6689
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 0 0 703
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 0 0 3516
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 0 0 6330
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 0 0 87
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 0 0 435
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 0 0 783
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 0 0 66
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 0 0 332
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 0 0 598
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 0 0 24
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 0 0 122
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 0 0 220
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 0 0 102
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 0 0 511
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 0 0 920
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 0 0 292
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 0 0 1460
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 0 0 2628
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 0 0 302
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 0 0 1511
XWithoutLoopFusion /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 0 0 2721

# --------------------
# loop-fusion
# esize 25
# bsize 50
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 0 0 91
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 0 0 457
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 0 0 823
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 0 0 131
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 0 0 659
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 0 0 1186
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 0 0 47
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 0 0 237
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 0 0 428
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 0 0 255
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 0 0 1277
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 0 0 2299
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 0 0 424
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 0 0 2122
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 0 0 3820
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 0 0 417
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 0 0 2086
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 0 0 3755
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 0 0 22
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 0 0 112
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 0 0 202
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 0 0 19
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 0 0 97
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 0 0 175
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 0 0 20
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 0 0 101
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 0 0 182
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 0 0 60
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 0 0 303
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 0 0 546
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 0 0 348
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 0 0 1740
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 0 0 3133
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 0 0 475
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 0 0 2375
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 0 0 4275
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 0 0 173
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 0 0 865
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 0 0 1558
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 0 0 201
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 0 0 1006
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 0 0 1810
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 0 0 91
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 0 0 456
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 0 0 821
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 0 0 400
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 0 0 2000
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 0 0 3600
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 0 0 743
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 0 0 3716
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 0 0 6689
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 0 0 703
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 0 0 3516
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 0 0 6330
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 0 0 87
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 0 0 435
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 0 0 783
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 0 0 66
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 0 0 332
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 0 0 598
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 0 0 24
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 0 0 122
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 0 0 220
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 0 0 102
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 0 0 511
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 0 0 920
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 0 0 292
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 0 0 1460
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 0 0 2628
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 0 0 302
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 0 0 1511
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 0 0 2721

date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE