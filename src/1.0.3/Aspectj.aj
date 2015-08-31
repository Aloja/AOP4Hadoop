import java.io.*;
import java.util.*;
import java.lang.management.ManagementFactory;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.net.InetAddress;
import java.lang.ClassLoader;

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

	private void testAspect2(String s) {
		try {

			Random rand = new Random();
			new File("/vagrant/workspace/instrumentation/" + s).mkdir();
			File file = new File("/vagrant/workspace/instrumentation/" + s + "/" + s + rand.nextInt() + ".txt");


			if (!file.exists()) {
					file.createNewFile();
			}

			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			bw.write("This is just a test");
			bw.close();
		}
		 catch (IOException e) {
			e.printStackTrace();
		}
	}

	private void instrumentation(String event, String when) {
		try {

			URL path = ClassLoader.getSystemResource("release.txt");
			File file = new File(path.toURI());
			BufferedReader br = new BufferedReader(new FileReader(file));
			String logPath = br.readLine();

			File logFile = new File(logPath + "/log.csv");

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

			//Append log to logFile

			log += "\n";

			FileWriter fw = new FileWriter(logFile.getAbsoluteFile(),true);
			BufferedWriter bw = new BufferedWriter(fw);
			bw.write(log);
			bw.close();

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

	pointcut registerJobTracker(): execution(* org.apache.hadoop.mapred.JobTracker.startTracker(..)) && args(Object);

	//HEARTBEAT

	//pointcut heartbeat(): call (* *.getTime(..)) && withincode(* org.apache.hadoop.mapred.JobTracker.heartbeat(..));

	pointcut heartbeat(): execution(* org.apache.hadoop.mapred.JobTracker.heartbeat(..));

	//TASK RUN ---- NOT SHOWING LOGS

	pointcut taskRunInitialize(): execution(* org.apache.hadoop.mapred.MapTask.run(..)) && args(Object,Object) ;

	//TASKFLUSH ---- NOT SHOWING LOGS 

	pointcut flushTask(): execution(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.flush());

	//MAPTASK SORTANDSPILL

	pointcut taskSortAndSpill(): execution(* org.apache.hadoop.mapred.MapTask.MapOutputBuffer.sortAndSpill());

	//REDUCETASK RUN ---- NOT SHOWING LOGS

	pointcut reduceTaskRun(): execution(* org.apache.hadoop.mapred.ReduceTask.run(..));


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
	before() : startDataNode(){
		String s = "RegisterDataNode";
		instrumentation(s,"before");
	}

	//RegisterNameNode

	after() : initializeNameNode(){
		String s = "RegisterNameNode";
		instrumentation(s,"after");
	}

	before() : initializeNameNode(){
		String s = "RegisterNameNode";
		instrumentation(s,"before");
	}

	//RegisterSecondaryNamenode

	after() : initializeSecondaryNameNode(){
		String s = "RegisterSecondaryNameNode";
		instrumentation(s,"after");
	}

	before() : initializeSecondaryNameNode(){
		String s = "RegisterSecondaryNameNode";
		instrumentation(s,"before");
	}

	//RegisterTask CHILD
 
	after() : initializeChild() {
		String s = "GeneralTask";
		instrumentation(s,"after");
	}
	
	before() : initializeChild() {
		String s = "GeneralTask";
		instrumentation(s,"before");
	}

	// RegiterJobTracker
	before() : registerJobTracker(){
		String s = "registerJobTracker";
		instrumentation(s,"before");
	}

	after() : registerJobTracker(){
		String s = "registerJobTracker";
		instrumentation(s,"after");
	}

	//HEARTBEAT 
	after() : heartbeat(){
		String s = "Heartbeat";
		instrumentation(s,"after");
	}

	before() : heartbeat(){
		String s = "Heartbeat";
		instrumentation(s,"before");
	}
	
	//TASK RUN

	before() : taskRunInitialize(){
		String s = "runMapTask";
		instrumentation(s,"before");
	}

	after() : taskRunInitialize(){
		String s = "runMapTask";
		instrumentation(s,"after");
	}

	//FLUSHTASK

	before() : flushTask(){
		String s = "Flush";
		instrumentation(s,"before");
	}


	after() : flushTask(){
		String s = "Flush";
		instrumentation(s,"after");
	}

	//REDUCETASK RUN

	before() : reduceTaskRun(){
		String s = "runReduceTask";
		instrumentation(s,"before");
	}

	after() : reduceTaskRun(){
		String s = "runReduceTask";
		instrumentation(s,"after");
	}

	//MAPTASK SORTANDSPILL

	before() : taskSortAndSpill(){
		String s = "sortAndSpill";
		instrumentation(s,"before");
	}

	after() : taskSortAndSpill(){
		String s = "sortAndSpill";
		instrumentation(s,"after");
	}
}




