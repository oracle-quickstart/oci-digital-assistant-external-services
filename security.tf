# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#


locals {
  app_name_normalized = replace(var.app_name, " ", "-")
}

#*************************************
#          Dynamic Groups
#*************************************

resource "oci_identity_dynamic_group" "oda-dynamic-group" {
  provider        = oci.home
  compartment_id  = var.tenancy_ocid
  description     = "${var.app_name} Dynamic Group"
  name            = "${local.app_name_normalized}DynamicGroup"
  matching_rule   = "any {all {resource.type='odainstance',resource.compartment.id='${var.compartment_ocid}'} ,all {resource.type='fnfunc',resource.compartment.id='${var.compartment_ocid}'}, all {resource.type='ApiGateway',resource.compartment.id='${var.compartment_ocid}'}, all {instance.compartment.id='${var.compartment_ocid}'} }"
}

#*************************************
#              Vault
#*************************************

resource "oci_kms_vault" "oda-vault" {
  count = var.create_vault ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name = "${var.app_name} Vault" //var.vault_name
  vault_type = "DEFAULT"
}

resource "oci_kms_key" "oda-key" {
  count = var.create_vault ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name = "${var.app_name} Vault Encryption Key"
  key_shape {
    algorithm = "AES"
    length = 32
  }
  management_endpoint = oci_kms_vault.oda-vault[0].management_endpoint
}


#*************************************
#           Policies
#*************************************

resource "oci_identity_policy" "oda-policy" {
  provider       = oci.home
  compartment_id = var.compartment_ocid
  description    = "${var.app_name} Policies"
  name           = "${local.app_name_normalized}Policies"
  statements     = [
    "Allow service FaaS to use virtual-network-family ${data.oci_identity_compartment.current_compartment.id == var.tenancy_ocid ? "in tenancy" : "in compartment ${data.oci_identity_compartment.current_compartment.name}" }" ,
    "Allow dynamic-group ${oci_identity_dynamic_group.oda-dynamic-group.name} to use virtual-network-family ${data.oci_identity_compartment.current_compartment.id == var.tenancy_ocid ? "in tenancy" : "in compartment ${data.oci_identity_compartment.current_compartment.name}" }" ,
    "Allow dynamic-group ${oci_identity_dynamic_group.oda-dynamic-group.name} to use functions-family ${data.oci_identity_compartment.current_compartment.id == var.tenancy_ocid ? "in tenancy" : "in compartment ${data.oci_identity_compartment.current_compartment.name}" }" ,
    "Allow dynamic-group ${oci_identity_dynamic_group.oda-dynamic-group.name} to use functions-family ${data.oci_identity_compartment.current_compartment.id == var.tenancy_ocid ? "in tenancy" : "in compartment ${data.oci_identity_compartment.current_compartment.name}" }" ,
    "Allow dynamic-group ${oci_identity_dynamic_group.oda-dynamic-group.name} to manage objects ${data.oci_identity_compartment.current_compartment.id == var.tenancy_ocid ? "in tenancy" : "in compartment ${data.oci_identity_compartment.current_compartment.name}" }" ,
    "Allow dynamic-group ${oci_identity_dynamic_group.oda-dynamic-group.name} to manage public-ips ${data.oci_identity_compartment.current_compartment.id == var.tenancy_ocid ? "in tenancy" : "in compartment ${data.oci_identity_compartment.current_compartment.name}" }",
    "Allow dynamic-group ${oci_identity_dynamic_group.oda-dynamic-group.name} to manage secret-family ${data.oci_identity_compartment.current_compartment.id == var.tenancy_ocid ? "in tenancy" : "in compartment ${data.oci_identity_compartment.current_compartment.name}" }",
    "Allow dynamic-group ${oci_identity_dynamic_group.oda-dynamic-group.name} to manage vaults ${data.oci_identity_compartment.current_compartment.id == var.tenancy_ocid ? "in tenancy" : "in compartment ${data.oci_identity_compartment.current_compartment.name}" }",
    "Allow dynamic-group ${oci_identity_dynamic_group.oda-dynamic-group.name} to manage keys ${data.oci_identity_compartment.current_compartment.id == var.tenancy_ocid ? "in tenancy" : "in compartment ${data.oci_identity_compartment.current_compartment.name}" }",
    "Allow dynamic-group ${oci_identity_dynamic_group.oda-dynamic-group.name} to use oda-family ${data.oci_identity_compartment.current_compartment.id == var.tenancy_ocid ? "in tenancy" : "in compartment ${data.oci_identity_compartment.current_compartment.name}" }"
  ]
}