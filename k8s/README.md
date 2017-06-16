## softlayer-terraform-k8s

[Terraform](https://www.terraform.io/) configuration and scripts for provision Kubernetes cluster on [Softlayer](https://softlayer.com/)

Followed [K8s installation](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)

Here is the [provision graph](graph.png)

### Cluster Topology

There are two kinds of nodes, master and worker  Weave network add-on is enabled. 

Local environment (kubectl) is also enabled with proxy server. 

### Software Version

* Docker 1.12.6
* Kubernetes 1.6.4


### To use:

* Clone or download repo.

* Generate a `do-key` keypair (with an empty passphrase):

	ssh-keygen -t rsa -P '' -f ./do-key

* Copy [sample.terraform.tfvars](./sample.terraform.tfvars) to `terraform.tfvars` and revise your variables. Reference [vars.tf](./vars.tf) for variable definitions

* Run Provision

	terraform apply

#### Configuration Details

| Scenario | Configuration | Default Value | Notes|
|----------|---------------|-------|------|
|Wait Time for VM        | provision_vm_wait_time           | 15           | Adjust the value to make sure remote provisioner actions only start after VM is ready.|
|K8s Proxy Port          | k8s_proxy_port                   | "8001"       | Local proxy port. set to "" will disable the enablement |
|K8s weave pod ip range  | k8s_weave_iprange                | ""           | Set to non-empty to bypass weave default colliding with Softlayer private ip|
|K8s service ip range    | k8s_service_cidr                 | ""           | Set to non-empty to bypass default value colliding with Softlayer private ip|
|K8s cluster dns         | k8s_cluster_dns                  | ""           | Set to non-empty to bypass service default value colliding with Softlayer private ip|
|K8s Weave Monitor Token | k8s_weave_monitor_service_token  | ""           | set to non-empty string to create Weave Monitor agent |


### Known issue, limitation and workaround

* Provision has specific code for CENTOS and alike
* Only provision single master 
* The provisioner connection host is currently set on public ip. 
* [Additional code](install/install-k8s.sh) is added for solving v1.6.4 issues
