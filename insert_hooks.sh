#!/bin/bash 

echo "###########################################################"
echo "################# SETTING UP VARIABLES ####################"
echo "###########################################################"

. local_environment.sh

mkdir -p $RELEASE_PATH
mkdir -p $INSTRUMENTATION_PATH
echo $INSTRUMENTATION_PATH > /dev/shm/last_execution
echo `pwd` > /dev/shm/pwd_path

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

echo "date,event moment,event,PID,Hostname,Extra data" > $INSTRUMENTATION_PATH/log.csv

ajc -1.5 -showWeaveInfo -classpath ${CLASSPATH} -inpath ${HADOOP_CORE_FILE_PATH} $SOURCE_AJC/Aspectj.aj -outjar $PATCHED_HADOOP_CORE_FILE > $INSTRUMENTATION_PATH/detectedPointCuts.txt


echo "###########################################################"
echo "################# DONE ####################################"
echo "###########################################################"
