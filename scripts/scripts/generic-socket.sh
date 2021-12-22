#!/bin/bash
#NOTE: remember to synchronize the date and time between the producer and consumer nodes.
#the idea of this script is to run the experiments that read data from the socket and execute for a limited time to measure energy consumption.
#we do not use the parameter t on the Task because the Task itself implements a hard coded time limit.
#in the future, it might be worth to measure the energy consumption of the total execution of such algorithms.
#most things that need changing are in function Y, before the if.
#the paths MOA_HOME and RESULT_DIR need to be adjusted to your environment.
#memory is specially important if you are running in a machine with smaller memory, change it or the machine will brick.
#the current version uses 3 auxiliar files (with the MOA dumps) to get all data needed.
function Y {
  #Usage: $0 FILE ALGORITHM BATCH_SIZE RATE
  #function Y has an additional parameter when working with sockets, which is the batch_size, or $3 parameter.
  #environment variables for paths -> these will need to be adjusted
  export MOA_HOME=/opt/data/moa-LAST
  export RESULT_DIR=/opt/data/channel_16-50-250
  export REMOTE_DIR=/home/gcassales/bases/
  mkdir -p $RESULT_DIR
  export ORDER_FILE=$RESULT_DIR/exper_order-Xeon-16-50-250.log
  #configuration of remote call
  username="gcassales"
  remoteIp="192.168.0.11"
  remotePort="9004"
  echo "file: $1 algorithm: $2 batch_size: $3 rate: $4"
  #Memory used in the JVM Heap
  Memory=50G
  #the CPU slots we are going to pin the processing
  CORES="0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15"
  #Variables for experiment parameters and naming (using declare allows the declaration of arrays or single values)
  nCores=16
  declare -a esize=(100)
  faux=${1##*\/}
  dataset=${faux%%.*}
  alg=${2##*.}
  bsize=${3}
  rate=${4}

  date +"%d/%m/%y %T"
  date +"%d/%m/%y %T" >> $ORDER_FILE
  echo "ssh-${dataset}-${alg}-${bsize}-${rate}" >> ${RESULT_DIR}/ssh-log
  #remote call to start the producer with correct rate and redirect the output to the ssh-log file.
  #then we sleep for 3 seconds to give time for the producer to get ready
  #NOTE: bigger datasets may need a bigger interval
  ssh ${username}@${remoteIp} java ChannelServer ${remoteIp} ${remotePort} ${REMOTE_DIR}${faux} $rate >> ${RESULT_DIR}/ssh-log &
  sleep 3
  #here we use the name of the class to define which is the correct task configuration.
  #if, in the future, MOA is updated to have all this built-in on the base class, we will need to pass an argument to the function
  if [[ ${alg} == *"MAX"* ]]; then
    #if we are using a mini-batch algorithm
    #no iteration in here unless we replicate the remote call inside the if...
    #filename follows the structure `dataset-algorithm-eSize-nCores-MBsize-rate`
    #rate is the rate of instances per second that the producer generates
    echo "$RESULT_DIR/${dataset}-${alg}-${esize}-${nCores}-${bsize}-${rate}" >> $ORDER_FILE
    echo "$RESULT_DIR/${dataset}-${alg}-${esize}-${nCores}-${bsize}-${rate}"
    #numactl pins the processing to the desired cores so we use it on every parallel execution
    numactl --physcpubind=${CORES} java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelChunksTIMED -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -c ${bsize} -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${dataset}-${alg}-${esize}-${nCores}-${bsize}-${rate}" > ${RESULT_DIR}/term-${dataset}-${alg}-${esize}-${nCores}-${bsize}-${rate}
  elif [[ ${alg} == *"RUNPER"* ]]; then
    #if we are using the parallel version without mini-batch we call it once with correct parameters
    #MBsize of 1 means it processes 1 instance per time
    echo "$RESULT_DIR/${dataset}-${alg}-${esize}-${nCores}-1-${rate}" >> $ORDER_FILE
    echo "$RESULT_DIR/${dataset}-${alg}-${esize}-${nCores}-1-${rate}"
    numactl --physcpubind=${CORES} java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelTIMED -l ($2 -s ${esize} -c ${nCores}) -s (ArffFileStream -f $1) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${dataset}-${alg}-${esize}-${nCores}-1-${rate}" > ${RESULT_DIR}/term-${dataset}-${alg}-${esize}-${nCores}-1-${rate}
  else
    #if we are using the sequential version without mini-batch we call it once with correct parameters
    #nCores of 1 means it uses only 1 core (sequential)
    echo "$RESULT_DIR/${dataset}-${alg}-${esize}-1-1-${rate}" >> $ORDER_FILE
    echo "$RESULT_DIR/${dataset}-${alg}-${esize}-1-1-${rate}"
    #sequential uses only one core, in theory we would not need, to pin the processing, but we do anyway.
    numactl --physcpubind=0 java -Xshare:off -XX:+UseParallelGC -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "ChannelTIMED -l ($2 -s ${esize}) -s (ArffFileStream -f $1) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${dataset}-${alg}-${esize}-1-1-${rate}" > ${RESULT_DIR}/term-${dataset}-${alg}-${esize}-1-1-${rate}
  fi
  echo ""
  date +"%d/%m/%y %T"
  date +"%d/%m/%y %T" >> $ORDER_FILE
}

function X {
  #Parameters: FILE ALG_ID MBSize RateSeq RatePar RateMB
  #this function merely converts the acronym passed as argument to the full class name used in the Task  and calls the Y function for each algorithm.
  #in this case we have extra parameters when compared to reading from file experiments.
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
  Y $1 ${algs[${ID}]} $3 $4
  Y $1 ${algs[$(( ID+1 ))]} $3 $5
  Y $1 ${algs[$(( ID+2 ))]} $3 $6
}

#beginning of the script
#since we are reading from sockets, we can NOT use a loop without using complicated collections to allow the production rate parameters
#the notebook get_rates prints the call lines with correct parameters based on previous experiments.
#we only have to paste the output of get_rates notebook here
#Bsize 50
X $1kyoto_binary.arff ARF 50 0 0 320
X $1kyoto_binary.arff ARF 50 0 0 1600
X $1kyoto_binary.arff ARF 50 0 0 2881
X $1kyoto_binary.arff LBag 50 0 0 325
X $1kyoto_binary.arff LBag 50 0 0 1628
X $1kyoto_binary.arff LBag 50 0 0 2930
X $1kyoto_binary.arff SRP 50 0 0 169
X $1kyoto_binary.arff SRP 50 0 0 849
X $1kyoto_binary.arff SRP 50 0 0 1528
X $1kyoto_binary.arff OBagAd 50 0 0 438
X $1kyoto_binary.arff OBagAd 50 0 0 2191
X $1kyoto_binary.arff OBagAd 50 0 0 3944
X $1kyoto_binary.arff OBagASHT 50 0 0 452
X $1kyoto_binary.arff OBagASHT 50 0 0 2264
X $1kyoto_binary.arff OBagASHT 50 0 0 4076
X $1kyoto_binary.arff OBag 50 0 0 374
X $1kyoto_binary.arff OBag 50 0 0 1870
X $1kyoto_binary.arff OBag 50 0 0 3366
X $1elecNormNew.arff ARF 50 0 0 198
X $1elecNormNew.arff ARF 50 0 0 994
X $1elecNormNew.arff ARF 50 0 0 1789
X $1elecNormNew.arff LBag 50 0 0 234
X $1elecNormNew.arff LBag 50 0 0 1173
X $1elecNormNew.arff LBag 50 0 0 2112
X $1elecNormNew.arff SRP 50 0 0 114
X $1elecNormNew.arff SRP 50 0 0 574
X $1elecNormNew.arff SRP 50 0 0 1034
X $1elecNormNew.arff OBagAd 50 0 0 342
X $1elecNormNew.arff OBagAd 50 0 0 1713
X $1elecNormNew.arff OBagAd 50 0 0 3083
X $1elecNormNew.arff OBagASHT 50 0 0 349
X $1elecNormNew.arff OBagASHT 50 0 0 1745
X $1elecNormNew.arff OBagASHT 50 0 0 3141
X $1elecNormNew.arff OBag 50 0 0 365
X $1elecNormNew.arff OBag 50 0 0 1826
X $1elecNormNew.arff OBag 50 0 0 3287
X $1covtypeNorm.arff ARF 50 0 0 158
X $1covtypeNorm.arff ARF 50 0 0 791
X $1covtypeNorm.arff ARF 50 0 0 1424
X $1covtypeNorm.arff LBag 50 0 0 112
X $1covtypeNorm.arff LBag 50 0 0 560
X $1covtypeNorm.arff LBag 50 0 0 1008
X $1covtypeNorm.arff SRP 50 0 0 68
X $1covtypeNorm.arff SRP 50 0 0 340
X $1covtypeNorm.arff SRP 50 0 0 612
X $1covtypeNorm.arff OBagAd 50 0 0 124
X $1covtypeNorm.arff OBagAd 50 0 0 624
X $1covtypeNorm.arff OBagAd 50 0 0 1124
X $1covtypeNorm.arff OBagASHT 50 0 0 121
X $1covtypeNorm.arff OBagASHT 50 0 0 609
X $1covtypeNorm.arff OBagASHT 50 0 0 1097
X $1covtypeNorm.arff OBag 50 0 0 124
X $1covtypeNorm.arff OBag 50 0 0 620
X $1covtypeNorm.arff OBag 50 0 0 1116
X $1airlines.arff ARF 50 0 0 62
X $1airlines.arff ARF 50 0 0 311
X $1airlines.arff ARF 50 0 0 560
X $1airlines.arff LBag 50 0 0 90
X $1airlines.arff LBag 50 0 0 451
X $1airlines.arff LBag 50 0 0 813
X $1airlines.arff SRP 50 0 0 66
X $1airlines.arff SRP 50 0 0 333
X $1airlines.arff SRP 50 0 0 600
X $1airlines.arff OBagAd 50 0 0 144
X $1airlines.arff OBagAd 50 0 0 723
X $1airlines.arff OBagAd 50 0 0 1302
X $1airlines.arff OBagASHT 50 0 0 221
X $1airlines.arff OBagASHT 50 0 0 1109
X $1airlines.arff OBagASHT 50 0 0 1997
X $1airlines.arff OBag 50 0 0 212
X $1airlines.arff OBag 50 0 0 1063
X $1airlines.arff OBag 50 0 0 1913
X $1GMSC.arff ARF 50 0 0 179
X $1GMSC.arff ARF 50 0 0 898
X $1GMSC.arff ARF 50 0 0 1617
X $1GMSC.arff LBag 50 0 0 253
X $1GMSC.arff LBag 50 0 0 1269
X $1GMSC.arff LBag 50 0 0 2285
X $1GMSC.arff SRP 50 0 0 121
X $1GMSC.arff SRP 50 0 0 608
X $1GMSC.arff SRP 50 0 0 1094
X $1GMSC.arff OBagAd 50 0 0 514
X $1GMSC.arff OBagAd 50 0 0 2570
X $1GMSC.arff OBagAd 50 0 0 4627
X $1GMSC.arff OBagASHT 50 0 0 666
X $1GMSC.arff OBagASHT 50 0 0 3330
X $1GMSC.arff OBagASHT 50 0 0 5995
X $1GMSC.arff OBag 50 0 0 411
X $1GMSC.arff OBag 50 0 0 2059
X $1GMSC.arff OBag 50 0 0 3707




#bsize 250
X $1kyoto_binary.arff ARF 250 0 0 474
X $1kyoto_binary.arff ARF 250 0 0 2372
X $1kyoto_binary.arff ARF 250 0 0 4271
X $1kyoto_binary.arff LBag 250 0 0 434
X $1kyoto_binary.arff LBag 250 0 0 2171
X $1kyoto_binary.arff LBag 250 0 0 3909
X $1kyoto_binary.arff SRP 250 0 0 260
X $1kyoto_binary.arff SRP 250 0 0 1303
X $1kyoto_binary.arff SRP 250 0 0 2346
X $1kyoto_binary.arff OBagAd 250 0 0 636
X $1kyoto_binary.arff OBagAd 250 0 0 3180
X $1kyoto_binary.arff OBagAd 250 0 0 5724
X $1kyoto_binary.arff OBagASHT 250 0 0 716
X $1kyoto_binary.arff OBagASHT 250 0 0 3583
X $1kyoto_binary.arff OBagASHT 250 0 0 6449
X $1kyoto_binary.arff OBag 250 0 0 541
X $1kyoto_binary.arff OBag 250 0 0 2705
X $1kyoto_binary.arff OBag 250 0 0 4870
X $1elecNormNew.arff ARF 250 0 0 298
X $1elecNormNew.arff ARF 250 0 0 1490
X $1elecNormNew.arff ARF 250 0 0 2683
X $1elecNormNew.arff LBag 250 0 0 401
X $1elecNormNew.arff LBag 250 0 0 2006
X $1elecNormNew.arff LBag 250 0 0 3611
X $1elecNormNew.arff SRP 250 0 0 161
X $1elecNormNew.arff SRP 250 0 0 808
X $1elecNormNew.arff SRP 250 0 0 1454
X $1elecNormNew.arff OBagAd 250 0 0 501
X $1elecNormNew.arff OBagAd 250 0 0 2505
X $1elecNormNew.arff OBagAd 250 0 0 4509
X $1elecNormNew.arff OBagASHT 250 0 0 536
X $1elecNormNew.arff OBagASHT 250 0 0 2683
X $1elecNormNew.arff OBagASHT 250 0 0 4830
X $1elecNormNew.arff OBag 250 0 0 557
X $1elecNormNew.arff OBag 250 0 0 2789
X $1elecNormNew.arff OBag 250 0 0 5020
X $1covtypeNorm.arff ARF 250 0 0 263
X $1covtypeNorm.arff ARF 250 0 0 1319
X $1covtypeNorm.arff ARF 250 0 0 2374
X $1covtypeNorm.arff LBag 250 0 0 142
X $1covtypeNorm.arff LBag 250 0 0 713
X $1covtypeNorm.arff LBag 250 0 0 1284
X $1covtypeNorm.arff SRP 250 0 0 82
X $1covtypeNorm.arff SRP 250 0 0 411
X $1covtypeNorm.arff SRP 250 0 0 740
X $1covtypeNorm.arff OBagAd 250 0 0 169
X $1covtypeNorm.arff OBagAd 250 0 0 845
X $1covtypeNorm.arff OBagAd 250 0 0 1521
X $1covtypeNorm.arff OBagASHT 250 0 0 150
X $1covtypeNorm.arff OBagASHT 250 0 0 750
X $1covtypeNorm.arff OBagASHT 250 0 0 1350
X $1covtypeNorm.arff OBag 250 0 0 172
X $1covtypeNorm.arff OBag 250 0 0 863
X $1covtypeNorm.arff OBag 250 0 0 1555
X $1airlines.arff ARF 250 0 0 103
X $1airlines.arff ARF 250 0 0 517
X $1airlines.arff ARF 250 0 0 932
X $1airlines.arff LBag 250 0 0 135
X $1airlines.arff LBag 250 0 0 679
X $1airlines.arff LBag 250 0 0 1223
X $1airlines.arff SRP 250 0 0 91
X $1airlines.arff SRP 250 0 0 459
X $1airlines.arff SRP 250 0 0 827
X $1airlines.arff OBagAd 250 0 0 219
X $1airlines.arff OBagAd 250 0 0 1098
X $1airlines.arff OBagAd 250 0 0 1977
X $1airlines.arff OBagASHT 250 0 0 361
X $1airlines.arff OBagASHT 250 0 0 1808
X $1airlines.arff OBagASHT 250 0 0 3254
X $1airlines.arff OBag 250 0 0 274
X $1airlines.arff OBag 250 0 0 1374
X $1airlines.arff OBag 250 0 0 2474
X $1GMSC.arff ARF 250 0 0 251
X $1GMSC.arff ARF 250 0 0 1258
X $1GMSC.arff ARF 250 0 0 2264
X $1GMSC.arff LBag 250 0 0 360
X $1GMSC.arff LBag 250 0 0 1801
X $1GMSC.arff LBag 250 0 0 3243
X $1GMSC.arff SRP 250 0 0 160
X $1GMSC.arff SRP 250 0 0 803
X $1GMSC.arff SRP 250 0 0 1446
X $1GMSC.arff OBagAd 250 0 0 715
X $1GMSC.arff OBagAd 250 0 0 3577
X $1GMSC.arff OBagAd 250 0 0 6439
X $1GMSC.arff OBagASHT 250 0 0 1035
X $1GMSC.arff OBagASHT 250 0 0 5179
X $1GMSC.arff OBagASHT 250 0 0 9322
X $1GMSC.arff OBag 250 0 0 625
X $1GMSC.arff OBag 250 0 0 3129
X $1GMSC.arff OBag 250 0 0 5632


date +"%d/%m/%y %T" >> $ORDER_FILE
