#!/bin/bash

### GMSC

### Execucao sequencial

echo "[GMSC] Execução Sequencial, limitado em 100.000 instancias..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

perf stat -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/perf-GMSC-OzaBag-25-1-1-1 -e context-switches,cache-misses,cache-references,minor-faults,major-faults,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-store-misses,LLC-stores,branch-load-misses,branch-loads,dTLB-load-misses,dTLB-loads,dTLB-store-misses,dTLB-stores,iTLB-load-misses,iTLB-loads,node-load-misses,node-loads,node-store-misses,node-stores time -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/time-GMSC-OzaBag-25-1-1-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp /home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/:/home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/moa.jar moa.DoTask "EITTTExperiments -l (meta.OzaBag -s 25) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff) -i 100000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/dump-GMSC-OzaBag-25-1-1-1" > /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/term-interleaved-GMSC-OzaBag-25-1-1-1

### Execucao Mini Batching sem Loop Fusion

echo "[GMSC] Execução Mini-Batching Sem Loop Fusion, limitado em 100.000 instancias..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/without-loop-fusion
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

perf stat -o /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/perf-GMSC-OzaBagExecutorMAXChunk-25-4-50-1 -e context-switches,cache-misses,cache-references,minor-faults,major-faults,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-store-misses,LLC-stores,branch-load-misses,branch-loads,dTLB-load-misses,dTLB-loads,dTLB-store-misses,dTLB-stores,iTLB-load-misses,iTLB-loads,node-load-misses,node-loads,node-store-misses,node-stores time -o /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/time-GMSC-OzaBagExecutorMAXChunk-25-4-50-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp /home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/:/home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l (meta.OzaBagExecutorMAXChunk -s 25 -c 4) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff) -i 100000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/dump-GMSC-OzaBagExecutorMAXChunk-25-4-50-1" > /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/term-interleaved-GMSC-OzaBagExecutorMAXChunk-25-4-50-1

### Execucao Loop Fusion

echo "[GMSC] Execução Loop Fusion, limitado em 100.000 instancias..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT/
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/loop-fusion
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

perf stat -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion/perf-GMSC-OzaBagExecutorMAXChunk-25-4-50-1 -e context-switches,cache-misses,cache-references,minor-faults,major-faults,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-store-misses,LLC-stores,branch-load-misses,branch-loads,dTLB-load-misses,dTLB-loads,dTLB-store-misses,dTLB-stores,iTLB-load-misses,iTLB-loads,node-load-misses,node-loads,node-store-misses,node-stores time -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion/time-GMSC-OzaBagExecutorMAXChunk-25-4-50-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp /home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT/lib/:/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunksOptimized -l (meta.OzaBagExecutorMAXChunk -s 25 -c 4) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/GMSC.arff) -i 100000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d /home/pi/reginaldojunior/experimentos/testes/loop-fusion/dump-GMSC-OzaBagExecutorMAXChunk-25-4-50-1" > /home/pi/reginaldojunior/experimentos/testes/loop-fusion/term-interleaved-GMSC-OzaBagExecutorMAXChunk-25-4-50-1


### AIRLINES
### Execucao sequencial

echo "[airlines] Execução Sequencial, limitado em 100.000 instancias..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

perf stat -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/perf-airlines-OzaBag-25-1-1-1 -e context-switches,cache-misses,cache-references,minor-faults,major-faults,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-store-misses,LLC-stores,branch-load-misses,branch-loads,dTLB-load-misses,dTLB-loads,dTLB-store-misses,dTLB-stores,iTLB-load-misses,iTLB-loads,node-load-misses,node-loads,node-store-misses,node-stores time -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/time-airlines-OzaBag-25-1-1-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp /home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/:/home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/moa.jar moa.DoTask "EITTTExperiments -l (meta.OzaBag -s 25) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff) -i 100000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/dump-airlines-OzaBag-25-1-1-1" > /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/term-interleaved-airlines-OzaBag-25-1-1-1

### Execucao Mini Batching sem Loop Fusion

echo "[airlines] Execução Mini-Batching Sem Loop Fusion, limitado em 100.000 instancias..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/without-loop-fusion
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

perf stat -o /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/perf-airlines-OzaBagExecutorMAXChunk-25-4-50-1 -e context-switches,cache-misses,cache-references,minor-faults,major-faults,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-store-misses,LLC-stores,branch-load-misses,branch-loads,dTLB-load-misses,dTLB-loads,dTLB-store-misses,dTLB-stores,iTLB-load-misses,iTLB-loads,node-load-misses,node-loads,node-store-misses,node-stores time -o /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/time-airlines-OzaBagExecutorMAXChunk-25-4-50-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp /home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/:/home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l (meta.OzaBagExecutorMAXChunk -s 25 -c 4) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff) -i 100000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/dump-airlines-OzaBagExecutorMAXChunk-25-4-50-1" > /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/term-interleaved-airlines-OzaBagExecutorMAXChunk-25-4-50-1

### Execucao Loop Fusion

echo "[airlines] Execução Loop Fusion, limitado em 100.000 instancias..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT/
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/loop-fusion
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

perf stat -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion/perf-airlines-OzaBagExecutorMAXChunk-25-4-50-1 -e context-switches,cache-misses,cache-references,minor-faults,major-faults,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-store-misses,LLC-stores,branch-load-misses,branch-loads,dTLB-load-misses,dTLB-loads,dTLB-store-misses,dTLB-stores,iTLB-load-misses,iTLB-loads,node-load-misses,node-loads,node-store-misses,node-stores time -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion/time-airlines-OzaBagExecutorMAXChunk-25-4-50-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp /home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT/lib/:/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunksOptimized -l (meta.OzaBagExecutorMAXChunk -s 25 -c 4) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/airlines.arff) -i 100000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d /home/pi/reginaldojunior/experimentos/testes/loop-fusion/dump-airlines-OzaBagExecutorMAXChunk-25-4-50-1" > /home/pi/reginaldojunior/experimentos/testes/loop-fusion/term-interleaved-airlines-OzaBagExecutorMAXChunk-25-4-50-1

### ElecNormNew
### Execucao sequencial

echo "[elecNormNew] Execução Sequencial, limitado em 10.000 instancias..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

perf stat -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/perf-elecNormNew-OzaBag-25-1-1-1 -e context-switches,cache-misses,cache-references,minor-faults,major-faults,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-store-misses,LLC-stores,branch-load-misses,branch-loads,dTLB-load-misses,dTLB-loads,dTLB-store-misses,dTLB-stores,iTLB-load-misses,iTLB-loads,node-load-misses,node-loads,node-store-misses,node-stores time -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/time-elecNormNew-OzaBag-25-1-1-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp /home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/:/home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/moa.jar moa.DoTask "EITTTExperiments -l (meta.OzaBag -s 25) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff) -i 10000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/dump-elecNormNew-OzaBag-25-1-1-1" > /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/term-interleaved-elecNormNew-OzaBag-25-1-1-1

### Execucao Mini Batching sem Loop Fusion

echo "[elecNormNew] Execução Mini-Batching Sem Loop Fusion, limitado em 10.000 instancias..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/without-loop-fusion
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

perf stat -o /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/perf-elecNormNew-OzaBagExecutorMAXChunk-25-4-50-1 -e context-switches,cache-misses,cache-references,minor-faults,major-faults,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-store-misses,LLC-stores,branch-load-misses,branch-loads,dTLB-load-misses,dTLB-loads,dTLB-store-misses,dTLB-stores,iTLB-load-misses,iTLB-loads,node-load-misses,node-loads,node-store-misses,node-stores time -o /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/time-elecNormNew-OzaBagExecutorMAXChunk-25-4-50-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp /home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/:/home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l (meta.OzaBagExecutorMAXChunk -s 25 -c 4) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff) -i 10000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/dump-elecNormNew-OzaBagExecutorMAXChunk-25-4-50-1" > /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/term-interleaved-elecNormNew-OzaBagExecutorMAXChunk-25-4-50-1

### Execucao Loop Fusion

echo "[elecNormNew] Execução Loop Fusion, limitado em 10.000 instancias..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT/
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/loop-fusion
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

perf stat -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion/perf-elecNormNew-OzaBagExecutorMAXChunk-25-4-50-1 -e context-switches,cache-misses,cache-references,minor-faults,major-faults,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-store-misses,LLC-stores,branch-load-misses,branch-loads,dTLB-load-misses,dTLB-loads,dTLB-store-misses,dTLB-stores,iTLB-load-misses,iTLB-loads,node-load-misses,node-loads,node-store-misses,node-stores time -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion/time-elecNormNew-OzaBagExecutorMAXChunk-25-4-50-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp /home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT/lib/:/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunksOptimized -l (meta.OzaBagExecutorMAXChunk -s 25 -c 4) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/elecNormNew.arff) -i 10000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d /home/pi/reginaldojunior/experimentos/testes/loop-fusion/dump-elecNormNew-OzaBagExecutorMAXChunk-25-4-50-1" > /home/pi/reginaldojunior/experimentos/testes/loop-fusion/term-interleaved-elecNormNew-OzaBagExecutorMAXChunk-25-4-50-1

### CovTypeNorm
### Execucao sequencial

echo "[covtypeNorm] Execução Sequencial, limitado em 100.000 instancias..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

perf stat -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/perf-covtypeNorm-OzaBag-25-1-1-1 -e context-switches,cache-misses,cache-references,minor-faults,major-faults,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-store-misses,LLC-stores,branch-load-misses,branch-loads,dTLB-load-misses,dTLB-loads,dTLB-store-misses,dTLB-stores,iTLB-load-misses,iTLB-loads,node-load-misses,node-loads,node-store-misses,node-stores time -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/time-covtypeNorm-OzaBag-25-1-1-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp /home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/:/home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/moa.jar moa.DoTask "EITTTExperiments -l (meta.OzaBag -s 25) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff) -i 100000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/dump-covtypeNorm-OzaBag-25-1-1-1" > /home/pi/reginaldojunior/experimentos/testes/loop-fusion-sequential/term-interleaved-covtypeNorm-OzaBag-25-1-1-1

### Execucao Mini Batching sem Loop Fusion

echo "[covtypeNorm] Execução Mini-Batching Sem Loop Fusion, limitado em 100.000 instancias..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-without-loop-fusion
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/without-loop-fusion
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

perf stat -o /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/perf-covtypeNorm-OzaBagExecutorMAXChunk-25-4-50-1 -e context-switches,cache-misses,cache-references,minor-faults,major-faults,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-store-misses,LLC-stores,branch-load-misses,branch-loads,dTLB-load-misses,dTLB-loads,dTLB-store-misses,dTLB-stores,iTLB-load-misses,iTLB-loads,node-load-misses,node-loads,node-store-misses,node-stores time -o /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/time-covtypeNorm-OzaBagExecutorMAXChunk-25-4-50-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp /home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/:/home/pi/reginaldojunior/moa/moa-without-loop-fusion/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunks -l (meta.OzaBagExecutorMAXChunk -s 25 -c 4) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff) -i 100000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/dump-covtypeNorm-OzaBagExecutorMAXChunk-25-4-50-1" > /home/pi/reginaldojunior/experimentos/testes/without-loop-fusion/term-interleaved-covtypeNorm-OzaBagExecutorMAXChunk-25-4-50-1

### Execucao Loop Fusion

echo "[covtypeNorm] Execução Loop Fusion, limitado em 100.000 instancias..."
export MOA_HOME=/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT/
export RESULT_DIR=/home/pi/reginaldojunior/experimentos/testes/loop-fusion
export REMOTE_DIR=/home/pi/reginaldojunior/comparison-xue3m-minibatching

perf stat -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion/perf-covtypeNorm-OzaBagExecutorMAXChunk-25-4-50-1 -e context-switches,cache-misses,cache-references,minor-faults,major-faults,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,LLC-load-misses,LLC-loads,LLC-store-misses,LLC-stores,branch-load-misses,branch-loads,dTLB-load-misses,dTLB-loads,dTLB-store-misses,dTLB-stores,iTLB-load-misses,iTLB-loads,node-load-misses,node-loads,node-store-misses,node-stores time -o /home/pi/reginaldojunior/experimentos/testes/loop-fusion/time-covtypeNorm-OzaBagExecutorMAXChunk-25-4-50-1 -v  java -Xshare:off -XX:+UseParallelGC -Xmx700M -cp /home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT/lib/:/home/pi/reginaldojunior/moa/moa-release-2019.05.1-SNAPSHOT/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrainChunksOptimized -l (meta.OzaBagExecutorMAXChunk -s 25 -c 4) -s (ArffFileStream -f /home/pi/reginaldojunior/comparison-xue3m-minibatching/datasets/covtypeNorm.arff) -i 100000 -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d /home/pi/reginaldojunior/experimentos/testes/loop-fusion/dump-covtypeNorm-OzaBagExecutorMAXChunk-25-4-50-1" > /home/pi/reginaldojunior/experimentos/testes/loop-fusion/term-interleaved-covtypeNorm-OzaBagExecutorMAXChunk-25-4-50-1
