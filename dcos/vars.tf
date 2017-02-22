
variable "softlayer_user" {
  description = "Your Softlayer user name"
}

variable "softlayer_api_key" {
  description = "Your Softlayer API key"
}

variable "datacenter" {
  description = "Softlayer DataCenter"
  default = "mex01"
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

variable "wait_time_masters" {
  description = "Wait time in second for all masters up"
  default = "300"
}

variable "wait_time_agent" {
  description = "Wait time in second after agent VM up"
  default = "15"
}
