provider "softlayer" {
    username = ""
    api_key = ""
}

# This will create a new SSH key that will show up under the \
# Devices>Manage>SSH Keys in the SoftLayer console.
resource "softlayer_ssh_key" "terraform17" {
    label = "terraform17"
    notes = "terraform key for 2017"
    public_key = "${file("do-key.pub")}"
}

# Virtual Server created with existing SSH Key already in SoftLayer \
# inventory and not created using this Terraform template.
resource "softlayer_virtual_guest" "test_server" {
 
    count  = 2
    hostname = "${format("server-%02d", count.index)}"
    domain = "yl.softlayer.com"
    ssh_key_ids = ["${softlayer_ssh_key.terraform17.id}"]
    os_reference_code = "CENTOS_LATEST_64"
    datacenter = "sjc03"
    hourly_billing = "true"
    local_disk = "true"
    network_speed = 1000
    cores = 2
    memory = 4096
    disks =[25]
}

# Create 20G endurance file storage with 10G snapshot capacity and 0.25 IOPS/GB option.
resource "softlayer_file_storage" "storage" {
	    depends_on = ["softlayer_virtual_guest.test_server"]

        type = "Endurance"
        datacenter = "sjc03"
        capacity = 20
        iops = 0.25
        
        # Optional fields
        allowed_virtual_guest_ids =  ["${softlayer_virtual_guest.test_server.*.id}"]
        snapshot_capacity = 10
}

resource "null_resource" "nfs" {
    
    count = 2
    depends_on = ["softlayer_file_storage.storage"]
    connection {
      user = "root"
      private_key = "${file("do-key")}"
      host = "${element(softlayer_virtual_guest.test_server.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "./install_nfs.sh"
      destination = "/tmp/install_nfs.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/install_nfs.sh ${softlayer_file_storage.storage.mountpoint} /share_data > /tmp/installNFS.log"
	}

}