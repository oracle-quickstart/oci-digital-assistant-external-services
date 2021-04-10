# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#

resource "oci_objectstorage_bucket" "oda-bucket" {
  compartment_id = var.compartment_ocid
  name = "${local.app_name_normalized}Bucket"
  namespace = data.oci_objectstorage_namespace.os_namespace.namespace
  access_type = "ObjectReadWithoutList"
  object_events_enabled = "true"
  storage_tier = "Standard"
  versioning = "Enabled"
}