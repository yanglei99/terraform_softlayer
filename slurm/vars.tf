
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

variable "softlayer_bm_fixed_config" {
  description = "Hourly BareMetal fixed config"
  default = "D2620V4_128GB_2X800GB_SSD_RAID_1_K80_GPU2"
}

variable "softlayer_bm_fixed_config_cores" {
  description = "CPU cores for BM"
  default = "32"
}

variable "softlayer_bm_fixed_config_gpu" {
  description = "GPU cores for BM"
  default = "4"
}

variable "enable_iptables" {
  description = "Enable iptables"
  default = true
}


variable "enable_gpu" {
  description = "Enable GPU installation"
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

variable "wait_time_bm" {
  description = "Wait time in second after BM up"
  default = "30"
}

variable "cluster_name" {
  description = "Name of your cluster."
  default = "myslurm"
}

variable "master_count" {
  description = "Number of Slurm controller to deploy"
  default = "1"
}

variable "master_cores" {
  description = "Slurm controller VM cores"
  default = "2"
}

variable "master_memory" {
  description = "Slurm controller VM memory"
  default = "4096"
}

variable "master_disk" {
  description = "Slurm controller disk array"
  type    = "list"
  default = ["25"] 
}

variable "master_network" {
  description = "Slurm controller VM network"
  default = 1000
}

variable "master_iscompute" {
  description = "Slurm controller VM is also compute node"
  default = false
}

variable "worker_count" {
  description = "Number of Slurm worker to deploy"
  default = "1"
}

variable "worker_cores" {
  description = "Slurm worker VM cores"
  default = "2"
}

variable "worker_memory" {
  description = "Slurm worker VM memory"
  default = "4096"
}

variable "worker_disk" {
  description = "Slurm worker VM disk array"
  type    = "list"
  default = ["25"] 
}

variable "worker_network" {
  description = "Slurm worker VM network"
  default = 1000
}

variable "bm_worker_count" {
  description = "Number of baremetal workers to deploy"
  default = "0"
}

