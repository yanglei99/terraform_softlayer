output "agent-ip" {
  value = "${join(",", softlayer_virtual_guest.dcos_agent.*.ipv4_address)}"
}
output "agent-public-ip" {
  value = "${join(",", softlayer_virtual_guest.dcos_public_agent.*.ipv4_address)}"
}
output "master-ip" {
  value = "${join(",", softlayer_virtual_guest.dcos_master.*.ipv4_address)}"
}
output "bootstrap-ip" {
  value = "${softlayer_virtual_guest.dcos_bootstrap.ipv4_address}"
}

output "Use this link to access DCOS" {
  value = "http://${softlayer_virtual_guest.dcos_master.0.ipv4_address}/"
}
