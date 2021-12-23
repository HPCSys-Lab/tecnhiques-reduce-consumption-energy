#!/bin/bash
#the idea of this script is to run the experiments for a while to get an idea of the throughput when reading from a file.
#for this reason we use -t 180 in the task configuration, which means we use a 180second limit.
#the task terminates when the whole dataset is processed or it executes for 180 seconds, whatever happens first.
#most things that need changing are in function Y, before the if.
#the paths MOA_HOME and RESULT_DIR need to be adjusted to your environment.
#memory is specially important if you are running in a machine with smaller memory, change it or the machine will brick.
function Y {
  #Usage: $0 FILE ALGORITHM RATE
  #environment variables for paths
  export MOA_HOME=/opt/data/moa-LAST
  export RESULT_DIR=/opt/data/getrates
  mkdir -p $RESULT_DIR
  #Memory used in the JVM Heap
  Memory=50G
  #the CPU slots we are going to pin the processing
  CORES="0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15"
  #the experiment parameters (using declare allows the declaration of arrays or single values)
  declare -a esize=(100)
  declare -a mbsize=(50 250 500)
  declare -a nCores=(16)
  faux=${1##*\/}
  dataset=${faux%%.*}
  alg=${2##*.}
  #here we use the name of the class to define which is the correct task configuration.
  #if, in the future, MOA is updated to have all this built-in on the base class, we will need to pass an argument to the function
  if [[ $2 == *"MAX"* ]]; then
    #if we are using a mini-batch algorithm we iterate over the desired mini-batch sizes and call the respective evaluator task with correct parameter configuration
    #we can use this "format" to iterate through different array of parameters (like the nCores)
    for m in "${mbsize[@]}"
    do
      #filename follows the structure `dataset-algorithm-eSize-nCores-MBsize-rate`
      #rate is the rate of receiving instances, it is used mostly on socket experiments.
      #a rate of 1 means reading from file
      echo "$RESULT_DIR/${dataset}-${alg}-${esize}-${nCores}-$m-1"
      #numactl pins the processing to the desired cores so we use it on every parallel execution
      numactl --physcpubind=${CORES} java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -c $m -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -t 180 -d $RESULT_DIR/dump-${dataset}-${alg}-${esize}-${nCores}-$m-1" > ${RESULT_DIR}/term-${dataset}-${alg}-${esize}-${nCores}-$m-1
    done
  elif [[ ${2} == *"RUNPER"* ]]; then
    #if we are using the parallel version without mini-batch we call it once with correct parameters
    #MBsize of 1 means it processes 1 instance per time
    echo "$RESULT_DIR/${dataset}-${alg}-${esize}-${nCores}-1-1"
    numactl --physcpubind=${CORES} java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -t 180 -d $RESULT_DIR/dump-${dataset}-${alg}-${esize}-${nCores}-1-1" > ${RESULT_DIR}/term-${dataset}-${alg}-${esize}-${nCores}-1-1
  else
    #if we are using the sequential version without mini-batch we call it once with correct parameters
    #nCores of 1 means it uses only 1 core (sequential)
    echo "$RESULT_DIR/${dataset}-${alg}-${esize}-1-1-1"
    #sequential uses only one core, in theory we would not need, to pin the processing, but we do anyway.
    numactl --physcpubind=0 java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l ($2 -s ${esize}) -s (ArffFileStream -f $1) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -t 180 -d $RESULT_DIR/dump-${dataset}-${alg}-${esize}-1-1-1" > ${RESULT_DIR}/term--${dataset}-${alg}-${esize}-1-1
  fi
  echo ""
}

function X {
  #this function merely converts the acronym passed as argument to the full class name used in the Task and calls the Y function for each algorithm.
  #Y function handles the parameterization of the experiment.
  #since we have 3 versions it could be possible to use something similar to unix permissions (1 2 4) to determine which versions should be executed
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

  #ID calls the sequential version
  #ID+1 calls the parallel without mini-batch version
  #ID+2 calls the parallel with mini-batch version
  Y $1 ${algs[${ID}]}
  Y $1 ${algs[$(( ID+1 ))]}
  Y $1 ${algs[$(( ID+2 ))]}
}

#beginning of the script
#since we are reading from files, we can use a loop because there are no production rate parameters
for ds in "elecNormNew" "GMSC" "airlines" "covtypeNorm" "kyoto_binary";
do
  for alg in "ARF" "LBag" "SRP" "OBag" "OBagAd" "OBagASHT";
  do
    X $1${ds}.arff $alg
  done 
done

#for the experiments with sockets we need this method of calling to account for production rate parameters (see generic-socket.sh)
#the notebook get_rates prints the call lines with correct parameters based on previous experiments.
#we only have to paste the output of get_rates notebook here
# X $1elecNormNew.arff ARF
# X $1elecNormNew.arff LBag
# X $1elecNormNew.arff SRP
# X $1elecNormNew.arff OBag
# X $1elecNormNew.arff OBagAd
# X $1elecNormNew.arff OBagASHT

# X $1GMSC.arff ARF
# X $1GMSC.arff LBag
# X $1GMSC.arff SRP
# X $1GMSC.arff OBag
# X $1GMSC.arff OBagAd
# X $1GMSC.arff OBagASHT

# X $1airlines.arff ARF
# X $1airlines.arff LBag
# X $1airlines.arff SRP
# X $1airlines.arff OBag
# X $1airlines.arff OBagAd
# X $1airlines.arff OBagASHT

# X $1covtypeNorm.arff ARF
# X $1covtypeNorm.arff LBag
# X $1covtypeNorm.arff SRP
# X $1covtypeNorm.arff OBag
# X $1covtypeNorm.arff OBagAd
# X $1covtypeNorm.arff OBagASHT

# X $1kyoto_binary.arff ARF
# X $1kyoto_binary.arff LBag
# X $1kyoto_binary.arff SRP
# X $1kyoto_binary.arff OBag
# X $1kyoto_binary.arff OBagAd
# X $1kyoto_binary.arff OBagASHT
