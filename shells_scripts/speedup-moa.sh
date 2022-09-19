#!/bin/bash

export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching
export BASE_RESULT_DIR=/home/pi/reginaldojunior/experimentos/speedup

interations=( "15092022" )
for interation in "${interations[@]}"
do
    datasets=( "GMSC" "elecNormNew" "covtypeNorm" "airlines" )
    for dataset in "${datasets[@]}"
    do
        methods=( "sequential" "mini-batching" "mini-batching-loop-fusion")
        for method in "${methods[@]}"
        do
            algsSequentials=( "AdaptiveRandomForestSequential" "OzaBag" "OzaBagAdwin" "LeveragingBag" "OzaBagASHT" "StreamingRandomPatches" )
            for algs in "${algsSequentials[@]}"
            do
                echo "sequential"
                if [ $method = "sequential" ]; then            
                    export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
                    export RESULT_DIR=loop-fusion-sequential/0

                    mkdir -p $BASE_RESULT_DIR/$RESULT_DIR/$interation
                    
                    echo "[$dataset][$algs][$method]"
                    if [[ $dataset == "airlines" || $dataset == "covtypeNorm" ]]; then
                       numactl --physcpubind=0 java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l (meta.$algs -s 25) -s (ArffFileStream -f $REMOTE_DIR/datasets/$dataset.arff) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $BASE_RESULT_DIR/$RESULT_DIR/$interation/dump-$dataset-$algs-25-1-1-1" > $BASE_RESULT_DIR/$RESULT_DIR/$interation/term-interleaved-$dataset-$algs-25-1-1-1
                    else
                       numactl --physcpubind=0 java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l (meta.$algs -s 25) -s (ArffFileStream -f $REMOTE_DIR/datasets/$dataset.arff) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $BASE_RESULT_DIR/$RESULT_DIR/$interation/dump-$dataset-$algs-25-1-1-1" > $BASE_RESULT_DIR/$RESULT_DIR/$interation/term-interleaved-$dataset-$algs-25-1-1-1
                    fi
                fi
            done

            algsMB=( "AdaptiveRandomForestExecutorMAXChunk" "OzaBagExecutorMAXChunk" "OzaBagAdwinExecutorMAXChunk" "LBagExecutorMAXChunk" "OzaBagASHTExecutorMAXChunk" "StreamingRandomPatchesExecutorMAXChunk" )
            for algs in "${algsMB[@]}"
            do
                if [ $method = "mini-batching" ]; then
                    export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
                    export RESULT_DIR=without-loop-fusion/4
                    
                    mkdir -p $BASE_RESULT_DIR/$RESULT_DIR/$interation

                    echo "[$dataset][$algs][$method]"
                    if [[ $dataset == "airlines" || $dataset == "covtypeNorm" ]]; then
                        numactl --physcpubind="0,1,2,3" java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l (meta.$algs -s 25 -c 1) -s (ArffFileStream -f $REMOTE_DIR/datasets/$dataset.arff) -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $BASE_RESULT_DIR/$RESULT_DIR/$interation/dump-$dataset-$algs-25-4-50-1" > $BASE_RESULT_DIR/$RESULT_DIR/$interation/term-interleaved-$dataset-$algs-25-4-50-1
                    else
                        numactl --physcpubind="0,1,2,3" java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l (meta.$algs -s 25 -c 4) -s (ArffFileStream -f $REMOTE_DIR/datasets/$dataset.arff) -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $BASE_RESULT_DIR/$RESULT_DIR/$interation/dump-$dataset-$algs-25-4-50-1" > $BASE_RESULT_DIR/$RESULT_DIR/$interation/term-interleaved-$dataset-$algs-25-4-50-1
                    fi
                fi

                if [ $method = "mini-batching-loop-fusion" ]; then
                    export MOA_HOME=/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT
                    
                    cpus=( "0,1,2,3" )
                    COUNTER=4
                    for cpu in "${cpus[@]}"
                    do
                        export RESULT_DIR=loop-fusion/$COUNTER
                        
                        mkdir -p $BASE_RESULT_DIR/$RESULT_DIR/$interation

                        echo "[$dataset][$algs][$method]"
                        if [[ $dataset == "airlines" || $dataset == "covtypeNorm" ]]; then
                            echo "[$dataset][$algs][$method][$COUNTER]"
                            numactl --physcpubind=$cpu java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunksOptimized -l (meta.$algs -s 25 -c $COUNTER) -s (ArffFileStream -f $REMOTE_DIR/datasets/$dataset.arff) -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $BASE_RESULT_DIR/$RESULT_DIR/$interation/dump-$dataset-$algs-25-$COUNTER-50-1" > $BASE_RESULT_DIR/$RESULT_DIR/$interation/term-interleaved-$dataset-$algs-25-$COUNTER-50-1
                        else
                           echo "[$dataset][$algs][$method][$COUNTER]"
                           numactl --physcpubind=$cpu java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunksOptimized -l (meta.$algs -s 25 -c $COUNTER) -s (ArffFileStream -f $REMOTE_DIR/datasets/$dataset.arff) -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $BASE_RESULT_DIR/$RESULT_DIR/$interation/dump-$dataset-$algs-25-$COUNTER-50-1" > $BASE_RESULT_DIR/$RESULT_DIR/$interation/term-interleaved-$dataset-$algs-25-$COUNTER-50-1
                        fi
                            
                        let COUNTER++
                    done
               fi
            done
        done
    done
done
