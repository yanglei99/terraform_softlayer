
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
  default = "root"
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

variable "hadoop_version" {
  description = "Hadoop Version"
  default = "2.6.5"
}

variable "hadoop_password" {
  description = "Hadoop Password"
  default = "hd123ps"
}

variable "spark_version" {
  description = "Spark Version"
  default = ""
}

variable "enable_gpu" {
  description = "Enable GPU installation"
  default = true
}

variable "softlayer_bm_fixed_config" {
  description = "Hourly BareMetal fixed config"
  default = "D2620V4_128GB_2X800GB_SSD_RAID_1_K80_GPU2"
}

variable "softlayer_bm_fixed_config_cores" {
  description = "CPU cores for BM"
  default = "32"
}

variable "softlayer_bm_fixed_config_memory" {
  description = "CPU memory for BM"
  default = "128"
}

variable "softlayer_bm_fixed_config_gpu" {
  description = "GPU cores for BM"
  default = "4"
}

variable "bm_worker_count" {
  description = "Number of baremetal workers to deploy"
  default = "0"
}

variable "wait_time_bm" {
  description = "Wait time in second after BM up"
  default = "30"
}

variable "enable_xgboost" {
  description = "Enable XGBoost installation"
  default = false
}

variable "xgboost_patch" {
  description = "The patch for dmlc-core, such as the AWS_HOST enablement"
  default = ""
}