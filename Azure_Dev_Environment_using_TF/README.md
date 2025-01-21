# Project 1 - Azure Dev Environment created from Terraform

- [Project 1 - Azure Dev Environment created from Terraform](#project-1---azure-dev-environment-created-from-terraform)
  - [Components](#components)
  - [Setting up Terraform backend](#setting-up-terraform-backend)
  - [Reading azure resources using data blocks](#reading-azure-resources-using-data-blocks)
  - [Creating network elements.](#creating-network-elements)
  - [Creating log analytics workspace](#creating-log-analytics-workspace)
  - [Implementing terraform 'import' command](#implementing-terraform-import-command)
  - [Create Azure Federated Identity with Azure AD App](#create-azure-federated-identity-with-azure-ad-app)
  - [Azure app registration for Grafana](#azure-app-registration-for-grafana)
  - [Azure app registration for external-secrets-operator](#azure-app-registration-for-external-secrets-operator)
  - [Modules](#modules)
    - [AKS cluster creation](#aks-cluster-creation)
    - [Virtual Machine creation](#virtual-machine-creation)



## Components

- Setting up Terraform Backend in Azure blob container
- Creating Azure network components (e.g., subnets, security groups)
- Creating Virtual machines with `custom data` through a Terraform module
- Creating Azure app registrations and service principals
- Creating an AKS (Azure Kubernetes Service) cluster through a Terraform module
- Creating Azure log analytics workspaces
- Assigning Azure RBAC roles to resources


## Setting up Terraform backend

Ref: 

https://developer.hashicorp.com/terraform/language/settings/backends/azurerm

https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=terraform

1. Create an Azure app-registration to use it’s service principal to authenticate to azure.
2. Create certificates for the app-registration (so that we can provide client certificate path instead client-secret):
https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_client_certificate
3. Configure the backend and provider block.

[providers.tf](tf-azure/providers.tf)
[backend.tf](tf-azure/backend.tf)


## Reading azure resources using data blocks

[data_sources.tf](tf-azure/data_sources.tf)


## Creating network elements.

[network.tf](tf-azure/network.tf)

- Azure Virtual Network
- Subnet
- Network security group
- Network security rule
- Associating network security rule with the security group

## Creating log analytics workspace

[log-analytics.tf](tf-azure/log-analytics.tf)


## Implementing terraform 'import' command

[import.tf](tf-azure/import.tf)


## Create Azure Federated Identity with Azure AD App

[az-federated-identity.tf](tf-azure/az-federated-identity.tf)


Guide:
https://learn.microsoft.com/en-us/azure/active-directory/workload-identities/workload-identity-federation-create-trust?pivots=identity-wif-apps-methods-azp#github-actions

https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential

To perform the above from terraform, the app-registration needs :arrow_down:

RBAC roles: `Contributor` , `User Access Administrator`

AD roles: `Application Administrator`


## Azure app registration for Grafana

[grafana-appreg.tf](tf-azure/grafana-appreg.tf)

This includes
- Create Azure app registration
- Create client-secret for the applciation
- Create service principal
- Create key-vault secrets


## Azure app registration for external-secrets-operator

This includes

- Create Azure app registration
- Create client-secret for the applciation
- Create service principal
- Create key-vault secrets
- Create key-vault access policy


## Modules

### AKS cluster creation

This module includes the following concepts,

- Create an aks cluster
- Create RBAC role assignment to the cluster
- Create a log analytics workspace to monitor the AKS cluster

### Virtual Machine creation

This module includes the following concepts,

- Create virtual machine
- Use provisioners
- Use custom data with the VM
- Assign an availability set with tht VM
- Create and associate public IP address with the VM (NIC of the VM)
- Create and associate a data disk with the VM