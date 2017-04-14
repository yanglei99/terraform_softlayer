## softlayer-dcos-terraform

Terraform configuration and scripts for provision DC/OS on Softlayer, revised from [digitalocean-dcos-terraform](https://github.com/jmarhee/digitalocean-dcos-terraform)

* This repo holds [Terraform](https://www.terraform.io/) scripts to create a 1, 3, or 5 master DCOS cluster on the [softlayer](https://softlayer.com/) provider.

* Here is the [provision graph](graph.png)

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

| Scenario | Configuration | Default Value | Notes|
|----------|---------------|-------|------|
|Docker Installation | dcos_install_docker |false| Default behavior is for CoreOS which already includes docker installation. For other OS, set it to true.|
|Wait Time|wait_time_vm|15| You may need to adjust the value to make sure remote provisioner actions only start after VM is ready.|
|Logging| dcos_install_logging|false | Set to true to enable [Logging Aggregation using ELK](./logging/README.md). Script is only tested for CENTOS. |
|Monitoring| dcos_install_monitoring|false | Set to true to enable [Monitoring with cAdvisor,InfluxDB, Grafana](./monitoring/README.md).|


### Known issues and workaround

* The provisioner connection host is currently set on public ip. If you have access to VM private IP, change the `host=` under `connection`

* Make sure you have enough public agents when Logging and/or Monitoring are enabled


