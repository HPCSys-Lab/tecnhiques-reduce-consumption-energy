#!/bin/bash
if [ "$#" -ne 2 ]; then
	# echo "$# $*"
  echo "Usage: $0 PATH FILE_SUFFIX" >&2
  exit 1
fi
Memory=12288m
#------------------- CLASSIFIERS -------------------
#EvaluatePrequential -l functions.MajorityClass
#EvaluatePrequential -l functions.NoChange
#EvaluatePrequential -l bayes.NaiveBayes
#EvaluatePrequential -l lazy.kNN
#EvaluatePrequential -l trees.EFDT
#EvaluatePrequential -l trees.HoeffdingTree
#------------------- OUTLIERS -------------------
#EvaluateClustering -l functions.MajorityClass
#EvaluateClustering -l functions.NoChange
#EvaluateClustering -l bayes.NaiveBayes
#EvaluateClustering -l lazy.kNN
#EvaluateClustering -l trees.EFDT
#------------------- EXEMPLES -------------------
# -s (ArffFileStream -f /home/cassales/Documents/bases/CTU-13-Dataset/arffFiles/scen7-numeric.arff)
# -e (BasicClassificationPerformanceEvaluator -o -p -r -f)

# use for loop to read all values and indexes
# ----- for loop using proper names
#for i in "${arrayName[@]}"
# ----- for loop using indexes
# get length of an array
#arraylength=${#algs[@]}
#for (( i=1; i<${arraylength}+1; i++ ));

#count=0
#count=$(( count + 1 ))

#getting the average of column 2 using awk
#awk '{ total += $2 } END { print total/NR }' yourFile.whatever

#------------------- VARIABLES -------------------
## declare an array variable
#------- outlier detection methods -------
declare -a algs=("outliers.Angiulli.ApproxSTORM" "outliers.AnyOut.AnyOut" "outliers.MCOD.MCOD")
#"outliers.AbstractC.AbstractC" )

# mkdir /home/cassales/Documents/bases/$1outlier-results
MOA_HOME=/home/gcassale/moa-release-2019.05.1-SNAPSHOT/
mkdir /home/gcassale/outlier-results/
# ---------------------------------------------------- CODE ----------------------------------------------------
for i in $1*$2
do
  for j in "${algs[@]}"
  do
    i2=${i%%.*}
    onlyname=${i2##*\/}
    echo ""
    echo "using alg $j on file ${i##*\/} and putting results in /home/gcassale/outlier-results/${i2##*\/}-${j##*.}"

    java -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar -javaagent:$MOA_HOME/lib/sizeofag-1.0.4.jar moa.DoTask "EvaluateClustering -l $j -s (FileStream -f $i) -i -1 -g -f -e -c -t -d (/home/gcassale/outlier-results/dump${i2##*\/}-${j##*.}.csv)" > /home/gcassale/outlier-results/${i2##*\/}-${j##*.}_TERM
# > /home/cassales/Documents/bases/$1outlier-results/${i2##*\/}-${j##*.}


    # java -Xmx$Memory -cp $MOA_HOME/lib/:/home/cassales/Documents/moa-release-2019.05.0/lib/moa.jar \
    #   -javaagent:/home/cassales/Documents/moa-release-2019.05.0/lib/sizeofag-1.0.4.jar moa.DoTask \
    #   "EvaluateClustering -l $j -s (FileStream -f /home/cassales/Documents/bases/$i)
    #   -i 1000 -g -f -e -c -t
    #   -d (/home/cassales/Documents/bases/$1outlier-results/dump${i2##*\/}-${j##*.}.csv)"
    #         > /home/cassales/Documents/bases/$1outlier-results/${i2##*\/}-${j##*.}
  done
done

#Classification example java -cp lib/:lib/moa.jar -javaagent:lib/sizeofag-1.0.4.jar moa.DoTask "EvaluatePrequentiall functions.MajorityClass -s (ArffFileStream -f /home/cassales/Documents/bases/CTU-13-Dataset/arffFiles/scen7-numeric.arff) -e (BasicClassificationPerformanceEvaluator -o -p -r -f)"
#Outlier/Clustering example java -Xmx6144m -cp $MOA_HOME/lib/:/home/cassales/Documents/moa-release-2019.05.0/lib/moa.jar -javaagent:/home/cassales/Documents/moa-release-2019.05.0/lib/sizeofag-1.0.4.jar moa.DoTask "EvaluateClustering -l outliers.MCOD.MCOD -s (FileStream -f /home/cassales/Documents/bases/Kyoto/kyoto_multiclasse_binarized_2class_full.arff) -i -1 -g -f -e -c -t -d (/home/cassales/Documents/bases/Kyoto/outlier-results/dumpAbstractC.csv)" > /home/cassales/Documents/bases/Kyoto/outlier-results/kyoto_multiclasse_binarized_2class_full-MCOD
#./parse-outlier-results.sh $1
