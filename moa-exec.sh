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
  export MOA_HOME=/home/pi/moa/moa-LAST
  export RESULT_DIR=/home/pi/reginaldojunior/experimentos/moa
  export REMOTE_DIR=/home/pi/moa/bases

  faux=${1##*\/}
  onlyname=${faux%%.*}
  echo "$2  $1 $3"
  if [[ $2 == *"MAX"* ]]; then
    IDENT="chunk"
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-100-8-50"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($2 -s 100 -c 3) -s (ArffFileStream -f $1) -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-100-8-50" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-100-8-50
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-100-8-500"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($2 -s 100 -c 3) -s (ArffFileStream -f $1) -c 500 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-100-8-500" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-100-8-500
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-100-8-2000"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($2 -s 100 -c 3) -s (ArffFileStream -f $1) -c 2000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-100-8-2000" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-100-8-2000

    # ENSEMBLE SIZE 150
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${1##*.}-150-8-50"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($2 -s 150 -c 3) -s (ArffFileStream -f $1) -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-150-8-50" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-150-8-50
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-150-8-500"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($2 -s 150 -c 3) -s (ArffFileStream -f $1) -c 500 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-150-8-500" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-150-8-500
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-150-8-2000"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($2 -s 150 -c 3) -s (ArffFileStream -f $1) -c 2000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-150-8-2000" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-150-8-2000
  elif [[ ${2} == *"RUNPER"* ]]; then
    IDENT="interleaved"
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-100-8-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l ($2 -s 100 -c 3) -s (ArffFileStream -f $1) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-100-8-1" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-100-8-1
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-150-8-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l ($2 -s 150 -c 3) -s (ArffFileStream -f $1) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-150-8-1" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-150-8-1
  else
    IDENT="interleaved"
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-100-1-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l ($2 -s 100) -s (ArffFileStream -f $1) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-100-1-1" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-100-1-1
    echo "$RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/${IDENT}-${onlyname}-${2##*.}-150-1-1"
    java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l ($2 -s 150) -s (ArffFileStream -f $1) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/dump-${onlyname}-${2##*.}-150-1-1" > ${RESULT_DIR}/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/$3/term-${IDENT}-${onlyname}-${2##*.}-150-1-1
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
mkdir -p /home/pi/reginaldojunior/experimentos/moa
mkdir -p /home/pi/reginaldojunior/experimentos/moa
mkdir -p /home/pi/reginaldojunior/experimentos/moa/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/first \
        /home/pi/reginaldojunior/experimentos/moa/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/second \
        /home/pi/reginaldojunior/experimentos/moa/$FREQUENCIA_MAXIMA/$FREQUENCIA_MINIMA/third

#----------- FIRST ROUND
X /home/pi/moa/bases/elecNormNew.arff ARF first
X /home/pi/moa/bases/elecNormNew.arff LBag first
X /home/pi/moa/bases/elecNormNew.arff OBagAd first
X /home/pi/moa/bases/elecNormNew.arff OBag first
X /home/pi/moa/bases/elecNormNew.arff OBagASHT first
X /home/pi/moa/bases/elecNormNew.arff SRP first

X /home/pi/moa/bases/airlines.arff ARF first
X /home/pi/moa/bases/airlines.arff LBag first
X /home/pi/moa/bases/airlines.arff OBagAd first
X /home/pi/moa/bases/airlines.arff OBag first
X /home/pi/moa/bases/airlines.arff OBagASHT first
X /home/pi/moa/bases/airlines.arff SRP first

X /home/pi/moa/bases/covtypeNorm.arff ARF first
X /home/pi/moa/bases/covtypeNorm.arff LBag first
X /home/pi/moa/bases/covtypeNorm.arff OBagAd first
X /home/pi/moa/bases/covtypeNorm.arff OBag first
X /home/pi/moa/bases/covtypeNorm.arff OBagASHT first
X /home/pi/moa/bases/covtypeNorm.arff SRP first

X /home/pi/moa/bases/GMSC.arff ARF first
X /home/pi/moa/bases/GMSC.arff LBag first
X /home/pi/moa/bases/GMSC.arff OBagAd first
X /home/pi/moa/bases/GMSC.arff OBag first
X /home/pi/moa/bases/GMSC.arff OBagASHT first
X /home/pi/moa/bases/GMSC.arff SRP first

#----------- SECOND ROUND

X /home/pi/moa/bases/elecNormNew.arff ARF second
X /home/pi/moa/bases/elecNormNew.arff LBag second
X /home/pi/moa/bases/elecNormNew.arff OBagAd second
X /home/pi/moa/bases/elecNormNew.arff OBag second
X /home/pi/moa/bases/elecNormNew.arff OBagASHT second
X /home/pi/moa/bases/elecNormNew.arff SRP second

X /home/pi/moa/bases/airlines.arff ARF second
X /home/pi/moa/bases/airlines.arff LBag second
X /home/pi/moa/bases/airlines.arff OBagAd second
X /home/pi/moa/bases/airlines.arff OBag second
X /home/pi/moa/bases/airlines.arff OBagASHT second
X /home/pi/moa/bases/airlines.arff SRP second

X /home/pi/moa/bases/covtypeNorm.arff ARF second
X /home/pi/moa/bases/covtypeNorm.arff LBag second
X /home/pi/moa/bases/covtypeNorm.arff OBagAd second
X /home/pi/moa/bases/covtypeNorm.arff OBag second
X /home/pi/moa/bases/covtypeNorm.arff OBagASHT second
X /home/pi/moa/bases/covtypeNorm.arff SRP second

X /home/pi/moa/bases/GMSC.arff ARF second
X /home/pi/moa/bases/GMSC.arff LBag second
X /home/pi/moa/bases/GMSC.arff OBagAd second
X /home/pi/moa/bases/GMSC.arff OBag second
X /home/pi/moa/bases/GMSC.arff OBagASHT second
X /home/pi/moa/bases/GMSC.arff SRP second

#----------- THIRD ROUND
X /home/pi/moa/bases/elecNormNew.arff ARF third
X /home/pi/moa/bases/elecNormNew.arff LBag third
X /home/pi/moa/bases/elecNormNew.arff OBagAd third
X /home/pi/moa/bases/elecNormNew.arff OBag third
X /home/pi/moa/bases/elecNormNew.arff OBagASHT third
X /home/pi/moa/bases/elecNormNew.arff SRP third

X /home/pi/moa/bases/airlines.arff ARF third
X /home/pi/moa/bases/airlines.arff LBag third
X /home/pi/moa/bases/airlines.arff OBagAd third
X /home/pi/moa/bases/airlines.arff OBag third
X /home/pi/moa/bases/airlines.arff OBagASHT third
X /home/pi/moa/bases/airlines.arff SRP third

X /home/pi/moa/bases/covtypeNorm.arff ARF third
X /home/pi/moa/bases/covtypeNorm.arff LBag third
X /home/pi/moa/bases/covtypeNorm.arff OBagAd third
X /home/pi/moa/bases/covtypeNorm.arff OBag third
X /home/pi/moa/bases/covtypeNorm.arff OBagASHT third
X /home/pi/moa/bases/covtypeNorm.arff SRP third

X /home/pi/moa/bases/GMSC.arff ARF third
X /home/pi/moa/bases/GMSC.arff LBag third
X /home/pi/moa/bases/GMSC.arff OBagAd third
X /home/pi/moa/bases/GMSC.arff OBag third
X /home/pi/moa/bases/GMSC.arff OBagASHT third
X /home/pi/moa/bases/GMSC.arff SRP third
