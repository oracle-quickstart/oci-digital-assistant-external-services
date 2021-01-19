# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

#*************************************
#         OKE Specific
#*************************************

variable "oke-cluster-name" {
  default = "Digital Assistant OKE Cluster"
}
// OKE Kubernetes Version
variable "oke-k8s-version" {
  default = "v1.18.10"
}

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
  default=64
}
// Worker Node OCPU
variable "oke-worker-node-ocpu" {
  default=4
}

#*************************************
#    API Gateway Specific
#*************************************

// API Gateway Name
variable "apigateway_name" {
  default = "Digital Assistant Gateway"
}

#*************************************
#         Network Specific
#*************************************

// Network CIDRs
variable "network_cidrs" {
  type = map(string)

  default = {
    VCN-CIDR                        = "10.0.0.0/16"
    PUBLIC-SUBNET-REGIONAL-CIDR     = "10.0.0.0/24"
    PRIVATE-SUBNET-REGIONAL-CIDR    = "10.0.1.0/24"
    LB-PRIVATE-SUBNET-REGIONAL-CIDR = "10.0.2.0/24"
    ALL-CIDR                        = "0.0.0.0/0"
  }
}

// Network Names
variable "network_names" {
  type = map(string)

  default = {
    VCN-NAME                        = "Digital Assistant VCN"
    PUBLIC-SUBNET-REGIONAL-NAME     = "Digital Assistant - Public"
    PRIVATE-SUBNET-REGIONAL-NAME    = "Digital Assistant - Private"
    LB-PRIVATE-SUBNET-REGIONAL-NAME = "Digital Assistant (OKE LB) - Private"
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