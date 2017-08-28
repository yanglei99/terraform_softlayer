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

worker_cores= "8"
worker_memory = "8192"
worker_disk = ["25"]
worker_network = 1000

worker_count = "2"

wait_time_vm=30

enable_iptables = false

hadoop_version = "2.7.1"
hadoop_password = "hd123ps"

spark_version = "spark-2.2.0-bin-hadoop2.7"