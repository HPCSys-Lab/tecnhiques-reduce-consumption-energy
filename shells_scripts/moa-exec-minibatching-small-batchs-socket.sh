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
  # Y $1 ${algs[${ID}]} $3 $4
  # Y $1 ${algs[$(( ID+1 ))]} $3 $5
  Y $1 ${algs[$(( ID+2 ))]} $3 $6
}

# alterar para o caminho do HD/scratch
mkdir -p /home/pi/reginaldojunior/experimentos/socket
mkdir -p /home/pi/reginaldojunior/experimentos/socket/$FREQUENCIA_MINIMA/$FREQUENCIA_MAXIMA

# X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 1 31 47 47

# --------------------
# 19-04-2022
# esize 25
# bsize 5
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 5 31 47 63
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 5 159 236 315
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 5 286 425 568
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 5 52 68 70
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 5 261 340 353
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 5 471 613 635
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 5 16 25 33
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 5 84 126 169
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 5 151 227 305
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 5 121 108 79
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 5 605 544 399
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 5 1089 980 718
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 5 145 132 200
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 5 728 660 1001
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 5 1310 1188 1801
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 5 167 137 207
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 5 837 688 1036
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 5 1507 1239 1864
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 5 21 37 46
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 5 105 188 234
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 5 189 339 421
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 5 14 28 15
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 5 73 140 76
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 5 132 252 138
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 5 6 11 12
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 5 34 58 63
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 5 61 106 113
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 5 26 40 15
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 5 130 203 77
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 5 234 366 139
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 5 25 41 46
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 5 127 208 234
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 5 230 374 421
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 5 30 40 43
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 5 150 204 219
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 5 271 367 394
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 5 53 66 102
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 5 267 330 510
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 5 481 594 919
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 5 71 86 98
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 5 358 430 492
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 5 644 775 886
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 5 29 32 58
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 5 148 161 290
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 5 267 290 522
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 5 167 171 98
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 5 839 859 491
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 5 1511 1546 885
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 5 222 189 283
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 5 1112 947 1419
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 5 2002 1705 2555
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 5 226 179 275
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 5 1133 896 1375
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 5 2040 1613 2475
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 5 6 15 14
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 5 33 79 71
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 5 59 142 128
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 5 4 15 13
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 5 23 75 65
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 5 42 136 118
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 5 6 15 14
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 5 33 75 72
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 5 60 136 131
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 5 16 24 55
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 5 83 124 275
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 5 150 224 495
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 5 17 54 59
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 5 89 273 298
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 5 161 492 538
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 5 16 95 73
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 5 84 478 366
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 5 152 860 659

# --------------------
# 19-04-2022
# esize 25
# bsize 15
# with incremental: True

X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 15 31 47 70
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 15 159 236 353
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff ARF 15 286 425 636
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 15 52 68 101
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 15 261 340 506
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff LBag 15 471 613 912
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 15 16 25 36
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 15 84 126 180
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff SRP 15 151 227 325
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 15 121 108 151
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 15 605 544 755
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagAd 15 1089 980 1360
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 15 145 132 239
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 15 728 660 1195
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBagASHT 15 1310 1188 2152
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 15 167 137 233
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 15 837 688 1167
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff OBag 15 1507 1239 2101
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 15 21 37 55
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 15 105 188 276
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff ARF 15 189 339 498
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 15 14 28 30
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 15 73 140 152
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff LBag 15 132 252 274
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 15 6 11 14
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 15 34 58 70
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff SRP 15 61 106 127
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 15 26 40 37
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 15 130 203 185
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagAd 15 234 366 334
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 15 25 41 53
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 15 127 208 265
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBagASHT 15 230 374 477
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 15 30 40 57
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 15 150 204 285
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff OBag 15 271 367 513
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 15 53 66 116
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 15 267 330 582
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff ARF 15 481 594 1048
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 15 71 86 143
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 15 358 430 718
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff LBag 15 644 775 1292
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 15 29 32 59
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 15 148 161 296
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff SRP 15 267 290 533
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 15 167 171 194
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 15 839 859 970
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagAd 15 1511 1546 1746
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 15 222 189 342
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 15 1112 947 1710
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBagASHT 15 2002 1705 3079
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 15 226 179 314
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 15 1133 896 1570
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff OBag 15 2040 1613 2826
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 15 6 15 14
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 15 33 79 74
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff ARF 15 59 142 133
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 15 4 15 14
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 15 23 75 73
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff LBag 15 42 136 133
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 15 6 15 17
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 15 33 75 85
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff SRP 15 60 136 153
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 15 16 24 53
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 15 83 124 265
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagAd 15 150 224 478
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 15 17 54 74
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 15 89 273 371
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBagASHT 15 161 492 668
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 15 16 95 88
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 15 84 478 443
X /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff OBag 15 152 860 797

date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE