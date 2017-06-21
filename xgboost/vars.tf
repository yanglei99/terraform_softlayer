
variable "softlayer_user" {
  description = "Your Softlayer user name"
}

variable "softlayer_api_key" {
  description = "Your Softlayer API key"
}

variable "softlayer_domain" {
  description = "Softlayer Domain"
  default = "my.softlayer.com"
}

variable "softlayer_datacenter" {
  description = "Softlayer DataCenter"
  default = "mex01"
}

variable "softlayer_os_reference_code" {
  description = "Softlayer OS reference code"
  default = "COREOS_LATEST_64"
}

variable "softlayer_vm_user" {
  description = "Softlayer OS VM user"
  default = "core"
}

variable "master_cores" {
  description = "Ingest master VM cores"
  default = "2"
}

variable "master_memory" {
  description = "Ingest master VM memory"
  default = "4096"
}

variable "master_disk" {
  description = "Ingest master VM disk array"
  type    = "list"
  default = ["25"] 
}

variable "master_network" {
  description = "Ingest master VM network"
  default = 1000
}

variable "worker_cores" {
  description = "Ingest worker VM cores"
  default = "2"
}

variable "worker_memory" {
  description = "Ingest worker VM memory"
  default = "4096"
}

variable "worker_disk" {
  description = "Ingest worker VM disk array"
  type    = "list"
  default = ["25"] 
}

variable "worker_network" {
  description = "Ingest worker VM network"
  default = 1000
}

variable "master_count" {
  default = "3"
  description = "Number of ZK nodes. 1, 3, or 5."
}

variable "worker_count" {
  description = "Number of worker to deploy"
  default = "1"
}

variable "ssh_key_path" {
  description = "Path to your private SSH key path"
  default = "./do-key"
}

variable "ssh_public_key_path" {
  description = "Path to your public SSH key path"
  default = "./do-key.pub"
}

variable "provision_vm_wait_time" {
  description = "Wait time in second after VM up"
  default = "15"
}

variable "provision_zk_wait_time" {
  description = "Wait time in second after Zookeeper cluster up"
  default = "120"
}

variable "cluster_name" {
  description = "Name of your cluster. Alpha-numeric and hyphens only."
  default = "mycluster"
}

variable "install_docker" {
  description = "Need to install docker or not. COREOS has Docker already installed"
  default = false
}

variable "master_public_ip" {
  description = "Use public ip for spark master"
  default = true
}


