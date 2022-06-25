# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

#*************************************
#                 OKE
#*************************************

// OKE Cluster
resource "oci_containerengine_cluster" "oda-cc-cluster" {
  compartment_id      = var.compartment_ocid
  kubernetes_version  = local.cluster_k8s_latest_version
  name                = "${var.prefix_name} Cluster"
  vcn_id              = var.create_vcn ? oci_core_vcn.oda-cc-vcn[0].id : var.existing_vcn_id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id = var.create_vcn ? oci_core_subnet.oda-public-subnet-oke[0].id : var.existing_public_subnet_id_oke
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = true
      is_tiller_enabled               = true
    }
    admission_controller_options {
      is_pod_security_policy_enabled  = false
    }
    service_lb_subnet_ids             = [ var.create_vcn ? oci_core_subnet.oda-private-subnet-lb[0].id : var.existing_private_subnet_id_oke_lb]
  }
}

// OKE Cluster Node Pool
resource "oci_containerengine_node_pool" "node-pool-1" {
  cluster_id          = oci_containerengine_cluster.oda-cc-cluster.id
  compartment_id      = var.compartment_ocid
  kubernetes_version  = oci_containerengine_cluster.oda-cc-cluster.kubernetes_version
  name                = "node-pool-1"
  node_shape          = var.oke-worker-node-shape

  // if using flex shape, we have to specify shape details memory/ocpu
  dynamic "node_shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs     = var.oke-worker-node-memory
      ocpus             = var.oke-worker-node-ocpu
    }
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
        subnet_id           = var.create_vcn ? oci_core_subnet.oda-private-subnet[0].id : var.existing_private_subnet_id_oke_nodes
      }
    }
  }

  ssh_public_key = var.oke-worker-nodes-auto-generate-ssh-key ? tls_private_key.oke_worker_node_ssh_key.public_key_openssh : var.oke-worker-nodes-ssh-key
}

# Generate ssh keys to access Worker Nodes
resource "tls_private_key" "oke_worker_node_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}