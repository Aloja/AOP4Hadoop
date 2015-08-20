#!/bin/bash 

. local_environment.sh

mkdir -p $RELEASE_PATH

#REPLACE WITH AJC CODE
cp $HADOOP_CORE_FILE_PATH $PATCHED_HADOOP_CORE_FILE
