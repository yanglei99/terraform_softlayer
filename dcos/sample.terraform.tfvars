softlayer_user = ""

softlayer_api_key = ""

softlayer_domain = "yl.softlayer.com"
softlayer_datacenter = "sjc03"

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

master_cores= "4"
master_memory = "8192"
master_disk = ["25"]
master_network = 1000

agent_cores= "4"
agent_memory = "8192"
agent_disk = ["100"]
agent_network = 1000

boot_cores= "4"
boot_memory = "8192"
boot_disk = ["25"]
boot_network = 1000

dcos_cluster_name = "mydcos"

dcos_master_count = "1"
dcos_agent_count = "3"
dcos_public_agent_count = "2"

dcos_bm_agent_count = "0"

softlayer_bm_fixed_config = "D2620V4_128GB_2X800GB_SSD_RAID_1_K80_GPU2"
enable_gpu = true

#dcos_installer_url = "https://downloads.dcos.io/dcos/EarlyAccess/dcos_generate_config.sh"
dcos_installer_url = "https://downloads.dcos.io/dcos/stable/1.9.2/dcos_generate_config.sh?_ga=2.234161306.540963340.1501782101-96172467.1466007590"

dcos_ssh_key_path = "./do-key"

dcos_ssh_public_key_path = "./do-key.pub"

wait_time_vm=30
wait_time_bm=60

enable_iptables = "true"

enable_file_storage = true
nfs_dir = "/shared_data"
storage_type = "Endurance"
storage_capacity = 20
storage_iops = 2
storage_snapshot_capacity = 10

nr_license = ""
