# Provisioning Info for Permissions in Graph

## Abstract
The provisioning info file is a JSON file that contains a list of permissions and the cloud environments in which they are available.

## Introduction
The JSON permissions model seeks to be the authoritative source of truth for for data on permissions to API mapping. We have restricted the contents of the JSON permission files to modeling data that has to be reviewed for every change. This does not include data about the cloud environments in which API workloads intend to publish permissions to. Some of that data is only known after the permission has been published to the environment and would have to either be automatically or manually updated by the publishing team back to the permissions model file after the change review. This should not require a review of the change to the permission file. The provisioning info file is complementary to the JSON permissions model files and allows us to keep the permissions model file as the authoritative source of truth for permissions modeling data while allowing us to maintain a separate source of truth for cloud availability data.

## The Provisioning Info file
The provisioning info file is a single file for all permissions. Permissions are still the primary concept with a many to many relationship between permissions and cloud environments. Permission claim values are the top level members to enable quick lookup for provisioning for a permission. Not all implemented schemes of a permission are published consistently across all environments and even when published they would happen to have different unique identifiers. The provisioning info file allows us to model the cloud availability of each scheme of a permission.

```json
"provisioningInfo": {
  “Foo.Read.All”: {
    "requiredEnvironments": [
      {
        "mooncake": {
          "schemes": [
            {
              "DelegatedWork": {
                "isPresent": true,
                "isHidden": false,
                "isDisabled": false,
                "id": "bed71653-0fa8-42a0-b33c-a1aab02ecda6"
              }
            }
          ]
        },
        "global": {
          "schemes": [
            {
              "DelegatedWork": {
                "isPresent": true,
                "isHidden": false,
                "isDisabled": false,
                "id": "bed71653-0fa8-42a0-b33c-a1aab02ecda6"
              }
            }
          ]
        }
      }
    ]
  }
}
```

### isHidden
The "isHidden" member is a boolean value that indicates if a permission should be publicly usable in the API.  

### requiredEnvironments
The "requiredEnvironments" member is an array of strings that identifies the deployment environments in which the permission SHOULD be supported. When this member is not present, support for all environments is implied.

### resourceAppId
The "resourceAppId" member value provides an identifier of the resource server that is used to enforce Conditional Access checks for this permission.


