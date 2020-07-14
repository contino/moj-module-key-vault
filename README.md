# Module key vault

This is a terraform module for creating an azure key vault resource

## Usage
```
module "claim-store-vault" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                = "rhubarb-fe-${var.env}" // Max 24 characters
  product             = "${var.product}"
  env                 = "${var.env}"
  tenant_id           = "${var.tenant_id}"
  object_id           = "${var.jenkins_AAD_objectId}"
  resource_group_name = "${module.<another-module>.resource_group_name}"
  product_group_object_id = "<uuid>"
}
```

## Writing secrets to key vaults
The product group for the key vault have permissions to update / write / list / delete secrets in all environments
This should be your teams AD group, it's controlled by the `product_group_object_id` variable

You should always write secrets via the command line, as you normally don't have read access on the production vault but you can still write the secrets via CLI.

```bash
$ az keyvault secret set --vault-name vault-name --name name --value value
```

More docs can be found here:
https://docs.microsoft.com/en-us/cli/azure/keyvault/secret?view=azure-cli-latest

### product_group_object_id
The product group object id is the Azure AD group object_id of users
who should be allowed to write secrets into the vault
(note they can't read the secrets after writing).

Useful commands for finding your group object id:

List all reform groups:
```bash
$ az ad group list --query "[?contains(displayName, 'dcd_')].{DisplayName: displayName, ObjectID: objectId}" -o table
```

Retrieve by name if you know the display name:
```bash
$ az ad group list --query "[?displayName=='dcd_devops'].{DisplayName: displayName, ObjectID: objectId}" -o table
```

### managed_identity_object_ids
If your application is running in kubernetes it will retrieve the secrets with a managed identity.

In order to allow the managed identity access you need to add an additional variable to the module (`managed_identity_object_ids`).

Teams can use single Manage Identity for all the key vaults owned by a team.

```
resource "azurerm_user_assigned_identity" "cmc-identity" {

  resource_group_name = "managed-identities-${var.env}-rg"
  location            = "${var.location}"

  name = "${var.product}-${var.env}-mi"
  
  tags = "${var.common_tags}"
}
```

```
module "claim-store-vault" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  ....
  managed_identity_object_ids= [${azurerm_user_assigned_identity.cmc-identity.principal_id}]
}

```
You may need to join the readers group for the subscription in order to see the manged identity

It can be retrieved with: 
```bash
$ az identity show --name <identity-name>-sandbox-mi -g managed-identities-<env>-rg --subscription DCD-CFTAPPS-<env> --query principalId -o tsv
```

i.e. for sandbox 
```bash
$ az identity show --name rpe-sandbox-mi -g managed-identities-sbox-rg --subscription DCD-CFTAPPS-SBOX --query principalId -o tsv
```
