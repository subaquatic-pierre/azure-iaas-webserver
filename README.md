# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction

This project contains infrastructure to host a web application on Microsoft Azure. It uses Terraform to manage resources, packer to build an
image to be used for the virtual machine and create the necessary network resources to route traffic. It includes a private subnet with
a Network security group to prevent external access to the resources.

Follow the instructions below is setup the environment.

All commands are run through Azure CLI (see Dependencies section)

### Getting Started

1. Clone this repository
2. Ensure you have all dependencies installed and Microsoft accounts (see Dependencies section)
3. Run commands to create resources (see Instructions section for commands)

### Dependencies

1. Create an [Azure Account](https://portal.azure.com)
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

#### 1. Create service principal for Terraform and Packer [Create service Principal](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html)

#### 2. Set ARM environment variables:

    $ export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
    $ export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
    $ export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
    $ export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"

#### 3. Create resource group to store Packer Image:

    az group create -l eastus -n packer-image-rg

#### 4. Update Packer variables (optional):

If you chose a different name for the resource groups you will need to update the variables in the 'server.json' file.

```json
    ...
    "variables": {
        ...
        "resource_group": "packer-image-rg",
        "image_name": "packer-image"
        ...
    },
    ...
```

#### 5. Build packer image

    packer build server.json

#### 6. Get Image ID

Get the ID for the image you just created, to be used in the Terraform template

    az image show packer-image

#### 7. Edit Terraform variables

Edit variables in the 'variables.tf' to reflect your information.

The following items should be updated:

- prefix
- username
- password
- location (should match image resource group location)
- image_id

```hcl
variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "YOUR PREFIX"
}

variable "username" {
  description = "Enter username to associate with the machine"
  default     = "YOUR USER NAME"

}

variable "password" {
  description = "Enter password to use to access the machine"
  default     = "YOUR PASSWORD"

}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "YOUR LOCATION"
}

variable "image_id" {
  description = "Enter the ID for the image which will be used for craeting the Virtual Machines"
  default     = "YOURIMAGE ID HERE"
}

...

```

Instance count will be prompted on creation of the resources.

#### 7. Run Terraform

    terraform plan
    terraform apply

### Output

**Your words here**
