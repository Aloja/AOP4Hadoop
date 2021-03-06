HADOOP_EXECUTABLE="$HADOOP_PREFIX/bin/hadoop"
HADOOP_EXAMPLES_JAR="$HADOOP_PREFIX/hadoop-examples-1.0.3.jar"

DATA_HDFS=/HiBench
INPUT_HDFS=${DATA_HDFS}/Terasort/Input
OUTPUT_HDFS=${DATA_HDFS}/Terasort/Output

CONFIG_MAP_NUMBER=mapred.map.tasks
CONFIG_REDUCER_NUMBER=mapred.reduce.tasks

# for prepare (total) - 200MB
# DATASIZE specifies the number of blocks of 100 bytes each
<<<<<<< HEAD
DATASIZE=2000000
=======
DATASIZE=20000000
>>>>>>> e5081ce4aced29e72b8b4bacf2909200d9f8e01e
NUM_MAPS=5
# for running (total)
NUM_REDS=5

$HADOOP_EXECUTABLE jar $HADOOP_EXAMPLES_JAR teragen \
    -D $CONFIG_MAP_NUMBER=$NUM_MAPS \
    $DATASIZE $INPUT_HDFS

sleep 5

<<<<<<< HEAD
$HADOOP_EXECUTABLE jar $HADOOP_EXAMPLES_JAR terasort -D $CONFIG_REDUCER_NUMBER=$NUM_REDS $INPUT_HDFS $OUTPUT_HDFS
=======
$HADOOP_EXECUTABLE jar $HADOOP_EXAMPLES_JAR terasort -D $CONFIG_REDUCER_NUMBER=$NUM_REDS $INPUT_HDFS $OUTPUT_HDFS
>>>>>>> e5081ce4aced29e72b8b4bacf2909200d9f8e01e
