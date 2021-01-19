# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#


#*************************************
#          Dynamic Groups
#*************************************

resource "oci_identity_dynamic_group" "oda-dynamic-group" {
  provider        = oci.home
  compartment_id  = var.tenancy_ocid
  description     = "Digital Assistant Dynamic Group"
  name            = "DigitalAssistantDynamicGroup"
  matching_rule   = "any {all {resource.type='odainstance',resource.compartment.id='${var.compartment_ocid}'} ,all {resource.type='fnfunc',resource.compartment.id='${var.compartment_ocid}'}, all {resource.type='ApiGateway',resource.compartment.id='${var.compartment_ocid}'}, all {instance.compartment.id='${var.compartment_ocid}'} }"
}


#*************************************
#           Policies
#*************************************

resource "oci_identity_policy" "oda-policy" {
  provider       = oci.home
  compartment_id = var.compartment_ocid
  description    = "Digital Assistant Policies"
  name           = "DigitalAssistantPolicies"
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