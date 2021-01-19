# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

#*************************************
#           API Gateway
#*************************************

// Gateway
resource oci_apigateway_gateway oda-gateway {
  compartment_id    = var.compartment_ocid
  display_name      = var.apigateway_name
  endpoint_type     = "PUBLIC"
  subnet_id         = oci_core_subnet.oda-public-subnet.id
}

// Gateway Deployment
resource "oci_apigateway_deployment" "oda-gateway-deployment" {
  depends_on        = [data.kubernetes_service.ingress-nginx-controller]
  compartment_id    = var.compartment_ocid
  gateway_id        = oci_apigateway_gateway.oda-gateway.id
  path_prefix       = "/oda"
  display_name      = "ODA Services Deployment"

  // API Gateway Deployment Details
  specification {

    // Request Policies - enable cors, mainly needed when using WebViews that need access to any custom developed
    // utility services deployed within OKE
    request_policies {
      cors {
        allowed_origins = ["*"]
        allowed_headers = ["content-type" , "authorization"]
        allowed_methods = ["*"]
      }
    }

    // General Deployment Logging Policies
    logging_policies {
      access_log {
        is_enabled = true
      }
      execution_log {
        is_enabled = true
        log_level  = "INFO"
      }
    }

    # API Gateway Deployment Routing Rules

    // Get ODA Custom Component Metadata
    routes {
      path = "/skills/{skillName}/components"
      methods                   = ["GET"]
      backend {
        type                    = "HTTP_BACKEND"
        is_ssl_verify_disabled  = "true"
        url                     = "http://${data.kubernetes_service.ingress-nginx-controller.load_balancer_ingress[0].ip}/$${request.path[skillName]}/components"
      }
      // Route specific logging policies
      logging_policies {
        access_log {
          is_enabled = true
        }
        execution_log {
          is_enabled = true
          log_level  = "INFO"
        }
      }
    }

    // Execute ODA Custom Component
    routes {
      path = "/skills/{skillName}/components/{componentName}"
      methods                   = ["POST"]
      backend {
        type                    = "HTTP_BACKEND"
        is_ssl_verify_disabled  = "true"
        url                     = "http://${data.kubernetes_service.ingress-nginx-controller.load_balancer_ingress[0].ip}/$${request.path[skillName]}/components/$${request.path[componentName]}"
      }
      // Route specific logging policies
      logging_policies {
        access_log {
          is_enabled = true
        }
        execution_log {
          is_enabled = true
          log_level  = "INFO"
        }
      }
    }
  }

}