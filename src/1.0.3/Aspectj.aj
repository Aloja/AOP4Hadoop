import java.io.*;
import java.util.*;
import java.lang.management.ManagementFactory;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.net.InetAddress;
import java.lang.ClassLoader;
import org.apache.hadoop.io.DataInputBuffer;
import org.apache.hadoop.mapred.TaskStatus;
import org.apache.hadoop.fs.permission.FsPermission;
import org.apache.hadoop.util.Progressable;
import org.apache.hadoop.hdfs.protocol.DatanodeInfo;
import org.apache.hadoop.util.DataChecksum;
import java.net.Socket;


import org.apache.hadoop.security.token.Token;
import org.apache.hadoop.security.token.TokenIdentifier;
import org.apache.hadoop.hdfs.security.token.block.BlockTokenIdentifier;


import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.hdfs.DFSClient;

import org.apache.hadoop.mapred.TaskTrackerStatus;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


import org.apache.hadoop.conf.Configuration;






/**
 *
 * @author Alejandro
 */

aspect AlojaAspect {		

	private static final Log LOG = LogFactory.getLog(AlojaAspect.class);

	/*
	TYPES
	######################################################################################################################################
	######################################################################################################################################
	*/

    public static class Events {

        public static final int JobTracker = 11111;
        public static final int TaskTracker = 11112;
        public static final int NameNode = 11113;
        public static final int SecondaryNameNode = 11114;
        public static final int DataNode = 11115;
        public static final int Task = 11116;
        public static final int HeartBeat = 11119;
//        public static final int MapTask = 11117;
//        public static final int ReduceTask = 11118;
        public static final int MapOutputBuffer = 33333;
        public static final int MapTaskOutputSize = 44444;
    }

    public static class Values {

       	// Generic
		public static final int End = 0;        
        public static final int Start = 1;
        
        // Events.TaskTracker 
		public static final int RunMapper = 8;
        public static final int RunReducer = 9;
        public static final int ReducerCopyPhase = 10;
        public static final int ReducerSortPhase = 11;
        public static final int ReducerReducePhase = 12;

		// Events.MapOutputBuffer
        public static final int Flush = 1;
        public static final int SortAndSpill = 2;
        public static final int Sort = 3;        
        public static final int CreateSpillIndexFile = 5;
        //public static final int TotalIndexCacheMemory = 6;
        public static final int SpillRecordDumped = 7;
        public static final int Combine = 4;
    }    


	/*
	FUNCTIONS
	######################################################################################################################################
	######################################################################################################################################
	*/
	
	private static long getPID() {
		String name = java.lang.management.ManagementFactory.getRuntimeMXBean().getName();
		return Long.parseLong(name.split("@")[0]);
	}

	private void generateEvent(Integer key, Integer value) {
		//2:cpu:app:task:thread:time:type:value
		try{
			String hostname = InetAddress.getLocalHost().getHostName();
			long pid = getPID();
			LOG.info(hostname+","+pid+",2:"+hostname+":2:"+pid+":1:"+System.currentTimeMillis()+":"+key+":"+value);
		}
		catch (Exception e) {
			LOG.error(e, e);

		}
	}


	private void generateEvent(Integer key, String value) {
		//2:cpu:app:task:thread:time:type:value
		try{
			String hostname = InetAddress.getLocalHost().getHostName();
			long pid = getPID();
			LOG.info(hostname+","+pid+",2:"+hostname+":2:"+pid+":1:"+System.currentTimeMillis()+":"+key+":"+value);
		}
		catch (Exception e) {
			LOG.error(e, e);

		}
	}


	/*private void generateEVent(Integer key[], Integer value) {

		StringBuffer output = new StringBuffer();


		output.append()

	}*/

	private void instrumentation(String event, String when) {

		instrumentation(event, when, "");

	}
	private void instrumentation(String event, String when, String additional) {
		try {
			//Add hostname
			String log = InetAddress.getLocalHost().getHostName();
			//Add PID 
			log += "," + getPID();
			//Specify event
			log += "," + when + "," + event;
			//Specify event
			log += additional;
			//LOG.info(log);
			//writeLog(logFile,log);


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

	pointcut heartbeat(TaskTrackerStatus status,boolean restarted,boolean initialContact,boolean acceptNewTasks,short responseId): execution(* org.apache.hadoop.mapred.JobTracker.heartbeat(..)) && args(status, restarted, initialContact, acceptNewTasks,responseId);

	/*
		###########################################################################
		############################Task###########################################
		###########################################################################
	*/


	pointcut outputSize(): call (* *.getLen(..)) && withincode(* org.apache.hadoop.mapred.Task.calculateOutputSize());

	/*
		###########################################################################
		############################MAPPER#########################################
		###########################################################################
	*/

	//pointcut maptask(): execution(* org.apache.hadoop.mapred.MapTask.run(..));
	pointcut mapper(): call(* org.apache.hadoop.mapred.MapTask.runNewMapper(..)) && withincode(* org.apache.hadoop.mapred.MapTask.run(..));


	//  ############################SORT AND SPILL#################################

	//Start-End
	pointcut taskSortAndSpill(): execution(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill());


	pointcut flush(): execution(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.flush());

	//Spill File Size
	pointcut sortAndSpillSpillFile(int numSpills, long size) : call (* *.getSpillFileForWrite(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill()) && args(numSpills, size);

	//SpillIndex File Size
	pointcut sortAndSpillSpillIndexFile(int numSpills, long partitions) : call (* *.getSpillIndexFileForWrite(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill()) && args(numSpills, partitions);

	//Sort 
	pointcut sortAndSpillSort(int kvstart, int endPosition, Object reporter): call(* *.sort(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill()) && args(..,kvstart,endPosition,reporter);

	//Init Writer
	//pointcut sortAndSpillInitWriter() : call (org.apache.hadoop.mapred.IFile.Writer.new(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill());

	//Close Writer
	//pointcut sortAndSpillCloseWriter() : call (void org.apache.hadoop.mapred.IFile.Writer.close(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill());

	//Write key-value
	pointcut sortAndSpillWrite(DataInputBuffer key, DataInputBuffer value): call (* *.append(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill()) && args(key,value);
	
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
	pointcut initCodec(): call(* *.initCodec(..)) && withincode(* org.apache.hadoop.mapred.ReduceTask.run(..));
	pointcut setPhase(TaskStatus.Phase phase): call(* *.setPhase(..)) && withincode(* org.apache.hadoop.mapred.ReduceTask.run(..)) && args(phase);

	
	//pointcut endCopy(): call(* *.setPhase(..)) && withincode(* org.apache.hadoop.mapred.ReduceTask.run(..));
	//pointcut endSort(): call(* *.getMapOutputKeyClass(..)) && withincode(* org.apache.hadoop.mapred.ReduceTask.run(..));
	

	/*
		###########################################################################
		############################NETWORK########################################
		###########################################################################
	*/

	pointcut defaultBlockSize(): call(* org.apache.hadoop.hdfs.DFSClient.getDefaultBlockSize());
	//pointcut blockSize(): call(* org.apache.hadoop.hdfs.DFSClient.getBlockSize(..));
	pointcut createDFSFile(String src,FsPermission permission,boolean overwrite,boolean createParent,short replication,long blockSize,Progressable progress, int buffersize): execution (* org.apache.hadoop.hdfs.DFSClient.create(..)) && args(src,permission,overwrite,createParent,replication,blockSize,progress,buffersize);
	pointcut runDataStreamer(): execution (* org.apache.hadoop.hdfs.DFSClient.DFSOutputStream.DataStreamer.run());
	//pointcut readEntireBufferFromDataNode(byte buf[],int off,int len): execution(* org.apache.hadoop.hdfs.DFSClient.DFSInputStream.read(..)) && args(buf[],off,len);
	//pointcut readFromDataNode(): call (* org.apache.hadoop.hdfs.DFSClient.DFSInputStream.blockSeekTo(..)) && withincode(* org.apache.hadoop.hdfs.DFSClient.DFSInputStream.read(..));
	pointcut newBlockReader(Socket sock, String file, long blockId, Token<BlockTokenIdentifier> accessToken, long genStamp, long startOffset, long len, int bufferSize, boolean verifyChecksum, String clientName): execution (* org.apache.hadoop.hdfs.DFSClient.BlockReader.newBlockReader(..)) && args(sock,file,blockId,accessToken,genStamp,startOffset,len,bufferSize,verifyChecksum,clientName);

	/*
	Advices
	######################################################################################################################################
	######################################################################################################################################
	*/

	// RegiterJobTracker

	after() : registerJobTracker(){
		generateEvent(Events.JobTracker, Values.Start);

	}

	//RegisterTaskTracker ?


	//RegisterNameNode

	after() : initializeNameNode(){
		generateEvent(Events.NameNode, Values.Start);
	}

	//RegisterDataNode 

	after() : startDataNode(){
		generateEvent(Events.DataNode, Values.Start);
	}


	//RegisterSecondaryNamenode

	after() : initializeSecondaryNameNode(){
		generateEvent(Events.SecondaryNameNode, Values.Start);
	}


	//HEARTBEAT 
	after(TaskTrackerStatus status,boolean restarted,boolean initialContact,boolean acceptNewTasks,short responseId) : heartbeat(status, restarted, initialContact, acceptNewTasks,responseId){
		// SAMPLE trackername: tracker_vagrant-99-01:localhost/127.0.0.1:38149
		generateEvent(Events.HeartBeat, status.getTrackerName().replace(':','-').replace('/','_'));
	}


	/*
		###########################################################################
		############################Task###########################################
		###########################################################################
	*/

	//RegisterTask CHILD 
	after() : initializeChild() { //We need the  PID of this task to be registered
		generateEvent(Events.Task, Values.Start);
	}


/*	after() returning(long size) : outputSize() {
		String s = "Task-outputSize";
		instrumentation(s,"after",", size: " + Long.toString(size));
	}

	/*
		###########################################################################
		############################Mapper#########################################
		###########################################################################
	*/


	/*before() : maptask(){
		generateEvent(Events.MapTask, Values.Start);
	}*/

	before() : mapper(){
		generateEvent(Events.TaskTracker, Values.RunMapper);
	}

	after() : mapper(){
		generateEvent(Events.TaskTracker, Values.End);
	}


	

	//  ############################SORT AND SPILL#################################

	before() : taskSortAndSpill(){
		generateEvent(Events.MapOutputBuffer, Values.SortAndSpill);
	}


	after() : taskSortAndSpill(){
		generateEvent(Events.MapOutputBuffer, Values.End);
	}

	//flush

	before() : flush(){
		generateEvent(Events.MapOutputBuffer, Values.Flush);
	}

	after() : flush(){
		generateEvent(Events.MapOutputBuffer, Values.End);
	}



	// Spill File Size

	after(int numSpills, long size) returning : sortAndSpillSpillFile(numSpills, size){
		String s = "sortAndSpillSpillFile";
		instrumentation(s,"after",", numSpills: " +Integer.toString(numSpills) + ";size: " + Long.toString((size*numSpills) + size));
	}

	// SpillIndex File Size

	after(int numSpills, long partitions) returning : sortAndSpillSpillIndexFile(numSpills, partitions){
		String s = "sortAndSpillSpillIndexFile";
		instrumentation(s,"after","," + Long.toString(numSpills * partitions));
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
		generateEvent(Events.MapOutputBuffer, Values.Sort);
		//instrumentation(s,"before","," + Integer.toString(endPosition - kvstart));
	}
	after(int kvstart, int endPosition, Object reporter) returning : sortAndSpillSort(kvstart,endPosition,reporter){
		generateEvent(Events.MapOutputBuffer, Values.End);
		//instrumentation(s,"after","," + Integer.toString(endPosition - kvstart));
	}

	// Init writer
/*	after() returning : sortAndSpillInitWriter(){
		String s = "sortAndSpillInitWriter";
		instrumentation(s,"after");
	}

	// Close writer
	after() returning : sortAndSpillCloseWriter(){
		String s = "sortAndSpillCloseWriter";
		instrumentation(s,"after");
	}
*/

	after(DataInputBuffer key, DataInputBuffer value) returning : sortAndSpillWrite(key,value){
		generateEvent(Events.MapOutputBuffer, Values.SpillRecordDumped);
	}

	before() : sortAndSpillCombiner(){
		generateEvent(Events.MapOutputBuffer, Values.Combine);
	}

	after() returning : sortAndSpillCombiner(){
		generateEvent(Events.MapOutputBuffer, Values.End);	
	}

	before() : sortAndSpillSpillIndexWrite(){
		generateEvent(Events.MapOutputBuffer, Values.CreateSpillIndexFile);
	}

	after() returning : sortAndSpillSpillIndexWrite(){
		generateEvent(Events.MapOutputBuffer, Values.End);
	}

	/*
		###########################################################################
		############################REDUCER########################################
		###########################################################################
	*/

/*	before() : reducer(){
		String s = "Reducer";
		instrumentation(s,"before");
	}
*/

	before() : initCodec() {
		generateEvent(Events.TaskTracker, Values.RunReducer);
	}


	after() returning : initCodec() {
		generateEvent(Events.TaskTracker, Values.ReducerCopyPhase);
	}

	before(TaskStatus.Phase phase) : setPhase(phase) { //END OF A PHASE (SORT OR COPY)
			generateEvent(Events.TaskTracker, Values.End);
	}

	after(TaskStatus.Phase phase) returning: setPhase(phase) { 
		if (phase == TaskStatus.Phase.SORT) {
			generateEvent(Events.TaskTracker, Values.ReducerSortPhase);
		}
		else if (phase == TaskStatus.Phase.REDUCE) {
			generateEvent(Events.TaskTracker, Values.ReducerReducePhase);
		}
	}

	after() : reducer(){ //END OF REDUCE PHASE
			generateEvent(Events.TaskTracker, Values.End);	}

	/*
		###########################################################################
		############################NETWORK########################################
		###########################################################################
	*/

	after() returning(long blockSize) : defaultBlockSize() {
		String s = "Network-defaultBlockSize";
		instrumentation(s,"after",", size: " + Long.toString(blockSize));
	}
	// after() returning(long blockSize) : blockSize() {
	// 	String s = "Network-blockSize";
	// 	File logFile = getFile();
	// 	instrumentation(logFile,s,"after");
	// 	String log = ", size: " + Long.toString(blockSize);
	// 	writeLog(logFile,log);
	// }

	after(String src,FsPermission permission,boolean overwrite, boolean createParent,short replication,long blockSize,Progressable progress, int buffersize): createDFSFile(src,permission,overwrite,createParent,replication,blockSize,progress,buffersize) {
		String s = "Network-CreateDFSFile";

		//MODIFIED!!!!!!-----!!!!!!!!!!!
		instrumentation(s,"after",", path: " + src + ";permission: " + permission.toString() + ";overwrite: " + String.valueOf(overwrite) + ";createParent: " + String.valueOf(createParent) + ";replication: " + Short.toString(replication) + ";blockSize: " + Long.toString(blockSize) + ";buffersize: " + Integer.toString(buffersize));
	}
	before(): runDataStreamer() {
		String s = "DataStreamer";
		instrumentation(s,"after");
	}

	// before(byte buf[],int off, int len) : readEntireBufferFromDataNode(buf[],off,len){
	// 	String s = "Network-ReadEntireBuffer";
	// 	instrumentation(s,"after",", bufferLength: " + Integer.toString(len));
	// }

	// after() returning(DatanodeInfo datanode) : readFromDataNode(){
	// 	String s = "Network-fromDataNode";
	// 	instrumentation(s,"after", ", from : " + datanode.getHostName());
	// }

	after(Socket sock, String file, long blockId, Token<BlockTokenIdentifier> accessToken, long genStamp, long startOffset, long len, int bufferSize, boolean verifyChecksum, String clientName) : newBlockReader(sock,file,blockId,accessToken,genStamp,startOffset,len,bufferSize,verifyChecksum,clientName) {
		String s = "Network-NewBlockReader";
		String extra = ", DataNode: " + sock.getInetAddress().getCanonicalHostName();
		extra += ";file: " + file;
		//extra += ", length: " + Long.toString(len) + "B";
		extra += ";" + Long.toString(len);
		extra += ";blockId: " + Long.toString(blockId);
		extra += ";startOffset: " + Long.toString(startOffset);		
		instrumentation(s,"after",extra);
	}
}




