import java.io.*;
import java.util.*;
import java.net.InetAddress;
import org.apache.hadoop.mapred.TaskStatus;



import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 *
 * @author Alejandro
 */

aspect AlojaAspect {		

	private static final Log LOG = LogFactory.getLog(AlojaAspect.class);

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
	//Pointcuts

	/*
		###########################################################################
		############################MAPPER#########################################
		###########################################################################
	*/
	pointcut mapper(): execution(* org.apache.hadoop.mapred.MapTask.run(..));
	pointcut flush(): execution(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.flush());

	//  ############################SORT AND SPILL#################################

	pointcut taskSortAndSpill(): execution(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill());
	pointcut sortAndSpillSpillFile(int numSpills, long size) : call (* *.getSpillFileForWrite(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill()) && args(numSpills, size);
	pointcut sortAndSpillSpillIndexFile(int numSpills, long partitions) : call (* *.getSpillIndexFileForWrite(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill()) && args(numSpills, partitions);
	pointcut sortAndSpillSort(int kvstart, int endPosition, Object reporter): call(* *.sort(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill()) && args(..,kvstart,endPosition,reporter);
	pointcut sortAndSpillInitWriter() : call (org.apache.hadoop.mapred.IFile.Writer.new(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill());
	pointcut sortAndSpillCloseWriter() : call (void org.apache.hadoop.mapred.IFile.Writer.close(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill());
	pointcut sortAndSpillCombiner(): call(* *.combine(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill());
	pointcut sortAndSpillSpillIndexWrite(): call(* *.writeToFile(..)) && withincode(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill());

	/*
		###########################################################################
		############################REDUCER########################################
		###########################################################################
	*/

	pointcut reducer(): execution(* org.apache.hadoop.mapred.ReduceTask.run(..));
	pointcut initCopy(): call(* *.initCodec(..)) && withincode(* org.apache.hadoop.mapred.ReduceTask.run(..));
	pointcut endPhase(TaskStatus.Phase phase): call(* *.setPhase(..)) && withincode(* org.apache.hadoop.mapred.ReduceTask.run(..)) && args(phase);

	/*
		###########################################################################
		############################NETWORK########################################
		###########################################################################
	*/

	//Advices

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

	after(int numSpills, long size) returning : sortAndSpillSpillFile(numSpills, size){
		String s = "sortAndSpillSpillFile";
		instrumentation(s,"after",", numSpills: " +Integer.toString(numSpills) + ", size: " + Long.toString((size*numSpills) + size));
	}

	// SpillIndex File Size

	after(int numSpills, long partitions) returning : sortAndSpillSpillIndexFile(numSpills, partitions){
		String s = "sortAndSpillSpillIndexFile";
		instrumentation(s,"after","," + Long.toString(numSpills * partitions));
	}

	before(int kvstart, int endPosition, Object reporter) : sortAndSpillSort(kvstart,endPosition,reporter){
		String s = "sortAndSpillSort";
		instrumentation(s,"before","," + Integer.toString(endPosition - kvstart));
	}
	after(int kvstart, int endPosition, Object reporter) returning : sortAndSpillSort(kvstart,endPosition,reporter){
		String s = "sortAndSpillSort";
		instrumentation(s,"after","," + Integer.toString(endPosition - kvstart));
	}

	after() returning : sortAndSpillInitWriter(){
		String s = "sortAndSpillInitWriter";
		instrumentation(s,"after");
	}

	after() returning : sortAndSpillCloseWriter(){
		String s = "sortAndSpillCloseWriter";
		instrumentation(s,"after");
	}

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

}