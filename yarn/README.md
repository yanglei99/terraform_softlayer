## softlayer-terraform-yarn

[Terraform](https://www.terraform.io/) configuration and scripts for provision [Yarn cluster](https://hadoop.apache.org) on [Softlayer](https://softlayer.com/)

[Reference Yarn Installation](https://unskilledcoder.github.io/hadoop/2016/12/10/hadoop-cluster-installation-basic-version.html)

### Cluster Topology

There are 3 kinds of nodes: master, worker, baremetal worker

### Software Version

Configurable. Verified on the following version(s):

* Yarn 2.6.5 or 2.7.1 on CENTOS 7
* Spark 2.2.0
* XGboost 0.7

#### Master node details

* NameNode with ResourceManager
* [Option] Spark
* [Option] XGBoost

####  Worker node details

* DataNode with NodeManager
* First Worker Node is configured as secondary NameNode
* [Option] Spark

####  Worker node details

* DataNode with NodeManager
* [Option] GPU libraries and cuda
* [Option] Spark


### To use:

* Clone or download repo.

* Generate a `do-key` keypair (with an empty passphrase):

	ssh-keygen -t rsa -P '' -f ./do-key

* Copy [sample.terraform.tfvars](./sample.terraform.tfvars) to `terraform.tfvars` and revise your variables. Reference [vars.tf](./vars.tf) for variable definitions

* Run Provision

	terraform apply
	
### Check status

#### [enable VPN to access status WebUI](https://www.softlayer.com/VPN-Access) with private IP. 

    # For Yarn
	http://$MASTER_PRIVATE_IP:8088/
	
    # For HDFS
	http://$MASTER_PRIVATE_IP:50070/

#### use SSH tunnel to access status WebUI with localhost

    # For Yarn
	ssh -i do-key -L 8088:$MASTER_PRIVATE_IP:8088 root@$MASTER_PUBLIC_IP
	http://localhost:8088/
	
    # For HDFS
	ssh -i do-key -L 50070:$MASTER_PRIVATE_IP:50070 root@$MASTER_PUBLIC_IP
	http://localhost:50070


#### Configuration Details

| Scenario | Configuration | Default Value | Notes|
|----------|---------------|-------|------|
|Wait Time for VM  | wait_time_vm   | 15   | Adjust the value to make sure remote provisioner actions only start after VM is ready.|


### Submit Jobs


#### Spark Jobs

Log onto Master node with Spark enabled

	spark-submit --master yarn --deploy-mode cluster $SPARK_HOME/examples/src/main/python/pi.py
	
	# For GPU
	
	spark-submit --master yarn --deploy-mode cluster --conf spark.yarn.executor.nodeLabelExpression=gpu --conf spark.yarn.am.nodeLabelExpression=gpu  $SPARK_HOME/examples/src/main/python/pi.py


#### XGBoost Jobs

Log onto Master node with XGBoost enabled. If you run XGBoost in Spark, Spark also needs to be enabled.

Before upload file to [S3 Object Storage on Softlayer](https://knowledgelayer.softlayer.com/procedure/connecting-cos-s3-using-s3cmd), change `~/.s3cfg` with S3 access key and secret

	
	export BUCKET=YOUR BUCKET

	cd ~/xgboost

	s3cmd put demo/data/agaricus.txt.train s3://${BUCKET}/xgb-demo/train/
	s3cmd put demo/data/agaricus.txt.test s3://${BUCKET}/xgb-demo/test/
    
    
##### Run Python Jobs

	export AWS_ACCESS_KEY_ID=YOUR KEY
	export AWS_SECRET_ACCESS_KEY=YOUR Secret
	export AWS_HOST=s3-api.us-geo.objectstorage.softlayer.net
    
	cd ~/xgboost/demo/distributed-training

	../../dmlc-core/tracker/dmlc-submit --cluster=yarn --num-workers=2 --worker-cores=2\
    ../../xgboost mushroom.aws.conf nthread=2\
    data=s3://${BUCKET}/xgb-demo/train\
    eval[test]=s3://${BUCKET}/xgb-demo/test\
    model_dir=s3://${BUCKET}/xgb-demo/model
    
    # look at generate model
    s3cmd ls s3://${BUCKET}/xgb-demo/model/
 
##### Run Spark Job
   
Create Spark Hadoop S3 configuration. Referenc [myspark.properties](myspark.properties)

    spark-submit --class  ml.dmlc.xgboost4j.scala.example.spark.SparkWithDataFrame --master yarn --jars /root/xgboost/jvm-packages/xgboost4j-spark/target/xgboost4j-spark-0.7-jar-with-dependencies.jar --packages org.apache.hadoop:hadoop-aws:2.7.3 --properties-file myspark.properties /root/xgboost/jvm-packages/xgboost4j-example/target/xgboost4j-example-0.7.jar 100 2 s3a://${BUCKET}/xgb-demo/train s3a://${BUCKET}/xgb-demo/test
        
   
##### Check job status

From dashboard, you need to either use the generated etc.hosts to append to /etc/hosts after enable VPN, or ssh tunnel into the worker node where the job runs

	ssh -i do-key -L 8042:$WORKER_PRIVATE_IP:8042 root@$WORKER_PUBLIC_IP
	http://localhost:8042/node/containerlogs/...

	
	
### Known issue, limitation and workaround

* Provision has specific code for CENTOS and alike
* [XGBoost S3 patch](https://github.com/dmlc/xgboost/issues/2665) is created to support S3 Object Storage on Softlayer. Provision will automatically apply the patch when `xgboost_patch` is defined.
* If you hit can not download library during spark submit on master, you may need to remove both `~/.m2` and `~/.ivy2` 

