variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_authorized_keys" {}
variable "ssh_private_key" {}

variable "label_prefix" {
  default = ""
}

variable "image_id" {
  type = "map"

  # --------------------------------------------------------------------------
  # Oracle-provided image "Oracle-Linux-7.4-2018.02.21-1"
  # See https://docs.us-phoenix-1.oraclecloud.com/images/
  # --------------------------------------------------------------------------
  default = {
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaaupbfz5f5hdvejulmalhyb6goieolullgkpumorbvxlwkaowglslq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaajlw3xfie2t5t52uegyhiq2npx7bqyu4uvi2zyu3w3mqayc2bxmaa"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7d3fsb6272srnftyi4dphdgfjf6gurxqhmv6ileds7ba3m2gltxq"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaaa6h6gj6v4n56mqrbgnosskq63blyv2752g36zerymy63cfkojiiq"
  }
}

variable "nn_port" {
  default = 50070
}

variable "rm_port" {
  default = 8088
}

variable "jhs_port" {
  default = 19888
}

variable "hadoop_version" {
  default = "2.9.2"
}

variable "slave_count" {
  default = "3"
}

variable "bastion_display_name" {
  default = "hadoopBastion"
}

variable "bastion_shape" {
  default = "VM.Standard2.1"
}

variable "bastion_host" {
  default = ""
}

variable "bastion_user" {
  default = "opc"
}

variable "bastion_authorized_keys" {}
variable "bastion_private_key" {}

variable "bastion_ad_index" {
  default = 0
}
