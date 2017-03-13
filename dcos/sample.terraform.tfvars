softlayer_user = ""

softlayer_api_key = ""

softlayer_domain = "yl.softlayer.com"
softlayer_datacenter = "mex01"


softlayer_os_reference_code = "CENTOS_LATEST_64"
softlayer_vm_user = "root"
dcos_install_docker = true
dcos_install_logging = false
dcos_install_monitoring = false

#softlayer_os_reference_code = "COREOS_LATEST_64"
#softlayer_vm_user = "core"
#dcos_install_docker = false
#dcos_install_logging = false
#dcos_install_monitoring = false

master_cores= "2"
master_memory = "4096"
master_disk = ["25"]
master_network = 1000

agent_cores= "2"
agent_memory = "4096"
agent_disk = ["25"]
agent_network = 1000

boot_cores= "2"
boot_memory = "4096"
boot_disk = ["25"]
boot_network = 1000

dcos_cluster_name = "mydcos"

dcos_master_count = "3"

dcos_agent_count = "2"

dcos_public_agent_count = "2"

dcos_installer_url = "https://downloads.dcos.io/dcos/EarlyAccess/dcos_generate_config.sh"

dcos_ssh_key_path = "./do-key"

dcos_ssh_public_key_path = "./do-key.pub"

wait_time_vm=30