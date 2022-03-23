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
  echo "file: $1 algorithm: $2 batch_size: $3 rate: $4 cores: $CPUS freq-min: $FREQUENCIA_MINIMA freq-max: $FREQUENCIA_MAXIMA"

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
    echo "java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask \"ChannelTIMED -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -t 120 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}\" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelTIMED -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -t 120 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-1-${rate}
  else
    #SEQUENTIAL OR PARALLEL
    IDENT="timedinterleaved"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-1-1-${rate}" >> ${EXPER_ORDER_FILE}
    echo "java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask \"ChannelTIMED -l ($2 -s ${esize}) -s (ArffFileStream -f $1) -t 120 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-1-1-${rate}\" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-1-1-${rate}"
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
  Y $1 ${algs[${ID}]} $3 $6
  Y $1 ${algs[$(( ID+1 ))]} $3 $6
  # Y $1 ${algs[$(( ID+2 ))]} $3 $6
}

mkdir -p /home/pi/reginaldojunior/experimentos/results/socket
mkdir -p /home/pi/reginaldojunior/experimentos/results/socket/$CPUS
mkdir -p /home/pi/reginaldojunior/experimentos/results/socket/$CPUS/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA

# 06-03-2022
# esize 25
# bsize 1
# with incremental: True

function 2_cores {
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 1 14 25 25
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 1 73 129 129
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 1 131 233 233
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 1 24 37 37
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 1 124 186 186
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 1 223 335 335
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 1 9 14 14
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 1 46 73 73
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 1 84 132 132
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 1 63 59 59
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 1 315 295 295
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 1 568 532 532
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 1 78 68 68
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 1 392 340 340
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 1 706 612 612
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 1 87 73 73
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 1 439 365 365
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 1 790 658 658
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 1 8 20 20
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 1 44 101 101
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 1 80 183 183
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 1 7 15 15
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 1 36 75 75
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 1 66 135 135
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 1 3 5 5
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 1 18 29 29
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 1 34 53 53
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 1 9 20 20
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 1 48 103 103
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 1 87 185 185
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 1 11 18 18
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 1 55 90 90
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 1 100 163 163
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 1 11 16 16
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 1 56 84 84
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 1 101 152 152
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 1 27 38 38
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 1 135 193 193
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 1 244 347 347
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 1 35 48 48
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 1 178 242 242
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 1 321 436 436
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 1 14 20 20
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 1 73 100 100
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 1 133 180 180
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 1 89 91 91
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 1 448 455 455
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 1 807 820 820
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 1 120 99 99
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 1 603 497 497
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 1 1086 895 895
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 1 121 95 95
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 1 607 478 478
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 1 1093 860 860
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 1 3 9 9
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 1 17 45 45
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 1 31 81 81
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 1 2 9 9
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 1 14 46 46
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 1 25 83 83
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 1 3 8 8
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 1 17 43 43
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 1 31 77 77
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 1 8 14 14
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 1 44 71 71
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 1 79 129 129
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 1 8 28 28
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 1 43 140 140
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 1 78 253 253
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 1 8 48 48
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 1 42 240 240
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 1 76 433 433
}

function 4_cores {
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 1 20 43 43
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 1 104 217 217
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 1 188 391 391
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 1 15 29 29
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 1 75 148 148
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 1 136 267 267
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 1 6 12 12
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 1 33 60 60
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 1 60 109 109
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 1 28 45 45
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 1 140 228 228
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 1 252 410 410
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 1 26 43 43
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 1 130 216 216
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 1 235 389 389
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 1 28 43 43
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 1 143 219 219
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 1 258 395 395
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 1 54 66 66
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 1 270 332 332
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 1 487 597 597
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 1 72 90 90
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 1 360 453 453
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 1 648 816 816
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 1 29 33 33
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 1 149 169 169
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 1 269 304 304
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 1 171 174 174
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 1 856 873 873
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 1 1542 1571 1571
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 1 225 188 188
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 1 1127 944 944
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 1 2029 1700 1700
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 1 225 181 181
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 1 1129 906 906
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 1 2033 1632 1632
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 1 0 0 0
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 1 0 0 0
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 1 0 0 0
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 1 4 15 15
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 1 21 77 77
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 1 37 139 139
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 1 6 15 15
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 1 34 79 79
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 1 61 142 142
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 1 16 26 26
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 1 83 132 132
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 1 151 238 238
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 1 18 59 59
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 1 91 299 299
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 1 165 538 538
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 1 17 103 103
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 1 85 516 516
  X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 1 154 929 929
}

# 2_cores
# 4_cores
date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE