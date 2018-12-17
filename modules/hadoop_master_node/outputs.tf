output "id" {
  value = "${oci_core_instance.TFhadoopMaster.id}"
}

output "private_ip" {
  value = "${oci_core_instance.TFhadoopMaster.private_ip}"
}

output "public_ip" {
  value = "${oci_core_instance.TFhadoopMaster.public_ip}"
}
