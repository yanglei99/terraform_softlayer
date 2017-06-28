output "ip-public" {
  value = "${join(",", softlayer_virtual_guest.test_server.*.ipv4_address)}"
}

output "ip-private" {
  value = "${join(",", softlayer_virtual_guest.test_server.*.ipv4_address_private)}"
}

output "storage-mountpoint" {
  value = "${softlayer_file_storage.storage.mountpoint}"
}
