#!/bin/bash 

. local_environment.sh
. set_tracing_environment.sh

echo "###########################################################"
echo "############### STARTING HADOOP CLUSTER ###################"
echo "###########################################################"

$HADOOP_PREFIX/sbin/stop-dfs.sh
$HADOOP_PREFIX/sbin/stop-yarn.sh
rm -rf /tmp/hadoop/*
rm -rf $HADOOP_PREFIX/logs/*

$HADOOP_PREFIX/bin/hdfs namenode -format
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh
$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver

echo "###########################################################"
echo "###################### EXECUTING JOB ######################"
echo "###########################################################"

$JOBS_PREFIX/terasort.sh

echo "###########################################################"
echo "############### STOPPING HADOOP CLUSTER ###################"
echo "###########################################################"

$HADOOP_PREFIX/sbin/stop-dfs.sh
$HADOOP_PREFIX/sbin/stop-yarn.sh