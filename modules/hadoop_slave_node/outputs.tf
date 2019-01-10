output "ids" {
  value = "${oci_core_instance.TFhadoopSlave.*.id}"
}

output "private_ips" {
  value = "${oci_core_instance.TFhadoopSlave.*.private_ip}"
}

output "slave_host_names" {
  value = "${oci_core_instance.TFhadoopSlave.*.display_name}"
}
