softlayer_user = ""
softlayer_api_key = ""

softlayer_domain = "yl.softlayer.com"
softlayer_datacenter = "mex01"

softlayer_os_reference_code = "CENTOS_LATEST_64"
softlayer_vm_user = "root"

cluster_name = "myk8s"

master_cores= "4"
master_memory = "8192"
master_disk = ["25"]
master_network = 1000

worker_cores= "2"
worker_memory = "4096"
worker_disk = ["25"]
worker_network = 1000

master_count = "1"
worker_count = "1"

ssh_key_path = "./do-key"
ssh_public_key_path = "./do-key.pub"

provision_vm_wait_time=30

k8s_proxy_port = "8181"
k8s_weave_iprange = "11.32.0.0\\/12"
k8s_service_cidr = "12.32.0.0/12"
k8s_cluster_dns = "12.32.0.10"
k8s_weave_monitor_service_token = ""