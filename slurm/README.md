## softlayer-terraform-slurm

[Terraform](https://www.terraform.io/) configuration and scripts for provision [Slurm cluster](https://slurm.schedmd.com) on [Softlayer](https://softlayer.com/)

[Reference Slurm Installation](https://www.slothparadise.com/how-to-install-slurm-on-centos-7-cluster/)

### Cluster Topology

There are 3 kinds of nodes: master, worker, Bare Metal (with GPU option) worker.

### Software Version

* Slurm 17.02.6 on CENTOS 7

#### Master node details

* munge
* slurmctld
* NFS mount to a provisioned file storage
* [option] slurmd

####  Worker node details

* munge
* slurmd
* NFS mount to a provisioned file storage


### To use:

* Clone or download repo.

* Generate a `do-key` keypair (with an empty passphrase):

	ssh-keygen -t rsa -P '' -f ./do-key

* Copy [sample.terraform.tfvars](./sample.terraform.tfvars) to `terraform.tfvars` and revise your variables. Reference [vars.tf](./vars.tf) for variable definitions

* Download [slurm-17.02.6.tar.bz2](https://www.schedmd.com/downloads.php)

* Run Provision

	terraform apply

#### To verify

Log onto one of the node, run  commands like [slurm_cmd.txt](test/slurm_cmd.txt)


#### Configuration Details

| Scenario | Configuration | Default Value | Notes|
|----------|---------------|-------|------|
|Wait Time for VM  | wait_time_vm   | 15   | Adjust the value to make sure remote provisioner actions only start after VM is ready.|
|Wait Time for BareMetal  | wait_time_bm   | 30   | Adjust the value to make sure remote provisioner actions only start after BareMetal is ready.|
|Slurm Configuration Template| |[slurm.conf](./install/slurm.conf.template) | Cluster related configuration are auto generated and add-on to the defaults |
|Slurm cgroup configuration ||[cgroup.conf](./install/cgroup.conf), [cgroup_allowed_devices_file.conf](./install/cgroup_allowed_devices_file.conf) |
|Enable GPU on BareMetal Worker| enable_gpu |false | When enabled, will install NVIDIA M80 and CUDA|


### Known issue, limitation and workaround

* Provision has specific code for CENTOS and alike
* Only provision single master 
* When Iptable is enabled, slurmd fails to start
