## softlayer-terraform-ingect

[Terraform](https://www.terraform.io/) configuration and scripts for provision data ingest scenarios on [Softlayer](https://softlayer.com/)

Here is the [provision graph](graph.png)

### Cluster Topology

There are two kinds of nodes, master and worker, which work together to support clusters of:

* ZooKeeper with Exhibitor
* Spark stand-alone cluster with HA using Zookeeper
* Kafka broker cluster

### Software Components

As Docker container is used for provision, Docker are installed on all nodes.

#### Master node details

* ZooKeeper with Exhibitor
* Spark stand-alone cluster master with HA using Zookeeper
* [option] Spark stand-alone cluster worker
* [option] Kafka broker  

#### Worker node details

* [option] Spark stand-alone cluster worker
* [option] Kafka broker  


### To use:

* Clone or download repo.

* Generate a `do-key` keypair (with an empty passphrase):

	ssh-keygen -t rsa -P '' -f ./do-key

* Copy [sample.terraform.tfvars](./sample.terraform.tfvars) to `terraform.tfvars` and revise your variables. Reference [vars.tf](./vars.tf) for variable definitions

* Run Provision

	terraform apply

#### Important ports

[make-files](make-files.sh)

* Exhibitor Web UI start at : 8181
* Spark Master Web UI at: 8090
* Spark Worker Web UI at: 8091
* Kafka broker at: 9092

Output will display the calculated KAFKA_BROKER,SPARK_MASTER and ZK_MASTER, besides the list of master-ip and worker-ip.
	
#### Configuration Details

| Scenario | Configuration | Default Value | Notes|
|----------|---------------|-------|------|
|Docker Installation | provision_install_docker |false| Default behavior is for CoreOS which already includes docker installation. For other OS, set it to true.|
|Wait Time for VM    | provision_vm_wait_time   |15   | You may need to adjust the value to make sure remote provisioner actions only start after VM is ready.|
|Wait Time for ZK    | provision_zk_wait_time   |120  | You may need to adjust the value to make sure zookeeper dependent actions only start after ZK cluster is ready.|


### Known issue, limitation and workaround

* The provisioner connection host is currently set on public ip. 
