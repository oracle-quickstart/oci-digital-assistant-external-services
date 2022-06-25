# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#


#*************************************
#         Ingress-NGINX
#*************************************

// Install Nginx Ingress Helm Chart
resource "helm_release" "helm-chart-ingress-nginx" {
  depends_on = [oci_containerengine_node_pool.node-pool-1]
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  timeout    = 600000
  wait       = true
  values     = [
    data.template_file.helm-values-ingress-nginx.rendered
  ]
}

// Nginx Ingress HElM Chart Values.yaml file
data "template_file" "helm-values-ingress-nginx" {
  template = <<END
controller:
  service:
    annotations:
      service.beta.kubernetes.io/oci-load-balancer-internal: "true"
      service.beta.kubernetes.io/oci-load-balancer-subnet1: ${ var.create_vcn ? oci_core_subnet.oda-private-subnet-lb[0].id : var.existing_private_subnet_id_oke_lb}
      service.beta.kubernetes.io/oci-load-balancer-shape: "flexible"
      service.beta.kubernetes.io/oci-load-balancer-shape-flex-min: "10"
      service.beta.kubernetes.io/oci-load-balancer-shape-flex-max: "100"
END
}

// Create an Kubernetes Ingress Resource - Terraform
resource "kubernetes_ingress_v1" "oda-services-ingress" {
  depends_on = [helm_release.helm-chart-taerfik]
  metadata {
    name = "${lower(local.prefix_name_normalized)}-services-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = "${lower(local.prefix_name_normalized)}-services-traefik"
              port {
                number = 80
              }
            }
          }
          path = "/"
        }
      }
    }
  }
}

// Create an Kubernetes Ingress Resource - ORM
#resource "kubernetes_ingress" "oda-services-ingress" {
#  depends_on = [helm_release.helm-chart-taerfik]
#  metadata {
#    name = "${lower(local.prefix_name_normalized)}-services-ingress"
#    annotations = {
#      "kubernetes.io/ingress.class" = "nginx"
#    }
#  }
#  spec {
#    rule {
#      http {
#        path {
#          backend {
#            service_name = "${lower(local.prefix_name_normalized)}-services-traefik"
#            service_port = 80
#          }
#          path = "/"
#        }
#      }
#    }
#  }
#}

#*************************************
#        Taerfik Edge Router
#*************************************

// Taerfik Edge Router Helm Chart
resource "helm_release" "helm-chart-taerfik" {
  name       = "${lower(local.prefix_name_normalized)}-services"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  wait       = true
  depends_on = [helm_release.helm-chart-ingress-nginx]
  values = [
    data.template_file.helm-values-taerfik.rendered
  ]

}

// Taerfik Edge Router HElM Chart Values.yaml file
data "template_file" "helm-values-taerfik" {
  template = <<END
service:
  type: ClusterIP
providers:
  kubernetesIngress:
    enabled: false
END
}