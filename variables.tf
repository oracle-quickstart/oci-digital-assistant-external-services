# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

#*************************************
#         General
#*************************************

// Prefix name. Will be used as a name prefix to identify resources, such as OKE, VCN, API Gateway, and others
variable "app_name" {
  default = "Digital Assistant"
}

#*************************************
#         OKE Specific
#*************************************

// OKE Worker Nodes Shape
variable "oke-worker-node-shape" {
  default = "VM.Standard.E3.Flex"
}
// Worker Nodes OS Image
variable "oke-worker-node-os-version" {
  default="7.9"
}
// Worker Node Memory
variable "oke-worker-node-memory" {
  default=32
}
// Worker Node OCPU
variable "oke-worker-node-ocpu" {
  default=2
}
// Auto-generate OKE Worker Nodes SSH Key
variable "oke-worker-nodes-auto-generate-ssh-key" {
  default = true
}
// OKE Worker Nodes SSH Key
variable "oke-worker-nodes-ssh-key" {
  default = ""
}

#*************************************
#    API Gateway Specific
#*************************************

// API Gateway Path Prefix
// IMPORTANT: Must start with a leading "/"
variable "apigateway_path_prefix" {
  default = "/oda"
}

#*************************************
#    OCI Vault Specific
#*************************************

// Create new vault
variable "create_vault" {
  default = true
}

// Existing Vault OCID - Only if "create_vault" is set to "false"
variable "existing_vault_id" {
  default = ""
}

#*************************************
#         Network Specific
#*************************************

// Create New VCN
variable "create_vcn" {
  default = true
}

// Existing VCN OCID - Only if "create_vcn" is set to "false"
variable "existing_vcn_id" {
  default = ""
}

// Existing Public Subnet (API Gateway) OCID - Only if "create_vcn" is set to "false"
variable "existing_public_subnet_id" {
  default = ""
}

// Existing Public Subnet (OKE API Endpoint) OCID - Only if "create_vcn" is set to "false"
variable "existing_public_subnet_id_oke" {
  default = ""
}

// Existing Private Subnet (OKE Worker Nodes) OCID - Only if "create_vcn" is set to "false"
variable "existing_private_subnet_id_oke_nodes" {
  default = ""
}

// Existing Private Subnet (OKE Load Balancer) OCID - Only if "create_vcn" is set to "false"
variable "existing_private_subnet_id_oke_lb" {
  default = ""
}

// Network CIDRs
variable "network_cidrs" {
  type = map(string)

  default = {
    VCN-CIDR                        = "10.0.0.0/16"
    PUBLIC-SUBNET-REGIONAL-CIDR     = "10.0.0.0/24"
    PRIVATE-SUBNET-REGIONAL-CIDR    = "10.0.1.0/24"
    LB-PRIVATE-SUBNET-REGIONAL-CIDR = "10.0.2.0/24"
    OKE-PUBLIC-SUBNET-REGIONAL-CIDR = "10.0.3.0/24"
    ALL-CIDR                        = "0.0.0.0/0"
  }
}

#*************************************
#           TF Requirements
#*************************************
variable "tenancy_ocid" {
}
variable "region" {
}
variable "user_ocid" {
  default = ""
}
variable "private_key_path"{
  default = ""
}
variable "fingerprint"{
  default = ""
}
variable "compartment_ocid" {
}