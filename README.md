# Oracle Digital Assistant External Services

## Introduction

This solution shows how to provision and configure the infrastructure that you need to deploy [Digital Assistant](https://docs.oracle.com/en-us/iaas/digital-assistant/index.html) custom components/webviews to [Oracle Kubernetes Engine (**_OKE_**)](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengoverview.htm) using either [Oracle Cloud Infrastructure Resource Manager](https://docs.cloud.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resourcemanager.htm) or [Terraform](https://www.terraform.io/docs/providers/oci/index.html). You also can use this infrastructure to deploy different utility services that Digital Assistant can benefit from, like custom channel webhook implementations.

The following list shows all the artifacts that will be provisioned.

| Component                                                                                                           | Description                                         | Default Name             
|---------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------|-------------------------
| [OKE](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengoverview.htm)                              | Oracle Container Engine for Kubernetes              | Digital Assistant OKE Cluster
| [API Gateway](https://docs.cloud.oracle.com/en-us/iaas/Content/APIGateway/Concepts/apigatewayconcepts.htm)          | Oracle Cloud Infrastructure API Gateway             | Digital Assistant API Gateway 
| [Vault](https://docs.oracle.com/en-us/iaas/Content/KeyManagement/Concepts/keyoverview.htm#Overview_of_Vault)        | Oracle Cloud Infrastructure Vault                   | Digital Assistant Vault 
| [VCN](https://docs.cloud.oracle.com/en-us/iaas/Content/Network/Tasks/managingVCNs.htm#VCNsandSubnets)               | Oracle Cloud Infrastructure VCN                     | Digital Assistant VCN
| [Subnets](https://docs.cloud.oracle.com/en-us/iaas/Content/Network/Tasks/managingVCNs.htm#VCNsandSubnets)           | Oracle Cloud Infrastructure VCN Subnets             | Digital Assistant - Public <br>Digital Assistant (OKE Nodes) - Private <br>Digital Assistant (OKE LB) - Private <br> Digital Assistant (OKE API) - Public
| [Object Storage Bucket](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm)       | Oracle Object Storage Bucket                        | Digital_AssistantBucket
| [Dynamic Group](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm)          | Oracle Cloud Infrastructure Dynamic Group           | DigitalAssistantDynamicGroup 
| [Policies (compartment)](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Concepts/policygetstarted.htm)   | Oracle Cloud Infrastructure Security Policies       | DigitalAssistantPolicies

## Prerequisites

- You must belong to a user group with tenancy administrator privileges to complete these steps.
- Make sure that the newly provisioned artifacts won't cause your tenancy to exceed its service limits.

## Provision infrastructure using Oracle Resource Manager (ORM)

The simplest way to provision the infrastructure is to click on the **Deploy to Oracle Cloud** button.

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-quickstart/oci-digital-assistant-external-services/releases/download/V1.0.3/oci-digital-assistant-external-services-v1.0.3.zip)

Or you can manually install the stack by following the below steps:

1. Download [`oci-digital-assistant-external-services-v1.0.3.zip`](../../releases/download/V1.0.3/oci-digital-assistant-external-services-v1.0.3.zip) file
1. From Oracle Cloud Infrastructure **Console/Resource Manager**, create a new stack.
1. Make sure you select **My Configurations** and then upload the zip file downloaded in the previous step.
1. Set a name for the stack and click Next.
1. Set the required variables values and then click Create.
    ![create stack](images/create_stack.gif)

1. From the stack details page, click **Terraform Actions**, and then click **Plan**. Ensure that the action completes successfully.
    ![plan](images/plan.png)

1. From the stack details page, click **Terraform Actions**, and then click **Apply**. Ensure that the action completes successfully.
    ![Apply](images/apply.png)

### Destroying The Infrastructure

If you later decide to delete the created artifacts, click **Terraform Actions**, and then click **Destroy**. Ensure that the action completes successfully.
    ![Destroy](images/destroy.png)

## Provision infrastructure using Terraform

1. Clone this repo

   ```
   git clone git clone git clone git@github.com:oracle-quickstart/oci-digital-assistant-external-services.git
   cd oci-digital-assistant-external-services/deploy/terraform
   ```

1. Create a copy of the **oci-digital-assistant-external-services/terraform.tfvars.example** file in the same directory and name it **terraform.tfvars**.
1. Open the newly created **oci-digital-assistant-external-services/terraform.tfvars** file and add your Oracle Cloud Infrastructure user and tenant details to the TF Requirements section.

        ```
           #*************************************
           #           TF Requirements
           #*************************************
           
           // Oracle Cloud Infrastructure Region, user "Region Identifier" as documented here https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm
           region=""
           // The Compartment OCID to provision artificats within
           compartment_ocid=""
           // Oracle Cloud Infrastructure User OCID, more details can be found at https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five
           user_ocid=""
           // Oracle Cloud Infrastructure tenant OCID, more details can be found at https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five
           tenancy_ocid=""
           // Path to private key used to create Oracle Cloud Infrastructure "API Key", more details can be found at https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/credentials.htm#two
           private_key_path=""
           // "API Key" fingerprint, more details can be found at https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/credentials.htm#two
           fingerprint=""
        ```
1. In the same file, revise the below settings:
   1. Set Application Name prefix
      ```
         #*************************************
         #         General
         #*************************************
         
         // Prefix name. Will be used as a name prefix to identify resources, such as OKE, VCN, API Gateway, and others
         app_name = "Digital Assistant"
      ```
   1. Set API Gateway URL Path prefix (must start with a leading / )
      ```
         #*************************************
         #    API Gateway Specific
         #*************************************
         
         // API Gateway Path Prefix
         // IMPORTANT: Must start with a leading "/"
         apigateway_path_prefix = "/oda"
      ```
   1. Configure Network Settings. By default, the stack will create a new VCN and its corresponding subnets, route tables, security list...etc
      if ```create_vcn = false```, then you must specify the OCID of an existing VCN to use, along with required subnets OCID.
      ```
         #*************************************
         #         Network Specific
         #*************************************
         
         // Create New VCN
         create_vcn = true
         
         // Existing VCN OCID - Only if "create_vcn" is set to "false"
         existing_vcn_id = ""
         
         // Existing Public Subnet (API Gateway) OCID - Only if "create_vcn" is set to "false"
         existing_public_subnet_id = ""
         
         // Existing Public Subnet (OKE API Endpoint) OCID - Only if "create_vcn" is set to "false"
         existing_public_subnet_id_oke = ""
         
         // Existing Private Subnet (OKE Worker Nodes) OCID - Only if "create_vcn" is set to "false"
         existing_private_subnet_id_oke_nodes = ""
         
         // Existing Private Subnet (OKE Load Balancer) OCID - Only if "create_vcn" is set to "false"
         existing_private_subnet_id_oke_lb = ""
      ```
   1. Vault Settings. By default, the stack will create a Vault, if ```create_vault = false```, then you must specify the OCID of an existing vault.
      ```
         #*************************************
         #    Vault Specific
         #*************************************
         // Create new vault
         create_vault = true
         
         // Existing Vault OCID - Only if "create_vault" is set to "false"
         existing_vault_id = ""
      ```
   
1. Run this command to Initialize the Terraform provider:

   ```shell
    terraform init
   ```

1. To see what components you'll create, and to verify that you can run the terraform scripts successfully, run this command:

    ```shell
    terraform plan
   ```

1. To execute the Terraform scripts, run this command:

    ```shell
    terraform apply -auto-approve
   ```

### Destroying the infrastructure

If you later decide to delete the created artifacts, run this command:

```shell
    terraform destroy -auto-approve
```

[magic_button]: https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg
[magic_stack]: https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-quickstart/oci-digital-assistant-external-services/releases/download/V1.0.1/oci-digital-assistant-external-services-v1.0.1.zip
