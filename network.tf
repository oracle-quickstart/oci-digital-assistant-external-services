# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

#*************************************
#               VCN
#*************************************

// VCN To host all subnets
resource "oci_core_vcn" "oda-cc-vcn" {
  count             = var.create_vcn ? 1 : 0
  cidr_block        = lookup(var.network_cidrs,"VCN-CIDR" )
  compartment_id    = var.compartment_ocid
  display_name      = "${var.prefix_name} VCN"
}

#*************************************
#           Subnets
#*************************************

// Public Subnet for API Gateway
resource "oci_core_subnet" "oda-public-subnet" {
  count                       = var.create_vcn ? 1 : 0
  cidr_block                  = lookup(var.network_cidrs, "PUBLIC-SUBNET-REGIONAL-CIDR" )
  compartment_id              = var.compartment_ocid
  vcn_id                      = oci_core_vcn.oda-cc-vcn[0].id
  display_name                = "${var.prefix_name} - Public"
  prohibit_public_ip_on_vnic  = false // Public Subnet
  route_table_id              = oci_core_route_table.oda-public-rt[0].id
  security_list_ids           = [oci_core_security_list.oda-public-sl[0].id]
}

// Public Subnet for OKE API Endpoint
resource "oci_core_subnet" "oda-public-subnet-oke" {
  count                       = var.create_vcn ? 1 : 0
  cidr_block                  = lookup(var.network_cidrs, "OKE-PUBLIC-SUBNET-REGIONAL-CIDR" )
  compartment_id              = var.compartment_ocid
  vcn_id                      = oci_core_vcn.oda-cc-vcn[0].id
  display_name                = "${var.prefix_name} (OKE API) - Public"
  prohibit_public_ip_on_vnic  = false // Public Subnet
  route_table_id              = oci_core_route_table.oda-public-rt-oke[0].id
  security_list_ids           = [oci_core_security_list.oda-public-sl-oke[0].id]
}

// Private Subnet for OKE Worker Nodes
resource "oci_core_subnet" "oda-private-subnet" {
  count                       = var.create_vcn ? 1 : 0
  cidr_block                  = lookup(var.network_cidrs, "PRIVATE-SUBNET-REGIONAL-CIDR" )
  compartment_id              = var.compartment_ocid
  vcn_id                      = oci_core_vcn.oda-cc-vcn[0].id
  display_name                =  "${var.prefix_name} (OKE Nodes) - Private"
  prohibit_public_ip_on_vnic  = true // Private Subnet
  route_table_id              = oci_core_route_table.oda-private-rt[0].id
  security_list_ids           = [oci_core_security_list.oda-private-sl[0].id]
}

// Private Subnet for OKE LB
resource "oci_core_subnet" "oda-private-subnet-lb" {
  count                       = var.create_vcn ? 1 : 0
  cidr_block                  = lookup(var.network_cidrs, "LB-PRIVATE-SUBNET-REGIONAL-CIDR" )
  compartment_id              = var.compartment_ocid
  vcn_id                      = oci_core_vcn.oda-cc-vcn[0].id
  display_name                = "${var.prefix_name} (OKE LB) - Private"
  prohibit_public_ip_on_vnic  = true // Private Subnet
  route_table_id              = oci_core_route_table.oda-private-rt-lb[0].id
  security_list_ids           = [oci_core_security_list.oda-private-sl-lb[0].id]
}


#*************************************
#         Internet Gateway
#*************************************

// Internet Gateway for Public Subnets
resource "oci_core_internet_gateway" "oda-internet-gateway" {
  count           = var.create_vcn ? 1 : 0
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_vcn.oda-cc-vcn[0].id
  display_name    = "${var.prefix_name} Internet Gateway"
  enabled         = true
}

#*************************************
#         NAT Gateway
#*************************************

// Nat Gateway for Private Subnets
resource "oci_core_nat_gateway" "oda-nat-gateway" {
  count           = var.create_vcn ? 1 : 0
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_vcn.oda-cc-vcn[0].id
  display_name    = "${var.prefix_name} Nat Gateway"
}

#*************************************
#         Service Gateway
#*************************************
// Service Gateway to access all OCI services
resource "oci_core_service_gateway" "oda_service_gateway" {
  count          = var.create_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${var.prefix_name} Service Gateway"
  vcn_id         = oci_core_vcn.oda-cc-vcn[0].id
  services {
    service_id   = lookup(data.oci_core_services.all_services.services[0], "id")
  }
}


#*************************************
#           Route Tables
#*************************************

// Public Subnet Routing Table for API Gateway
resource "oci_core_route_table" "oda-public-rt" {
  count                = var.create_vcn ? 1 : 0
  compartment_id       = var.compartment_ocid
  vcn_id               = oci_core_vcn.oda-cc-vcn[0].id
  display_name         = "${var.prefix_name} Public RT"

  // Enable all traffic through Internet Gateway
  route_rules {
    network_entity_id  = oci_core_internet_gateway.oda-internet-gateway[0].id
    destination        = lookup(var.network_cidrs , "ALL-CIDR" )
    destination_type   = "CIDR_BLOCK"
  }

}

// Public Subnet Routing Table for OKE API Endpoint
resource "oci_core_route_table" "oda-public-rt-oke" {
  count                = var.create_vcn ? 1 : 0
  compartment_id       = var.compartment_ocid
  vcn_id               = oci_core_vcn.oda-cc-vcn[0].id
  display_name         = "${var.prefix_name} Public RT (OKE API)"

  // Enable all traffic through Internet Gateway
  route_rules {
    network_entity_id  = oci_core_internet_gateway.oda-internet-gateway[0].id
    destination        = lookup(var.network_cidrs , "ALL-CIDR" )
    destination_type   = "CIDR_BLOCK"
  }

}

// Private Subnet Routing Table for OKE Worker Nodes
resource "oci_core_route_table" "oda-private-rt" {
  count                 = var.create_vcn ? 1 : 0
  compartment_id        = var.compartment_ocid
  vcn_id                = oci_core_vcn.oda-cc-vcn[0].id
  display_name          = "${var.prefix_name} Private RT (OKE Nodes)"

  // Enable all traffic through NAT Gateway
  route_rules {
    network_entity_id   = oci_core_nat_gateway.oda-nat-gateway[0].id
    destination         = lookup(var.network_cidrs , "ALL-CIDR" )
    destination_type    = "CIDR_BLOCK"
  }

  // Enable all traffic through Service Gateway
  route_rules {
    network_entity_id   = oci_core_service_gateway.oda_service_gateway[0].id
    destination         = data.oci_core_services.all_services.services.0.cidr_block
    destination_type    = "SERVICE_CIDR_BLOCK"
  }

}

// Private Subnet Routing Table for OKE LB
resource "oci_core_route_table" "oda-private-rt-lb" {
  count                 = var.create_vcn ? 1 : 0
  compartment_id        = var.compartment_ocid
  vcn_id                = oci_core_vcn.oda-cc-vcn[0].id
  display_name          = "${var.prefix_name} Private RT (OKE LB)"

  // Enable all traffic through NAT Gateway
  route_rules {
    network_entity_id   = oci_core_nat_gateway.oda-nat-gateway[0].id
    destination         = lookup(var.network_cidrs , "ALL-CIDR" )
    destination_type    = "CIDR_BLOCK"
  }

}

#*************************************
#         Security List
#*************************************

// Public Subnet Security List for API Gateway
resource "oci_core_security_list" "oda-public-sl" {
  count                 = var.create_vcn ? 1 : 0
  compartment_id        = var.compartment_ocid
  vcn_id                = oci_core_vcn.oda-cc-vcn[0].id
  display_name          = "${var.prefix_name} Public SL"

  # Egress - Allow All traffic
  egress_security_rules {
    destination         = lookup(var.network_cidrs , "ALL-CIDR" )
    protocol            = "All"
    stateless           = false
    destination_type    = "CIDR_BLOCK"

  }
  # Ingress - Allow All traffic
  ingress_security_rules {
    protocol            = "All"
    source              = lookup(var.network_cidrs , "ALL-CIDR" )
    source_type         = "CIDR_BLOCK"
    stateless           = false
  }
}

// Public Subnet Security List for OKE API Endpoint
resource "oci_core_security_list" "oda-public-sl-oke" {
  count          = var.create_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oda-cc-vcn[0].id
  display_name   = "${var.prefix_name} Public SL (OKE API)"

  # Egress - Allow All
  egress_security_rules {
    destination      = lookup(var.network_cidrs, "ALL-CIDR")
    protocol         = "All"
    stateless        = false
    destination_type = "CIDR_BLOCK"
  }

  # Ingress - All All
  ingress_security_rules {
    protocol    = "All"
    source      = lookup(var.network_cidrs, "ALL-CIDR" )
    source_type = "CIDR_BLOCK"
    stateless   = false
  }
}

// Private Subnet Security List for OKE Worker Nodes
resource "oci_core_security_list" "oda-private-sl" {
  count                 = var.create_vcn ? 1 : 0
  compartment_id        = var.compartment_ocid
  vcn_id                = oci_core_vcn.oda-cc-vcn[0].id
  display_name          = "${var.prefix_name} Private SL (OKE Nodes)"

  # Egress - Allow All
  egress_security_rules {
    destination         = lookup(var.network_cidrs , "ALL-CIDR" )
    protocol            = "All"
    stateless           = false
    destination_type    = "CIDR_BLOCK"
  }

  # Ingress - Allow All
  ingress_security_rules {
    protocol            = "All"
    source              = lookup(var.network_cidrs , "ALL-CIDR" )
    source_type         = "CIDR_BLOCK"
    stateless           = false
  }
}

// Private Subnet Security List for OKE LB
resource "oci_core_security_list" "oda-private-sl-lb" {
  count                 = var.create_vcn ? 1 : 0
  compartment_id        = var.compartment_ocid
  vcn_id                = oci_core_vcn.oda-cc-vcn[0].id
  display_name          = "${var.prefix_name} Private SL (OKE LB)"

  # Egress - Allow All traffic
  egress_security_rules {
    destination         = lookup(var.network_cidrs , "ALL-CIDR" )
    protocol            = "All"
    stateless           = false
    destination_type    = "CIDR_BLOCK"

  }
  # Ingress - Allow All traffic
  ingress_security_rules {
    protocol            = "All"
    source              = lookup(var.network_cidrs , "ALL-CIDR" )
    source_type         = "CIDR_BLOCK"
    stateless           = false
  }
}
