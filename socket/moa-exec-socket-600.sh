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

  export MOA_HOME=/home/pi/moa/moa-LAST/
  export RESULT_DIR=/home/pi/reginaldojunior/experimentos/results/socket/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA
  export REMOTE_DIR=/home/gcassales/bases/
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
    echo "java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask \"ChannelChunksTIMED -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -t 60 -c ${bsize} -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}\" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelChunksTIMED -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -t 60 -c ${bsize} -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}
  elif [[ ${2} == *"RUNPER"* ]]; then
    #PARALLEL
    IDENT="timedinterleaved"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}" >> ${EXPER_ORDER_FILE}
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelTIMED -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -t 60 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}
  else
    #SEQUENTIAL OR PARALLEL
    IDENT="timedinterleaved"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-1-1-${rate}" >> ${EXPER_ORDER_FILE}
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelTIMED -l ($2 -s ${esize}) -s (ArffFileStream -f $1) -t 60 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-1-1-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-1-1-${rate}
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

mkdir -p /home/pi/reginaldojunior/experimentos/results/socket
mkdir -p /home/pi/reginaldojunior/experimentos/results/socket
mkdir -p /home/pi/reginaldojunior/experimentos/results/socket/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 7 12 17
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 35 62 86
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 63 113 155
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 8 14 22
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 42 74 114
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 77 134 206
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 3 7 9
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 19 36 48
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 35 65 87
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 23 26 64
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 116 130 321
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 210 235 578
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 34 34 90
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 170 172 453
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 307 309 816
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 30 28 67
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 153 140 335
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 276 253 603
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 3 8 10
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 18 43 50
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 33 78 91
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 5 12 16
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 29 64 84
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 53 116 152
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 2 4 6
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 12 22 30
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 22 40 54
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 17 20 42
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 89 102 211
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 161 184 380
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 17 22 43
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 89 112 215
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 161 201 387
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 24 26 50
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 121 131 251
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 218 237 452
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 2 6 7
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 11 31 36
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 20 56 65
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 2 3 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 10 17 20
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 18 31 37
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 0 1 2
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 4 9 12
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 8 17 21
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 2 3 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 11 17 24
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 20 30 43
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 2 4 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 13 21 21
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 23 38 38
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 3 3 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 15 19 21
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 27 35 38

# --------------------
# 26-01-2022
# esize 100
# bsize 500
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 500 7 12 17
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 500 35 62 89
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 500 63 113 161
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 500 8 14 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 500 42 74 117
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 500 77 134 210
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 500 3 7 9
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 500 19 36 48
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 500 35 65 87
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 500 23 26 60
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 500 116 130 303
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 500 210 235 546
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 500 34 34 96
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 500 170 172 484
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 500 307 309 871
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 500 30 28 72
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 500 153 140 362
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 500 276 253 652
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 500 3 8 10
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 500 18 43 50
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 500 33 78 91
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 500 5 12 19
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 500 29 64 98
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 500 53 116 177
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 500 2 4 6
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 500 12 22 30
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 500 22 40 54
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 500 17 20 45
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 500 89 102 228
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 500 161 184 411
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 500 17 22 48
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 500 89 112 244
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 500 161 201 440
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 500 24 26 53
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 500 121 131 266
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 500 218 237 479
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 500 2 6 7
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 500 11 31 36
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 500 20 56 66
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 500 2 3 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 500 10 17 21
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 500 18 31 38
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 500 0 1 2
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 500 4 9 12
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 500 8 17 21
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 500 2 3 3
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 500 11 17 19
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 500 20 30 34
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 500 2 4 5
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 500 13 21 29
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 500 23 38 52
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 500 3 3 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 500 15 19 22
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 500 27 35 41

# --------------------
# 26-01-2022
# esize 100
# bsize 2000
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 2000 7 12 15
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 2000 35 62 79
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 2000 63 113 143
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 2000 8 14 21
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 2000 42 74 105
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 2000 77 134 189
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 2000 3 7 9
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 2000 19 36 47
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 2000 35 65 84
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 2000 23 26 55
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 2000 116 130 278
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 2000 210 235 502
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 2000 34 34 82
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 2000 170 172 411
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 2000 307 309 740
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 2000 30 28 65
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 2000 153 140 329
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 2000 276 253 593
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 2000 3 8 9
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 2000 18 43 49
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 2000 33 78 89
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 2000 5 12 18
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 2000 29 64 91
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 2000 53 116 164
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 2000 2 4 6
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 2000 12 22 31
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 2000 22 40 56
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 2000 17 20 42
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 2000 89 102 214
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 2000 161 184 386
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 2000 17 22 46
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 2000 89 112 231
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 2000 161 201 416
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 2000 24 26 50
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 2000 121 131 251
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 2000 218 237 452
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 2000 2 6 6
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 2000 11 31 30
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 2000 20 56 54
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 2000 2 3 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 2000 10 17 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 2000 18 31 42
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 2000 0 1 2
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 2000 4 9 13
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 2000 8 17 24
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 2000 2 3 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 2000 11 17 24
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 2000 20 30 43
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 2000 2 4 6
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 2000 13 21 30
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 2000 23 38 54
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 2000 3 3 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 2000 15 19 24
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 2000 27 35 43

date + "%d/%m/%y %T" >> $EXPER_ORDER_FILE
