# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

#*************************************
#                 OKE
#*************************************

// OKE Cluster
resource "oci_containerengine_cluster" "oda-cc-cluster" {
  compartment_id      = var.compartment_ocid
  kubernetes_version  = var.oke-k8s-version
  name                = var.oke-cluster-name
  vcn_id              = oci_core_vcn.oda-cc-vcn.id

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = true
      is_tiller_enabled               = true
    }
    admission_controller_options {
      is_pod_security_policy_enabled  = false
    }
    service_lb_subnet_ids             = [oci_core_subnet.oda-private-subnet-lb.id]
  }
}

// OKE Cluster Node Pool
resource "oci_containerengine_node_pool" "node-pool-1" {
  cluster_id          = oci_containerengine_cluster.oda-cc-cluster.id
  compartment_id      = var.compartment_ocid
  kubernetes_version  = oci_containerengine_cluster.oda-cc-cluster.kubernetes_version
  name                = "node-pool-1"
  node_shape          = var.oke-worker-node-shape
  // As we are using flex shape, we have to specify shape details memory/ocpu
  node_shape_config {
    memory_in_gbs     = var.oke-worker-node-memory
    ocpus             = var.oke-worker-node-ocpu
  }

  node_source_details {
    image_id          = data.oci_core_images.oke_node_pool_images.images.1.id
    source_type       = "IMAGE"
  }

  node_config_details {
    size                    = length(data.oci_identity_availability_domains.ADs.availability_domains)
    dynamic "placement_configs" {
      for_each              = data.oci_identity_availability_domains.ADs.availability_domains
      content {
        availability_domain = placement_configs.value.name
        subnet_id           = oci_core_subnet.oda-private-subnet.id
      }
    }
  }

  ssh_public_key = tls_private_key.oke_worker_node_ssh_key.public_key_openssh
}

# Generate ssh keys to access Worker Nodes, if generate_public_ssh_key=true, applies to the pool
resource "tls_private_key" "oke_worker_node_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}