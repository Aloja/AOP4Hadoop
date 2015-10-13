import java.io.*;
import java.util.*;
import java.net.InetAddress;

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
	pointcut registerApplicationMaster(): execution(* org.apache.hadoop.yarn.client.api.impl.AMRMClientImpl.registerApplicationMaster());

	//Advices

	after(): registerApplicationMaster() {
		String s = "YARN - registerApplicationMaster";
		instrumentation(s,"after");
	}
	
}