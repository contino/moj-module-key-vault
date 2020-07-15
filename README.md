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

Teams can use single Manage Identity for all the key vaults owned by a team.

In order to allow the managed identity access you need to either :

1. Add an additional variable to the module (`create_managed_identity`) which will create a managed identity and creates necessary access policy.
  ```
  module "claim-store-vault" {
    source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
    ....
    create_managed_identity = true
  }
  ```
  Object Id and Client id are available in terraform output in this case.

2. Add an additional variable to the module (`managed_identity_object_id`) with existing managed identity.
   
   ```
   module "claim-store-vault" {
     source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
     ....
     managed_identity_object_id= "<id goes here>"
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
