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

<<<<<<< HEAD
$JOBS_PREFIX/sort.sh
=======
$JOBS_PREFIX/terasort.sh
>>>>>>> 0c7ab13ea9c5cf9731648892fc926f321e900300

echo "###########################################################"
echo "############### STOPPING HADOOP CLUSTER ###################"
echo "###########################################################"

$HADOOP_PREFIX/sbin/stop-dfs.sh
$HADOOP_PREFIX/sbin/stop-yarn.sh