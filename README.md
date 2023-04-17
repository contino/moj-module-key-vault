# Module key vault

This is a terraform module for creating an azure key vault resource

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0.0 |

## Usage
```hcl
module "this" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                = "rhubarb-fe-${var.env}" // Max 24 characters
  product             = var.product
  env                 = var.env
  object_id           = var.jenkins_AAD_objectId
  resource_group_name = azurerm_resource_group.rg.name
  product_group_name  = "Your AAD group" # e.g. MI Data Platform, or dcd_cmc
}
```

## Notes

The module creates the following permissions:
 - Jenkins access to Keyvault
 - Managed Identity ($product)-$env-mi
 - Federated Identity Credential $product-$env-fdc
 - Product team/developers access

## Reading secrets

All developers have access to read non production secrets if they are a member of the `DTS CFT Developers` Azure AD group

Reading of production secrets is discouraged, in general you should overwrite the secret rather than trying to read it.

_If you really really need that secret then ask the Platform Operations team to get it for you._

Reading a secret via Azure CLI:
```bash
$ az keyvault secret show --vault-name $VAULT --name $SECRET
```

## Writing secrets to key vaults
The product group for the key vault have permissions to update / write / list / delete secrets in all environments
This should be your teams AD group, it's controlled by the `product_group_object_id` variable

You should always write secrets via the command line, as you normally don't have read access on the production vault, but you can still write the secrets via CLI.

```bash
$ az keyvault secret set --vault-name $VAULT_NAME --name "${SECRET_NAME}" --value "${SECRET_VALUE}"
```

More docs can be found here:
https://docs.microsoft.com/en-us/cli/azure/keyvault/secret?view=azure-cli-latest

### product_group_object_id (deprecated)

_Note: Historically this module couldn't look up groups by display name, that is now available in `product_group_name`_

The product group object id is the Azure AD group object_id of users
who should be allowed to write secrets into the vault
(note they can't read the secrets after writing).

Useful commands for finding your group object id:

List all reform groups:
```bash
$ az ad group list --query "[?contains(displayName, 'dcd_')].{DisplayName: displayName, id: id}" -o table
```

Retrieve by name if you know the display name:
```bash
$ az ad group list --query "[?displayName=='dcd_devops'].{DisplayName: displayName, id: id}" -o table
```

## Keyvault access using Access Control List
Allow the jenkins subnet id e.g [data.azurerm_subnet.jenkins_subnet.id] and others
Allow the listed set of IPs
```hcl
# Set by the Jenkins pipeline
variable "mgmt_subscription_id" {}

provider "azurerm" {
  alias           = "mgmt"
  subscription_id = var.mgmt_subscription_id
  features {}
}

# for SDS
data "azurerm_subnet" "jenkins_subnet" {
  provider             = azurerm.mgmt
  name                 = "iaas"
  virtual_network_name = var.env == "sbox" ? "ss-ptlsbox-vnet" : "ss-ptl-vnet"
  resource_group_name  = var.env == "sbox" ? "ss-ptlsbox-network-rg" : "ss-ptl-network-rg"
}

# for CFT
data "azurerm_subnet" "jenkins_subnet" {
  provider             = azurerm.mgmt
  name                 = "iaas"
  virtual_network_name = "cft-ptl-vnet"
  resource_group_name  = "cft-ptl-network-rg"
}

module "this" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
 #...
  network_acls_allowed_subnet_ids = [data.azurerm_subnet.jenkins_subnet.id] 
  network_acls_allowed_ip_ranges = ["IPs"]
  network_acls_default_action = "Deny" # Allow by default
}
```

## Application access using Managed Identities
If your application is running in kubernetes it will retrieve the secrets with a managed identity.

Teams can use single Manage Identity for all the key vaults owned by a team.

In order to allow the managed identity access you need to either :

#### Create a new Managed Identity

Add an additional variable to the module (`create_managed_identity`) which will create a managed identity and creates necessary access policy.
```hcl
module "this" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
 #...
  create_managed_identity = true
}
```
Object Id and Client id are available in terraform output.

#### Use an Existing MI
Add the `managed_identity_object_ids` variable to the module with an existing managed identity.

```hcl
data "azurerm_user_assigned_identity" "cmc-identity" {
 name                = "${var.product}-${var.env}-mi"
 resource_group_name = "managed-identities-${var.env}-rg"
}

module "this" { 
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  #...
  managed_identity_object_ids = [data.azurerm_user_assigned_identity.cmc-identity.principal_id]
}

```

### Accessing Managed Identity details
You may need to join the readers group for the subscription in order to see the manged identity

It can be retrieved with: 
```bash
$ az identity show --name <identity-name>-sandbox-mi -g managed-identities-<env>-rg --subscription <Subscription> --query principalId -o tsv
```

i.e. for sandbox 
```bash
$ az identity show --name cnp-sandbox-mi -g managed-identities-sbox-rg --subscription DCD-CFT-Sandbox --query principalId -o tsv
```

### Workload Identity

A Federated Identity Credential will be created with the name `$product-$env-fdc` for using Workload Identity on AKS. The subject of this resource is `system:serviceaccount:${local.namespace}:${local.namespace}`.

Your namespace will default to your product name, if these don't match then you will need to pass the `namespace` variable to override it:

```hcl
module "this" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                = "rhubarb-fe-${var.env}" // Max 24 characters
  product             = var.product
  namespace           = "Your team's AKS namespace" # e.g. sscs, xui, dm-store
  ...
}
```

AKS Cluster provider:

```hcl
variable "aks_subscription_id" {
  description = "Provided by the Jenkins library, ADO users will need to specify this."
  default     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```