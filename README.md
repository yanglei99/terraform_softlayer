# Terraform on Softlayer

[Terraform Softlayer Provider](https://github.com/softlayer/terraform-provider-softlayer)


## Notes on environment setup

Download Terraform binary and set onto PATH

Download Terraform Softlayer Provider binary and enable it in `~/.terraformrc`. Make sure the binary is executable. 

	providers {
    	softlayer = “/.../terraform-provider-softlayer_xxxx"
	}

## Scenarios

### Basic Scenario

* [VM](basic/sl_basic.tf). Provision 2 VMs with a new SSH Key
* [Auto Scale Group](asg/sl_asg.tf). Provision Auto Scale Group and reuse the created SSH Key
* [File Storage](basic_storage/sl_storage.tf). Provision File Storage and mount as NFS to newly provisioned VMs with a new SSH Key 
 
### Data Center Platform
* [Mesosphere DC/OS](dcos/README.md). Provision Mesosphere DC/OS cluster
* [Kubernetes](k8s/README.md). Provision Kubernetes cluster
* [Slurm](slurm/README.md). Provision Slurm cluster
* [Yarn](yarn/README.md). Provision Yarn cluster. With optional add-on Spark and XGBoost.
* [LSF](https://github.ibm.com/yanglei/terraform_lsf). Provision IBM Spectrum Scale LSF cluster.

### Specific Cluster
* [XGBoost Scenario](xgboost/README.md). Provision XGBoost Spark Cluster
* [Data Ingestion Scenario](ingest/README.md). Provision Zookeeper, Spark, Kafka clusters for data ingestion.

### Terraform UI

* [Jupyter Notebook in Python3](ui/Terraform_UI.ipynb)

### Verified

* Terraform: 0.9.8
* Terraform Softlayer Provider: 1.5.1


### Useful Terraform Command

	terraform plan
	terraform graph
	
	terraform apply
	terraform show
	
	terraform plan --destroy
	terraform destroy

