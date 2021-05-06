
data "oci_core_vnic_attachments" "edge_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  instance_id         = oci_core_instance.Edge.id
}

data "oci_core_vnic" "edge_vnic" {
  vnic_id = lookup(data.oci_core_vnic_attachments.edge_vnics.vnic_attachments[0],"vnic_id")
}
