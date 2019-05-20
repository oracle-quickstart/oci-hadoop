output "id" {
  value = "${oci_core_instance.TFhadoopMaster.id}"
}

output "master_display_name" {
  value = "${oci_core_instance.TFhadoopMaster.display_name}"
}

output "private_ip" {
  value = "${oci_core_instance.TFhadoopMaster.private_ip}"
}
