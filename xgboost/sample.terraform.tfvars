softlayer_user = ""
softlayer_api_key = ""

softlayer_domain = "yl.softlayer.com"
softlayer_datacenter = "sjc03"

softlayer_os_reference_code = "CENTOS_LATEST_64"
softlayer_vm_user = "root"

install_docker = true
cluster_name = "myxg"

master_cores= "4"
master_memory = "8192"
master_disk = ["100"]
master_network = 1000

worker_cores= "4"
worker_memory = "8192"
worker_disk = ["100"]
worker_network = 1000

master_count = "1"
worker_count = "2"

ssh_key_path = "./do-key"
ssh_public_key_path = "./do-key.pub"

provision_vm_wait_time=30
provision_zk_wait_time=5

