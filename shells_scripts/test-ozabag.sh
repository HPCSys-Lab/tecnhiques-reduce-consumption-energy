#!/bin/bash

### GMSC

### Execucao sequencial

echo "[GMSC] Execução Sequencial..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

numactl --physcpubind=0 perf stat -o $RESULT_DIR/perf-GMSC-OzaBag-25-1-1-1 -e cache-misses,cache-references time -o $RESULT_DIR/time-GMSC-OzaBag-25-1-1-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l (meta.OzaBag -s 25) -s (ArffFileStream -f $REMOTE_DIR/datasets/GMSC.arff) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-GMSC-OzaBag-25-1-1-1" > $RESULT_DIR/term-interleaved-GMSC-OzaBag-25-1-1-1

### Execucao Mini Batching sem Loop Fusion

echo "[GMSC] Execução Mini-Batching Sem Loop Fusion..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/without-loop-fusion
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

numactl --physcpubind="0,1,2,3" perf stat -o $RESULT_DIR/perf-GMSC-OzaBagExecutorMAXChunk-25-4-50-1 -e cache-misses,cache-references time -o $RESULT_DIR/time-GMSC-OzaBagExecutorMAXChunk-25-4-50-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l (meta.OzaBagExecutorMAXChunk -s 25 -c 4) -s (ArffFileStream -f $REMOTE_DIR/datasets/GMSC.arff) -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-GMSC-OzaBagExecutorMAXChunk-25-4-50-1" > $RESULT_DIR/term-interleaved-GMSC-OzaBagExecutorMAXChunk-25-4-50-1

### Execucao Loop Fusion

echo "[GMSC] Execução Loop Fusion..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/loop-fusion
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

numactl --physcpubind="0,1,2,3" perf stat -o $RESULT_DIR/perf-GMSC-OzaBagExecutorMAXChunk-25-4-50-1 -e cache-misses,cache-references time -o $RESULT_DIR/time-GMSC-OzaBagExecutorMAXChunk-25-4-50-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunksOptimized -l (meta.OzaBagExecutorMAXChunk -s 25 -c 4) -s (ArffFileStream -f $REMOTE_DIR/datasets/GMSC.arff) -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-GMSC-OzaBagExecutorMAXChunk-25-4-50-1" > $RESULT_DIR/term-interleaved-GMSC-OzaBagExecutorMAXChunk-25-4-50-1


#### AIRLINES
### Execucao sequencial

echo "[airlines] Execução Sequencial..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

numactl --physcpubind=0 perf stat -o $RESULT_DIR/perf-airlines-OzaBag-25-1-1-1 -e cache-misses,cache-references time -o $RESULT_DIR/time-airlines-OzaBag-25-1-1-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l (meta.OzaBag -s 25) -s (ArffFileStream -f $REMOTE_DIR/datasets/airlines.arff) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-airlines-OzaBag-25-1-1-1" > $RESULT_DIR/term-interleaved-GMSC-OzaBag-25-1-1-1


### Execucao Mini Batching sem Loop Fusion

echo "[airlines] Execução Mini-Batching Sem Loop Fusion..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/without-loop-fusion
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

numactl --physcpubind="0,1,2,3" perf stat -o $RESULT_DIR/perf-airlines-OzaBagExecutorMAXChunk-25-4-50-1 -e cache-misses,cache-references time -o $RESULT_DIR/time-airlines-OzaBagExecutorMAXChunk-25-4-50-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l (meta.OzaBagExecutorMAXChunk -s 25 -c 4) -s (ArffFileStream -f $REMOTE_DIR/datasets/airlines.arff) -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i 10000 -d $RESULT_DIR/dump-airlines-OzaBagExecutorMAXChunk-25-4-50-1" > $RESULT_DIR/term-interleaved-airlines-OzaBagExecutorMAXChunk-25-4-50-1

### Execucao Mini Batching com Loop Fusion

echo "[airlines] Execução Loop Fusion..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/loop-fusion
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

numactl --physcpubind="0,1,2,3" perf stat -o $RESULT_DIR/perf-airlines-OzaBagExecutorMAXChunk-25-4-50-1 -e cache-misses,cache-references time -o $RESULT_DIR/time-airlines-OzaBagExecutorMAXChunk-25-4-50-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunksOptimized -l (meta.OzaBagExecutorMAXChunk -s 25 -c 4) -s (ArffFileStream -f $REMOTE_DIR/datasets/airlines.arff) -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i 10000 -d $RESULT_DIR/dump-airlines-OzaBagExecutorMAXChunk-25-4-50-1" > $RESULT_DIR/term-interleaved-airlines-OzaBagExecutorMAXChunk-25-4-50-1


