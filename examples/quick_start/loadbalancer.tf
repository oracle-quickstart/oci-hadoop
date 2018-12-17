############################################
# Create Load Balancer
############################################

resource "oci_load_balancer" "hadoopLB" {
  shape          = "400Mbps"
  compartment_id = "${var.compartment_ocid}"

  subnet_ids = [
    "${oci_core_subnet.hadoopLBSubnet1.id}",
    "${oci_core_subnet.hadoopLBSubnet2.id}",
  ]

  display_name = "hadoopLB"
}

resource "oci_load_balancer_backend_set" "hadoopLBBes" {
  name             = "hadoopLBBes"
  load_balancer_id = "${oci_load_balancer.hadoopLB.id}"
  policy           = "ROUND_ROBIN"

  health_checker {
    port     = "${var.nn_port}"
    protocol = "TCP"
  }
}

resource "oci_load_balancer_backend_set" "hadoopLBRMBes" {
  name             = "hadoopLBBRMes"
  load_balancer_id = "${oci_load_balancer.hadoopLB.id}"
  policy           = "ROUND_ROBIN"

  health_checker {
    port     = "${var.rm_port}"
    protocol = "TCP"
  }
}

resource "oci_load_balancer_backend_set" "hadoopLBJHSBes" {
  name             = "hadoopLBBJHSes"
  load_balancer_id = "${oci_load_balancer.hadoopLB.id}"
  policy           = "ROUND_ROBIN"

  health_checker {
    port     = "${var.jhs_port}"
    protocol = "TCP"
  }
}

resource "oci_load_balancer_backend" "hadoopLBBe" {
  load_balancer_id = "${oci_load_balancer.hadoopLB.id}"
  backendset_name  = "${oci_load_balancer_backend_set.hadoopLBBes.name}"
  ip_address       = "${module.hadoop.master_private_ip}"
  port             = "${var.nn_port}"
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "hadoopLBRMBe" {
  load_balancer_id = "${oci_load_balancer.hadoopLB.id}"
  backendset_name  = "${oci_load_balancer_backend_set.hadoopLBRMBes.name}"
  ip_address       = "${module.hadoop.master_private_ip}"
  port             = "${var.rm_port}"
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "hadoopLBJHSBe" {
  load_balancer_id = "${oci_load_balancer.hadoopLB.id}"
  backendset_name  = "${oci_load_balancer_backend_set.hadoopLBJHSBes.name}"
  ip_address       = "${module.hadoop.master_private_ip}"
  port             = "${var.jhs_port}"
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "tls_private_key" "hadoopTLS" {
  count     = "${var.listener_ca_certificate == "" ? 1 : 0 }"
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "hadoopCert" {
  count           = "${var.listener_ca_certificate == "" ? 1 : 0 }"
  key_algorithm   = "${tls_private_key.hadoopTLS.algorithm}"
  private_key_pem = "${tls_private_key.hadoopTLS.private_key_pem}"

  validity_period_hours = 26280
  early_renewal_hours   = 8760
  is_ca_certificate     = true
  allowed_uses          = ["cert_signing"]

  subject {
    common_name  = "*.example.com"
    organization = "Example, Inc"
  }
}

resource "oci_load_balancer_certificate" "hadoopLBCert" {
  load_balancer_id   = "${oci_load_balancer.hadoopLB.id}"
  ca_certificate     = "${var.listener_ca_certificate == "" ? "${tls_self_signed_cert.hadoopCert.cert_pem}" : var.listener_ca_certificate}"
  certificate_name   = "hadoopCert"
  private_key        = "${var.listener_private_key == "" ? "${tls_private_key.hadoopTLS.private_key_pem}" : var.listener_private_key}"
  public_certificate = "${var.listener_public_certificate == "" ? "${tls_self_signed_cert.hadoopCert.cert_pem}" : var.listener_public_certificate}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_load_balancer_path_route_set" "hadoopPRS" {
  load_balancer_id = "${oci_load_balancer.hadoopLB.id}"
  name             = "pr-set1"

  path_routes {
    path = "/dfshealth.html/*"

    path_match_type {
      match_type = "PREFIX_MATCH"
    }

    backend_set_name = "${oci_load_balancer_backend_set.hadoopLBBes.name}"
  }

  path_routes {
    path = "/cluster/*"

    path_match_type {
      match_type = "PREFIX_MATCH"
    }

    backend_set_name = "${oci_load_balancer_backend_set.hadoopLBRMBes.name}"
  }

  path_routes {
    path = "/jobhistory/*"

    path_match_type {
      match_type = "PREFIX_MATCH"
    }

    backend_set_name = "${oci_load_balancer_backend_set.hadoopLBJHSBes.name}"
  }
}

resource "oci_load_balancer_listener" "hadoopLBLsnr_NN_SSL" {
  load_balancer_id         = "${oci_load_balancer.hadoopLB.id}"
  name                     = "Hadoop_Web_UI"
  default_backend_set_name = "${oci_load_balancer_backend_set.hadoopLBBes.name}"
  port                     = 443
  protocol                 = "HTTP"
  path_route_set_name      = "${oci_load_balancer_path_route_set.hadoopPRS.name}"

  ssl_configuration {
    certificate_name        = "${oci_load_balancer_certificate.hadoopLBCert.certificate_name}"
    verify_peer_certificate = false
  }
}
