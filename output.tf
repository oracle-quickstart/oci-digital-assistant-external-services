# Copyright (c) 2020 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

output "oda-cuctomComponents-url"{
  value = join("" , [oci_apigateway_deployment.oda-gateway-deployment.endpoint , oci_apigateway_deployment.oda-gateway-deployment.specification.0.routes.0.path])
}