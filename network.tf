# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

#*************************************
#               VCN
#*************************************

// VCN To host all subnets
resource "oci_core_vcn" "oda-cc-vcn" {
  cidr_block        = lookup(var.network_cidrs,"VCN-CIDR" )
  compartment_id    = var.compartment_ocid
  dns_label         = "oda"
  display_name      = lookup(var.network_names, "VCN-NAME" )
}

#*************************************
#           Subnets
#*************************************

// Public Subnet for API Gateway
resource "oci_core_subnet" "oda-public-subnet" {
  cidr_block                  = lookup(var.network_cidrs, "PUBLIC-SUBNET-REGIONAL-CIDR" )
  compartment_id              = var.compartment_ocid
  vcn_id                      = oci_core_vcn.oda-cc-vcn.id
  display_name                = lookup(var.network_names, "PUBLIC-SUBNET-REGIONAL-NAME" )
  prohibit_public_ip_on_vnic  = false // Public Subnet
  dns_label                   = "odapublic"
  route_table_id              = oci_core_route_table.oda-public-rt.id
  security_list_ids           = [oci_core_security_list.oda-public-sl.id]
}

// Public Subnet for OKE API Endpoint
resource "oci_core_subnet" "oda-public-subnet-oke" {
  cidr_block                  = lookup(var.network_cidrs, "OKE-PUBLIC-SUBNET-REGIONAL-CIDR" )
  compartment_id              = var.compartment_ocid
  vcn_id                      = oci_core_vcn.oda-cc-vcn.id
  display_name                = lookup(var.network_names, "OKE-PUBLIC-SUBNET-REGIONAL-CIDR" )
  prohibit_public_ip_on_vnic  = false // Public Subnet
  dns_label                   = "odaokepublic"
  route_table_id              = oci_core_route_table.oda-public-rt-oke.id
  security_list_ids           = [oci_core_security_list.oda-public-sl-oke.id]
}

// Private Subnet for OKE Worker Nodes
resource "oci_core_subnet" "oda-private-subnet" {
  cidr_block                  = lookup(var.network_cidrs, "PRIVATE-SUBNET-REGIONAL-CIDR" )
  compartment_id              = var.compartment_ocid
  vcn_id                      = oci_core_vcn.oda-cc-vcn.id
  display_name                = lookup(var.network_names, "PRIVATE-SUBNET-REGIONAL-NAME" )
  prohibit_public_ip_on_vnic  = true // Private Subnet
  dns_label                   = "odaprivate"
  route_table_id              = oci_core_route_table.oda-private-rt.id
  security_list_ids           = [oci_core_security_list.oda-private-sl.id]
}

// Private Subnet for OKE LB
resource "oci_core_subnet" "oda-private-subnet-lb" {
  cidr_block                  = lookup(var.network_cidrs, "LB-PRIVATE-SUBNET-REGIONAL-CIDR" )
  compartment_id              = var.compartment_ocid
  vcn_id                      = oci_core_vcn.oda-cc-vcn.id
  display_name                = lookup(var.network_names, "LB-PRIVATE-SUBNET-REGIONAL-NAME" )
  prohibit_public_ip_on_vnic  = true // Private Subnet
  dns_label                   = "odalbprivate"
  route_table_id              = oci_core_route_table.oda-private-rt-lb.id
  security_list_ids           = [oci_core_security_list.oda-private-sl-lb.id]
}


#*************************************
#         Internet Gateway
#*************************************

// Internet Gateway for Public Subnets
resource "oci_core_internet_gateway" "oda-internet-gateway" {
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_vcn.oda-cc-vcn.id
  display_name    = "Digital Assistant Internet Gateway"
  enabled         = true
}

#*************************************
#         NAT Gateway
#*************************************

// Nat Gateway for Private Subnets
resource "oci_core_nat_gateway" "oda-nat-gateway" {
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_vcn.oda-cc-vcn.id
  display_name    = "Digital Assistant Nat Gateway"
}

#*************************************
#         Service Gateway
#*************************************
// Service Gateway to access all OCI services
resource "oci_core_service_gateway" "oda_service_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "Digital Assistant Service Gateway"
  vcn_id         = oci_core_vcn.oda-cc-vcn.id
  services {
    service_id   = lookup(data.oci_core_services.all_services.services[0], "id")
  }
}


#*************************************
#           Route Tables
#*************************************

// Public Subnet Routing Table for API Gateway
resource "oci_core_route_table" "oda-public-rt" {
  compartment_id       = var.compartment_ocid
  vcn_id               = oci_core_vcn.oda-cc-vcn.id
  display_name         = "Digital Assistant Public RT"

  // Enable all traffic through Internet Gateway
  route_rules {
    network_entity_id  = oci_core_internet_gateway.oda-internet-gateway.id
    destination        = lookup(var.network_cidrs , "ALL-CIDR" )
    destination_type   = "CIDR_BLOCK"
  }

}

// Public Subnet Routing Table for OKE API Endpoint
resource "oci_core_route_table" "oda-public-rt-oke" {
  compartment_id       = var.compartment_ocid
  vcn_id               = oci_core_vcn.oda-cc-vcn.id
  display_name         = "Digital Assistant Public RT (OKE API)"

  // Enable all traffic through Internet Gateway
  route_rules {
    network_entity_id  = oci_core_internet_gateway.oda-internet-gateway.id
    destination        = lookup(var.network_cidrs , "ALL-CIDR" )
    destination_type   = "CIDR_BLOCK"
  }

}

// Private Subnet Routing Table for OKE Worker Nodes
resource "oci_core_route_table" "oda-private-rt" {
  compartment_id        = var.compartment_ocid
  vcn_id                = oci_core_vcn.oda-cc-vcn.id
  display_name          = "Digital Assistant Private RT"

  // Enable all traffic through NAT Gateway
  route_rules {
    network_entity_id   = oci_core_nat_gateway.oda-nat-gateway.id
    destination         = lookup(var.network_cidrs , "ALL-CIDR" )
    destination_type    = "CIDR_BLOCK"
  }

  // Enable all traffic through Service Gateway
  route_rules {
    network_entity_id   = oci_core_service_gateway.oda_service_gateway.id
    destination         = data.oci_core_services.all_services.services.0.cidr_block
    destination_type    = "SERVICE_CIDR_BLOCK"
  }

}

// Private Subnet Routing Table for OKE LB
resource "oci_core_route_table" "oda-private-rt-lb" {
  compartment_id        = var.compartment_ocid
  vcn_id                = oci_core_vcn.oda-cc-vcn.id
  display_name          = "Digital Assistant Private RT (OKE LB)"

  // Enable all traffic through NAT Gateway
  route_rules {
    network_entity_id   = oci_core_nat_gateway.oda-nat-gateway.id
    destination         = lookup(var.network_cidrs , "ALL-CIDR" )
    destination_type    = "CIDR_BLOCK"
  }

}

#*************************************
#         Security List
#*************************************

// Public Subnet Security List for API Gateway
resource "oci_core_security_list" "oda-public-sl" {
  compartment_id        = var.compartment_ocid
  vcn_id                = oci_core_vcn.oda-cc-vcn.id
  display_name          = "Digital Assistant Public SL"

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
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.oda-cc-vcn.id
  display_name = "Digital Assistant Public SL (OKE API)"

  # Egress - Allow Kubernetes Control Plane to communicate with OKE
  egress_security_rules {
    destination = lookup(var.network_cidrs, "PRIVATE-SUBNET-REGIONAL-NAME" )
    protocol = "6" // TCP
    stateless = false
    destination_type = "SERVICE_CIDR_BLOCK"
    description = "All traffic to worker nodes"
    tcp_options {
      max = "443"
      min = "443"
    }

  }

  # Egress - All traffic to worker nodes
  egress_security_rules {
    destination = lookup(var.network_cidrs, "PRIVATE-SUBNET-REGIONAL-NAME" )
    protocol = "All"
    stateless = false
    destination_type = "CIDR_BLOCK"
    description = "All traffic to worker nodes"

  }

  # Egress - Path discovery
  egress_security_rules {
    destination = lookup(var.network_cidrs, "PRIVATE-SUBNET-REGIONAL-NAME" )
    protocol = "1" // ICMP
    stateless = false
    destination_type = "CIDR_BLOCK"
    description = "Path discovery"
    icmp_options {
      type = "3"
      code = "4"
    }

  }

  # Ingress - External access to Kubernetes API endpoint
  ingress_security_rules {
    protocol = "6" // TCP
    source = lookup(var.network_cidrs, "ALL-CIDR" )
    source_type = "CIDR_BLOCK"
    stateless = false
    description = "External access to Kubernetes API endpoint"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }

  # Ingress - Kubernetes worker to Kubernetes API endpoint communication
  ingress_security_rules {
    protocol = "6" // TCP
    source = lookup(var.network_cidrs, "PRIVATE-SUBNET-REGIONAL-NAME" )
    source_type = "CIDR_BLOCK"
    stateless = false
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }

  # Ingress - Kubernetes worker to control plane communication
  ingress_security_rules {
    protocol = "6" // TCP
    source = lookup(var.network_cidrs, "PRIVATE-SUBNET-REGIONAL-NAME" )
    source_type = "CIDR_BLOCK"
    stateless = false
    description = "Kubernetes worker to control plane communication"
    tcp_options {
      max = "12250"
      min = "12250"
    }
  }

  # Ingress - Path discovery
  ingress_security_rules {
    protocol = "1" // ICMP
    source = lookup(var.network_cidrs, "PRIVATE-SUBNET-REGIONAL-NAME" )
    source_type = "CIDR_BLOCK"
    stateless = false
    description = "Path discovery"
    icmp_options {
      type = "3"
      code = "4"
    }
  }
}

// Private Subnet Security List for OKE Worker Nodes
resource "oci_core_security_list" "oda-private-sl" {
  compartment_id        = var.compartment_ocid
  vcn_id                = oci_core_vcn.oda-cc-vcn.id
  display_name          = "Digital Assistant Private SL"

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

// Private Subnet Security List for OKE LB
resource "oci_core_security_list" "oda-private-sl-lb" {
  compartment_id        = var.compartment_ocid
  vcn_id                = oci_core_vcn.oda-cc-vcn.id
  display_name          = "Digital Assistant Private SL (OKE LB)"

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
