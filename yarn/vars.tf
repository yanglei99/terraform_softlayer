
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
  default = "CENTOS_LATEST_64"
}

variable "softlayer_vm_user" {
  description = "Softlayer OS VM user"
  default = "core"
}

variable "ssh_key_path" {
  description = "Path to your private SSH key path"
  default = "./do-key"
}

variable "ssh_public_key_path" {
  description = "Path to your public SSH key path"
  default = "./do-key.pub"
}

variable "enable_iptables" {
  description = "Enable iptables"
  default = true
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

variable "wait_time_vm" {
  description = "Wait time in second after VM up"
  default = "15"
}

variable "cluster_name" {
  description = "Name of your cluster."
  default = "myyarn"
}

variable "master_count" {
  description = "Number of NameNode to deploy"
  default = "1"
}

variable "master_cores" {
  description = "Master VM cores"
  default = "2"
}

variable "master_memory" {
  description = "Master VM memory"
  default = "4096"
}

variable "master_disk" {
  description = "Master disk array"
  type    = "list"
  default = ["25"] 
}

variable "master_network" {
  description = "Master VM network"
  default = 1000
}

variable "worker_count" {
  description = "Number of DataNode to deploy"
  default = "1"
}

variable "worker_cores" {
  description = "Worker VM cores"
  default = "2"
}

variable "worker_memory" {
  description = "Worker VM memory"
  default = "4096"
}

variable "worker_disk" {
  description = "Worker VM disk array"
  type    = "list"
  default = ["25"] 
}

variable "worker_network" {
  description = "Worker VM network"
  default = 1000
}

variable "hadoop_verion" {
  description = "Hadoop Version"
  default = "2.6.5"
}

variable "hadoop_password" {
  description = "Hadoop Password"
  default = "hd123ps"
}
