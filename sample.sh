#!/bin/bash 

. env.sh
. set_tracing_environment.sh

echo "###########################################################"
echo "############### STARTING HADOOP CLUSTER ###################"
echo "###########################################################"

$HADOOP_PREFIX/bin/stop-all.sh
rm -rf /tmp/hadoop/*
rm -rf $HADOOP_PREFIX/logs/*

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
