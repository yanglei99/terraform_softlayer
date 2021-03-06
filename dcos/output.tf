output "agent-ip-public" {
  value = "${join(",", softlayer_virtual_guest.dcos_agent.*.ipv4_address)}"
}

output "agent-ip-private" {
  value = "${join(",", softlayer_virtual_guest.dcos_agent.*.ipv4_address_private)}"
}

output "public-agent-ip-public" {
  value = "${join(",", softlayer_virtual_guest.dcos_public_agent.*.ipv4_address)}"
}

output "public-agent-ip-private" {
  value = "${join(",", softlayer_virtual_guest.dcos_public_agent.*.ipv4_address_private)}"
}

output "bm-agent-ip-public" {
  value = "${join(",", softlayer_bare_metal.dcos_bm_agent.*.public_ipv4_address)}"
}

output "bm-agent-ip-private" {
  value = "${join(",", softlayer_bare_metal.dcos_bm_agent.*.private_ipv4_address)}"
}

output "master-ip-private" {
  value = "${join(",", softlayer_virtual_guest.dcos_master.*.ipv4_address_private)}"
}

output "master-ip-public" {
  value = "${join(",", softlayer_virtual_guest.dcos_master.*.ipv4_address)}"
}

output "bootstrap-ip" {
  value = "${softlayer_virtual_guest.dcos_bootstrap.ipv4_address}"
}

output "Use this link to access DCOS" {
  value = "http://${softlayer_virtual_guest.dcos_master.0.ipv4_address}/"
}

output "storage-mountpoint" {
  value = "${softlayer_file_storage.storage.mountpoint }"
}

