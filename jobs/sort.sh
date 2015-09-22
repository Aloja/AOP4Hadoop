HADOOP_EXECUTABLE="$HADOOP_PREFIX/bin/hadoop"
<<<<<<< HEAD
HADOOP_EXAMPLES_JAR="$HADOOP_PREFIX/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar"
=======
HADOOP_EXAMPLES_JAR="$HADOOP_PREFIX/hadoop-examples-1.0.3.jar"
>>>>>>> 0c7ab13ea9c5cf9731648892fc926f321e900300

DATA_HDFS=/HiBench
INPUT_HDFS=${DATA_HDFS}/Sort/Input
OUTPUT_HDFS=${DATA_HDFS}/Sort/Output

# sort 400MB total
# for prepare (per node) - 200MB/node
<<<<<<< HEAD
DATASIZE=2000000000
=======
DATASIZE=200000000
>>>>>>> 0c7ab13ea9c5cf9731648892fc926f321e900300
NUM_MAPS=2
# for running (in total)
NUM_REDS=4

$HADOOP_EXECUTABLE jar $HADOOP_EXAMPLES_JAR randomtextwriter \
-D test.randomtextwrite.bytes_per_map=$((${DATASIZE} / ${NUM_MAPS})) \
-D test.randomtextwrite.maps_per_host=${NUM_MAPS} \
$INPUT_HDFS

sleep 5

$HADOOP_EXECUTABLE jar $HADOOP_EXAMPLES_JAR sort \
-outKey org.apache.hadoop.io.Text \
-outValue org.apache.hadoop.io.Text \
-r ${NUM_REDS} \
$INPUT_HDFS $OUTPUT_HDFS