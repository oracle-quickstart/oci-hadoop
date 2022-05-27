# ---------------------------------------------------------------------------------------------------------------------
# Environmental variables
# You probably want to define these as environmental variables.
# Instructions on that are here: https://github.com/oci-quickstart/oci-prerequisites
# ---------------------------------------------------------------------------------------------------------------------
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_public_key" {}
variable "instances" {}
variable "subnet_id" {}
variable "user_data" {}
variable "image_ocid" {}
variable "is_flex_shape" {}
variable "dynamic_ocpus" {}
variable "memory_in_gbs" {}
variable "hadoop_version" {}
variable "hadoop_par" {}
variable "zk_version" {}
variable "install_hive" {}
variable "hive_version" {}
variable "hive_par" {}
variable "cluster_name" {}
variable "worker_shape" {}
variable "worker_block_volume_count" {}
variable "worker_count" {}
variable "worker_ocpus" {}
variable "worker_memory" {}
variable "worker_domain" {}
variable "UsePrefix" {}
# ---------------------------------------------------------------------------------------------------------------------
# Optional variables
# You can modify these.
# ---------------------------------------------------------------------------------------------------------------------
variable "availability_domain" {
  default = "1"
}
# Number of Master Nodes in the Cluster
variable "master_node_count" {
  default = "2"
}
# Size for NameNode and SecondaryNameNode data volume (Journal Data)
variable "nn_volume_size_in_gbs" {
  default = "500"
}
# Set Cluster Shapes in this section
variable "master_instance_shape" {
  default = "VM.Standard2.8"
}
# ---------------------------------------------------------------------------------------------------------------------
# Constants
# You probably don't need to change these.
# ---------------------------------------------------------------------------------------------------------------------
