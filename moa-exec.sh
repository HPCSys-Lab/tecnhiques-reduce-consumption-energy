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
  #alterar para memória do servidor
  Memory=700M
  CORES="0,1,2,3"
  
  #alterar caminhos
  export MOA_HOME=/home/reginaldojunior/Documentos/UFscar/MOA-last/moa-release-2019.05.1-SNAPSHOT
  export RESULT_DIR=/home/reginaldojunior/Documentos/UFscar/compare-dvfs-moa/results
  export REMOTE_DIR=/home/reginaldojunior/Documentos/UFscar/compare-dvfs-moa/datasets

  faux=${1##*\/}
  onlyname=${faux%%.*}
  echo "$2  $1 $3"
  
  if [[ $2 == *"MAX"* ]]; then
    IDENT="chunk"
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-100-4-50-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($2 -s 100 -c 3) -s (ArffFileStream -f $1) -t 300 -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-100-4-50-1" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-100-4-50-1
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-100-4-500-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($2 -s 100 -c 3) -s (ArffFileStream -f $1) -t 300 -c 500 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-100-4-500-1" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-100-4-500-1
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-100-4-2000-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($2 -s 100 -c 3) -s (ArffFileStream -f $1) -t 300 -c 2000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-100-4-2000-1" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-100-4-2000-1

    # ENSEMBLE SIZE 150
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${1##*.}-150-4-50-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($2 -s 150 -c 3) -s (ArffFileStream -f $1) -t 300 -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-150-4-50-1" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-150-4-50-1
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-150-4-500-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($2 -s 150 -c 3) -s (ArffFileStream -f $1) -t 300 -c 500 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-150-4-500-1" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-150-4-500-1
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-150-4-2000-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($2 -s 150 -c 3) -s (ArffFileStream -f $1) -t 300 -c 2000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-150-4-2000-1" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-150-4-2000-1
  elif [[ ${2} == *"RUNPER"* ]]; then
    IDENT="interleaved"
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-100-4-1-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l ($2 -s 100 -c 3) -s (ArffFileStream -f $1) -t 300 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-100-4-1-1" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-100-4-1-1
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-150-4-1-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l ($2 -s 150 -c 3) -s (ArffFileStream -f $1) -t 300 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-150-4-1-1" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-150-4-1-1
  else
    IDENT="interleaved"
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-100-1-1-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l ($2 -s 100) -s (ArffFileStream -f $1) -t 300 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-100-1-1-1" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-100-1-1-1
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-150-1-1-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l ($2 -s 150) -s (ArffFileStream -f $1) -t 300 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-150-1-1-1" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-150-1-1-1
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
  Y $1 ${algs[${ID}]} $3
  Y $1 ${algs[$(( ID+1 ))]} $3
  Y $1 ${algs[$(( ID+2 ))]} $3
}

# alterar para o caminho do HD/scratch
mkdir -p /home/reginaldojunior/Documentos/UFscar/compare-dvfs-moa/results
mkdir -p /home/reginaldojunior/Documentos/UFscar/compare-dvfs-moa/results
mkdir -p /home/reginaldojunior/Documentos/UFscar/compare-dvfs-moa/results/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/first \
        /home/reginaldojunior/Documentos/UFscar/compare-dvfs-moa/results/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/second \
        /home/reginaldojunior/Documentos/UFscar/compare-dvfs-moa/results/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/third

#----------- FIRST ROUND
X datasets/elecNormNew.arff ARF first
X datasets/elecNormNew.arff LBag first
X datasets/elecNormNew.arff OBagAd first
X datasets/elecNormNew.arff OBag first
X datasets/elecNormNew.arff OBagASHT first
X datasets/elecNormNew.arff SRP first

X datasets/airlines.arff ARF first
X datasets/airlines.arff LBag first
X datasets/airlines.arff OBagAd first
X datasets/airlines.arff OBag first
X datasets/airlines.arff OBagASHT first
X datasets/airlines.arff SRP first

X datasets/covtypeNorm.arff ARF first
X datasets/covtypeNorm.arff LBag first
X datasets/covtypeNorm.arff OBagAd first
X datasets/covtypeNorm.arff OBag first
X datasets/covtypeNorm.arff OBagASHT first
X datasets/covtypeNorm.arff SRP first

X datasets/GMSC.arff ARF first
X datasets/GMSC.arff LBag first
X datasets/GMSC.arff OBagAd first
X datasets/GMSC.arff OBag first
X datasets/GMSC.arff OBagASHT first
X datasets/GMSC.arff SRP first


#----------- SECOND ROUND

X datasets/elecNormNew.arff ARF second
X datasets/elecNormNew.arff LBag second
X datasets/elecNormNew.arff OBagAd second
X datasets/elecNormNew.arff OBag second
X datasets/elecNormNew.arff OBagASHT second
X datasets/elecNormNew.arff SRP second

X datasets/airlines.arff ARF second
X datasets/airlines.arff LBag second
X datasets/airlines.arff OBagAd second
X datasets/airlines.arff OBag second
X datasets/airlines.arff OBagASHT second
X datasets/airlines.arff SRP second

X datasets/covtypeNorm.arff ARF second
X datasets/covtypeNorm.arff LBag second
X datasets/covtypeNorm.arff OBagAd second
X datasets/covtypeNorm.arff OBag second
X datasets/covtypeNorm.arff OBagASHT second
X datasets/covtypeNorm.arff SRP second

X datasets/GMSC.arff ARF second
X datasets/GMSC.arff LBag second
X datasets/GMSC.arff OBagAd second
X datasets/GMSC.arff OBag second
X datasets/GMSC.arff OBagASHT second
X datasets/GMSC.arff SRP second
#----------- THIRD ROUND

X datasets/elecNormNew.arff ARF third
X datasets/elecNormNew.arff LBag third
X datasets/elecNormNew.arff OBagAd third
X datasets/elecNormNew.arff OBag third
X datasets/elecNormNew.arff OBagASHT third
X datasets/elecNormNew.arff SRP third

X datasets/airlines.arff ARF third
X datasets/airlines.arff LBag third
X datasets/airlines.arff OBagAd third
X datasets/airlines.arff OBag third
X datasets/airlines.arff OBagASHT third
X datasets/airlines.arff SRP third

X datasets/covtypeNorm.arff ARF third
X datasets/covtypeNorm.arff LBag third
X datasets/covtypeNorm.arff OBagAd third
X datasets/covtypeNorm.arff OBag third
X datasets/covtypeNorm.arff OBagASHT third
X datasets/covtypeNorm.arff SRP third

X datasets/GMSC.arff ARF third
X datasets/GMSC.arff LBag third
X datasets/GMSC.arff OBagAd third
X datasets/GMSC.arff OBag third
X datasets/GMSC.arff OBagASHT third
X datasets/GMSC.arff SRP third
