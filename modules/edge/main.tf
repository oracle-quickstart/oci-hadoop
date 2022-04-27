resource "oci_core_instance" "Edge" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  shape               = var.edge_instance_shape
  display_name        = var.UsePrefix ? "${var.cluster_name}-Edge" : "Edge"

  source_details {
    source_type             = "image"
    source_id               = var.image_ocid
  }

  create_vnic_details {
    subnet_id         = var.subnet_id
    display_name      = "Edge"
    hostname_label    = "Edge"
    assign_public_ip  = true 
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data		= var.user_data 
  }

  extended_metadata = {
    worker_shape        = var.worker_shape
    worker_block_volume_count  = var.worker_block_volume_count
    worker_count        = var.worker_count
    cluster_name        = var.cluster_name
    private_subnet      = var.private_subnet
    worker_domain       = var.worker_domain
    hadoop_version      = var.hadoop_version
    UsePrefix           = var.UsePrefix
  }

  dynamic "shape_config" {
    for_each = local.is_edge_flex_shape
      content {
	baseline_ocpu_utilization="BASELINE_1_1"
        ocpus = shape_config.value.ocpus
        memory_in_gbs = shape_config.value.memory_in_gbs
      }
  }
  timeouts {
    create = "30m"
  }
}
