locals {
  is_worker_flex_shape = var.is_flex_shape ? [{ ocpus = var.dynamic_ocpus, memory_in_gbs = var.memory_in_gbs }] : []
  primary_label_prefix = "Worker-primary-"
  secondary_label_prefix = "Worker-"
}
