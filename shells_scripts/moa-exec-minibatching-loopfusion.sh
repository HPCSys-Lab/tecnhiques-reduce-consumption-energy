#!/bin/bash

#alterar caminhos
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching
export BASE_RESULT_DIR=/home/pi/reginaldojunior/experimentos/socket

function Y {
  #Usage: $0 FILE ALGORITHM RATE
  #alterar para memória do servidor
  Memory=700M
  CORES="0,1,2,3"

  faux=${1##*\/}
  onlyname=${faux%%.*}
  echo "$2  $1 $3"

  if [[ $2 == *"MAX"* ]]; then
    IDENT="chunk"
    
    ## mini batching com loop fusion
    export MOA_HOME=/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT

    echo "$BASE_RESULT_DIR/loop-fusion/${IDENT}-${onlyname}-${2##*.}-25-4-50-1"
    numactl --physcpubind="0,1,2,3" java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunksOptimized -l ($2 -s 25 -c 4) -s (ArffFileStream -f $1) -t 120 -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $BASE_RESULT_DIR/loop-fusion/dump-${onlyname}-${2##*.}-25-4-50-1" > ${BASE_RESULT_DIR}/loop-fusion/term-${IDENT}-${onlyname}-${2##*.}-25-4-50-1
    
    ## mini batching sem loop fusion
    export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion

    echo "$BASE_RESULT_DIR/without-loop-fusion/${IDENT}-${onlyname}-${2##*.}-25-4-50-1"
    numactl --physcpubind="0,1,2,3" java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($2 -s 25 -c 4) -s (ArffFileStream -f $1) -t 120 -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $BASE_RESULT_DIR/without-loop-fusion/dump-${onlyname}-${2##*.}-25-4-50-1" > ${BASE_RESULT_DIR}/without-loop-fusion/term-${IDENT}-${onlyname}-${2##*.}-25-4-50-1
  else
    export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion

    IDENT="interleaved"
    echo "$BASE_RESULT_DIR/loop-fusion-sequential/${IDENT}-${onlyname}-${2##*.}-25-1-1-1"
    numactl --physcpubind=0 java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l ($2 -s 25) -s (ArffFileStream -f $1) -t 120 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $BASE_RESULT_DIR/loop-fusion-sequential/dump-${onlyname}-${2##*.}-25-1-1-1" > ${BASE_RESULT_DIR}/loop-fusion-sequential/term-${IDENT}-${onlyname}-${2##*.}-25-1-1-1
  fi

  echo ""
}

function X {
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
  Y $1 ${algs[${ID}]} $3 ## loop fusion and without loop fusion
  Y $1 ${algs[$(( ID+2 ))]} $3 ## sequential
}

# alterar para o caminho do HD/scratch
mkdir -p $BASE_RESULT_DIR
mkdir -p $BASE_RESULT_DIR/loop-fusion \
         $BASE_RESULT_DIR/without-loop-fusion \
         $BASE_RESULT_DIR/loop-fusion-sequential

datasets=( "GMSC" "elecNormNew" "covtypeNorm" "airlines" )
for dataset in "${datasets[@]}"
do
    algs=( "ARF" "LBag" "OBagAd" "OBag" "OBagASHT" "SRP" )
    for alg in "${algs[@]}"
    do
        X $REMOTE_DIR/datasets/$dataset.arff $alg first
    done
done