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

- Create service principal for Terraform and Packer [Create service Principal](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html)
- Set ARM environment variables

  $ export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
    $ export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
  $ export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
    $ export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"

- Create resource group to store Packer Image

  az group create -l eastus -n packer-image-rg

- Update 'server.json' variables block (optional, if you chose a different name for Packer Image resource group)

  variables.resource_group = "packer-image-rg"

- Build packer image

  packer build server.json

-

### Output

**Your words here**
