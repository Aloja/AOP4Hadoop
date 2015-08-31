#!/bin/bash 

echo ""
echo HADOOP FOLDER: $HADOOP_PREFIX
echo HADOOP VERSION: $HADOOP_VERSION
ENVIRONMENTS_PREFIX=`pwd`/environments
JOBS_PREFIX=`pwd`/jobs
HADOOP_CORE_FILE_PATH=`ls $HADOOP_PREFIX/*.jar | grep core`
HADOOP_CORE_FILE=$(basename $HADOOP_CORE_FILE_PATH)
RELEASE=`md5sum $HADOOP_CORE_FILE_PATH | cut -d " " -f 1`
RELEASE_PATH=$ENVIRONMENTS_PREFIX/$RELEASE
INSTRUMENTATION_PATH=$RELEASE_PATH/instrumentation
PATCHED_HADOOP_CORE_FILE=$RELEASE_PATH/$HADOOP_CORE_FILE

SOURCE_AJC=/`pwd`/src/$HADOOP_VERSION
echo SOURCE_AJC:$SOURCE_AJC

#echo $INSTRUMENTATION_PATH >> $SOURCE_AJC/release.txt

echo RELEASE: $RELEASE

echo ""
