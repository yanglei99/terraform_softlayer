
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

variable "cluster_name" {
  description = "Name of your cluster. Alpha-numeric and hyphens only."
  default = "mycluster"
}

variable "master_count" {
  description = "K8s master VM cores"
  default = "1"
}

variable "master_cores" {
  description = "k8s master VM cores"
  default = "2"
}

variable "master_memory" {
  description = "k8s master VM memory"
  default = "4096"
}

variable "master_disk" {
  description = "k8s master VM disk array"
  type    = "list"
  default = ["25"] 
}

variable "master_network" {
  description = "k8s master VM network"
  default = 1000
}


variable "worker_cores" {
  description = "k8s worker VM cores"
  default = "2"
}

variable "worker_memory" {
  description = "k8s worker VM memory"
  default = "4096"
}

variable "worker_disk" {
  description = "k8s worker VM disk array"
  type    = "list"
  default = ["25"] 
}

variable "worker_network" {
  description = "k8s worker VM network"
  default = 1000
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

variable "k8s_proxy_port" {
  description = "k8s local proxy port"
  default = "8001"
}

variable "k8s_weave_iprange" {
  description = "k8s weave IPALLOC_RANGE"
  default = ""
}

variable "k8s_service_cidr" {
  description = "k8s service-cidr"
  default = ""
}

variable "k8s_cluster_dns" {
  description = "k8s cluster-dns"
  default = ""
}

variable "k8s_weave_monitor_service_token"{
  description = "enable k8s weave network monitor with the token"
  default = ""
}
