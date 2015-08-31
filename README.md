    +----------------+-----------+-----------------+
    | Hadoop Release | Supported |  Testing date   |
    +----------------+-----------+-----------------+
    | 1.0.3          | yes       | Aug. 20th, 2015 |
    | 2.x            | no        | Aug. 20th, 2015 |
    +----------------+-----------+-----------------+


The user is responsible for:

Set the environment variable HADOOP_PREFIX to point to the Hadoop environment to be used and also to specify the exact Hadoop version to be used in the following script:

```
user-provided-env.sh
```
From the AOP4Hadoop folder run the following scritps once:
```
insert_hooks.sh
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

The vagrant folder contains an easy way to test AOP4Hadoop, it includes a vagrant provisioning with three VM which includes Hadoop 1.0.3 installed, along with all the required packages, also the variable *HADOOP_ENV.SH* is already configured. 

In order to 

Have fun...

