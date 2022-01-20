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
  ssh gcassales@192.168.0.11 java ChannelServer 192.168.0.11 9004 ${REMOTE_DIR}${faux} ${rate} >> ${RESULT_DIR}/ssh-log &
  
  sleep 3
  if [[ $2 == *"MAX"* ]]; then
    #CHUNK
    IDENT="timedchunk"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}" >> ${EXPER_ORDER_FILE}
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelChunksTIMED -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -t 120 -c ${bsize} -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}
  elif [[ ${2} == *"RUNPER"* ]]; then
    #PARALLEL
    IDENT="timedinterleaved"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}" >> ${EXPER_ORDER_FILE}
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelTIMED -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -t 120 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}
  else
    #SEQUENTIAL OR PARALLEL
    IDENT="timedinterleaved"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-1-1-${rate}" >> ${EXPER_ORDER_FILE}
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelTIMED -l ($2 -s ${esize}) -s (ArffFileStream -f $1) -t 120 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-1-1-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-1-1-${rate}
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

# 18-01-2022
# esize 100
# bsize 50
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 13 18 29
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 66 94 148
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 119 169 267
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 16 23 33
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 84 119 166
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 152 214 299
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 7 11 18
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 39 59 91
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 70 106 164
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 42 44 91
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 211 220 457
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 380 397 824
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 65 58 172
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 328 291 862
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 591 525 1552
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 55 48 113
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 278 244 566
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 501 439 1019
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 7 14 21
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 37 71 107
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 67 127 192
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 13 23 33
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 65 116 168
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 117 210 303
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 4 7 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 23 36 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 42 65 42
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 34 36 74
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 171 180 371
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 309 324 668
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 41 35 35
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 206 178 178
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 370 320 320
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 46 47 94
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 233 238 473
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 420 429 852
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 4 10 10
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 23 53 53
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 42 96 96
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 3 6 7
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 19 30 35
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 34 54 63
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 1 3 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 9 15 20
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 17 27 37
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 3 6 8
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 18 31 40
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 33 56 72
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 4 6 6
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 21 33 33
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 38 60 60
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 5 6 9
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 25 33 45
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 46 60 81



# --------------------
# 18-01-2022
# esize 100
# bsize 500
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 500 13 18 29
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 500 66 94 148
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 500 119 169 267
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 500 16 23 33
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 500 84 119 166
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 500 152 214 299
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 500 7 11 18
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 500 39 59 91
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 500 70 106 164
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 500 42 44 91
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 500 211 220 457
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 500 380 397 824
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 500 65 58 172
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 500 328 291 862
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 500 591 525 1552
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 500 55 48 113
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 500 278 244 566
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 500 501 439 1019
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 500 7 14 21
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 500 37 71 107
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 500 67 127 192
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 500 13 23 33
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 500 65 116 168
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 500 117 210 303
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 500 4 7 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 500 23 36 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 500 42 65 42
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 500 34 36 74
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 500 171 180 371
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 500 309 324 668
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 500 41 35 35
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 500 206 178 178
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 500 370 320 320
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 500 46 47 94
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 500 233 238 473
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 500 420 429 852
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 500 4 10 10
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 500 23 53 53
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 500 42 96 96
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 500 3 6 7
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 500 19 30 35
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 500 34 54 63
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 500 1 3 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 500 9 15 20
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 500 17 27 37
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 500 3 6 8
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 500 18 31 40
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 500 33 56 72
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 500 4 6 6
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 500 21 33 33
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 500 38 60 60
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 500 5 6 9
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 500 25 33 45
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 500 46 60 81



# --------------------
# 18-01-2022
# esize 100
# bsize 2000
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 2000 13 18 29
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 2000 66 94 148
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 2000 119 169 267
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 2000 16 23 33
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 2000 84 119 166
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 2000 152 214 299
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 2000 7 11 18
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 2000 39 59 91
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 2000 70 106 164
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 2000 42 44 91
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 2000 211 220 457
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 2000 380 397 824
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 2000 65 58 172
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 2000 328 291 862
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 2000 591 525 1552
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 2000 55 48 113
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 2000 278 244 566
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 2000 501 439 1019
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 2000 7 14 21
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 2000 37 71 107
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 2000 67 127 192
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 2000 13 23 33
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 2000 65 116 168
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 2000 117 210 303
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 2000 4 7 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 2000 23 36 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 2000 42 65 42
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 2000 34 36 74
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 2000 171 180 371
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 2000 309 324 668
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 2000 41 35 35
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 2000 206 178 178
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 2000 370 320 320
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 2000 46 47 94
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 2000 233 238 473
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 2000 420 429 852
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 2000 4 10 10
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 2000 23 53 53
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 2000 42 96 96
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 2000 3 6 7
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 2000 19 30 35
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 2000 34 54 63
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 2000 1 3 4
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 2000 9 15 20
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 2000 17 27 37
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 2000 3 6 8
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 2000 18 31 40
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 2000 33 56 72
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 2000 4 6 6
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 2000 21 33 33
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 2000 38 60 60
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 2000 5 6 9
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 2000 25 33 45
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 2000 46 60 81


date + "%d/%m/%y %T" >> $EXPER_ORDER_FILE
