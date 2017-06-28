
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

variable "agent_cores" {
  description = "DCOS Agent VM cores"
  default = "2"
}

variable "agent_memory" {
  description = "DCOS Agent VM memory"
  default = "4096"
}

variable "agent_disk" {
  description = "DCOS Agent VM disk array"
  type    = "list"
  default = ["25"] 
}

variable "agent_network" {
  description = "DCOS Agent VM network"
  default = 1000
}


variable "master_cores" {
  description = "DCOS Master VM cores"
  default = "2"
}

variable "master_memory" {
  description = "DCOS Master VM memory"
  default = "4096"
}

variable "master_disk" {
  description = "DCOS Master VM disk array"
  type    = "list"
  default = ["25"] 
}

variable "master_network" {
  description = "DCOS Master VM network"
  default = 1000
}

variable "boot_cores" {
  description = "DCOS Boot Server VM cores"
  default = "4"
}

variable "boot_memory" {
  description = "DCOS Boot Server VM memory"
  default = "4096"
}

variable "boot_disk" {
  description = "DCOS Boot Server VM disk array"
  type    = "list"
  default = ["25"] 
}

variable "boot_network" {
  description = "DCOS Boot Server VM network"
  default = 1000
}

variable "dcos_cluster_name" {
  description = "Name of your cluster. Alpha-numeric and hyphens only, please."
  default = "softlayer-dcos"
}

variable "dcos_master_count" {
  default = "3"
  description = "Number of master nodes. 1, 3, or 5."
}

variable "dcos_agent_count" {
  description = "Number of agents to deploy"
  default = "1"
}

variable "dcos_public_agent_count" {
  description = "Number of public agents to deploy"
  default = "1"
}

variable "dcos_ssh_key_path" {
  description = "Path to your private SSH key path"
  default = "./do-key"
}

variable "dcos_ssh_public_key_path" {
  description = "Path to your public SSH key path"
  default = "./do-key.pub"
}

variable "dcos_installer_url" {
  description = "Path to get DCOS"
  default = "https://downloads.dcos.io/dcos/EarlyAccess/dcos_generate_config.sh"
}

variable "wait_time_vm" {
  description = "Wait time in second after VM up"
  default = "15"
}

variable "dcos_install_docker" {
  description = "Need to install docker or not. COREOS has Docker already installed"
  default = false
}

variable "dcos_install_logging" {
  description = "Need to install logging (ELK) or not. Only tested on CENTOS"
  default = false
}

variable "dcos_install_monitoring" {
  description = "Need to install monitoring (cAdvisor + InfluxDB + Grafana) or not."
  default = false
}

variable "nr_license" {
  description = "Your NewRelic License"
  default = ""
}

variable "enable_iptables" {
  description = "Enable iptables"
  default = "true"
}

variable "enable_file_storage" {
  description = "Enable shared file storage"
  default = false
}

variable "nfs_dir" {
  description = "NFS directory"
  default = "/shared_data"
}

variable "storage_type" {
  description = "Softlayer File Storage Type"
  default = "Endurance"
}

variable "storage_capacity" {
  description = "Softlayer File Storage Capacity"
  default = 20
}

variable "storage_iops" {
  description = "Softlayer File Storage iops"
  default = 0.25
}

variable "storage_snapshot_capacity" {
  description = "Softlayer File Storage Snapshot Capacity"
  default = 10
}
