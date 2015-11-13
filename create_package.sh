#!/bin/bash 

. insert_hooks.sh 

rm -r $PACKAGE_PREFIX/*

mkdir $PACKAGE_PREFIX/AOP4Hadoop

cp $RELEASE_PATH/hadoop-yarn-client-2.7.1.jar $PACKAGE_PREFIX/AOP4Hadoop/AOP4Hadoop-hadoop-yarn-client-2.7.1.jar
cp $RELEASE_PATH/hadoop-mapreduce-client-core-2.7.1.jar $PACKAGE_PREFIX/AOP4Hadoop/AOP4Hadoop-hadoop-mapreduce-client-core-2.7.1.jar
cp $RELEASE_PATH/hadoop-hdfs-2.7.1.jar $PACKAGE_PREFIX/AOP4Hadoop/AOP4Hadoop-hadoop-hdfs-2.7.1.jar
#cp $RELEASE_PATH/hadoop-common-2.7.1.jar $PACKAGE_PREFIX/AOP4Hadoop/AOP4Hadoop-hadoop-common-2.7.1.jar
cp $LIB_PREFIX/*.jar $PACKAGE_PREFIX/AOP4Hadoop/

cd $PACKAGE_PREFIX

tar -czf AOP4Hadoop.tar.gz AOP4Hadoop

cp AOP4Hadoop.tar.gz /home/alejandro/Documents/AOP4Hadoop/aloja/aloja/blobs/aplic2/tarballs/ 

#scp -P 22122 -i /home/alejandro/Documents/AOP4Hadoop/aloja/aloja/secure/id_rsa $PACKAGE_PREFIX/AOP4Hadoop.tar.gz pristine@aloja.bsc.es:/scratch/attached/1/public/aplic2/tarballs/AOP4Hadoop.tar.gz
