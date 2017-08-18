softlayer_user = ""
softlayer_api_key = ""

softlayer_domain = "yl.softlayer.com"
softlayer_datacenter = "tor01"

softlayer_os_reference_code = "CENTOS_LATEST_64"
softlayer_vm_user = "root"

cluster_name = "myslurm"

ssh_key_path = "./do-key"
ssh_public_key_path = "./do-key.pub"

master_cores= "2"
master_memory = "4096"
master_disk = ["25"]
master_network = 1000
master_iscompute = true

worker_cores= "4"
worker_memory = "8192"
worker_disk = ["25"]
worker_network = 1000

master_count = "1"
worker_count = "2"
bm_worker_count = "0"

wait_time_vm=30
wait_time_bm=60

enable_file_storage = true
nfs_dir = "/shared_data"
storage_type = "Endurance"
storage_capacity = 20
storage_iops = 2
storage_snapshot_capacity = 10

softlayer_bm_fixed_config = "D2620V4_128GB_2X800GB_SSD_RAID_1_K80_GPU2"
softlayer_bm_fixed_config_cores = 32
softlayer_bm_fixed_config_gpu = 4
enable_gpu = true

enable_iptables = false


