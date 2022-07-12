#!/bin/bash

#alterar caminhos
export MOA_HOME=/home/pi/moa/moa-LAST
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/results/socket/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA
export REMOTE_DIR=/home/gcassales/bases/
export EXPER_ORDER_FILE=$RESULT_DIR/exper_order-freq-max-$FREQUENCIA_MAXIMA-freq-min-$FREQUENCIA_MINIMA.log

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
  # Y /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/ ${algs[${ID}]} $3 $4
  # Y /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/ ${algs[$(( ID+1 ))]} $3 $5
  Y /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/ ${algs[$(( ID+2 ))]} $3 $6
}

# alterar para o caminho do HD/scratch
mkdir -p /home/pi/reginaldojunior/experimentos/socket
mkdir -p /home/pi/reginaldojunior/experimentos/socket/optimized
mkdir -p /home/pi/reginaldojunior/experimentos/socket/optimized/$FREQUENCIA_MINIMA/$FREQUENCIA_MAXIMA

# optimized
# esize 25
# bsize 5
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 5 31 47 73
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 5 156 236 365
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 5 281 426 657
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 5 164 134 306
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 5 821 670 1531
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 5 1478 1206 2757
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 5 20 37 70
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 5 104 189 352
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 5 187 341 634
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 5 30 40 231
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 5 150 202 1159
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 5 270 363 2087
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 5 6 17 20
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 5 33 85 102
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 5 60 154 184
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 5 16 101 367
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 5 84 506 1837
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 5 152 911 3306
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 5 54 63 129
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 5 270 319 646
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 5 486 575 1164
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 5 224 179 521
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 5 1123 898 2605
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 5 2022 1616 4690

# --------------------
# optimized
# esize 25
# bsize 15
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 15 31 47 83
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 15 156 236 419
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 15 281 426 754
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 15 164 134 382
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 15 821 670 1911
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 15 1478 1206 3440
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 15 20 37 91
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 15 104 189 456
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 15 187 341 821
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 15 30 40 259
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 15 150 202 1298
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 15 270 363 2337
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 15 6 17 21
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 15 33 85 108
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 15 60 154 195
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 15 16 101 432
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 15 84 506 2163
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 15 152 911 3894
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 15 54 63 156
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 15 270 319 783
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 15 486 575 1409
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 15 224 179 594
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 15 1123 898 2973
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 15 2022 1616 5352

# --------------------
# optimized
# esize 25
# bsize 25
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 25 31 47 86
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 25 156 236 432
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 25 281 426 778
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 25 164 134 395
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 25 821 670 1976
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 25 1478 1206 3558
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 25 20 37 83
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 25 104 189 418
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 25 187 341 753
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 25 30 40 275
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 25 150 202 1378
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 25 270 363 2480
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 25 6 17 22
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 25 33 85 110
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 25 60 154 198
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 25 16 101 479
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 25 84 506 2395
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 25 152 911 4311
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 25 54 63 157
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 25 270 319 785
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 25 486 575 1414
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 25 224 179 640
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 25 1123 898 3201
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 25 2022 1616 5762



--------------------
optimized
esize 25
bsize 50
with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 31 47 92
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 156 236 460
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 281 426 828
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 164 134 421
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 821 670 2106
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 1478 1206 3791
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 20 37 94
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 104 189 474
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 187 341 853
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 30 40 295
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 150 202 1479
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 270 363 2663
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 6 17 22
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 33 85 112
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 60 154 203
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 16 101 526
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 84 506 2630
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 152 911 4735
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 54 63 149
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 270 319 748
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 486 575 1347
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 224 179 700
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 1123 898 3502
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 2022 1616 6304

# --------------------
# optimized
# esize 25
# bsize 75
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 75 31 47 93
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 75 156 236 466
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 75 281 426 840
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 75 164 134 422
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 75 821 670 2111
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 75 1478 1206 3800
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 75 20 37 88
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 75 104 189 443
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 75 187 341 798
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 75 30 40 316
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 75 150 202 1581
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 75 270 363 2846
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 75 6 17 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 75 33 85 116
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 75 60 154 210
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 75 16 101 567
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 75 84 506 2836
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 75 152 911 5106
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 75 54 63 158
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 75 270 319 794
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 75 486 575 1429
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 75 224 179 747
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 75 1123 898 3737
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 75 2022 1616 6727

# --------------------
# optimized
# esize 25
# bsize 100
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 100 31 47 91
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 100 156 236 459
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 100 281 426 827
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 100 164 134 458
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 100 821 670 2294
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 100 1478 1206 4130
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 100 20 37 87
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 100 104 189 435
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 100 187 341 784
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 100 30 40 321
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 100 150 202 1607
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 100 270 363 2893
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 100 6 17 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 100 33 85 117
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 100 60 154 211
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 100 16 101 569
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 100 84 506 2845
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 100 152 911 5121
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 100 54 63 155
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 100 270 319 775
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 100 486 575 1396
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 100 224 179 763
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 100 1123 898 3819
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 100 2022 1616 6875

# --------------------
# optimized
# esize 25
# bsize 250
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 250 31 47 95
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 250 156 236 478
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 250 281 426 861
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 250 164 134 476
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 250 821 670 2383
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 250 1478 1206 4290
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 250 20 37 97
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 250 104 189 485
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 250 187 341 873
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 250 30 40 361
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 250 150 202 1805
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 250 270 363 3250
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 250 6 17 25
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 250 33 85 128
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 250 60 154 230
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 250 16 101 605
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 250 84 506 3025
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 250 152 911 5446
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 250 54 63 159
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 250 270 319 797
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 250 486 575 1436
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 250 224 179 843
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 250 1123 898 4219
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 250 2022 1616 7594

# --------------------
# optimized
# esize 25
# bsize 500
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 500 31 47 95
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 500 156 236 476
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 500 281 426 857
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 500 164 134 476
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 500 821 670 2381
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 500 1478 1206 4286
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 500 20 37 97
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 500 104 189 487
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 500 187 341 877
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 500 30 40 363
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 500 150 202 1816
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 500 270 363 3270
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 500 6 17 27
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 500 33 85 136
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 500 60 154 245
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 500 16 101 619
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 500 84 506 3095
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 500 152 911 5571
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 500 54 63 160
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 500 270 319 802
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 500 486 575 1444
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 500 224 179 876
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 500 1123 898 4380
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 500 2022 1616 7885

# --------------------
# optimized
# esize 25
# bsize 2000
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 2000 31 47 90
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 2000 156 236 452
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 2000 281 426 814
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 2000 164 134 448
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 2000 821 670 2241
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 2000 1478 1206 4034
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 2000 20 37 92
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 2000 104 189 461
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 2000 187 341 829
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 2000 30 40 356
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 2000 150 202 1781
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 2000 270 363 3206
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 2000 6 17 28
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 2000 33 85 144
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 2000 60 154 259
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 2000 16 101 621
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 2000 84 506 3107
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 2000 152 911 5592
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 2000 54 63 159
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 2000 270 319 795
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 2000 486 575 1432
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 2000 224 179 792
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 2000 1123 898 3961
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 2000 2022 1616 7131

date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE