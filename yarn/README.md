## softlayer-terraform-yarn

[Terraform](https://www.terraform.io/) configuration and scripts for provision [Yarn cluster](https://hadoop.apache.org) on [Softlayer](https://softlayer.com/)

[Reference Yarn Installation](https://unskilledcoder.github.io/hadoop/2016/12/10/hadoop-cluster-installation-basic-version.html)

### Cluster Topology

There are 2 kinds of nodes: master, worker

### Software Version

* Yarn 2.6.5 on CENTOS 7

#### Master node details

* NameNode with ResourceManager
* NFS mount to a provisioned file storage

####  Worker node details

* DataNode with NodeManager
* First Worker Node is configured as secondary NameNode
* NFS mount to a provisioned file storage


### To use:

* Clone or download repo.

* Generate a `do-key` keypair (with an empty passphrase):

	ssh-keygen -t rsa -P '' -f ./do-key

* Copy [sample.terraform.tfvars](./sample.terraform.tfvars) to `terraform.tfvars` and revise your variables. Reference [vars.tf](./vars.tf) for variable definitions

* Run Provision

	terraform apply
	
* Check status

You need to [enable VPN to access](https://www.softlayer.com/VPN-Access) the private IP. 

    # For Yarn
	http://$MASTER_PRIVATE_IP:8088/
	
    # For HDFS
	http://$MASTER_PRIVATE_IP:50070/

Or you can use SSH tunnel to access the status Web UI

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


### Known issue, limitation and workaround

* Provision has specific code for CENTOS and alike
