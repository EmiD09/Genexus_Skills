<!-- GENERATED from catalog/properties/properties-common-integrated-security.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: properties-common-integrated-security
description: Shared integrated security properties for object property definitions
---

Applies to: common definition for integrated security property groups

# INTEGRATED SECURITY

## Integrated Security Level
Authentication and authorization requirement level
- Type: `enum{None,Authentication,Authorization}`
- Options:
  - `None`: No security checks are enforced for the object
  - `Authentication`: Requires a logged-in user, without permission checks
  - `Authorization`: Requires authentication and permission checks through GAM
- Default: `Depends on the EnableNationalLanguageSupport property in src/#preferences/*.kb.gx version: if EnableNationalLanguageSupport = 'Yes' the default is Authentication; if EnableNationalLanguageSupport = 'No' or not set, the default is None`

## Permission Prefix
Prefix used when generating permissions
- Type: `string`
