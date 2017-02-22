softlayer_user = ""

softlayer_api_key = ""

datacenter = "mex01"

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

wait_time_masters=300
wait_time_agent=15