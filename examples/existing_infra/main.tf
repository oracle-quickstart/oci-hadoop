############################################
# Datasource
############################################
# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ad" {
  compartment_id = "${var.tenancy_ocid}"
}

data "template_file" "ad_names" {
  count    = "${length(data.oci_identity_availability_domains.ad.availability_domains)}"
  template = "${lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")}"
}

############################################
# Provider
############################################
provider "oci" {
  version          = ">= 3.4.0"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

# ##############################################################################
# Deploy Hadoop Cluster
# ##############################################################################
module "hadoop" {
  source              = "../../"
  compartment_ocid    = "${var.compartment_ocid}"
  hadoop_version      = "${var.hadoop_version}"
  master_ad           = "${data.template_file.ad_names.*.rendered[0]}"
  master_subnet_id    = "${oci_core_subnet.hadoopMasterSubnetAD.id}"
  master_image_id     = "${var.image_id[var.region]}"
  slave_count         = "${var.slave_count}"
  slave_ads           = "${data.template_file.ad_names.*.rendered}"
  slave_subnet_ids    = "${split(",",join(",", oci_core_subnet.hadoopSlaveSubnetAD.*.id))}"
  slave_image_id      = "${var.image_id[var.region]}"
  ssh_authorized_keys = "${var.ssh_authorized_keys}"
  ssh_private_key     = "${var.ssh_private_key}"
  bastion_host        = "${oci_core_instance.hadoopBastion.public_ip}"
  bastion_user        = "${var.bastion_user}"
  bastion_private_key = "${var.bastion_private_key}"
}
