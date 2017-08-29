## softlayer-terraform-yarn

[Terraform](https://www.terraform.io/) configuration and scripts for provision [Yarn cluster](https://hadoop.apache.org) on [Softlayer](https://softlayer.com/)

[Reference Yarn Installation](https://unskilledcoder.github.io/hadoop/2016/12/10/hadoop-cluster-installation-basic-version.html)

### Cluster Topology

There are 2 kinds of nodes: master, worker

### Software Version

Configurable. Verified on the following version(s):

* Yarn 2.6.5 or 2.7.4 on CENTOS 7
* Spark 2.2.0

#### Master node details

* NameNode with ResourceManager
* [Option] Spark

####  Worker node details

* DataNode with NodeManager
* First Worker Node is configured as secondary NameNode
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


### To Run Spark Job

Log onto Master node with Spark enabled

	spark-submit --master yarn --deploy-mode cluster $SPARK_HOME/examples/src/main/python/pi.py
	
	# For GPU
	
	spark-submit --master yarn --deploy-mode cluster --conf spark.yarn.executor.nodeLabelExpression=gpu --conf spark.yarn.am.nodeLabelExpression=gpu  $SPARK_HOME/examples/src/main/python/pi.py

#### Check job status

You need to either use the generated etc.hosts to append to /etc/hosts after enable VPN, or ssh tunnel into the worker node where the job runs

	ssh -i do-key -L 8042:$WORKER_PRIVATE_IP:8042 root@$WORKER_PUBLIC_IP
	http://localhost:8042/node/containerlogs/...
	
### Known issue, limitation and workaround

* Provision has specific code for CENTOS and alike
