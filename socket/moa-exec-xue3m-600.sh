#!/bin/bash

if [[ "$#" -eq 0 ]]; then
  echo "This program requires inputs. Type -h for help." >&2
  exit 1
fi

while getopts ":c:f:F:h" opt;
do
    echo $opt
    case $opt in
        h)
            echo "f: Frequencia Minima."
            echo "F: Frequencia Máxima."
            echo "c: Quantidade de CPUs a ser utilizada"
            echo "h: Help Opções disponiveis."
            exit 1
        ;;
        c)
            if [[ -n $CPUS ]]; then
                echo "Invalid input: option -c has already been used!" >&2
                exit 1
            else
                CPUS="${OPTARG//,/ }"
            fi
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
if [[ -z $CPUS && -z $CPUS ]]; then
    echo "Nothing to run. Expected -c!" >&2
    exit 1
fi

if [[ -z $FREQUENCIA_MINIMA && -z $FREQUENCIA_MINIMA ]]; then
    echo "Nothing to run. Expected -f!" >&2
    exit 1
fi

if [[ -z $FREQUENCIA_MAXIMA && -z $FREQUENCIA_MAXIMA ]]; then
    echo "Nothing to run. Expected -F!" >&2
    exit 1
fi

function Y {
  #Usage: $0 FILE ALGORITHM RATE
  Memory=700M
  echo "file: /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/ algorithm: $2 batch_size: $3 rate: $4 cores: $CPUS freq-min: $FREQUENCIA_MINIMA freq-max: $FREQUENCIA_MAXIMA"

  export MOA_HOME=/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT/
  export RESULT_DIR=/home/pi/reginaldojunior/experimentos/results/socket/$CPUS/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA
  export REMOTE_DIR=/home/gcassales/bases/
  export EXPER_ORDER_FILE=$RESULT_DIR/exper_order-freq-max-$FREQUENCIA_MAXIMA-freq-min-$FREQUENCIA_MINIMA.log

  declare -a esize=(25)
  mkdir -p $RESULT_DIR
  faux=${1##*\/}
  onlyname=${faux%%.*}
  bsize=${3}
  rate=${4}
  nCores=$CPUS
  date +"%d/%m/%y %T"
  date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE
  echo "ssh-${onlyname}-${2##*.}-${bsize}-${rate}" >> ${RESULT_DIR}/ssh-log
  ssh gcassales@192.168.0.11 java ChannelServer 192.168.0.11 9004 ${REMOTE_DIR}${faux} ${rate} >> ${RESULT_DIR}/ssh-log &
  # java ChannelServer 127.0.0.1 9004 ${REMOTE_DIR}${faux} ${rate} >> ${RESULT_DIR}/ssh-log &
  
  sleep 3
  
  if [[ ${2} == *"RUNPER"* ]]; then
    #PARALLEL
    IDENT="timedinterleaved"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}" >> ${EXPER_ORDER_FILE}
    echo "java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask \"ChannelTIMED -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/) -t 120 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}\" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelTIMED -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/) -t 120 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}
  else
    #SEQUENTIAL OR PARALLEL
    IDENT="timedinterleaved"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-1-1-${rate}" >> ${EXPER_ORDER_FILE}
    echo "java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask \"ChannelTIMED -l ($2 -s ${esize}) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/) -t 120 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-1-1-${rate}\" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-1-1-${rate}"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelTIMED -l ($2 -s ${esize}) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/) -t 120 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-1-1-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-1-1-${rate}
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
  Y /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/ ${algs[${ID}]} $3 $6
  Y /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/ ${algs[$(( ID+1 ))]} $3 $6
  # Y /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/ ${algs[$(( ID+2 ))]} $3 $6
}

mkdir -p /home/pi/reginaldojunior/experimentos/results/socket
mkdir -p /home/pi/reginaldojunior/experimentos/results/socket/$CPUS
mkdir -p /home/pi/reginaldojunior/experimentos/results/socket/$CPUS/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA

# 06-03-2022
# esize 25
# bsize 1
# with incremental: True

function 2_cores {
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 1 13 20 20
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 1 68 102 102
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 1 122 184 184
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 1 24 30 30
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 1 123 153 153
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 1 222 276 276
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 1 8 10 10
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 1 44 54 54
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 1 80 97 97
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 1 63 49 49
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 1 315 247 247
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 1 568 444 444
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 1 76 61 61
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 1 382 309 309
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 1 687 556 556
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 1 83 64 64
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 1 418 320 320
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 1 753 577 577
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 1 8 16 16
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 1 44 84 84
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 1 80 152 152
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 1 7 13 13
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 1 35 65 65
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 1 64 117 117
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 1 3 5 5
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 1 18 25 25
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 1 32 46 46
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 1 9 16 16
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 1 49 83 83
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 1 89 150 150
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 1 11 12 12
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 1 56 60 60
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 1 102 108 108
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 1 11 15 15
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 1 56 75 75
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 1 102 135 135
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 1 26 32 32
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 1 132 160 160
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 1 237 289 289
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 1 34 41 41
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 1 172 205 205
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 1 310 369 369
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 1 14 17 17
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 1 71 88 88
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 1 129 158 158
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 1 87 72 72
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 1 439 361 361
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 1 791 650 650
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 1 116 89 89
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 1 584 446 446
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 1 1052 802 802
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 1 119 87 87
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 1 599 436 436
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 1 1078 785 785
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 1 3 6 6
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 1 16 32 32
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 1 30 58 58
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 1 2 5 5
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 1 13 28 28
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 1 24 51 51
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 1 3 5 5
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 1 16 28 28
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 1 29 51 51
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 1 8 10 10
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 1 42 50 50
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 1 76 91 91
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 1 8 23 23
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 1 42 117 117
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 1 75 210 210
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 1 8 36 36
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 1 40 182 182
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 1 73 327 327
}

function 4_cores {
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 1 14 26 26
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 1 74 130 130
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 1 134 234 234
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 1 25 36 36
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 1 128 183 183
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 1 231 330 330
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 1 9 13 13
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 1 46 67 67
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 1 84 122 122
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 1 63 61 61
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 1 317 309 309
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 1 571 557 557
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 1 78 71 71
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 1 393 358 358
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 1 708 645 645
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 1 86 74 74
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 1 431 373 373
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 1 775 673 673
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 1 8 19 19
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 1 44 98 98
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 1 80 177 177
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 1 7 15 15
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 1 36 75 75
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 1 66 135 135
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 1 3 5 5
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 1 18 29 29
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 1 33 53 53
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 1 9 20 20
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 1 49 101 101
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 1 88 182 182
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 1 11 17 17
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 1 55 87 87
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 1 99 157 157
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 1 11 16 16
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 1 56 83 83
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 1 101 150 150
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 1 26 39 39
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 1 134 195 195
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 1 242 351 351
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 1 36 49 49
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 1 182 248 248
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 1 328 447 447
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 1 14 20 20
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 1 72 102 102
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 1 131 184 184
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 1 89 93 93
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 1 446 465 465
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 1 803 838 838
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 1 119 102 102
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 1 599 514 514
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 1 1079 925 925
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 1 123 100 100
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 1 619 501 501
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 1 1115 903 903
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 1 3 8 8
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 1 17 41 41
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 1 32 75 75
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 1 2 7 7
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 1 14 39 39
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 1 26 71 71
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 1 3 7 7
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 1 17 38 38
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 1 31 69 69
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 1 8 13 13
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 1 44 65 65
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 1 80 118 118
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 1 8 27 27
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 1 44 139 139
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 1 79 250 250
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 1 8 45 45
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 1 42 227 227
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 1 76 409 409
}

# 2_cores
# 4_cores
date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE
