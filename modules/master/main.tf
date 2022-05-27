resource "oci_core_instance" "Master" {
  count               = var.instances
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  shape               = var.master_instance_shape
  display_name        = var.UsePrefix ? "${var.cluster_name}-Master ${format("%01d", count.index+1)}" : "Master ${format("%01d", count.index+1)}"

  source_details {
    source_type             = "image"
    source_id               = var.image_ocid
  }

  create_vnic_details {
    subnet_id         = var.subnet_id
    display_name      = "Master ${format("%01d", count.index+1)}"
    hostname_label    = "Master-${format("%01d", count.index+1)}"
    assign_public_ip  = false
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data		= var.user_data
    agent_hostname      = "master-${count.index+1}.${var.worker_domain}"
  }

  extended_metadata = {
    hadoop_version      = var.hadoop_version
    hadoop_par          = var.hadoop_par
    zk_version          = var.zk_version
    install_hive        = var.install_hive
    hive_version        = var.hive_version
    hive_par            = var.hive_par
    cluster_name        = var.cluster_name
    UsePrefix        = var.UsePrefix
    worker_shape        = var.worker_shape
    worker_block_volume_count = var.worker_block_volume_count
    worker_count        = var.worker_count
    worker_ocpus        = var.worker_ocpus
    worker_memory       = var.worker_memory
  }

  dynamic "shape_config" {
    for_each = local.is_master_flex_shape
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

// Block Volume Creation for Master 

# Data Volume for /data (Name & SecondaryName)
resource "oci_core_volume" "MasterNNVolume" {
  count               = var.instances
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "Master ${format("%01d", count.index+1)} Journal Data"
  size_in_gbs         = var.nn_volume_size_in_gbs
}

resource "oci_core_volume_attachment" "MasterNNAttachment" {
  count           = var.instances
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.Master[count.index].id
  volume_id       = oci_core_volume.MasterNNVolume[count.index].id
  device          = "/dev/oracleoci/oraclevdb"
}

