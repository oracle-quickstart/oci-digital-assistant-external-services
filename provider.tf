# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# 

terraform {
  required_version = ">= 1.1"

  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    local = {
      source = "hashicorp/local"
    }
    oci = {
      source = "hashicorp/oci"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

// Default Provider
provider "oci" {
  region            = var.region
  tenancy_ocid      = var.tenancy_ocid

  # Uncomment the below if you are running locally using your laptop
  user_ocid         = var.user_ocid
  fingerprint       = var.fingerprint
  private_key_path  = var.private_key_path

}

// Home Provider
provider "oci" {
  alias             = "home"
  region            = lookup(data.oci_identity_regions.home-region.regions[0], "name")
  tenancy_ocid      = var.tenancy_ocid

  # Uncomment the below if you are running locally using your laptop
  user_ocid         = var.user_ocid
  fingerprint       = var.fingerprint
  private_key_path  = var.private_key_path

}

// Kubernetes
provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = local.cluster_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["ce", "cluster", "generate-token", "--cluster-id", local.cluster_id, "--region", local.cluster_region]
    command     = "oci"
  }
}

// Helm
provider "helm" {
  kubernetes {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = local.cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["ce", "cluster", "generate-token", "--cluster-id", local.cluster_id, "--region", local.cluster_region]
      command     = "oci"
    }
  }
}
