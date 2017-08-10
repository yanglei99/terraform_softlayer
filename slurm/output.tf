output "master-ip-public" {
  value = "${join(",", softlayer_virtual_guest.slurm_master.*.ipv4_address)}"
}

output "master-ip-private" {
  value = "${join(",", softlayer_virtual_guest.slurm_master.*.ipv4_address_private)}"
}

output "worker-ip-public" {
  value = "${join(",", softlayer_virtual_guest.slurm_worker.*.ipv4_address)}"
}

output "worker-ip-private" {
  value = "${join(",", softlayer_virtual_guest.slurm_worker.*.ipv4_address_private)}"
}

output "bm-worker-ip-public" {
  value = "${join(",", softlayer_bare_metal.slurm_bm_worker.*.public_ipv4_address)}"
}

output "bm-worker-ip-private" {
  value = "${join(",", softlayer_bare_metal.slurm_bm_worker.*.private_ipv4_address)}"
}

output "storage-mountpoint" {
  value = "${softlayer_file_storage.storage.mountpoint }"
}

