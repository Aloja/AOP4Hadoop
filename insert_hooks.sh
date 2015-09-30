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

for i in `ls ${AOP_PREFIX}/lib/*.jar `
do
	export CLASSPATH=$CLASSPATH:"${i}"
done

for i in `ls ${HADOOP_PREFIX}/share/hadoop/common/lib/*.jar `
do
	export CLASSPATH=$CLASSPATH:"${i}"
done

for i in `ls ${JAR_PREFIX}/common/*.jar `
do
	export CLASSPATH=$CLASSPATH:"${i}"
done


echo "###########################################################"
echo "################# WEAVING HADOOP  #########################"
echo "###########################################################"

#echo "date,event moment,event,PID,Hostname,Extra data" > $INSTRUMENTATION_PATH/log.csv


# echo "################# WEAVING CORE ##########################"


# ajc -showWeaveInfo -classpath ${CLASSPATH} -inpath ${HADOOP_CORE_FILE_PATH} $SOURCE_AJC/Aspect-2.0.6.aj -outjar $PATCHED_HADOOP_CORE_FILE > $INSTRUMENTATION_PATH/detectedPointCuts.txt

echo "################# WEAVING MAPRED ##########################"

#ajc -showWeaveInfo -classpath ${CLASSPATH} -inpath ${HADOOP_MAPRED_FILE_PATH} $SOURCE_AJC/Aspect-2.6.0-mapred.aj -outjar $PATCHED_HADOOP_MAPRED_FILE > $INSTRUMENTATION_PATH/detectedPointCuts.txt

echo "################# WEAVING HDFS ##########################"
echo $CLASSPATH

ajc -1.6 -showWeaveInfo -classpath ${CLASSPATH} -inpath ${HADOOP_HDFS_FILE_PATH} $SOURCE_AJC/Aspect-2.6.0-hdfs.aj -outjar $PATCHED_HADOOP_HDFS_FILE >> $INSTRUMENTATION_PATH/detectedPointCuts.txt

echo "###########################################################"
echo "################# WEAVING COMPLETE ########################"
echo "###########################################################"
