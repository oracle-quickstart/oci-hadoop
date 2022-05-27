# ---------------------------------------------------------------------------------------------------------------------
# Template variables
# You probably do not want to modify these
# Instructions on that are here: https://github.com/oci-quickstart/oci-prerequisites
# ---------------------------------------------------------------------------------------------------------------------
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_public_key" {}
variable "instances" {}
variable "subnet_id" {}
variable "blockvolume_subnet_id" {}
variable "user_data" {}
variable "image_ocid" {}
variable "block_volume_count" {}
variable "secondary_vnic_count" {
  default = "0"
}
variable "enable_secondary_vnic" {
  default = "false"
}
variable "worker_domain" {}
variable "worker_module_count" {}
variable "worker_count" {}
variable "hadoop_version" {}
variable "hadoop_par" {}
variable "install_hive" {}
variable "hive_version" {}
variable "hive_par" {}
variable "cluster_name" {}
variable "is_flex_shape" {}
variable "dynamic_ocpus" {}
variable "memory_in_gbs" {}
variable "UsePrefix" {}
# ---------------------------------------------------------------------------------------------------------------------
# Optional variables
# You can modify these.
# ---------------------------------------------------------------------------------------------------------------------
variable "availability_domain" {}
# Number of Workers per module - this shouldn't increment
variable "worker_node_count" {
  default = "1"
}
variable "hdfs_blocksize_in_gbs" {
  default = "1000"
}
variable "vpus_per_gb" {
   default = "10" 
}
# Set Cluster Shapes in this section
variable "worker_instance_shape" {
  default = "VM.Standard2.8"
}
#
# Static Mapping for Block Volumes
#
variable "data_volume_attachment_device" {
  type = map
  default = {
    "0" = "/dev/oracleoci/oraclevdb"
    "1" = "/dev/oracleoci/oraclevdc"
    "2" = "/dev/oracleoci/oraclevdd"
    "3" = "/dev/oracleoci/oraclevde"
    "4" = "/dev/oracleoci/oraclevdf"
    "5" = "/dev/oracleoci/oraclevdg"
    "6" = "/dev/oracleoci/oraclevdh"
    "7" = "/dev/oracleoci/oraclevdi"
    "8" = "/dev/oracleoci/oraclevdj"
    "9" = "/dev/oracleoci/oraclevdk"
    "10" = "/dev/oracleoci/oraclevdl" 
    "11" = "/dev/oracleoci/oraclevdm"
    "12" = "/dev/oracleoci/oraclevdn"
    "13" = "/dev/oracleoci/oraclevdo"
    "14" = "/dev/oracleoci/oraclevdp"
    "15" = "/dev/oracleoci/oraclevdq"
    "16" = "/dev/oracleoci/oraclevdr"
    "17" = "/dev/oracleoci/oraclevds"
    "18" = "/dev/oracleoci/oraclevdt"
    "19" = "/dev/oracleoci/oraclevdu"
    "20" = "/dev/oracleoci/oraclevdv"
    "12" = "/dev/oracleoci/oraclevdw"
    "22" = "/dev/oracleoci/oraclevdx" 
    "23" = "/dev/oracleoci/oraclevdy"
    "24" = "/dev/oracleoci/oraclevdz"
    "25" = "/dev/oracleoci/oraclevdab"
    "26" = "/dev/oracleoci/oraclevdac"
    "27" = "/dev/oracleoci/oraclevdad"
    "28" = "/dev/oracleoci/oraclevdae"
    "29" = "/dev/oracleoci/oraclevdaf"
    "30" = "/dev/oracleoci/oraclevdag"
    "31" = "/dev/oracleoci/oraclevdah"
  }
}
