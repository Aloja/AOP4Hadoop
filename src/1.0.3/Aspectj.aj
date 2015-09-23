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
	FUNCTIONS
	######################################################################################################################################
	######################################################################################################################################
	*/
	
	private static long getPID() {
		String name = java.lang.management.ManagementFactory.getRuntimeMXBean().getName();
		return Long.parseLong(name.split("@")[0]);
	}

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
			LOG.info(log);
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

	pointcut heartbeat(): execution(* org.apache.hadoop.mapred.JobTracker.heartbeat(..));

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
	pointcut endPhase(TaskStatus.Phase phase): call(* *.setPhase(..)) && withincode(* org.apache.hadoop.mapred.ReduceTask.run(..)) && args(phase);

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

	//RegisterDataNode 

	after() : startDataNode(){
		String s = "RegisterDataNode";
		instrumentation(s,"after");
	}

	//RegisterNameNode

	after() : initializeNameNode(){
		String s = "RegisterNameNode";
		instrumentation(s,"after");
	}


	//RegisterSecondaryNamenode

	after() : initializeSecondaryNameNode(){
		String s = "RegisterSecondaryNameNode";
		instrumentation(s,"after");
	}


	//RegisterTask CHILD
 
	after() : initializeChild() {
		String s = "ChildCreation";
		instrumentation(s,"after");
	}
	
	// RegiterJobTracker

	after() : registerJobTracker(){
		String s = "registerJobTracker";
		instrumentation(s,"after");
	}

	//HEARTBEAT 
	after() : heartbeat(){
		String s = "Heartbeat";
		instrumentation(s,"after");
	}
/*
	before() : heartbeat(){
		String s = "Heartbeat";
		instrumentation(s,"before");
	}
*/	


	/*
		###########################################################################
		############################Task###########################################
		###########################################################################
	*/

	after() returning(long size) : outputSize() {
		String s = "Task-outputSize";
		instrumentation(s,"after",", size: " + Long.toString(size));
	}

	/*
		###########################################################################
		############################Mapper#########################################
		###########################################################################
	*/


	before() : mapper(){
		String s = "Mapper";
		instrumentation(s,"before");
	}

	after() : mapper(){
		String s = "Mapper";
		instrumentation(s,"after");
	}

	//flush

	before() : flush(){
		String s = "Flush";
		instrumentation(s,"before");
	}


	after() : flush(){
		String s = "Flush";
		instrumentation(s,"after");
	}

	//  ############################SORT AND SPILL#################################

	before() : taskSortAndSpill(){
		String s = "sortAndSpill";
		instrumentation(s,"before");
	}

	after() : taskSortAndSpill(){
		String s = "sortAndSpill";
		instrumentation(s,"after");
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
		String s = "sortAndSpillSort";
		instrumentation(s,"before","," + Integer.toString(endPosition - kvstart));
	}
	after(int kvstart, int endPosition, Object reporter) returning : sortAndSpillSort(kvstart,endPosition,reporter){
		String s = "sortAndSpillSort";
		instrumentation(s,"after","," + Integer.toString(endPosition - kvstart));
	}

	// Init writer
	after() returning : sortAndSpillInitWriter(){
		String s = "sortAndSpillInitWriter";
		instrumentation(s,"after");
	}

	// Close writer
	after() returning : sortAndSpillCloseWriter(){
		String s = "sortAndSpillCloseWriter";
		instrumentation(s,"after");
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
		instrumentation(s,"before");
	}

	after() returning : sortAndSpillCombiner(){
		String s = "sortAndSpillCombiner";
		instrumentation(s,"after");
	}

	before() : sortAndSpillSpillIndexWrite(){
		String s = "sortAndSpillSpillIndexWrite";
		instrumentation(s,"before");
	}

	after() returning : sortAndSpillSpillIndexWrite(){
		String s = "sortAndSpillSpillIndexWrite";
		instrumentation(s,"after");
	}

	/*
		###########################################################################
		############################REDUCER########################################
		###########################################################################
	*/

	before() : reducer(){
		String s = "Reducer";
		instrumentation(s,"before");
	}

	after() returning : initCopy() {
		String s = "Reducer-copy-phase";
		instrumentation(s,"before");
	}

	before(TaskStatus.Phase phase) : endPhase(phase) {
		if (phase == TaskStatus.Phase.SORT){
			String s = "Reducer-copy-phase";
			instrumentation(s,"after"); 
		}
		else if (phase == TaskStatus.Phase.REDUCE) {
			String s = "Reducer-sort-phase";
			instrumentation(s,"after");
		}
	}

	after(TaskStatus.Phase phase) returning: endPhase(phase) { 
		if (phase == TaskStatus.Phase.SORT) {
			String s = "Reducer-sort-phase";
			instrumentation(s,"before");
		}
		else if (phase == TaskStatus.Phase.REDUCE) {
			String s = "Reducer-reduce-phase";
			instrumentation(s,"before");
		}
	}

	after() : reducer(){
		String s = "Reducer-reduce-phase";
		instrumentation(s,"after");
	}

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




