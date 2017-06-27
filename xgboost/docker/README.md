## Spark XGBoost in Docker on Mesosphere DC/OS

The Docker image can be used to

* Submit XGBoost Spark job against local cluster, Standalone cluster, Mesos (using the image as executor)
* Start Spark Standalone cluster which enabled XGBoost on Mesos

[Reference Mesosphere DC/OS cluster creation on Sofltayer through Terraform](../../dcos/README.md)

Here is a sample [runtime topology](../images/xgboost_spark_mesos.jpg)

### Build Docker Image

Reference [Dockerfile](Dockerfile) for build instructions.

Here is the [pre-built images](https://hub.docker.com/r/yanglei99/spark_xgboost_mesosphere/tags/)

#### Latest

* Base image: mesosphere/mesos:1.3.0
* Spark 2.1.0 with Hadoop 2.7
* Java 8
* XGBoost 0.6 (with XGBoost-Spark 0.7)


### Start Spark Standalone Cluster in Docker with Marathon

This is only needed if you want to use Spark Standalone cluster manager on Mesosphere DC/OS

#### Start Master in Docker

The master will use DC/OS Zookeeper for HA

Spark Master on private IP (default) [job description](spark-cluster/marathon-master.json)

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-master.json $marathonIp:8080/v2/apps


Spark Master on public IP [job description](spark-cluster/marathon-master-pub.json)

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-master-pub.json $marathonIp:8080/v2/apps

#### Start Slave in Docker

There are two ways to configure the Spark master address for a Spark slaves

* Use the Spark master address directly, e.g.`SPARK_MASTER_HOST=xxx.xxx.xxx.xxx` or `SPARK_MASTER=spark://xxx.xxx.xxx.xxx:7077`
* Use the cluster's Spark master marathon job name, `SPARK_MASTER_ID=spark-master`, if Spark master is created on the same DC/OS cluster using private IP (default)

Spark slave against master marathon job name [job description](spark-cluster/marathon-slave.json). 

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-slave.json $marathonIp:8080/v2/apps


Spark slave against Spark master ip [job description](spark-cluster/marathon-slave-jobname.json). 

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-slave-jobname.json $marathonIp:8080/v2/apps


#### The console

If private IP (default) is used, enable VPN to see the console.

* Spark Master at: `spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT`
* Spark Master console start at: `$SPARK_MASTER_HOST:$SPARK_MASTER_WEBUI_PORT`
* Spark Slave console start at: `$SPARK_SLAVE_HOST:$SPARK_WORKER_WEBUI_PORT`


### Submit Spark Job using Marathon


#### using Mesos as Cluster Manager with docker executor

In this scenario, Spark executors will be started on Mesos on-demand, during the spark job submission.

Pre-built XGBoost Example [job description](spark-cluster/marathon-mesos.json) 

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-mesos.json $marathonIp:8080/v2/apps

Lending Example [job description](spark-cluster/marathon-mesos-lending.json) 

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-mesos-lending.json $marathonIp:8080/v2/apps


#### using Spark Standalone Cluster Manager

There are two ways to configure the Spark master address for a standalone cluster 

* Use the Spark master address directly, e.g.`SPARK_MASTER_HOST=xxx.xxx.xxx.xxx` or `SPARK_MASTER=spark://xxx.xxx.xxx.xxx:7077`
* Use the cluster's Spark master marathon job name, `SPARK_MASTER_ID=spark-master`, if Spark master is created on the same DC/OS cluster using private IP (default)

Pre-built XGBoost Example against Spark Cluster of known IP [Job description](marathon-standalone.json) 

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-standalone.json $marathonIp:8080/v2/apps

Lending Example against Spark Cluster of known IP [Job description](marathon-standalone-lending.json) 

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-standalone-lending.json $marathonIp:8080/v2/apps


Against Spark Cluster in Docker on the same DC/OS [Job description](spark-cluster/marathon-standalone-jobname.json)

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-standalone-jobname.json $marathonIp:8080/v2/apps
	

### Known issue and constraints

* You may hit "DAGScheduler: Shuffle files lost for executor:" issue for standalone Spark cluster master in docker after XGBoost training. 
