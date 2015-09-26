#!/bin/bash 

#echo "###########################################################"
#echo "################# SETTING UP VARIABLES ####################"
#echo "###########################################################"


echo Weaving environment...

. variables.sh

mkdir -p $RELEASE_PATH
mkdir -p $INSTRUMENTATION_PATH
#echo $INSTRUMENTATION_PATH > /dev/shm/last_execution
#echo `pwd` > /dev/shm/pwd_path

#echo "###########################################################"
#echo "################# SETTING CLASSPATH #######################"
#echo "###########################################################"


for i in `ls ${HADOOP_PREFIX}/lib/*.jar `
do
	export CLASSPATH=$CLASSPATH:"${i}"
done

for i in `ls ${HADOOP_PREFIX}/lib/jsp-2.1/*.jar `
do
	export CLASSPATH=$CLASSPATH:"${i}"
done


export CLASSPATH=$ROOT/lib/aspectjrt-1.8.7.jar:$ROOT/lib/aspectjtools-1.8.7.jar:$ROOT/lib/ant-1.9.6.jar:$CLASSPATH

#echo "###########################################################"
#echo "################# WEAVING HADOOP CORE #####################"
#echo "###########################################################"

echo Weaving Hadoop Code...

echo "date,event moment,event,PID,Hostname,Extra data" > $INSTRUMENTATION_PATH/log.csv

ajc -1.8 -showWeaveInfo -classpath ${CLASSPATH} -inpath ${HADOOP_CORE_FILE_PATH} $SOURCE_AJC/Aspectj.aj -outjar $PATCHED_HADOOP_CORE_FILE > $INSTRUMENTATION_PATH/detectedPointCuts.txt

echo " Output file can be found at: "$PATCHED_HADOOP_CORE_FILE

echo Done.

