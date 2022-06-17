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
  #alterar para memória do servidor
  Memory=700M
  CORES="0,1,2,3"
  nCores=$CPUS

  faux=${1##*\/}
  onlyname=${faux%%.*}
  echo "$2  $1 $3"
  
  if [[ $2 == *"MAX"* ]]; then
    IDENT="timedchunk"
    echo "$RESULT_DIR/$3/${IDENT}-${onlyname}-${2##*.}-25-$nCores-50-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunksOptimized -l ($2 -s 25 -c ${nCores}) -s (ArffFileStream -f $1) -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$3/dump-${onlyname}-${2##*.}-25-${nCores}-50-1" > ${RESULT_DIR}/$3/term-${IDENT}-${onlyname}-${2##*.}-25-${nCores}-50-1
  else
    IDENT="interleaved"
    echo "$RESULT_DIR/$3/${IDENT}-${onlyname}-${2##*.}-25-1-1-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l ($2 -s 25) -s (ArffFileStream -f $1) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$3/dump-${onlyname}-${2##*.}-25-1-1-1" > ${RESULT_DIR}/$3/term-${IDENT}-${onlyname}-${2##*.}-25-1-1-1
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
  Y $1 ${algs[${ID}]} $3 # without loop fusion
  # Y $1 ${algs[$(( ID+1 ))]} $3
  # Y $1 ${algs[$(( ID+2 ))]} $3 # loop fusion
}

#alterar caminhos

## local mac
# export MOA_HOME=/Users/reginaldoluisdeluna/Documents/Ufscar/Parallel-Classifier-MOA/moa-full/target/moa-release-2019.05.1-SNAPSHOT/
# export RESULT_DIR=/Users/reginaldoluisdeluna/Documents/Ufscar/results/speedup/$CPUS/
# export REMOTE_DIR=/Users/reginaldoluisdeluna/Documents/Ufscar/comparison-xue3m-minibatching

## rasp
export MOA_HOME=/home/pi/moa/moa-LAST
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/loop-fusion/results/$CPUS/
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

# alterar para o caminho do HD/scratch
mkdir -p $RESULT_DIR
mkdir -p $RESULT_DIR/first

#----------- FIRST ROUND
X $REMOTE_DIR/datasets/elecNormNew.arff ARF first
X $REMOTE_DIR/datasets/elecNormNew.arff OBag first

X $REMOTE_DIR/datasets/airlines.arff ARF first
X $REMOTE_DIR/datasets/airlines.arff OBag first