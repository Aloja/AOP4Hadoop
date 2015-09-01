#!/bin/bash 

echo "###########################################################"
echo "################# SETTING UP VARIABLES ####################"
echo "###########################################################"

. user-provided-env.sh
. local_environment.sh

mkdir -p $RELEASE_PATH
mkdir -p $INSTRUMENTATION_PATH

#REPLACE WITH AJC CODE

echo "###########################################################"
echo "################# WEAVING NEW HADOOP CORE #################"
echo "###########################################################"

echo ""

echo "###########################################################"
echo "################# SETTING CLASSPATH #######################"
echo "###########################################################"

for i in `ls ${HADOOP_PREFIX}/lib/*.jar `
do
	export CLASSPATH=$CLASSPATH:"${i}"
done

for i in `ls ${HADOOP_PREFIX}/lib/jsp-2.1/*.jar `
do
	export CLASSPATH=$CLASSPATH:"${i}"
done


echo "###########################################################"
echo "################# WEAVING HADOOP CORE #####################"
echo "###########################################################"

echo "date,event moment,event,PID,Hostname" >> $INSTRUMENTATION_PATH/log.csv

ajc -1.5 -classpath ${CLASSPATH} -inpath ${HADOOP_CORE_FILE_PATH} $SOURCE_AJC/Aspectj.aj -outjar $PATCHED_HADOOP_CORE_FILE >> $INSTRUMENTATION_PATH/detectedPointCuts.txt


cp $HADOOP_CORE_FILE_PATH $PATCHED_HADOOP_CORE_FILE 


echo "###########################################################"
echo "################# DONE ####################################"
echo "###########################################################"


echo "###########################################################"
echo "############### STARTING HADOOP CLUSTER ###################"
echo "###########################################################"

$HADOOP_PREFIX/bin/hadoop namenode -format
$HADOOP_PREFIX/bin/start-all.sh

echo "###########################################################"
echo "###################### EXECUTING JOB ######################"
echo "###########################################################"

$JOBS_PREFIX/terasort.sh

echo "###########################################################"
echo "############### STOPPING HADOOP CLUSTER ###################"
echo "###########################################################"

$HADOOP_PREFIX/bin/stop-all.sh
