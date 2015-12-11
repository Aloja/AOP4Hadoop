#!/bin/bash 

if [ -z "$ROOT" ]
then
    ROOT=$(while ! test -e README.md; do cd ..; done; pwd)
    export ROOT
fi



#Where is your binary Hadoop distribution located?
export HADOOP_PREFIX=$ROOT/dist/hadoop-1.0.3

#What is the version of the Hadoop distribution that you are using?
export HADOOP_VERSION=1.0.3

#Where is JAVA located?
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre





export PATH=$ROOT/bin:$PATH

if [ "$JAVA_HOME" = "" ] ; then echo JAVA_HOME needs to be defined; return;
fi

if [ "$HADOOP_VERSION" = "" ] ; then echo HADOOP_VERSION needs to be defined; return;
fi

if [ "$HADOOP_PREFIX" = "" ] ; then echo HADOOP_PREFIX needs to be defined; return;
fi
