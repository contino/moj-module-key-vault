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