provider "softlayer" {
    username = ""
    api_key = ""
}

# Create a new scale group using image "CENTOS_LATEST_64"

resource "softlayer_scale_group" "asg" {
    name = "yl-asg"
    regional_group = "na-usa-west-2"
    minimum_member_count = 1
    maximum_member_count = 3
    cooldown = 30
    termination_policy = "CLOSEST_TO_NEXT_CHARGE"
    virtual_guest_member_template = {
      hostname = "ylasg"
      domain = "yl.softlayer.com"
      cores = 1
      memory = 1024
      network_speed = 100
      hourly_billing = true
      os_reference_code = "CENTOS_LATEST_64"
      # Optional Fields for virtual guest template (SL defaults apply):
      local_disk = true
      disks = [25]
      datacenter = "sjc03"
      post_install_script_uri = ""
      ssh_key_ids = []
    }
}