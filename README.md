    +----------------+-----------+-----------------+
    | Hadoop Release | Supported |  Initial date   |
    +----------------+-----------+-----------------+
    | 1.0.3          | yes       | Aug. 20th, 2015 |
    | 2.x            | no        |        -        |
    +----------------+-----------+-----------------+


Usage instructions:

Copy env.sh.sample to env.sh and edit the following variables:

```
HADOOP_PREFIX: the folder where a binary Hadoop distribution has been placed. Recommended location is the dist folder
HADOOP_VERSION: version of the Hadoop distribution pointed by HADOOP_PREFIX (example: 1.0.3)
JAVA_HOME: location of your JAVA JDK (recommended 1.8+)
```

After that run the following script to generate the instrumented jar files:
```
./insert_hooks.sh
```

Everytime that an instrumented execution is desired, add the following 2 lines to *$HADOOP_PREFIX/conf/hadoop-env.sh*
```
HADOOP_USER_CLASSPATH_FIRST=true
HADOOP_CLASSPATH=$HADOOP_TRACING_CLASSPATH
```

Removing these lines (or just setting *HADOOP_USER_CLASSPATH_FIRST* to false) will disable the tracing environment.

To setup the tracing environment before every run the following command from the AOP4Hadoop folder:
```
source set_tracing_environment.sh
```


Notice that this step needs to be repeated for all machines (the AOP4Hadoop folder needs to be available from all nodes or replicated to the very same path in all nodes)


Finally, to produce the logs, the following lines need to be added to the log4j.conf
````
log4j.appender.ALOJA=org.apache.log4j.DailyRollingFileAppender
log4j.appender.ALOJA.File=${hadoop.log.dir}/aloja.log
log4j.appender.ALOJA.layout=org.apache.log4j.PatternLayout
log4j.appender.ALOJA.layout.ConversionPattern=%d{ISO8601}, %m%n
log4j.logger.AlojaAspect=INFO, ALOJA
log4j.additivity.AlojaAspect=false
```

Have fun...

