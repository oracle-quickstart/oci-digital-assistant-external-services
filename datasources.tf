# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#


// Get Tenant Details
data "oci_identity_tenancy" "tenant_details" {
  tenancy_id = var.tenancy_ocid
}

// Get Tenant Home Region
data "oci_identity_regions" "home-region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenant_details.home_region_key]
  }
}

// Get Tenant Current Region
data "oci_identity_regions" "current_region" {
  filter {
    name    = "name"
    values  = [var.region]
  }
}

// All OCI Available Services
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

// Get Current Compartment
data "oci_identity_compartment" "current_compartment" {
  id = var.compartment_ocid
}

// Get Tenant Object Storage Namespace
data "oci_objectstorage_namespace" "os_namespace" {
  compartment_id = var.compartment_ocid
}

# Gets a list of supported images based on the shape, operating_system and operating_system_version provided
data "oci_core_images" "oke_node_pool_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = var.oke-worker-node-os-version
  shape                    = var.oke-worker-node-shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

// Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

// Get OKE Cluster CONFIG File
data "oci_containerengine_cluster_kube_config" "oke_cluster_kube_config" {
  cluster_id = oci_containerengine_cluster.oda-cc-cluster.id
}

data "oci_containerengine_cluster_option" "oke" {
  cluster_option_id = "all"
}

data "kubernetes_service" "ingress-nginx-controller" {
  depends_on = [helm_release.helm-chart-ingress-nginx]
  metadata {
    name = "ingress-nginx-controller"
  }
}
