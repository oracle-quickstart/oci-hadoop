# ---------------------------------------------------------------------------------------------------------------------
# Environmental variables
# You probably want to define these as environmental variables.
# Instructions on that are here: https://github.com/oci-quickstart/oci-prerequisites
# ---------------------------------------------------------------------------------------------------------------------

variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}
variable "oci_service_gateway" {}
variable "VCN_CIDR" {}
variable "useExistingVcn" {}
variable "custom_vcn" {
  type = list(string)
  default = [" "]
}
variable "custom_cidrs" {
  default = "false"
}
variable "vcn_dns_label" {
  default = "hadoopvcn"
}
variable "public_cidr" {}
variable "private_cidr" {}
variable "blockvolume_cidr" {}
variable "enable_secondary_vnic" {}
variable "myVcn" {}
variable "privateSubnet" {
  default = " "
}
variable "publicSubnet" {
  default = " "
}
variable "blockvolumeSubnet" {
  default = " "
}
# ---------------------------------------------------------------------------------------------------------------------
# Optional variables
# You can modify these.
# ---------------------------------------------------------------------------------------------------------------------
