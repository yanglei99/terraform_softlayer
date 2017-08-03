## softlayer-dcos-terraform

Terraform configuration and scripts for provision DC/OS on Softlayer, revised from [digitalocean-dcos-terraform](https://github.com/jmarhee/digitalocean-dcos-terraform)

* This repo holds [Terraform](https://www.terraform.io/) scripts to create a 1, 3, or 5 master DCOS cluster on the [softlayer](https://softlayer.com/) provider.

##### Theory of Operation:

This script will start the infrastructure machines (bootstrap and masters),
then collect their IPs to build an installer package on the bootstrap machine
with a static master list. All masters wait for an installation script to be
generated on the localhost, then receive that script. This script, in turn,
pings the bootstrap machine whilst waiting for the web server to come online
and serve the install script itself.

When the install script is generated, the bootstrap completes and un-blocks
the cadre of agent nodes, which are  cut loose to provision metal and
eventually install software.


### Cluster Topology

There are four kinds of nodes: bootstrap, master, agent, public agent, Bare Metal (with GPU option) agent. 
You can use its specific count variable to control the number of nodes of the type.

### Software Components

Docker are installed on all nodes. Firewall rules are enabled

#### Master node details

* ZooKeeper with Exhibitor
* Mesos Master
* [option] NFS mount to a provisioned file storage
* [option] Integration with NewRelic
* [option] Logging and Monitoring

####  all agent details

* Mesos Agent (public or private)
* [option] GPU kernel and CUDA on Bare Metal private agent node
* [option] NFS mount to a provisioned file storage
* [option] Integration with NewRelic
* [option] Logging and Monitoring

#### Verified 

* DCOS: 1.9.2

### To use:

* Clone or download repo.

* Generate a `do-key` keypair (with an empty passphrase):

	ssh-keygen -t rsa -P '' -f ./do-key

* Copy [sample.terraform.tfvars](./sample.terraform.tfvars) to `terraform.tfvars` and revise your variables. Reference [vars.tf](./vars.tf) for variable definitions

* Run Provision

	terraform apply

* Change agent count

	terraform apply -var ‘dcos_agent_count=N’` 
	
#### Configuration Details

Reference [vars.tf](./vars.tf) for more definitions

| Scenario | Configuration | Default Value | Notes|
|----------|---------------|-------|------|
|Docker Installation | dcos_install_docker |false| Default behavior is for CoreOS which already includes docker installation. For other OS, set it to true.|
|Wait Time|wait_time_vm|15| You may need to adjust the value to make sure remote provisioner actions only start after VM is ready.|
|Logging| dcos_install_logging|false | Set to true to enable [Logging Aggregation using ELK](./logging/README.md). Script is only tested for CENTOS. |
|Monitoring| dcos_install_monitoring|false | Set to true to enable [Monitoring with cAdvisor,InfluxDB, Grafana](./monitoring/README.md).|
|NewRelic License | nr_license |""| When not empty will be used to install and start NewRelic services for infrastructure monitoring...|
|Enable Shared File System| enable_file_storage |false | When enabled, will create File Storage and mount as nfs on each agent, public agent as shared file system. Check other detailed attributes|
|Enable GPU on BareMetal Agent| enable_gpu |false | When enabled, will install NVIDIA M80 and CUDA|

### Known issues and workaround

* Make sure you have enough public agents when Logging and/or Monitoring are enabled
* Most of the optional capabilities are only tested on CENTOS


