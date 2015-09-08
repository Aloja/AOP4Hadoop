import java.io.*;
import java.util.*;
import java.lang.management.ManagementFactory;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.net.InetAddress;
import java.lang.ClassLoader;
import org.apache.hadoop.io.DataInputBuffer;


import org.apache.hadoop.conf.Configuration;

/**
 *
 * @author Alejandro
 */

aspect Aspect {		

	/*
	FUNCTIONS
	######################################################################################################################################
	######################################################################################################################################
	*/
	
	private static long getPID() {
		String name = java.lang.management.ManagementFactory.getRuntimeMXBean().getName();
		return Long.parseLong(name.split("@")[0]);
	}

	private File getFile() {
		try {
			File file = new File("/dev/shm/last_execution");
			BufferedReader br = new BufferedReader(new FileReader(file));
			String logPath = br.readLine();
			File log = new File(logPath + "/log.csv");
			return log;
		}
		catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}

	private void writeLog(File logFile, String log) {

		try {
			FileWriter fw = new FileWriter(logFile.getAbsoluteFile(),true);
			BufferedWriter bw = new BufferedWriter(fw);
			bw.write(log);
			bw.close();
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}

	private void instrumentation(File logFile, String event, String when) {
		try {

			String log = "\n";
			//Create TimeStamp
			java.util.Date date = new java.util.Date();
			Calendar calendar = Calendar.getInstance();
			calendar.setTime(date);
			log += calendar.getTimeInMillis();
			//Specify event
			log += "," + when + "," + event;
			//Add PID 
			log += "," + getPID();
			//Add hostname
			log += "," + InetAddress.getLocalHost().getHostName();
			writeLog(logFile,log);

		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}


	/*
	POINTCUTS
	######################################################################################################################################
	######################################################################################################################################
	*/

	//RegisterDataNode Pointcut

	pointcut startDataNode(): execution(* org.apache.hadoop.hdfs.server.datanode.DataNode.startDataNode(..));

	//RegisterNameNode Pointcut

	pointcut initializeNameNode():  execution(* org.apache.hadoop.hdfs.server.namenode.NameNode.initialize(..));

	//RegisterSecondaryNamenode Pointcut

	pointcut initializeSecondaryNameNode(): execution(* org.apache.hadoop.hdfs.server.namenode.SecondaryNameNode.initialize(..));

	//RegisterTask - CHILD

	//pointcut initializeChild(): call(* org.apache.hadoop.mapred.Child.initMetrics(..)) && withincode(* org.apache.hadoop.mapred.Child.main(..)); 

	pointcut initializeChild(): execution(* org.apache.hadoop.mapred.Child.main(..)); 

	//Register JobTracker Pointcut

	pointcut registerJobTracker(): execution(* org.apache.hadoop.mapred.JobTracker.startTracker(..));

	//HEARTBEAT

	pointcut heartbeat(): execution(* org.apache.hadoop.mapred.JobTracker.heartbeat(..));

	/*
		###########################################################################
		############################MAPPER#########################################
		###########################################################################
	*/

	pointcut mapper(): execution(* org.apache.hadoop.mapred.MapTask.run(..));
	pointcut flush(): execution(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.flush());


	//  ############################SORT AND SPILL#################################

	//Start-End
	pointcut taskSortAndSpill(): execution(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill());

	//Spill File Size
	pointcut sortAndSpillSpillFile(int numSpills, long size) : call (* *.getSpillFileForWrite(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill()) && args(numSpills, size);

	//SpillIndex File Size
	pointcut sortAndSpillSpillIndexFile(int numSpills, long partitions) : call (* *.getSpillIndexFileForWrite(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill()) && args(numSpills, partitions);

	//Sort 
	pointcut sortAndSpillSort(int kvstart, int endPosition, Object reporter): call(* *.sort(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill()) && args(..,kvstart,endPosition,reporter);

	//Init Writer
	pointcut sortAndSpillInitWriter() : call (org.apache.hadoop.mapred.IFile.Writer.new(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill());

	//Close Writer
	pointcut sortAndSpillCloseWriter() : call (void org.apache.hadoop.mapred.IFile.Writer.close(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill());

	//Write key-value

	//pointcut sortAndSpillWrite(DataInputBuffer key, DataInputBuffer value): call (* *.append(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill()) && args(key,value) && !within(Aspect);
	
	//Combiner
	pointcut sortAndSpillCombiner(): call(* *.combine(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill());

	//Spill Index File
	pointcut sortAndSpillSpillIndexWrite(): call(* *.writeToFile(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill());

	/*
		###########################################################################
		############################REDUCER########################################
		###########################################################################
	*/

	//REDUCETASK RUN

	pointcut reducer(): execution(* org.apache.hadoop.mapred.ReduceTask.run(..));
	pointcut initCopy(): call(* *.initCodec(..)) && withincode(* org.apache.hadoop.mapred.ReduceTask.run(..));
	pointcut endCopy(): call(* *.getRaw(..)) && withincode(* org.apache.hadoop.mapred.ReduceTask.run(..));
	pointcut endSort(): call(* *.getMapOutputKeyClass(..)) && withincode(* org.apache.hadoop.mapred.ReduceTask.run(..));
	/*
	Advices
	######################################################################################################################################
	######################################################################################################################################
	*/

	//RegisterDataNode 

	after() : startDataNode(){
		String s = "RegisterDataNode";
		instrumentation(getFile(),s,"after");
	}
	before() : startDataNode(){
		String s = "RegisterDataNode";
		instrumentation(getFile(),s,"before");
	}

	//RegisterNameNode

	after() : initializeNameNode(){
		String s = "RegisterNameNode";
		instrumentation(getFile(),s,"after");
	}

	before() : initializeNameNode(){
		String s = "RegisterNameNode";
		instrumentation(getFile(),s,"before");
	}

	//RegisterSecondaryNamenode

	after() : initializeSecondaryNameNode(){
		String s = "RegisterSecondaryNameNode";
		instrumentation(getFile(),s,"after");
	}

	before() : initializeSecondaryNameNode(){
		String s = "RegisterSecondaryNameNode";
		instrumentation(getFile(),s,"before");
	}

	//RegisterTask CHILD
 
	after() : initializeChild() {
		String s = "GeneralTask";
		instrumentation(getFile(),s,"after");
	}
	
	before() : initializeChild() {
		String s = "GeneralTask";
		instrumentation(getFile(),s,"before");
	}

	// RegiterJobTracker
	before() : registerJobTracker(){
		String s = "registerJobTracker";
		instrumentation(getFile(),s,"before");
	}

	after() : registerJobTracker(){
		String s = "registerJobTracker";
		instrumentation(getFile(),s,"after");
	}

	//HEARTBEAT 
	after() : heartbeat(){
		String s = "Heartbeat";
		instrumentation(getFile(),s,"after");
	}
/*
	before() : heartbeat(){
		String s = "Heartbeat";
		instrumentation(getFile(),s,"before");
	}
*/	
	//TASK RUN

	before() : mapper(){
		String s = "Mapper";
		instrumentation(getFile(),s,"before");
	}

	after() : mapper(){
		String s = "Mapper";
		instrumentation(getFile(),s,"after");
	}

	//flush

	before() : flush(){
		String s = "Flush";
		instrumentation(getFile(),s,"before");
	}


	after() : flush(){
		String s = "Flush";
		instrumentation(getFile(),s,"after");
	}

	/*
		###########################################################################
		############################SORT AND SPILL#################################
		###########################################################################
	*/

	before() : taskSortAndSpill(){
		String s = "sortAndSpill";
		instrumentation(getFile(),s,"before");
	}

	after() : taskSortAndSpill(){
		String s = "sortAndSpill";
		instrumentation(getFile(),s,"after");
	}

	// Spill File Size

	after(int numSpills, long size) returning : sortAndSpillSpillFile(numSpills, size){
		String s = "sortAndSpillSpillFile";
		File logFile = getFile();
		instrumentation(logFile,s,"after");
		String log = ", numSpills: " +Integer.toString(numSpills) + ", size: " + Long.toString(size);
		writeLog(logFile,log);
	}

	// SpillIndex File Size

	after(int numSpills, long partitions) returning : sortAndSpillSpillIndexFile(numSpills, partitions){
		String s = "sortAndSpillSpillIndexFile";
		File logFile = getFile();
		instrumentation(logFile,s,"after");
		String log = "," + Long.toString(numSpills * partitions);
		writeLog(logFile,log);
	}

/*
	before(int length) : kvbufferState(length){

		String s = "kvbufferState";
		File logFile = getFile();
		instrumentation(logFile,s,"before");
		writeLog(logFile,Integer.toString(length));
	}

*/

	before(int kvstart, int endPosition, Object reporter) : sortAndSpillSort(kvstart,endPosition,reporter){
		String s = "sortAndSpillSort";
		File logFile = getFile();
		instrumentation(logFile,s,"before");
		String log = "," + Integer.toString(endPosition - kvstart);
		writeLog(logFile,log);
	}
	after(int kvstart, int endPosition, Object reporter) returning : sortAndSpillSort(kvstart,endPosition,reporter){
		String s = "sortAndSpillSort";
		File logFile = getFile();
		instrumentation(logFile,s,"after");
		String log = "," + Integer.toString(endPosition - kvstart);
		writeLog(logFile,log);
	}

	// Init writer
	after() returning : sortAndSpillInitWriter(){
		String s = "sortAndSpillInitWriter";
		instrumentation(getFile(),s,"after");
	}

	// Close writer
	after() returning : sortAndSpillCloseWriter(){
		String s = "sortAndSpillCloseWriter";
		instrumentation(getFile(),s,"after");
	}

/*
	after(DataInputBuffer key, DataInputBuffer value) returning : sortAndSpillWrite(key,value){
		String s = "sortAndSpillWrite";
		File logFile = getFile();
		instrumentation(logFile,s,"after");
		String log = "," + key.getData(); // + "," + value.getData();
		writeLog(logFile,log);
	}
*/
	before() : sortAndSpillCombiner(){
		String s = "sortAndSpillCombiner";
		instrumentation(getFile(),s,"before");
	}

	after() returning : sortAndSpillCombiner(){
		String s = "sortAndSpillCombiner";
		instrumentation(getFile(),s,"after");
	}

	before() : sortAndSpillSpillIndexWrite(){
		String s = "sortAndSpillSpillIndexWrite";
		instrumentation(getFile(),s,"before");
	}

	after() returning : sortAndSpillSpillIndexWrite(){
		String s = "sortAndSpillSpillIndexWrite";
		instrumentation(getFile(),s,"after");
	}

	/*
		###########################################################################
		############################REDUCER########################################
		###########################################################################
	*/

	before() : reducer(){
		String s = "Reducer";
		instrumentation(getFile(),s,"before");
	}

	after() : reducer(){
		String s = "Reducer";
		instrumentation(getFile(),s,"after");
	}

	after() returning : initCopy() {
		String s = "Reducer-copy-phase";
		instrumentation(getFile(),s,"before");
	}

	before() : endCopy() {
		String s = "Reducer-copy-phase";
		instrumentation(getFile(),s,"after");
	}

	after() returning : endCopy() {
		String s = "Reducer-sort-phase";
		instrumentation(getFile(),s,"before");
	}

	before() : endSort() {
		String s = "Reducer-sort-phase";
		instrumentation(getFile(),s,"after");
	}
}




