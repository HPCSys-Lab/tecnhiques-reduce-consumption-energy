#!/bin/bash

## rasp
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/socket/pareto/
export REMOTE_DIR=/home/gcassales/bases/
export EXPER_ORDER_FILE=$RESULT_DIR/exper_order.log

function Y {
  # Usage: $0 FILE ALGORITHM RATE
  Memory=700M
  echo "file: $1 algorithm: $2 batch_size: $3 rate: $4"

  declare -a esize=(25)
  mkdir -p $RESULT_DIR
  faux=${1##*\/}
  onlyname=${faux%%.*}
  bsize=${3}
  rate=${4}
  methodology=${5}
  nCores=4
  date +"%d/%m/%y %T"
  date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE
  echo "ssh-${onlyname}-${2##*.}-${bsize}-${rate}" >> ${RESULT_DIR}/ssh-log
  ssh gcassales@192.168.0.11 java ChannelServer 192.168.0.11 9004 ${REMOTE_DIR}${faux} ${rate} >> ${RESULT_DIR}/ssh-log &
  
  sleep 3

  export MOA_HOME=/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT

  #CHUNK
  IDENT="timedchunk"
  echo "$RESULT_DIR/${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}" >> ${EXPER_ORDER_FILE}
  numactl --physcpubind="0,1,2,3" java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelChunksTIMEDOptimized -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -t 120 -c ${bsize} -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}" > ${RESULT_DIR}/term-${onlyname}-${2##*.}-${esize}-${nCores}-${bsize}-${rate}

  echo ""
  date +"%d/%m/%y %T"
  date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE
}

function X {
  #Usage: $0 FILE ID RS RP RC
  # 1 -> sequential, 2 -> mb sem loop fusion, 3 -> mb com loop fusion
  declare -a algs=(
    "meta.AdaptiveRandomForestSequential" "meta.AdaptiveRandomForestExecutorMAXChunk"
    "meta.OzaBag" "meta.OzaBagExecutorMAXChunk"
    "meta.OzaBagAdwin" "meta.OzaBagAdwinExecutorMAXChunk"
    "meta.LeveragingBag" "meta.LBagExecutorMAXChunk"
    "meta.OzaBagASHT" "meta.OzaBagASHTExecutorMAXChunk"
    "meta.StreamingRandomPatches" "meta.StreamingRandomPatchesExecutorMAXChunk"
  )
  if [[ $2 == *"ARF"* ]]; then
    ID=0
  elif [[ $2 == "OBag" ]]; then
    ID=2
  elif [[ $2 == "OBagAd" ]]; then
    ID=4
  elif [[ $2 == "LBag" ]]; then
    ID=6
  elif [[ $2 == "OBagASHT" ]]; then
    ID=8
  elif [[ $2 == "SRP" ]]; then
    ID=10
  fi

  Y $1 ${algs[$(( ID+1 ))]} $3 $4
}

# alterar para o caminho do HD/scratch
mkdir -p $RESULT_DIR

# loop-fusion
# esize 25
# bsize 25
# with incremental: True

export LOCAL_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 25 84
X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 25 422
X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 25 760
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 25 57
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 25 287
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 25 517
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 25 25
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 25 126
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 25 228
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 25 79
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 25 397
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 25 714
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 25 270
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 25 1354
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 25 2438
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 25 267
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 25 1339
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 25 2411
X $LOCAL_DIR/datasets/airlines.arff ARF 25 21
X $LOCAL_DIR/datasets/airlines.arff ARF 25 106
X $LOCAL_DIR/datasets/airlines.arff ARF 25 192
X $LOCAL_DIR/datasets/airlines.arff LBag 25 21
X $LOCAL_DIR/datasets/airlines.arff LBag 25 105
X $LOCAL_DIR/datasets/airlines.arff LBag 25 189
X $LOCAL_DIR/datasets/airlines.arff SRP 25 23
X $LOCAL_DIR/datasets/airlines.arff SRP 25 118
X $LOCAL_DIR/datasets/airlines.arff SRP 25 212
X $LOCAL_DIR/datasets/airlines.arff OBagAd 25 71
X $LOCAL_DIR/datasets/airlines.arff OBagAd 25 358
X $LOCAL_DIR/datasets/airlines.arff OBagAd 25 646
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 25 273
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 25 1367
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 25 2462
X $LOCAL_DIR/datasets/airlines.arff OBag 25 480
X $LOCAL_DIR/datasets/airlines.arff OBag 25 2400
X $LOCAL_DIR/datasets/airlines.arff OBag 25 4320
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 25 88
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 25 441
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 25 794
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 25 125
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 25 629
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 25 1132
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 25 49
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 25 248
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 25 446
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 25 214
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 25 1071
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 25 1928
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 25 392
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 25 1963
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 25 3533
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 25 394
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 25 1972
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 25 3550
X $LOCAL_DIR/datasets/GMSC.arff ARF 25 157
X $LOCAL_DIR/datasets/GMSC.arff ARF 25 787
X $LOCAL_DIR/datasets/GMSC.arff ARF 25 1417
X $LOCAL_DIR/datasets/GMSC.arff LBag 25 186
X $LOCAL_DIR/datasets/GMSC.arff LBag 25 930
X $LOCAL_DIR/datasets/GMSC.arff LBag 25 1675
X $LOCAL_DIR/datasets/GMSC.arff SRP 25 89
X $LOCAL_DIR/datasets/GMSC.arff SRP 25 449
X $LOCAL_DIR/datasets/GMSC.arff SRP 25 808
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 25 306
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 25 1533
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 25 2760
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 25 686
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 25 3431
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 25 6177
X $LOCAL_DIR/datasets/GMSC.arff OBag 25 665
X $LOCAL_DIR/datasets/GMSC.arff OBag 25 3326
X $LOCAL_DIR/datasets/GMSC.arff OBag 25 5988

# --------------------
# loop-fusion
# esize 25
# bsize 50
# with incremental: True

X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 50 101
X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 50 506
X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 50 911
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 50 66
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 50 333
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 50 600
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 50 25
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 50 127
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 50 230
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 50 99
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 50 498
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 50 896
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 50 270
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 50 1354
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 50 2437
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 50 267
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 50 1337
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 50 2407
X $LOCAL_DIR/datasets/airlines.arff ARF 50 22
X $LOCAL_DIR/datasets/airlines.arff ARF 50 110
X $LOCAL_DIR/datasets/airlines.arff ARF 50 198
X $LOCAL_DIR/datasets/airlines.arff LBag 50 21
X $LOCAL_DIR/datasets/airlines.arff LBag 50 107
X $LOCAL_DIR/datasets/airlines.arff LBag 50 192
X $LOCAL_DIR/datasets/airlines.arff SRP 50 23
X $LOCAL_DIR/datasets/airlines.arff SRP 50 119
X $LOCAL_DIR/datasets/airlines.arff SRP 50 215
X $LOCAL_DIR/datasets/airlines.arff OBagAd 50 68
X $LOCAL_DIR/datasets/airlines.arff OBagAd 50 341
X $LOCAL_DIR/datasets/airlines.arff OBagAd 50 614
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 50 379
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 50 1899
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 50 3419
X $LOCAL_DIR/datasets/airlines.arff OBag 50 502
X $LOCAL_DIR/datasets/airlines.arff OBag 50 2513
X $LOCAL_DIR/datasets/airlines.arff OBag 50 4525
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 50 91
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 50 459
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 50 827
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 50 131
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 50 658
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 50 1184
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 50 48
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 50 244
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 50 440
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 50 252
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 50 1261
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 50 2270
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 50 414
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 50 2070
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 50 3727
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 50 416
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 50 2081
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 50 3745
X $LOCAL_DIR/datasets/GMSC.arff ARF 50 169
X $LOCAL_DIR/datasets/GMSC.arff ARF 50 849
X $LOCAL_DIR/datasets/GMSC.arff ARF 50 1529
X $LOCAL_DIR/datasets/GMSC.arff LBag 50 203
X $LOCAL_DIR/datasets/GMSC.arff LBag 50 1018
X $LOCAL_DIR/datasets/GMSC.arff LBag 50 1833
X $LOCAL_DIR/datasets/GMSC.arff SRP 50 95
X $LOCAL_DIR/datasets/GMSC.arff SRP 50 479
X $LOCAL_DIR/datasets/GMSC.arff SRP 50 862
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 50 402
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 50 2013
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 50 3625
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 50 728
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 50 3642
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 50 6556
X $LOCAL_DIR/datasets/GMSC.arff OBag 50 699
X $LOCAL_DIR/datasets/GMSC.arff OBag 50 3495
X $LOCAL_DIR/datasets/GMSC.arff OBag 50 6291

# --------------------
# loop-fusion
# esize 25
# bsize 100
# with incremental: True

X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 100 106
X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 100 530
X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 100 955
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 100 71
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 100 356
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 100 641
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 100 26
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 100 132
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 100 238
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 100 112
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 100 563
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 100 1014
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 100 314
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 100 1573
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 100 2831
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 100 299
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 100 1495
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 100 2691
X $LOCAL_DIR/datasets/airlines.arff ARF 100 23
X $LOCAL_DIR/datasets/airlines.arff ARF 100 115
X $LOCAL_DIR/datasets/airlines.arff ARF 100 207
X $LOCAL_DIR/datasets/airlines.arff LBag 100 21
X $LOCAL_DIR/datasets/airlines.arff LBag 100 108
X $LOCAL_DIR/datasets/airlines.arff LBag 100 195
X $LOCAL_DIR/datasets/airlines.arff SRP 100 24
X $LOCAL_DIR/datasets/airlines.arff SRP 100 121
X $LOCAL_DIR/datasets/airlines.arff SRP 100 218
X $LOCAL_DIR/datasets/airlines.arff OBagAd 100 68
X $LOCAL_DIR/datasets/airlines.arff OBagAd 100 341
X $LOCAL_DIR/datasets/airlines.arff OBagAd 100 614
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 100 447
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 100 2236
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 100 4026
X $LOCAL_DIR/datasets/airlines.arff OBag 100 511
X $LOCAL_DIR/datasets/airlines.arff OBag 100 2555
X $LOCAL_DIR/datasets/airlines.arff OBag 100 4599
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 100 93
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 100 467
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 100 841
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 100 141
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 100 705
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 100 1270
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 100 51
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 100 256
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 100 462
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 100 272
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 100 1363
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 100 2453
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 100 424
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 100 2121
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 100 3819
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 100 448
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 100 2241
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 100 4034
X $LOCAL_DIR/datasets/GMSC.arff ARF 100 176
X $LOCAL_DIR/datasets/GMSC.arff ARF 100 881
X $LOCAL_DIR/datasets/GMSC.arff ARF 100 1587
X $LOCAL_DIR/datasets/GMSC.arff LBag 100 217
X $LOCAL_DIR/datasets/GMSC.arff LBag 100 1088
X $LOCAL_DIR/datasets/GMSC.arff LBag 100 1959
X $LOCAL_DIR/datasets/GMSC.arff SRP 100 97
X $LOCAL_DIR/datasets/GMSC.arff SRP 100 488
X $LOCAL_DIR/datasets/GMSC.arff SRP 100 878
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 100 457
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 100 2288
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 100 4119
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 100 786
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 100 3934
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 100 7082
X $LOCAL_DIR/datasets/GMSC.arff OBag 100 751
X $LOCAL_DIR/datasets/GMSC.arff OBag 100 3757
X $LOCAL_DIR/datasets/GMSC.arff OBag 100 6764

# --------------------
# loop-fusion
# esize 25
# bsize 250
# with incremental: True

X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 250 97
X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 250 485
X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 250 874
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 250 76
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 250 381
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 250 686
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 250 28
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 250 141
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 250 253
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 250 118
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 250 592
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 250 1067
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 250 306
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 250 1530
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 250 2755
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 250 329
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 250 1647
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 250 2964
X $LOCAL_DIR/datasets/airlines.arff ARF 250 25
X $LOCAL_DIR/datasets/airlines.arff ARF 250 128
X $LOCAL_DIR/datasets/airlines.arff ARF 250 230
X $LOCAL_DIR/datasets/airlines.arff LBag 250 22
X $LOCAL_DIR/datasets/airlines.arff LBag 250 112
X $LOCAL_DIR/datasets/airlines.arff LBag 250 203
X $LOCAL_DIR/datasets/airlines.arff SRP 250 26
X $LOCAL_DIR/datasets/airlines.arff SRP 250 130
X $LOCAL_DIR/datasets/airlines.arff SRP 250 235
X $LOCAL_DIR/datasets/airlines.arff OBagAd 250 72
X $LOCAL_DIR/datasets/airlines.arff OBagAd 250 361
X $LOCAL_DIR/datasets/airlines.arff OBagAd 250 650
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 250 477
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 250 2388
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 250 4300
X $LOCAL_DIR/datasets/airlines.arff OBag 250 572
X $LOCAL_DIR/datasets/airlines.arff OBag 250 2863
X $LOCAL_DIR/datasets/airlines.arff OBag 250 5155
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 250 92
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 250 461
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 250 830
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 250 142
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 250 712
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 250 1282
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 250 51
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 250 256
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 250 460
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 250 288
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 250 1441
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 250 2594
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 250 465
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 250 2326
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 250 4188
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 250 466
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 250 2332
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 250 4198
X $LOCAL_DIR/datasets/GMSC.arff ARF 250 170
X $LOCAL_DIR/datasets/GMSC.arff ARF 250 854
X $LOCAL_DIR/datasets/GMSC.arff ARF 250 1538
X $LOCAL_DIR/datasets/GMSC.arff LBag 250 228
X $LOCAL_DIR/datasets/GMSC.arff LBag 250 1141
X $LOCAL_DIR/datasets/GMSC.arff LBag 250 2054
X $LOCAL_DIR/datasets/GMSC.arff SRP 250 95
X $LOCAL_DIR/datasets/GMSC.arff SRP 250 479
X $LOCAL_DIR/datasets/GMSC.arff SRP 250 862
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 250 425
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 250 2128
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 250 3830
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 250 869
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 250 4349
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 250 7829
X $LOCAL_DIR/datasets/GMSC.arff OBag 250 846
X $LOCAL_DIR/datasets/GMSC.arff OBag 250 4234
X $LOCAL_DIR/datasets/GMSC.arff OBag 250 7622

# --------------------
# loop-fusion
# esize 25
# bsize 500
# with incremental: True

X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 500 96
X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 500 481
X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 500 866
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 500 78
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 500 391
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 500 704
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 500 27
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 500 138
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 500 248
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 500 115
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 500 577
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 500 1039
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 500 336
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 500 1684
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 500 3031
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 500 370
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 500 1854
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 500 3337
X $LOCAL_DIR/datasets/airlines.arff ARF 500 27
X $LOCAL_DIR/datasets/airlines.arff ARF 500 138
X $LOCAL_DIR/datasets/airlines.arff ARF 500 249
X $LOCAL_DIR/datasets/airlines.arff LBag 500 24
X $LOCAL_DIR/datasets/airlines.arff LBag 500 122
X $LOCAL_DIR/datasets/airlines.arff LBag 500 220
X $LOCAL_DIR/datasets/airlines.arff SRP 500 26
X $LOCAL_DIR/datasets/airlines.arff SRP 500 133
X $LOCAL_DIR/datasets/airlines.arff SRP 500 239
X $LOCAL_DIR/datasets/airlines.arff OBagAd 500 75
X $LOCAL_DIR/datasets/airlines.arff OBagAd 500 376
X $LOCAL_DIR/datasets/airlines.arff OBagAd 500 678
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 500 485
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 500 2428
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 500 4371
X $LOCAL_DIR/datasets/airlines.arff OBag 500 617
X $LOCAL_DIR/datasets/airlines.arff OBag 500 3085
X $LOCAL_DIR/datasets/airlines.arff OBag 500 5553
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 500 93
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 500 465
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 500 837
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 500 147
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 500 735
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 500 1324
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 500 49
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 500 247
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 500 445
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 500 279
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 500 1397
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 500 2515
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 500 471
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 500 2356
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 500 4241
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 500 445
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 500 2227
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 500 4009
X $LOCAL_DIR/datasets/GMSC.arff ARF 500 182
X $LOCAL_DIR/datasets/GMSC.arff ARF 500 910
X $LOCAL_DIR/datasets/GMSC.arff ARF 500 1638
X $LOCAL_DIR/datasets/GMSC.arff LBag 500 227
X $LOCAL_DIR/datasets/GMSC.arff LBag 500 1135
X $LOCAL_DIR/datasets/GMSC.arff LBag 500 2044
X $LOCAL_DIR/datasets/GMSC.arff SRP 500 101
X $LOCAL_DIR/datasets/GMSC.arff SRP 500 509
X $LOCAL_DIR/datasets/GMSC.arff SRP 500 917
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 500 473
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 500 2366
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 500 4260
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 500 861
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 500 4308
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 500 7755
X $LOCAL_DIR/datasets/GMSC.arff OBag 500 849
X $LOCAL_DIR/datasets/GMSC.arff OBag 500 4249
X $LOCAL_DIR/datasets/GMSC.arff OBag 500 7649

# --------------------
# loop-fusion
# esize 25
# bsize 2000
# with incremental: True

X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 2000 108
X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 2000 540
X $LOCAL_DIR/datasets/covtypeNorm.arff ARF 2000 972
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 2000 70
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 2000 351
X $LOCAL_DIR/datasets/covtypeNorm.arff LBag 2000 632
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 2000 29
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 2000 145
X $LOCAL_DIR/datasets/covtypeNorm.arff SRP 2000 262
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 2000 114
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 2000 574
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagAd 2000 1034
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 2000 331
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 2000 1657
X $LOCAL_DIR/datasets/covtypeNorm.arff OBagASHT 2000 2982
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 2000 355
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 2000 1778
X $LOCAL_DIR/datasets/covtypeNorm.arff OBag 2000 3201
X $LOCAL_DIR/datasets/airlines.arff ARF 2000 29
X $LOCAL_DIR/datasets/airlines.arff ARF 2000 146
X $LOCAL_DIR/datasets/airlines.arff ARF 2000 263
X $LOCAL_DIR/datasets/airlines.arff LBag 2000 44
X $LOCAL_DIR/datasets/airlines.arff LBag 2000 220
X $LOCAL_DIR/datasets/airlines.arff LBag 2000 396
X $LOCAL_DIR/datasets/airlines.arff SRP 2000 27
X $LOCAL_DIR/datasets/airlines.arff SRP 2000 138
X $LOCAL_DIR/datasets/airlines.arff SRP 2000 249
X $LOCAL_DIR/datasets/airlines.arff OBagAd 2000 97
X $LOCAL_DIR/datasets/airlines.arff OBagAd 2000 485
X $LOCAL_DIR/datasets/airlines.arff OBagAd 2000 873
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 2000 498
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 2000 2494
X $LOCAL_DIR/datasets/airlines.arff OBagASHT 2000 4490
X $LOCAL_DIR/datasets/airlines.arff OBag 2000 622
X $LOCAL_DIR/datasets/airlines.arff OBag 2000 3110
X $LOCAL_DIR/datasets/airlines.arff OBag 2000 5598
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 2000 87
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 2000 437
X $LOCAL_DIR/datasets/elecNormNew.arff ARF 2000 787
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 2000 140
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 2000 701
X $LOCAL_DIR/datasets/elecNormNew.arff LBag 2000 1262
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 2000 51
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 2000 259
X $LOCAL_DIR/datasets/elecNormNew.arff SRP 2000 467
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 2000 252
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 2000 1264
X $LOCAL_DIR/datasets/elecNormNew.arff OBagAd 2000 2275
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 2000 420
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 2000 2101
X $LOCAL_DIR/datasets/elecNormNew.arff OBagASHT 2000 3782
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 2000 404
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 2000 2021
X $LOCAL_DIR/datasets/elecNormNew.arff OBag 2000 3638
X $LOCAL_DIR/datasets/GMSC.arff ARF 2000 180
X $LOCAL_DIR/datasets/GMSC.arff ARF 2000 900
X $LOCAL_DIR/datasets/GMSC.arff ARF 2000 1620
X $LOCAL_DIR/datasets/GMSC.arff LBag 2000 222
X $LOCAL_DIR/datasets/GMSC.arff LBag 2000 1112
X $LOCAL_DIR/datasets/GMSC.arff LBag 2000 2001
X $LOCAL_DIR/datasets/GMSC.arff SRP 2000 97
X $LOCAL_DIR/datasets/GMSC.arff SRP 2000 487
X $LOCAL_DIR/datasets/GMSC.arff SRP 2000 877
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 2000 454
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 2000 2270
X $LOCAL_DIR/datasets/GMSC.arff OBagAd 2000 4086
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 2000 890
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 2000 4453
X $LOCAL_DIR/datasets/GMSC.arff OBagASHT 2000 8015
X $LOCAL_DIR/datasets/GMSC.arff OBag 2000 841
X $LOCAL_DIR/datasets/GMSC.arff OBag 2000 4205
X $LOCAL_DIR/datasets/GMSC.arff OBag 2000 7569

date +"%d/%m/%y %T" >> $EXPER_ORDER_FILE