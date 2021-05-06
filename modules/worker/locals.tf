locals {
  is_worker_flex_shape = var.worker_instance_shape == "VM.Standard.E3.Flex" ? [var.dynamic_ocpus] : []
  primary_label_prefix = "Worker-primary-"
  secondary_label_prefix = "Worker-"
}
