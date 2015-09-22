import java.io.*;
import java.util.*;
import java.net.InetAddress;
import java.net.Socket;
import java.net.InetSocketAddress;
import org.apache.hadoop.fs.permission.FsPermission;
import org.apache.hadoop.util.Progressable;
import org.apache.hadoop.security.token.Token;
import org.apache.hadoop.security.token.TokenIdentifier;
import org.apache.hadoop.hdfs.security.token.block.BlockTokenIdentifier;
import org.apache.hadoop.fs.Options.ChecksumOpt;
import org.apache.hadoop.fs.CreateFlag;
import org.apache.hadoop.hdfs.protocol.ExtendedBlock;
import org.apache.hadoop.hdfs.net.Peer;
import org.apache.hadoop.hdfs.protocol.DatanodeID;
import org.apache.hadoop.hdfs.PeerCache;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 *
 * @author Alejandro
 */

aspect AlojaAspect2 {		

	private static final Log LOG = LogFactory.getLog(AlojaAspect2.class);

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
		############################NETWORK########################################
		###########################################################################
	*/

	pointcut defaultBlockSize(): call(* org.apache.hadoop.hdfs.DFSClient.getDefaultBlockSize());
	pointcut createDFSFile(String src,FsPermission permission,EnumSet<CreateFlag> flag,boolean createParent,short replication,long blockSize,Progressable progress,int buffersize,ChecksumOpt checksumOpt,InetSocketAddress[] favoredNodes): execution (* org.apache.hadoop.hdfs.DFSClient.create(..)) && args(src,permission,flag,createParent,replication,blockSize,progress,buffersize,checksumOpt,favoredNodes);
	pointcut newBlockReader(String file,ExtendedBlock block,Token<BlockTokenIdentifier> blockToken,long startOffset, long len,boolean verifyChecksum,String clientName,Peer peer, DatanodeID datanodeID,PeerCache peerCache,CachingStrategy cachingStrategy): execution (* org.apache.hadoop.hdfs.RemoteBlockReader2.newBlockReader(..)) && args(file,block,blockToken,startOffset,len,verifyChecksum,clientName,peer,datanodeID,peerCache,cachingStrategy);

	//Advices

	after() returning(long blockSize) : defaultBlockSize() {
		String s = "Network-defaultBlockSize";
		instrumentation(s,"after",", size: " + Long.toString(blockSize));
	}
	after(String src,FsPermission permission,EnumSet<CreateFlag> flag,boolean createParent,short replication,long blockSize,Progressable progress,int buffersize,ChecksumOpt checksumOpt,InetSocketAddress[] favoredNodes): createDFSFile(src,permission,flag,createParent,replication,blockSize,progress,buffersize,checksumOpt,favoredNodes) {
		String s = "Network-CreateDFSFile";
		instrumentation(s,"after",", path: " + src + ", permission: " + permission.toString() + ", createParent: " + String.valueOf(createParent) + ", replication: " + Short.toString(replication) + ", blockSize: " + Long.toString(blockSize) + ", buffersize: " + Integer.toString(buffersize));
	}
	after(String file,ExtendedBlock block,Token<BlockTokenIdentifier> blockToken,long startOffset, long len,boolean verifyChecksum,String clientName,Peer peer, DatanodeID datanodeID,PeerCache peerCache,CachingStrategy cachingStrategy) : newBlockReader(file,block,blockToken,startOffset,len,verifyChecksum,clientName,peer,datanodeID,peerCache,cachingStrategy) {
		String s = "Network-NewBlockReader";
		// String extra = ", DataNode: " + sock.getInetAddress().getCanonicalHostName();
		// extra += ", file: " + file;
		// //extra += ", length: " + Long.toString(len) + "B";
		// extra += "," + Long.toString(len);
		// extra += ", blockId: " + Long.toString(blockId);
		// extra += ", startOffset: " + Long.toString(startOffset);		
		// instrumentation(s,"after",extra);
	}
}