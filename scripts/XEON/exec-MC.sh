#!/bin/bash
if [ "$#" -ne 2 ]; then
	# echo "$# $*"
  echo "Usage: $0 PATH FILE_SUFFIX" >&2
  exit 1
fi
Memory=8144m
declare -a algs=("meta.LBagMC" "meta.OzaBagAdwinMC" "meta.OzaBagMC" "meta.AdaptiveRandomForestMC")
#declare -a algs=("meta.OzaBagAdwinMC")
declare -a ensemble_size=(100 150)
declare -a cores=(1 2 4 8)
declare -a cpus=("" "0" "0,1" "" "0,1,2,3" "" "" "" "0,1,2,3,4,5,6,7")
mkdir /opt/data/MC-results-fifth
export RESULT_DIR=/opt/data/MC-results-fifth
export MOA_HOME=/opt/data/moa-MC-2019.05.1-SNAPSHOT
# ---------------------------------------------------- CODE ----------------------------------------------------
for i in $1*$2
do
  for k in "${ensemble_size[@]}"
  do
    for j in "${algs[@]}"
    do
      for l in "${cores[@]}"
      do
        i2=${i%%.*}
        onlyname=${i2##*\/}
        #echo "Using EvaluatePrequential with alg $j on file ${i##*\/} with ensemble_size $k and $l cores."
        #echo "Saving results in $RESULT_DIR/${i2##*\/}-${j##*.}"
        #/usr/bin/time -o ${RESULT_DIR}/time-Interleaved-${onlyname}-${j##*.}-${k}-${l} java -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar -javaagent:$MOA_HOME/lib/sizeofag-1.0.4.jar moa.DoTask "EvaluatePrequential -l ($j -s $k -c $l) -s (ArffFileStream -f $i) -e (WindowClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${j##*.}-${k}-${l} -o $RESULT_DIR/pred-${onlyname}-${j##*.}-${k}-${l} -O $RESULT_DIR/taskres-${onlyname}-${j##*.}-${k}-${l}" > "${RESULT_DIR}/term-${onlyname}-${j##*.}-${k}-${l}"
        #echo ""
        echo "Using EvaluateInterleavedTestThenTrain with alg $j on file ${i##*\/} with ensemble_size $k and $l cores."
        echo "Saving results in $RESULT_DIR/${i2##*\/}-${j##*.}"
        /opt/data/time-1.9/time -o ${RESULT_DIR}/time-Interleaved-${onlyname}-${j##*.}-${k}-${l} numactl --physcpubind=${cpus[l]} java -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar moa.DoTask "EvaluateInterleavedTestThenTrain -l ($j -s $k -c $l) -s (ArffFileStream -f $i) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -i -1 -d $RESULT_DIR/dump-${onlyname}-${j##*.}-${k}-${l}" > ${RESULT_DIR}/term-Interleaved-${onlyname}-${j##*.}-${k}-${l}
        echo ""
      done
    done
  done
done

#Classification example java -cp lib/:lib/moa.jar -javaagent:lib/sizeofag-1.0.4.jar moa.DoTask "EvaluatePrequentiall functions.MajorityClass -s (ArffFileStream -f /home/cassales/Documents/bases/CTU-13-Dataset/arffFiles/scen7-numeric.arff) -e (BasicClassificationPerformanceEvaluator -o -p -r -f)"
#Outlier/Clustering example java -Xmx6144m -cp $MOA_HOME/lib/:/home/cassales/Documents/moa-release-2019.05.0/lib/moa.jar -javaagent:/home/cassales/Documents/moa-release-2019.05.0/lib/sizeofag-1.0.4.jar moa.DoTask "EvaluateClustering -l outliers.MCOD.MCOD -s (FileStream -f /home/cassales/Documents/bases/Kyoto/kyoto_multiclasse_binarized_2class_full.arff) -i -1 -g -f -e -c -t -d (/home/cassales/Documents/bases/Kyoto/outlier-results/dumpAbstractC.csv)" > /home/cassales/Documents/bases/Kyoto/outlier-results/kyoto_multiclasse_binarized_2class_full-MCOD
#./parse-outlier-results.sh $1
