provider "softlayer" {
    username = ""
    api_key = ""
}

# This will create a new SSH key that will show up under the \
# Devices>Manage>SSH Keys in the SoftLayer console.
resource "softlayer_ssh_key" "terraform17" {
    label = "terraform17"
    notes = "terraform key for 2017"
    public_key = "${file("~/Documents/SELF/ssh-key/terraform17.pub")}"
}

# Virtual Server created with existing SSH Key already in SoftLayer \
# inventory and not created using this Terraform template.
resource "softlayer_virtual_guest" "test_server_1" {
    hostname = "server1"
    domain = "yl.softlayer.com"
    ssh_key_ids = ["${softlayer_ssh_key.terraform17.id}"]
    os_reference_code = "CENTOS_LATEST_64"
    datacenter = "sjc03"
    hourly_billing = "true"
    local_disk = "true"
    network_speed = 1000
    cores = 2
    memory = 4096
    disks =[25,100]
}


# Virtual Server created with a mix of previously existing and \
# Terraform created/managed resources.
resource "softlayer_virtual_guest" "test_server_2" {
    hostname = "server2"
    domain = "yl.softlayer.com"
    ssh_key_ids = ["${softlayer_ssh_key.terraform17.id}"]
    os_reference_code = "WIN_LATEST_64"
    datacenter = "sjc03"
    hourly_billing = "true"
    local_disk = "true"
    network_speed = 100
    cores = 2
    memory = 4096
    disks =[100]
}