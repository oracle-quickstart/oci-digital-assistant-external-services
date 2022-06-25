# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

locals {
  // OKE Ingress Public IP
  ingress_ip = data.kubernetes_service.ingress-nginx-controller.status[0].load_balancer[0].ingress[0].ip
  # Checks if is using Flexible Compute Shapes
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.oke-worker-node-shape)
  # Get OKE options
  cluster_k8s_latest_version   = reverse(sort(data.oci_containerengine_cluster_option.oke.kubernetes_versions))[0]
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex"
  ]

  prefix_name_normalized = replace(var.prefix_name, " ", "-")

  cluster_endpoint       = yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["clusters"][0]["cluster"]["certificate-authority-data"])
  cluster_id             = yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][4]
  cluster_region         = yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content)["users"][0]["user"]["exec"]["args"][6]
}