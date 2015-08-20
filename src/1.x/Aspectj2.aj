import java.io.*;


aspect Aspect {		

	//START DATA NODE

	before() : execution(* org.apache.hadoop.hdfs.server.datanode.DataNode.startDataNode(..)){
		try {

			new File("./Test").mkdir();
			File file = new File("./Test/" + thisJoinPoint + ".txt");


			if (!file.exists()) {
					file.createNewFile();
			}

			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			bw.write("This is just a test, I am at " + thisJoinPoint + ":)");
			bw.close();
		}
		 catch (IOException e) {
		 	e.printStackTrace();
		 }
	}

	//INITIALIZE NAMENODE

	before() : execution(* org.apache.hadoop.hdfs.server.namenode.NameNode.initialize(..)){
		try {

			new File("./Test").mkdir();
			File file = new File("./Test/" + thisJoinPoint + ".txt");


			if (!file.exists()) {
					file.createNewFile();
			}

			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			bw.write("This is just a test, I am at " + thisJoinPoint + ":)");
			bw.close();
		}
		 catch (IOException e) {
		 	e.printStackTrace();
		 }
	}

	//INITIALIZE SECONDARY NAMENODE

	before() : execution(* org.apache.hadoop.hdfs.server.namenode.SecondaryNameNode.initialize(..)){
		try {

			new File("./Test").mkdir();
			File file = new File("./Test/" + thisJoinPoint + ".txt");


			if (!file.exists()) {
					file.createNewFile();
			}

			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			bw.write("This is just a test, I am at " + thisJoinPoint + ":)");
			bw.close();
		}
		 catch (IOException e) {
		 	e.printStackTrace();
		 }
	}

	//STARTING CHILD
 
	before() : execution(* org.apache.hadoop.mapred.Child.main(..)) && args(String[]){
		try {

			new File("./Test").mkdir();
			File file = new File("./Test/" + thisJoinPoint + ".txt");


			if (!file.exists()) {
					file.createNewFile();
			}

			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			bw.write("This is just a test, I am at " + thisJoinPoint + ":)");
			bw.close();
		}
		 catch (IOException e) {
		 	e.printStackTrace();
		 }
	}
	

	// Regiter JobTracker
	before() : execution(* org.apache.hadoop.mapred.JobTracker.startTracker(..)) && args(Object){
		try {

			new File("./Test").mkdir();
			File file = new File("./Test/" + thisJoinPoint + ".txt");


			if (!file.exists()) {
					file.createNewFile();
			}

			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			bw.write("This is just a test, I am at " + thisJoinPoint + ":)");
			bw.close();
		}
		 catch (IOException e) {
		 	e.printStackTrace();
		 }
	}
}
