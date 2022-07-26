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
    #CHUNK
    IDENT="timedchunk"
    echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}" >> ${EXPER_ORDER_FILE}
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelChunksTIMEDOptimized -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -t 120 -c ${bsize} -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}
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
  Y $1 ${algs[$(( ID+2 ))]} $3 $6
}

## rasp
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT/
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/socket/optimized/
export REMOTE_DIR=/home/gcassales/bases/
export EXPER_ORDER_FILE=$RESULT_DIR/exper_order.log

# alterar para o caminho do HD/scratch
mkdir -p $RESULT_DIR
mkdir -p $RESULT_DIR/first
mkdir -p $RESULT_DIR/second
mkdir -p $RESULT_DIR/third

# loop-fusion
# esize 25
# bsize 25
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 25 31 45 79
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 25 157 229 397
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 25 284 413 714
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 25 51 65 103
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 25 257 326 516
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 25 463 588 928
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 25 17 25 35
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 25 85 128 177
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 25 153 231 318
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 25 121 113 202
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 25 607 565 1013
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 25 1093 1018 1824
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 25 158 122 348
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 25 790 611 1743
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 25 1423 1100 3139
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 25 166 133 398
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 25 832 669 1993
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 25 1498 1205 3588
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 25 21 38 88
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 25 105 192 441
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 25 189 346 793
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 25 15 28 57
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 25 75 141 285
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 25 136 254 514
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 25 6 11 24
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 25 32 59 120
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 25 59 107 217
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 25 28 42 81
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 25 141 211 409
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 25 255 381 737
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 25 24 42 272
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 25 122 213 1360
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 25 220 383 2448
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 25 28 40 279
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 25 140 204 1398
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 25 253 367 2516
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 25 6 17 22
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 25 33 85 110
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 25 60 154 198
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 25 4 17 21
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 25 23 88 109
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 25 41 158 196
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 25 6 17 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 25 34 87 115
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 25 61 156 207
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 25 17 27 71
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 25 85 136 359
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 25 153 245 647
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 25 17 53 312
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 25 89 267 1562
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 25 161 482 2812
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 25 16 101 479
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 25 84 506 2395
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 25 152 911 4311
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 25 51 62 154
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 25 257 312 771
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 25 464 562 1389
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 25 71 83 173
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 25 356 418 869
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 25 640 754 1565
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 25 29 30 77
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 25 147 154 387
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 25 264 278 697
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 25 171 171 286
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 25 856 857 1430
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 25 1541 1542 2575
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 25 224 186 680
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 25 1121 933 3402
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 25 2018 1680 6124
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 25 223 178 644
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 25 1115 890 3221
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 25 2008 1603 5798



# --------------------
# loop-fusion
# esize 25
# bsize 50
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 31 45 73
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 157 229 365
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 50 284 413 658
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 51 65 107
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 257 326 538
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 50 463 588 969
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 17 25 38
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 85 128 190
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 50 153 231 343
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 121 113 232
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 607 565 1164
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 50 1093 1018 2096
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 158 122 381
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 790 611 1905
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 50 1423 1100 3429
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 166 133 368
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 832 669 1843
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 50 1498 1205 3318
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 21 38 89
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 105 192 446
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 50 189 346 804
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 15 28 66
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 75 141 332
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 50 136 254 598
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 6 11 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 32 59 116
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 50 59 107 208
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 28 42 102
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 141 211 511
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 50 255 381 920
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 24 42 282
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 122 213 1412
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 50 220 383 2542
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 28 40 309
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 140 204 1549
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 50 253 367 2789
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 6 17 22
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 33 85 112
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 50 60 154 203
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 4 17 22
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 23 88 111
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 50 41 158 200
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 6 17 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 34 87 117
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 50 61 156 210
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 17 27 68
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 85 136 341
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 50 153 245 614
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 17 53 368
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 89 267 1841
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 50 161 482 3315
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 16 101 526
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 84 506 2630
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 50 152 911 4735
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 51 62 147
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 257 312 739
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 50 464 562 1330
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 71 83 202
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 356 418 1011
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 50 640 754 1819
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 29 30 80
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 147 154 403
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 50 264 278 725
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 171 171 392
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 856 857 1960
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 50 1541 1542 3528
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 224 186 728
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 1121 933 3640
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 50 2018 1680 6552
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 223 178 694
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 1115 890 3472
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 50 2008 1603 6249



# --------------------
# loop-fusion
# esize 25
# bsize 75
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 75 31 45 72
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 75 157 229 360
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 75 284 413 649
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 75 51 65 124
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 75 257 326 623
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 75 463 588 1121
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 75 17 25 38
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 75 85 128 190
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 75 153 231 342
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 75 121 113 218
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 75 607 565 1094
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 75 1093 1018 1970
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 75 158 122 374
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 75 790 611 1873
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 75 1423 1100 3371
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 75 166 133 423
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 75 832 669 2118
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 75 1498 1205 3814
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 75 21 38 102
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 75 105 192 514
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 75 189 346 925
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 75 15 28 72
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 75 75 141 362
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 75 136 254 652
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 75 6 11 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 75 32 59 117
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 75 59 107 211
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 75 28 42 104
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 75 141 211 522
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 75 255 381 939
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 75 24 42 299
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 75 122 213 1497
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 75 220 383 2694
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 75 28 40 311
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 75 140 204 1557
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 75 253 367 2803
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 75 6 17 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 75 33 85 116
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 75 60 154 210
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 75 4 17 22
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 75 23 88 112
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 75 41 158 203
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 75 6 17 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 75 34 87 119
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 75 61 156 214
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 75 17 27 68
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 75 85 136 341
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 75 153 245 614
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 75 17 53 435
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 75 89 267 2175
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 75 161 482 3916
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 75 16 101 567
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 75 84 506 2836
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 75 152 911 5106
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 75 51 62 158
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 75 257 312 791
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 75 464 562 1424
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 75 71 83 199
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 75 356 418 997
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 75 640 754 1795
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 75 29 30 80
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 75 147 154 402
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 75 264 278 724
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 75 171 171 440
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 75 856 857 2202
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 75 1541 1542 3963
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 75 224 186 777
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 75 1121 933 3889
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 75 2018 1680 7001
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 75 223 178 746
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 75 1115 890 3733
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 75 2008 1603 6720



# --------------------
# loop-fusion
# esize 25
# bsize 100
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 100 31 45 73
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 100 157 229 365
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 100 284 413 658
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 100 51 65 112
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 100 257 326 560
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 100 463 588 1009
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 100 17 25 39
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 100 85 128 199
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 100 153 231 359
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 100 121 113 273
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 100 607 565 1365
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 100 1093 1018 2458
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 100 158 122 353
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 100 790 611 1765
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 100 1423 1100 3178
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 100 166 133 447
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 100 832 669 2239
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 100 1498 1205 4030
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 100 21 38 96
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 100 105 192 482
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 100 189 346 869
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 100 15 28 72
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 100 75 141 363
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 100 136 254 653
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 100 6 11 22
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 100 32 59 113
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 100 59 107 203
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 100 28 42 108
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 100 141 211 540
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 100 255 381 972
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 100 24 42 308
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 100 122 213 1543
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 100 220 383 2778
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 100 28 40 319
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 100 140 204 1597
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 100 253 367 2874
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 100 6 17 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 100 33 85 117
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 100 60 154 211
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 100 4 17 22
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 100 23 88 114
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 100 41 158 206
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 100 6 17 24
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 100 34 87 123
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 100 61 156 221
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 100 17 27 68
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 100 85 136 341
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 100 153 245 613
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 100 17 53 461
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 100 89 267 2309
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 100 161 482 4156
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 100 16 101 569
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 100 84 506 2845
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 100 152 911 5121
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 100 51 62 162
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 100 257 312 811
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 100 464 562 1460
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 100 71 83 205
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 100 356 418 1026
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 100 640 754 1848
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 100 29 30 82
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 100 147 154 412
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 100 264 278 743
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 100 171 171 453
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 100 856 857 2268
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 100 1541 1542 4082
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 100 224 186 768
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 100 1121 933 3842
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 100 2018 1680 6917
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 100 223 178 758
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 100 1115 890 3791
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 100 2008 1603 6824



# --------------------
# loop-fusion
# esize 25
# bsize 250
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 250 31 45 80
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 250 157 229 400
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 250 284 413 721
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 250 51 65 129
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 250 257 326 645
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 250 463 588 1161
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 250 17 25 39
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 250 85 128 198
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 250 153 231 358
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 250 121 113 241
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 250 607 565 1207
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 250 1093 1018 2172
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 250 158 122 374
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 250 790 611 1873
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 250 1423 1100 3371
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 250 166 133 339
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 250 832 669 1698
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 250 1498 1205 3058
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 250 21 38 94
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 250 105 192 472
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 250 189 346 849
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 250 15 28 75
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 250 75 141 379
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 250 136 254 682
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 250 6 11 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 250 32 59 115
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 250 59 107 208
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 250 28 42 113
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 250 141 211 565
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 250 255 381 1018
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 250 24 42 335
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 250 122 213 1678
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 250 220 383 3022
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 250 28 40 363
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 250 140 204 1817
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 250 253 367 3272
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 250 6 17 25
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 250 33 85 128
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 250 60 154 230
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 250 4 17 24
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 250 23 88 120
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 250 41 158 216
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 250 6 17 24
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 250 34 87 124
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 250 61 156 223
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 250 17 27 70
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 250 85 136 350
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 250 153 245 630
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 250 17 53 488
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 250 89 267 2441
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 250 161 482 4394
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 250 16 101 605
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 250 84 506 3025
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 250 152 911 5446
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 250 51 62 161
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 250 257 312 806
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 250 464 562 1451
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 250 71 83 210
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 250 356 418 1051
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 250 640 754 1892
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 250 29 30 77
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 250 147 154 387
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 250 264 278 698
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 250 171 171 477
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 250 856 857 2386
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 250 1541 1542 4296
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 250 224 186 831
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 250 1121 933 4155
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 250 2018 1680 7480
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 250 223 178 827
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 250 1115 890 4137
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 250 2008 1603 7447



# --------------------
# loop-fusion
# esize 25
# bsize 500
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 500 31 45 74
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 500 157 229 373
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 500 284 413 671
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 500 51 65 106
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 500 257 326 531
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 500 463 588 956
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 500 17 25 39
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 500 85 128 198
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 500 153 231 358
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 500 121 113 240
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 500 607 565 1200
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 500 1093 1018 2160
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 500 158 122 477
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 500 790 611 2387
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 500 1423 1100 4297
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 500 166 133 485
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 500 832 669 2425
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 500 1498 1205 4365
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 500 21 38 96
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 500 105 192 482
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 500 189 346 867
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 500 15 28 77
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 500 75 141 389
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 500 136 254 701
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 500 6 11 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 500 32 59 115
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 500 59 107 207
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 500 28 42 114
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 500 141 211 573
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 500 255 381 1031
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 500 24 42 356
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 500 122 213 1784
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 500 220 383 3211
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 500 28 40 384
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 500 140 204 1921
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 500 253 367 3459
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 500 6 17 27
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 500 33 85 136
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 500 60 154 245
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 500 4 17 25
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 500 23 88 129
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 500 41 158 232
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 500 6 17 27
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 500 34 87 136
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 500 61 156 245
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 500 17 27 74
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 500 85 136 374
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 500 153 245 674
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 500 17 53 487
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 500 89 267 2436
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 500 161 482 4385
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 500 16 101 619
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 500 84 506 3095
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 500 152 911 5571
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 500 51 62 165
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 500 257 312 828
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 500 464 562 1491
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 500 71 83 216
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 500 356 418 1082
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 500 640 754 1947
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 500 29 30 84
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 500 147 154 421
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 500 264 278 758
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 500 171 171 483
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 500 856 857 2417
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 500 1541 1542 4351
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 500 224 186 875
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 500 1121 933 4379
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 500 2018 1680 7882
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 500 223 178 845
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 500 1115 890 4229
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 500 2008 1603 7613



# --------------------
# loop-fusion
# esize 25
# bsize 2000
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 2000 31 45 64
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 2000 157 229 323
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 2000 284 413 582
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 2000 51 65 114
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 2000 257 326 570
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 2000 463 588 1026
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 2000 17 25 38
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 2000 85 128 191
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 2000 153 231 344
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 2000 121 113 224
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 2000 607 565 1123
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 2000 1093 1018 2022
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 2000 158 122 374
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 2000 790 611 1873
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 2000 1423 1100 3372
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 2000 166 133 444
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 2000 832 669 2224
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 2000 1498 1205 4004
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 2000 21 38 88
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 2000 105 192 444
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 2000 189 346 799
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 2000 15 28 67
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 2000 75 141 338
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 2000 136 254 609
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 2000 6 11 23
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 2000 32 59 115
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 2000 59 107 208
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 2000 28 42 115
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 2000 141 211 578
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 2000 255 381 1041
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 2000 24 42 353
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 2000 122 213 1765
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 2000 220 383 3178
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 2000 28 40 357
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 2000 140 204 1789
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 2000 253 367 3220
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 2000 6 17 28
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 2000 33 85 144
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 2000 60 154 259
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 2000 4 17 44
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 2000 23 88 220
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 2000 41 158 396
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 2000 6 17 27
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 2000 34 87 139
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 2000 61 156 250
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 2000 17 27 95
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 2000 85 136 476
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 2000 153 245 857
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 2000 17 53 481
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 2000 89 267 2407
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 2000 161 482 4332
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 2000 16 101 621
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 2000 84 506 3107
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 2000 152 911 5592
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 2000 51 62 168
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 2000 257 312 842
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 2000 464 562 1516
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 2000 71 83 215
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 2000 356 418 1079
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 2000 640 754 1943
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 2000 29 30 79
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 2000 147 154 395
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 2000 264 278 712
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 2000 171 171 449
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 2000 856 857 2249
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 2000 1541 1542 4048
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 2000 224 186 893
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 2000 1121 933 4467
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 2000 2018 1680 8041
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 2000 223 178 816
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 2000 1115 890 4081
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 2000 2008 1603 7346

date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE