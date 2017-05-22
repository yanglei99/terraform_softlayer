softlayer_user = ""
softlayer_api_key = ""

softlayer_domain = "yl.softlayer.com"
softlayer_datacenter = "mex01"

softlayer_os_reference_code = "CENTOS_LATEST_64"
softlayer_vm_user = "root"

install_docker = true
cluster_name = "myingest"

#softlayer_os_reference_code = "COREOS_LATEST_64"
#softlayer_vm_user = "core"
#install_docker = false

master_cores= "4"
master_memory = "8192"
master_disk = ["25"]
master_network = 1000

worker_cores= "8"
worker_memory = "16384"
worker_disk = ["25"]
worker_network = 1000

master_count = "3"
worker_count = "1"

ssh_key_path = "./do-key"
ssh_public_key_path = "./do-key.pub"

master_install_kafka="true"
master_install_spark_worker="false"

worker_install_kafka="true"
worker_install_spark_worker="true"

provision_vm_wait_time=30
provision_zk_wait_time=300

