# Permissions for HTTP APIs 

## Abstract
This document defines a "permission" object and "permissions" document that describes identifiers that can be used by security claims to grant access to HTTP resources.

## Introduction

## Notational Conventions
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in BCP 14 [RFC2119] [RFC8174] when, and only when, they appear in all capitals, as shown here.

## <a name="permissionsObject"></a> Permissions JSON Object
The canonical model for a permissions document is a JSON [JSON] object. When serialized in a JSON document, that format is identified with the "application/permissions+json" media type.

```json
{
	"permissions": {
		"PrintSettings.Read.All": {
			"schemes": {
				"DelegatedWork": {
					"type": "DelegatedWork",
					"description": "Allow signed in user to read print settings"
				}
			},
			"pathSets": [{
				"schemes": ["DelegatedWork"],
				"methods": ["GET"],
				"paths": {
					"/print/settings": {}
				}
			}]
		}
	}
}
```
In this example, the claim "PrintSettings.Read.All" is required when using the "DelegatedWork" security scheme to access the resource "/print/settings" using the "GET" method.

### permissions
The "permissions" member is a JSON object whose members permission objects. The key of each member is the claim identifier used for the [Permission Object](#permissionObject)    


## <a name="permissionObject"></a>Permission Object

### note
The "note" member is a freeform string that provides additional details at about the permission that cannot be determined from the other members of the permission object.

### implicit
The "implicit" member is a boolean value that indicates that the current permission object is implied.  The default value is "false". This member us usually set to "true" in combination with a "alsoRequires" expression.

> Note: This member enables support for the Microsoft Graph create subscription endpoint and the Search query endpoint. 

### schemes
The "schemes" member is a REQUIRED JSON object whose members are [Scheme objects](#schemeObject) supported by the permission. The key of each member is an identifier of the scheme and the value is a [Scheme object](#schemeObject) that contains descriptions of the permission within the scheme.   

### pathSets
The "pathSets" member is a REQUIRED JSON Array. Each element of the array is a [pathSet object](#pathSetObject). 

### isHidden
The "isHidden" member is a boolean value that indicates if a permission should be publicly usable in the API.  

### requiredEnvironments
The "requiredEnvironments" member is an array of strings that identifies the deployment environments in which the permission SHOULD be supported. When this member is not present, support for all environments is implied.

### privilegeLevel
The "privilegeLevel" member value provides a hint as to the risks of consenting this permissions. Valid values include: low, medium and high.

### appIdForConditionalAccessChecks
TBD

### ownerEmail
The "ownerEmail" member is a REQUIRED string that provides a contact mechanism for communicating with the owner of the permission. It is important that owners of permissions are aware when new paths are added to an existing permission.

## <a name="pathSetObject"></a>PathSet Object
A pathSet object identifies a set of paths that are accessible via the identified HTTP methods and schemes. Ideally, a permission object contains a single pathSet object. This indicates that all paths protected by the permission support the same HTTP methods and and schemes. In practice there are cases where support is not uniform. Distinct pathSet objects can be created to separate the paths with varying support.  

> Note: The design chosen was intentional to encourage permission creators to ensure support for methods and schemes is as consistent as possible. This produces a better developer experience for API consumers.

```json
"pathSets": [{
        "schemes": ["DelegatedWork"],
        "methods": ["GET"],
        "paths": {
            "/print/settings": {}
        }
    },
    {
        "schemes": ["Application"],
        "methods": ["GET,POST"],
        "paths": {
            "/print/settings": {}
        }
    }
] 
```

### schemes
The "schemes" member is a REQUIRED array of strings that reference the schemes defined in the [permission object](#permissionObject) that are supported by the paths in this pathSet object.

### methods
The "methods" member is a REQUIRED array of strings that represent the HTTP methods supported by the paths in this pathSet object.

### paths
The "paths" member is a REQUIRED object whose keys contain a simplified URI template to identify the resources protected by this permission object.

## <a name="schemeObject"></a>Scheme Object
The scheme object has members that describe the permission within the context of the scheme. Additional members provide behavioral constraints of the permission when used with the scheme.  

```json
"schemes": {
    "DelegatedWork": {
        "adminDisplayName": "Read and write app activity to users'activity feed",
        "adminDescription": "Allows the app to read and report the signed-in user's activity in the app.",
        "consentDisplayName": "Read and write app activity to users'activity feed",
        "consentDescription": "Allows the app to read and report the signed-in user's activity in the app.",
        "requiresAdminConsent": true
    },
    "DelegatedPersonal": {
        "type": "DelegatedPersonal",
        "consentDisplayName": "Read and write app activity to users'activity feed",
        "consentDescription": "Allows the app to read and report the signed-in user's activity in the app."
    },
    "Application": {
        "type": "Application",
        "adminDisplayName": "Read and write app activity to users' activity feed",
        "adminDescription": "Allows the app to read and report the signed-in user's activity in the app.",
    }
```
### adminDisplayName
The "adminDisplayName" member is a string that provides a short permission name that considers the current scheme and the perspective of a resource administrator.

### adminDescription
The "adminDescription" member is a string that describes the permission considering the current scheme from the perspective of a resource administrator.

### consentDisplayName
The "consentDisplayName" member is a REQUIRED string that provides a short permission name that considers the current scheme and the perspective of the user consenting an application.

### consentDescription
The "consentDescription" member is a REQUIRED string that describes the permission considering the current scheme from the perspective of the user consenting an application.

### requiresAdminConsent
The "requiresAdminConsent" member is a boolean value with a default value of false. When true, this permission can only be consented by an adminstrator.

## <a name="pathObject"></a>Path Object
The path object contains properties that affect how the permission object controls access to resource identified by the key of the path object.

```json
"paths": {
  "/me/activities/{id}": {
    "leastPrivilegePath": ["DelegateedWork", "DelegatedPersonal"],
    "includedProperties": ["id","displayName"],
    "excludedProperties": ["cost"]
  }
```
### leastPrivilegePath
The "leastPrivilegePath" member is an array of strings that identify the schemes for which this permission is the least privilege permission for accessing the path.

### includedProperties
The "includedProperties" member is an array of strings that identify properties of the resource representation returned by the path, that are accessible with the permission.

### excludedProperties
The "includedProperties" member is an array of strings that identify properties of the resource representation returned by the path, that are not accessible with the permission.

### alsoRequires
The "alsoRequires" member is logical expression of permissions that must be presented as claims alongside the current permission. 

```
(User.Read | User.Read.All) & Group.Read
```

## Appendix A. JSON Schema for HTTP Problem 
```json
{
    "$schema": "http://json-schema.org/draft-07/schema",
    "title": "Schema for OAuth Permissions",
    "type": "object",
    "properties": {
        "additionalProperties": false,
        "permissions": {
            "title": "Map of permission name to definition",
            "additionalProperties": false,
            "type": "object",
            "patternProperties": {
                "[\\w]+\\.[\\w]+[\\.[\\w]+]?": {
                    "type": "object",
                    "title": "Permission definition",
                    "additionalProperties": false,
                    "properties": {
                        "note": {
                            "type": "string"
                        },
                        "schemes": {
                            "type": "object",
                            "patternProperties": {
                                ".*": {
                                    "$ref": "#/definitions/scheme"
                                  }
                                }
                            }
                        },
                        "pathSets": {
                            "type": "array",
                            "items": {
                                "$ref": "#/definitions/pathSet"
                               } 
                            }
                        }
                    }
                }
            }
        }
    },
    "definitions": {
        "schemeTypes": {
            "type": "string",
            "enum": [
                "delegated-work",
                "delegated-personal",
                "application",
                "resource-specific-consent"
            ]
        },
        "pathSet": {
            "type": "object",
            "additionalProperties": false,
            "properties": {
                "schemes": {
                    "type": "array",
                    "items": {
                        "$ref": "#/definitions/schemeTypes"
                    }
                },
                "methods": {
                    "type": "array",
                    "items": {
                        "type": "string",
                        "enum": ["GET","PUT","POST","DELETE","PATCH","HEAD","OPTIONS","<WriteMethods>","<ReadMethods>"
                        ]
                    }
                },
                "paths": {
                    "type": "object",
                    "patternProperties": {
                        ".*": {
                            "$ref": "#/definitions/path"
                           }
                        }
                    }
                }
        },
        "path": {
            "type": "object",
            "properties": {
                "excludeProperties": {
                    "type": "array",
                    "items": {
                        "type": "string"
                    }
                },
                "alsoRequires": {
                    "type": "string",
                    "pattern": "[\\w]+\\.[\\w]+[\\.[\\w]+]?"
                }
            },
        "scheme": {
            "type": "object",
            "properties": {
                "requiresAdminConsent": {
                    "type": "boolean"
                },
                "type": {
                    "$ref": "#/definitions/schemeTypes"
                },
                "description": {
                    "type": "string"
                },
                "consentDescription": {
                    "type": "string"
                }
            }
    }
}
```