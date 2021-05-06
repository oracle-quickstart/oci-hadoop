locals {
  is_master_flex_shape = var.master_instance_shape == "VM.Standard.E3.Flex" ? [var.dynamic_ocpus] : []
}
