softlayer_user = ""
softlayer_api_key = ""

softlayer_domain = "yl.softlayer.com"
softlayer_datacenter = "mex01"

softlayer_os_reference_code = "CENTOS_LATEST_64"
softlayer_vm_user = "root"

cluster_name = "myyarn"

ssh_key_path = "./do-key"
ssh_public_key_path = "./do-key.pub"

master_cores= "4"
master_memory = "8192"
master_disk = ["25"]
master_network = 1000
master_iscompute = false

worker_cores= "4"
worker_memory = "8192"
worker_disk = ["25"]
worker_network = 1000

worker_count = "2"

wait_time_vm=30

enable_file_storage = false
nfs_dir = "/shared_data"
storage_type = "Endurance"
storage_capacity = 20
storage_iops = 2
storage_snapshot_capacity = 10

enable_iptables = false

hadoop_verion = "2.6.5"
hadoop_password = "hd123ps"

