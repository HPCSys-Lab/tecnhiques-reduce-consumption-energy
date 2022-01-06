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

  export MOA_HOME=/home/reginaldo/UFscar/Parallel-Classifier-MOA/moa-full/target/moa-release-2019.05.1-SNAPSHOT
  export RESULT_DIR=/home/reginaldo/experimentos/socket/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA
  export REMOTE_DIR=/home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/
  export EXPER_ORDER_FILE=$RESULT_DIR/exper_order-freq-max-$FREQUENCIA_MAXIMA-freq-min-$FREQUENCIA_MINIMA.log

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
  # ssh gcassales@192.168.0.11 java ChannelServer 192.168.0.11 9004 ${REMOTE_DIR}${faux} ${rate} >> ${RESULT_DIR}/ssh-log &
  java ChannelServer 127.0.0.1 9004 ${REMOTE_DIR}${faux} ${rate} >> ${RESULT_DIR}/ssh-log &
  
  sleep 3
  if [[ $2 == *"MAX"* ]]; then
    #CHUNK
    IDENT="timedchunk"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}" >> ${EXPER_ORDER_FILE}
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelChunksTIMED -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -c ${bsize} -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}
  elif [[ ${2} == *"RUNPER"* ]]; then
    #PARALLEL
    IDENT="timedinterleaved"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}" >> ${EXPER_ORDER_FILE}
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelTIMED -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}
  else
    #SEQUENTIAL OR PARALLEL
    IDENT="timedinterleaved"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-1-1-${rate}" >> ${EXPER_ORDER_FILE}
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelTIMED -l ($2 -s ${esize}) -s (ArffFileStream -f $1) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-1-1-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-1-1-${rate}
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
  #Y $1 ${algs[${ID}]} $3 $4
  #Y $1 ${algs[$(( ID+1 ))]} $3 $5
  Y $1 ${algs[$(( ID+2 ))]} $3 $6
}

mkdir -p /home/reginaldo/experimentos/socket
mkdir -p /home/reginaldo/experimentos/socket
mkdir -p /home/reginaldo/experimentos/socket/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA

X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 12 21 12
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 63 105 63
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 113 189 113
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 15 25 15
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 77 125 77
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 140 226 140
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 7 12 7
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 36 60 36
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 65 109 65
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 42 45 45
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 211 225 225
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 380 406 406
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 63 58 58
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 319 294 294
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 575 529 529
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 54 49 49
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 273 246 246
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 492 443 443
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 7 13 13
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 35 65 65
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 63 117 117
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 11 21 21
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 55 109 109
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 99 197 197
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 4 8 4
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 22 43 22
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 40 78 40
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 31 33 31
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 156 165 156
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 281 297 281
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 32 30 32
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 162 154 162
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 293 278 293
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 44 44 44
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 220 224 220
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 397 403 397
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 4 9 4
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 21 48 21
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 39 87 39
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 3 6 3
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 19 32 19
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 34 59 34
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 1 3 1
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 9 16 9
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 16 30 16
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 4 6 6
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 21 31 31
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 38 56 56
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 4 7 4
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 24 36 24
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 44 65 44
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 5 7 5
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 28 37 28
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 51 68 51
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 1 4 1
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 7 20 7
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 14 36 14
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 1 4 1
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 5 20 5
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 9 36 9
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 2 4 2
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 10 21 10
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 18 39 18
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 2 7 2
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 12 35 12
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 22 64 22
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 9 10 9
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 48 50 48
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 87 91 87
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 2 8 8
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 13 41 41
X /home/reginaldo/UFscar/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 24 75 75

date + "%d/%m/%y %T" >> $EXPER_ORDER_FILE
