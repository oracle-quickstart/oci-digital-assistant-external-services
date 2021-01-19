# Oracle Digital Assistant External Services

## Introduction

This solution provision and configure the needed infrastructure to deploy [Oracle Digital Assistant (**_ODA_**)](https://docs.oracle.com/en-us/iaas/digital-assistant/index.html) custom components/webviews externally to [Oracle Kubernetes Engine (**_OKE_**)](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengoverview.htm) using [Terraform](https://www.terraform.io/docs/providers/oci/index.html) and [Oracle Cloud Infrastructure Resource Manager](https://docs.cloud.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resourcemanager.htm) . The provisioned infrastructure can also be used to deploy different utility services that ODA can benefit from like custom channel webhook implementations.

Below is a list of all artifacts that will be provisioned:

| Component                                                                                                           | Description                                         | Default Name             
|---------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------|-------------------------
| [API Gateway](https://docs.cloud.oracle.com/en-us/iaas/Content/APIGateway/Concepts/apigatewayconcepts.htm)          | Oracle Cloud Infrastructure API Gateway             | Digital Assistant API Gateway 
| [VCN](https://docs.cloud.oracle.com/en-us/iaas/Content/Network/Tasks/managingVCNs.htm#VCNsandSubnets)               | Oracle Cloud Infrastructure VCN                     | Digital Assistant VCN
| [Subnets](https://docs.cloud.oracle.com/en-us/iaas/Content/Network/Tasks/managingVCNs.htm#VCNsandSubnets)           | Oracle Cloud Infrastructure VCN Subnets             | Digital Assistant - Public <br>Digital Assistant - Private <br>Digital Assistant (OKE LB) - Private
| [Dynamic Group](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm)          | Oracle Cloud Infrastructure Dynamic Group           | DigitalAssistantDynamicGroup 
| [Policies (compartment)](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Concepts/policygetstarted.htm)   | Oracle Cloud Infrastructure Security Policies       | DigitalAssistantPolicies

## Prerequisite

- You need a user with an **Administrator** privileges to execute the ORM stack or Terraform scripts.
- Make sure your tenancy has service limits availabilities for the above components in the table.

## Provision infrastructure using Oracle Resource Manager (ORM)

1. clone repo `git clone git@github.com:oracle-quickstart/oci-digital-assistant-external-services.git`
1. Download [`oci-digital-assistant-external-services-v1.0.0.zip`](../../releases/download/v1.0.0/oci-digital-assistant-external-services-v1.0.0.zip) file
1. From Oracle Cloud Infrastructure **Console/Resource Manager**, create a new stack.
1. Make sure you select **My Configurations** and then upload the zip file downloaded in the previous step.
1. Set a name for the stack and click Next.
1. Set the required variables values and then Create.
    ![create stack](images/create_stack.gif)

1. From the stack details page, Select **Plan** under **Terraform Actions** menu button and make sure it completes successfully.
    ![plan](images/plan.png)

1. From the stack details page, Select **Apply** under **Terraform Actions** menu button and make sure it completes successfully.
    ![Apply](images/apply.png)

1. To destroy all created artifacts, from the stack details page, Select **Destroy** under **Terraform Actions** menu button and make sure it completes successfully.
    ![Destroy](images/destroy.png)

## Provision infrastructure using Terraform

1. Clone repo

   ```
   git clone git clone git clone git@github.com:oracle-quickstart/oci-digital-assistant-external-services.git
   cd oci-digital-assistant-external-services/deploy/terraform
   ```

1. Create a copy of the file **oci-digital-assistant-external-services/deploy/terraform/terraform.tfvars.example** in the same directory and name it **terraform.tfvars**.
1. Open the newly created **oci-digital-assistant-external-services/deploy/terraform/terraform.tfvars** file and edit the following sections:
    * **TF Requirements** : Add your Oracle Cloud Infrastructure user and tenant details:

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

1. Initialize terraform provider

   ```shell
    terraform init
   ```

1. Plan terraform scripts

    ```shell
    terraform plan
   ```

1. Run terraform scripts

    ```shell
    terraform apply -auto-approve
   ```

1. To Destroy all created artifacts

    ```shell
    terraform destroy -auto-approve
   ```
