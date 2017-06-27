#!/bin/bash

echo calculate Spark Master Host

if [ "$SPARK_MASTER_ID" != "" ]; then
	text=$(curl -s $MARATHON_HOST/v2/apps/$SPARK_MASTER_ID | jq .app.tasks[].host | sed -e 's/"/''/g'| sed -n -e 1p)
	echo calculate Spark Master from $MARATHON_HOST/v2/app/$SPARK_MASTER_ID : $text
	if [ "$text" != "" ]; then
		export SPARK_MASTER_HOST=$text
	fi
fi

if [ "$SPARK_MASTER_HOST" != "" ]; then
	export SPARK_MASTER=spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT
fi

echo calculate Spark Driver Host
if [ "$SPARK_USE_PRIVATE_NETWORK" == "true" ]; then
    export SPARK_DRIVER_HOST=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
else
    export SPARK_DRIVER_HOST=$(ip addr show eth1 | awk '/inet / {print $2}' | cut -d/ -f1)
fi

if [[ ! -z $SPARK_DRIVER_HOST ]]; then 
	export LIBPROCESS_IP=$SPARK_DRIVER_HOST
	export SPARK_PUBLIC_DNS=$SPARK_DRIVER_HOST
	export SPARK_LOCAL_IP=$SPARK_DRIVER_HOST
	export DMLC_TRACKER_URI=$SPARK_DRIVER_HOST
fi

env | grep SPARK
env | grep MESOS
env | grep MARATHON
env | grep DMLC

mkdir -p /spark/job/logs

if [ "$SPARK_PROCESS_NAME" == "master" ]; then
    echo "Start spark master on the node"
	export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=ZOOKEEPER -Dspark.deploy.zookeeper.url=leader.mesos:2181 -Dspark.deploy.zookeeper.dir=/sparkha" 
    $SPARK_HOME/sbin/start-master.sh -h $SPARK_DRIVER_HOST > /spark/job/logs/start.log
elif [ "$SPARK_PROCESS_NAME" == "slave" ]; then
    echo "Start spark slave on the node"
    $SPARK_HOME/sbin/start-slave.sh $SPARK_MASTER -h $SPARK_DRIVER_HOST > /spark/job/logs/start.log
elif  [ "$SPARK_PROCESS_NAME" == "application" ]; then
	if [ "$SPARK_JOB" != "" ]; then
		echo "Run Spark application: $SPARK_JOB"
		mycmd="$SPARK_HOME/bin/spark-submit --master $SPARK_MASTER $SPARK_JOB_CONFIG $SPARK_JOB_PACKAGES $SPARK_JOB_JARS $SPARK_JOB"
		echo $mycmd
		eval $mycmd 
		echo "End of job" >  /spark/job/logs/end.log
	else
		echo "No application defined " >  /spark/job/logs/end.log
	fi
else
		echo "No valid process defined: $SPARK_PROCESS_NAME" >  /spark/job/logs/end.log
fi

tail -F /spark/job/logs/*
