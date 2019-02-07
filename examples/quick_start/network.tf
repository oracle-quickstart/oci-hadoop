############################################
# Create VCN
############################################
resource "oci_core_virtual_network" "HadoopVCN" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "HadoopVCN"
  cidr_block     = "${var.vcn_cidr}"
  dns_label      = "HadoopVCN"
}

############################################
# Create Internet Gateway
############################################
resource "oci_core_internet_gateway" "HadoopIG" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.HadoopVCN.id}"
  display_name   = "HadoopIG"
}

############################################
# Create NAT Gateway
############################################
resource "oci_core_nat_gateway" "HadoopNG" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.HadoopVCN.id}"
  display_name   = "HadoopNG"
}

############################################
# Create Route Table
############################################
resource "oci_core_route_table" "public" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.HadoopVCN.id}"
  display_name   = "public"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.HadoopIG.id}"
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.HadoopVCN.id}"
  display_name   = "private"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_nat_gateway.HadoopNG.id}"
  }
}

############################################
# Create Security List
############################################
resource "oci_core_security_list" "HadoopPrivate" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "HadoopPrivate"
  vcn_id         = "${oci_core_virtual_network.HadoopVCN.id}"

  egress_security_rules = [{
    destination = "0.0.0.0/0"
    protocol    = "6"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 22
      "min" = 22
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  },
    {
      tcp_options {
        "max" = "${var.nn_port}"
        "min" = "${var.nn_port}"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "${var.rm_port}"
        "min" = "${var.rm_port}"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "${var.jhs_port}"
        "min" = "${var.jhs_port}"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "9000"
        "min" = "9000"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "8033"
        "min" = "8030"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "8080"
        "min" = "8080"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "10033"
        "min" = "10033"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "10020"
        "min" = "10020"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "50075"
        "min" = "50075"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "50010"
        "min" = "50010"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "57068"
        "min" = "57068"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "50020"
        "min" = "50020"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "8042"
        "min" = "8042"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "8040"
        "min" = "8040"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "13562"
        "min" = "13562"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "7999"
        "min" = "7999"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
    {
      tcp_options {
        "max" = "60050"
        "min" = "60000"
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
  ]
}

resource "oci_core_security_list" "hadoopBastion" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "hadoopBastion"
  vcn_id         = "${oci_core_virtual_network.HadoopVCN.id}"

  egress_security_rules = [{
    tcp_options {
      "max" = 22
      "min" = 22
    }

    protocol    = "6"
    destination = "${var.vcn_cidr}"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 22
      "min" = 22
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  }]
}

resource "oci_core_security_list" "hadoopLB" {
  display_name   = "hadoopLB"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.HadoopVCN.id}"

  egress_security_rules = [{
    protocol    = "all"
    destination = "0.0.0.0/0"
  }]

  ingress_security_rules = [
    {
      tcp_options {
        "min" = 443
        "max" = 443
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
  ]
}

############################################
# Create Master Subnet
############################################
resource "oci_core_subnet" "hadoopMasterSubnetAD" {
  availability_domain = "${data.template_file.ad_names.*.rendered[0]}"
  cidr_block          = "${cidrsubnet(local.app_subnet_prefix, 3, 4)}"
  display_name        = "${var.label_prefix}HadoopMasterSubnetAD"
  dns_label           = "masterad"
  security_list_ids   = ["${oci_core_security_list.HadoopPrivate.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.HadoopVCN.id}"
  route_table_id      = "${oci_core_route_table.private.id}"
  dhcp_options_id     = "${oci_core_virtual_network.HadoopVCN.default_dhcp_options_id}"
}

############################################
# Create Slave Subnet
############################################
resource "oci_core_subnet" "hadoopSlaveSubnetAD" {
  count               = "${length(data.template_file.ad_names.*.rendered)}"
  availability_domain = "${data.template_file.ad_names.*.rendered[count.index]}"
  cidr_block          = "${cidrsubnet(local.app_subnet_prefix, 3, count.index)}"
  display_name        = "${var.label_prefix}HadoopSlaveSubnetAD${count.index+1}"
  dns_label           = "slavead${count.index+1}"
  security_list_ids   = ["${oci_core_security_list.HadoopPrivate.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.HadoopVCN.id}"
  route_table_id      = "${oci_core_route_table.private.id}"
  dhcp_options_id     = "${oci_core_virtual_network.HadoopVCN.default_dhcp_options_id}"
}

############################################
# Create Bastion Subnet
############################################
resource "oci_core_subnet" "hadoopBastion" {
  availability_domain = "${data.template_file.ad_names.*.rendered[var.bastion_ad_index]}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "hadoopBastionAD${var.bastion_ad_index+1}"
  cidr_block          = "${cidrsubnet(local.bastion_subnet_prefix, 3, 0)}"
  security_list_ids   = ["${oci_core_security_list.hadoopBastion.id}"]
  vcn_id              = "${oci_core_virtual_network.HadoopVCN.id}"
  route_table_id      = "${oci_core_route_table.public.id}"
  dhcp_options_id     = "${oci_core_virtual_network.HadoopVCN.default_dhcp_options_id}"
}

############################################
# Create LoadBalancer Subnet
############################################
resource "oci_core_subnet" "hadoopLBSubnet1" {
  availability_domain = "${data.template_file.ad_names.*.rendered[0]}"
  cidr_block          = "${cidrsubnet(local.lb_subnet_prefix, 3, 0)}"
  display_name        = "hadoopLBSubnet1"
  dns_label           = "subnet1"
  security_list_ids   = ["${oci_core_security_list.hadoopLB.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.HadoopVCN.id}"
  route_table_id      = "${oci_core_route_table.public.id}"
  dhcp_options_id     = "${oci_core_virtual_network.HadoopVCN.default_dhcp_options_id}"
}

resource "oci_core_subnet" "hadoopLBSubnet2" {
  availability_domain = "${data.template_file.ad_names.*.rendered[1]}"
  cidr_block          = "${cidrsubnet(local.lb_subnet_prefix, 3, 1)}"
  display_name        = "hadoopLBSubnet2"
  dns_label           = "subnet2"
  security_list_ids   = ["${oci_core_security_list.hadoopLB.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.HadoopVCN.id}"
  route_table_id      = "${oci_core_route_table.public.id}"
  dhcp_options_id     = "${oci_core_virtual_network.HadoopVCN.default_dhcp_options_id}"
}
