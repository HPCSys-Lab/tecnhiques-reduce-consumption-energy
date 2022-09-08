#!/bin/bash

### elecNormNew

### Execucao sequencial

echo "[elecNormNew] Execução Sequencial..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

numactl --physcpubind=0 perf stat -o $RESULT_DIR/perf-elecNormNew-StreamingRandomPatches-25-1-1-1 -e cache-misses,cache-references time -o $RESULT_DIR/time-elecNormNew-StreamingRandomPatches-25-1-1-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EITTTExperiments -l (meta.StreamingRandomPatches -s 25) -s (ArffFileStream -f $REMOTE_DIR/datasets/elecNormNew.arff) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-elecNormNew-StreamingRandomPatches-25-1-1-1" > $RESULT_DIR/term-interleaved-elecNormNew-StreamingRandomPatches-25-1-1-1

### Execucao Mini Batching sem Loop Fusion

echo "[elecNormNew] Execução Mini-Batching Sem Loop Fusion..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/without-loop-fusion
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

numactl --physcpubind="0,1,2,3" perf stat -o $RESULT_DIR/perf-elecNormNew-StreamingRandomPatchesExecutorMAXChunk-25-4-50-1 -e cache-misses,cache-references time -o $RESULT_DIR/time-elecNormNew-StreamingRandomPatchesExecutorMAXChunk-25-4-50-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l (meta.StreamingRandomPatchesExecutorMAXChunk -s 25 -c 4) -s (ArffFileStream -f $REMOTE_DIR/datasets/elecNormNew.arff) -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-elecNormNew-StreamingRandomPatchesExecutorMAXChunk-25-4-50-1" > $RESULT_DIR/term-interleaved-elecNormNew-StreamingRandomPatchesExecutorMAXChunk-25-4-50-1

### Execucao Loop Fusion

echo "[elecNormNew] Execução Loop Fusion..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/loop-fusion
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

numactl --physcpubind="0,1,2,3" perf stat -o $RESULT_DIR/perf-elecNormNew-StreamingRandomPatchesExecutorMAXChunk-25-4-50-1 -e cache-misses,cache-references time -o $RESULT_DIR/time-elecNormNew-StreamingRandomPatchesExecutorMAXChunk-25-4-50-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunksOptimized -l (meta.StreamingRandomPatchesExecutorMAXChunk -s 25 -c 4) -s (ArffFileStream -f $REMOTE_DIR/datasets/elecNormNew.arff) -c 50 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-elecNormNew-StreamingRandomPatchesExecutorMAXChunk-25-4-50-1" > $RESULT_DIR/term-interleaved-elecNormNew-StreamingRandomPatchesExecutorMAXChunk-25-4-50-1

