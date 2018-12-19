# Oracle Cloud Infrastructure Hadoop Terraform Module

Apache Hadoop is an open-source software for reliable, scalable, distributed computing.  Hadoop framework allows distributed processing of large data sets across clusters of computers using simple programming models

Oracle Cloud Infrastructure Hadoop Terraform Module deploys a secure Hadoop replica set on Oracle Cloud Infrastructure (OCI) using Terraform.

## Prerequisites
1. [Download and install Terraform](https://www.terraform.io/downloads.html) (v0.10.3 or later)
2. [Download and install the OCI Terraform Provider](https://github.com/oracle/terraform-provider-oci) (v2.0.0 or later)
3. Export OCI credentials using guidance at [Export Credentials](https://github.com/oracle/terraform-provider-oci#export-credentials).

## Usage

```hcl
module "hadoop" {
  source               = "./modules"
  compartment_id       = "${var.compartment_ocid}"
  display_name         = "${var.display_name}"
  availability_domains = "${var.availability_domains}"
  image_id             = "${var.image_id}"
  subnet_ids           = "${var.subnet_ids}"
  ssh_authorized_keys  = "${var.ssh_authorized_keys}"
  ssh_private_key      = "${var.ssh_private_key}"
  bastion_host         = "${var.bastion_public_ip}"
  bastion_user         = "${var.bastion_user}"
  bastion_private_key  = "${var.bastion_private_key}"
}
```
