#!/bin/bash
if [ "$#" -ne 2 ]; then
	# echo "$# $*"
  echo "Usage: $0 PATH FILE_SUFFIX" >&2
  exit 1
fi
Memory=61440m
#------------------- CLASSIFIERS -------------------
#EvaluatePrequential -l functions.MajorityClass
#EvaluatePrequential -l functions.NoChange
#EvaluatePrequential -l bayes.NaiveBayes
#EvaluatePrequential -l lazy.kNN
#EvaluatePrequential -l trees.HoeffdingTree
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
#------- classification methods -------
declare -a algs=("functions.MajorityClass" "functions.NoChange" "bayes.NaiveBayes" "lazy.kNN" "trees.HoeffdingTree")
#declare -a algs=("bayes.NaiveBayes" "lazy.kNN" "trees.HoeffdingTree")
#declare -a algs=("lazy.kNN")
#------- outlier detection methods -------
# declare -a algs=("functions.MajorityClass" "functions.NoChange" "bayes.NaiveBayes" "lazy.kNN" "trees.EFDT")


MOA_HOME=/home/gcassale/moa-release-2019.05.0/
mkdir /home/gcassale/results/
# ---------------------------------------------------- CODE ----------------------------------------------------
for i in $1*$2
# for i in *-numeric.arff
do
	for j in "${algs[@]}"
	do
		i2=${i%%.*}
		echo ""
		echo "using alg $j on file ${i##*\/} and putting results in /home/gcassale/results/${i2##*\/}-${j##*.} file"
			# -e (BasicClassificationPerformanceEvaluator -o -p -r -f)\" > ./results/${##*\/i%%.*}-${j##*.}"
		java -XX:-UseGCOverheadLimit -Xmx$Memory -cp $MOA_HOME/lib/:$MOA_HOME/lib/moa.jar -javaagent:$MOA_HOME/lib/sizeofag-1.0.4.jar moa.DoTask "EvaluatePrequential -l $j -s (ArffFileStream -f $i) -e (BasicClassificationPerformanceEvaluator -o -p -r -f) -o /home/gcassale/results/PRED-${i2##*\/}-${j##*.}" > /home/gcassale/results/${i2##*\/}-${j##*.}
		#i is remove suffix starting with the first dot. j is remove prefix through the last dot
	done
done

#java -cp lib/:lib/moa.jar -javaagent:lib/sizeofag-1.0.4.jar moa.DoTask "EvaluatePrequentiall functions.MajorityClass -s (ArffFileStream -f /home/cassales/Documents/bases/CTU-13-Dataset/arffFiles/scen7-numeric.arff) -e (BasicClassificationPerformanceEvaluator -o -p -r -f)"
#./parse-results.sh /home/gcassale/
