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

  export MOA_HOME=/home/pi/moa/moa-LAST
  export RESULT_DIR=/home/pi/reginaldojunior/experimentos/socket/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/
  export REMOTE_DIR=/home/pi/moa/bases/
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
  ssh gcassales@192.168.0.11 java ChannelServer 192.168.0.11 9004 ${REMOTE_DIR}${faux} ${rate} >> ${RESULT_DIR}/ssh-log &
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

mkdir -p /home/pi/reginaldojunior/experimentos/socket
mkdir -p /home/pi/reginaldojunior/experimentos/socket
mkdir -p /home/pi/reginaldojunior/experimentos/socket/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA


X $1airlines.arff ARF 50 0 1 1
X $1airlines.arff ARF 50 2 6 6
X $1airlines.arff ARF 50 4 10 11
X $1airlines.arff LBag 50 0 1 0
X $1airlines.arff LBag 50 3 5 4
X $1airlines.arff LBag 50 6 10 8
X $1airlines.arff SRP 50 0 0 1
X $1airlines.arff SRP 50 0 0 8
X $1airlines.arff SRP 50 0 0 14
X $1airlines.arff OBagAd 50 0 0 1
X $1airlines.arff OBagAd 50 0 0 9
X $1airlines.arff OBagAd 50 0 0 16
X $1airlines.arff OBagASHT 50 0 0 10
X $1airlines.arff OBagASHT 50 0 0 50
X $1airlines.arff OBagASHT 50 0 0 90
X $1airlines.arff OBag 50 0 0 2
X $1airlines.arff OBag 50 0 0 10
X $1airlines.arff OBag 50 0 0 18
X $1elecNormNew.arff ARF 50 1 3 5
X $1elecNormNew.arff ARF 50 9 19 27
X $1elecNormNew.arff ARF 50 16 34 49
X $1elecNormNew.arff LBag 50 2 7 10
X $1elecNormNew.arff LBag 50 13 37 50
X $1elecNormNew.arff LBag 50 24 67 90
X $1elecNormNew.arff SRP 50 1 3 4
X $1elecNormNew.arff SRP 50 7 15 20
X $1elecNormNew.arff SRP 50 12 28 36
X $1elecNormNew.arff OBagAd 50 9 11 27
X $1elecNormNew.arff OBagAd 50 48 58 137
X $1elecNormNew.arff OBagAd 50 87 105 247
X $1elecNormNew.arff OBagASHT 50 9 10 24
X $1elecNormNew.arff OBagASHT 50 46 50 122
X $1elecNormNew.arff OBagASHT 50 83 91 220
X $1elecNormNew.arff OBag 50 14 15 34
X $1elecNormNew.arff OBag 50 70 79 170
X $1elecNormNew.arff OBag 50 126 142 306
X $1covtypeNorm.arff ARF 50 0 0 4
X $1covtypeNorm.arff ARF 50 0 0 21
X $1covtypeNorm.arff ARF 50 0 0 38
X $1covtypeNorm.arff LBag 50 0 0 3
X $1covtypeNorm.arff LBag 50 0 0 16
X $1covtypeNorm.arff LBag 50 0 0 29
X $1covtypeNorm.arff SRP 50 0 0 1
X $1covtypeNorm.arff SRP 50 0 0 7
X $1covtypeNorm.arff SRP 50 0 0 14
X $1covtypeNorm.arff OBagAd 50 0 0 3
X $1covtypeNorm.arff OBagAd 50 0 0 16
X $1covtypeNorm.arff OBagAd 50 0 0 29
X $1covtypeNorm.arff OBagASHT 50 0 0 4
X $1covtypeNorm.arff OBagASHT 50 0 0 22
X $1covtypeNorm.arff OBagASHT 50 0 0 40
X $1covtypeNorm.arff OBag 50 0 0 3
X $1covtypeNorm.arff OBag 50 0 0 18
X $1covtypeNorm.arff OBag 50 0 0 33
X $1GMSC.arff ARF 50 0 0 10
X $1GMSC.arff ARF 50 0 0 53
X $1GMSC.arff ARF 50 0 0 96
X $1GMSC.arff LBag 50 0 0 14
X $1GMSC.arff LBag 50 0 0 72
X $1GMSC.arff LBag 50 0 0 130
X $1GMSC.arff SRP 50 0 0 6
X $1GMSC.arff SRP 50 0 0 30
X $1GMSC.arff SRP 50 0 0 54
X $1GMSC.arff OBagAd 50 0 0 41
X $1GMSC.arff OBagAd 50 0 0 205
X $1GMSC.arff OBagAd 50 0 0 370
X $1GMSC.arff OBagASHT 50 0 0 61
X $1GMSC.arff OBagASHT 50 0 0 305
X $1GMSC.arff OBagASHT 50 0 0 550
X $1GMSC.arff OBag 50 0 0 47
X $1GMSC.arff OBag 50 0 0 235
X $1GMSC.arff OBag 50 0 0 424



X $1airlines.arff ARF 250 0 0 0
X $1airlines.arff ARF 250 0 0 0
X $1airlines.arff ARF 250 0 0 0
X $1airlines.arff LBag 250 0 0 0
X $1airlines.arff LBag 250 0 0 0
X $1airlines.arff LBag 250 0 0 0
X $1airlines.arff SRP 250 0 0 0
X $1airlines.arff SRP 250 0 0 0
X $1airlines.arff SRP 250 0 0 0
X $1airlines.arff OBagAd 250 0 0 0
X $1airlines.arff OBagAd 250 0 0 0
X $1airlines.arff OBagAd 250 0 0 0
X $1airlines.arff OBagASHT 250 0 0 0
X $1airlines.arff OBagASHT 250 0 0 0
X $1airlines.arff OBagASHT 250 0 0 0
X $1airlines.arff OBag 250 0 0 0
X $1airlines.arff OBag 250 0 0 0
X $1airlines.arff OBag 250 0 0 0
X $1elecNormNew.arff ARF 250 0 0 0
X $1elecNormNew.arff ARF 250 0 0 0
X $1elecNormNew.arff ARF 250 0 0 0
X $1elecNormNew.arff LBag 250 0 0 0
X $1elecNormNew.arff LBag 250 0 0 0
X $1elecNormNew.arff LBag 250 0 0 0
X $1elecNormNew.arff SRP 250 0 0 0
X $1elecNormNew.arff SRP 250 0 0 0
X $1elecNormNew.arff SRP 250 0 0 0
X $1elecNormNew.arff OBagAd 250 0 0 0
X $1elecNormNew.arff OBagAd 250 0 0 0
X $1elecNormNew.arff OBagAd 250 0 0 0
X $1elecNormNew.arff OBagASHT 250 0 0 0
X $1elecNormNew.arff OBagASHT 250 0 0 0
X $1elecNormNew.arff OBagASHT 250 0 0 0
X $1elecNormNew.arff OBag 250 0 0 0
X $1elecNormNew.arff OBag 250 0 0 0
X $1elecNormNew.arff OBag 250 0 0 0
X $1covtypeNorm.arff ARF 250 0 0 0
X $1covtypeNorm.arff ARF 250 0 0 0
X $1covtypeNorm.arff ARF 250 0 0 0
X $1covtypeNorm.arff LBag 250 0 0 0
X $1covtypeNorm.arff LBag 250 0 0 0
X $1covtypeNorm.arff LBag 250 0 0 0
X $1covtypeNorm.arff SRP 250 0 0 0
X $1covtypeNorm.arff SRP 250 0 0 0
X $1covtypeNorm.arff SRP 250 0 0 0
X $1covtypeNorm.arff OBagAd 250 0 0 0
X $1covtypeNorm.arff OBagAd 250 0 0 0
X $1covtypeNorm.arff OBagAd 250 0 0 0
X $1covtypeNorm.arff OBagASHT 250 0 0 0
X $1covtypeNorm.arff OBagASHT 250 0 0 0
X $1covtypeNorm.arff OBagASHT 250 0 0 0
X $1covtypeNorm.arff OBag 250 0 0 0
X $1covtypeNorm.arff OBag 250 0 0 0
X $1covtypeNorm.arff OBag 250 0 0 0
X $1GMSC.arff ARF 250 0 0 0
X $1GMSC.arff ARF 250 0 0 0
X $1GMSC.arff ARF 250 0 0 0
X $1GMSC.arff LBag 250 0 0 0
X $1GMSC.arff LBag 250 0 0 0
X $1GMSC.arff LBag 250 0 0 0
X $1GMSC.arff SRP 250 0 0 0
X $1GMSC.arff SRP 250 0 0 0
X $1GMSC.arff SRP 250 0 0 0
X $1GMSC.arff OBagAd 250 0 0 0
X $1GMSC.arff OBagAd 250 0 0 0
X $1GMSC.arff OBagAd 250 0 0 0
X $1GMSC.arff OBagASHT 250 0 0 0
X $1GMSC.arff OBagASHT 250 0 0 0
X $1GMSC.arff OBagASHT 250 0 0 0
X $1GMSC.arff OBag 250 0 0 0
X $1GMSC.arff OBag 250 0 0 0
X $1GMSC.arff OBag 250 0 0 0


X $1airlines.arff ARF 500 0 0 1
X $1airlines.arff ARF 500 0 0 7
X $1airlines.arff ARF 500 0 0 13
X $1airlines.arff LBag 500 0 0 0
X $1airlines.arff LBag 500 0 0 0
X $1airlines.arff LBag 500 0 0 0
X $1airlines.arff SRP 500 0 0 0
X $1airlines.arff SRP 500 0 0 0
X $1airlines.arff SRP 500 0 0 0
X $1airlines.arff OBagAd 500 0 0 0
X $1airlines.arff OBagAd 500 0 0 0
X $1airlines.arff OBagAd 500 0 0 0
X $1airlines.arff OBagASHT 500 0 0 0
X $1airlines.arff OBagASHT 500 0 0 0
X $1airlines.arff OBagASHT 500 0 0 0
X $1airlines.arff OBag 500 0 0 0
X $1airlines.arff OBag 500 0 0 0
X $1airlines.arff OBag 500 0 0 0
X $1elecNormNew.arff ARF 500 0 0 5
X $1elecNormNew.arff ARF 500 0 0 26
X $1elecNormNew.arff ARF 500 0 0 48
X $1elecNormNew.arff LBag 500 0 0 10
X $1elecNormNew.arff LBag 500 0 0 52
X $1elecNormNew.arff LBag 500 0 0 94
X $1elecNormNew.arff SRP 500 0 0 4
X $1elecNormNew.arff SRP 500 0 0 20
X $1elecNormNew.arff SRP 500 0 0 37
X $1elecNormNew.arff OBagAd 500 0 0 30
X $1elecNormNew.arff OBagAd 500 0 0 152
X $1elecNormNew.arff OBagAd 500 0 0 275
X $1elecNormNew.arff OBagASHT 500 0 0 26
X $1elecNormNew.arff OBagASHT 500 0 0 131
X $1elecNormNew.arff OBagASHT 500 0 0 236
X $1elecNormNew.arff OBag 500 0 0 34
X $1elecNormNew.arff OBag 500 0 0 174
X $1elecNormNew.arff OBag 500 0 0 313
X $1covtypeNorm.arff ARF 500 0 0 0
X $1covtypeNorm.arff ARF 500 0 0 0
X $1covtypeNorm.arff ARF 500 0 0 0
X $1covtypeNorm.arff LBag 500 0 0 0
X $1covtypeNorm.arff LBag 500 0 0 0
X $1covtypeNorm.arff LBag 500 0 0 0
X $1covtypeNorm.arff SRP 500 0 0 0
X $1covtypeNorm.arff SRP 500 0 0 0
X $1covtypeNorm.arff SRP 500 0 0 0
X $1covtypeNorm.arff OBagAd 500 0 0 0
X $1covtypeNorm.arff OBagAd 500 0 0 0
X $1covtypeNorm.arff OBagAd 500 0 0 0
X $1covtypeNorm.arff OBagASHT 500 0 0 0
X $1covtypeNorm.arff OBagASHT 500 0 0 0
X $1covtypeNorm.arff OBagASHT 500 0 0 0
X $1covtypeNorm.arff OBag 500 0 0 0
X $1covtypeNorm.arff OBag 500 0 0 0
X $1covtypeNorm.arff OBag 500 0 0 0
X $1GMSC.arff ARF 500 0 0 0
X $1GMSC.arff ARF 500 0 0 0
X $1GMSC.arff ARF 500 0 0 0
X $1GMSC.arff LBag 500 0 0 0
X $1GMSC.arff LBag 500 0 0 0
X $1GMSC.arff LBag 500 0 0 0
X $1GMSC.arff SRP 500 0 0 0
X $1GMSC.arff SRP 500 0 0 0
X $1GMSC.arff SRP 500 0 0 0
X $1GMSC.arff OBagAd 500 0 0 0
X $1GMSC.arff OBagAd 500 0 0 0
X $1GMSC.arff OBagAd 500 0 0 0
X $1GMSC.arff OBagASHT 500 0 0 0
X $1GMSC.arff OBagASHT 500 0 0 0
X $1GMSC.arff OBagASHT 500 0 0 0
X $1GMSC.arff OBag 500 0 0 0
X $1GMSC.arff OBag 500 0 0 0
X $1GMSC.arff OBag 500 0 0 0

date + "%d/%m/%y %T" >> $EXPER_ORDER_FILE
