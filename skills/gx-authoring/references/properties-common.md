<!-- GENERATED from catalog/properties/properties-common.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: properties-common
description: Shared properties across all objects
---

Applies to: shared properties included by object property catalogs; applies to every object type

# GENERAL

## Description
Describes the content or purpose of the element
- Type: `string`

## Object Visibility
Defines object visibility, access scope, and distribution; inherited from containing Module object unless explicitly overridden
- Type: `enum{Public,Private,Internal,Knowledge Base}`
- Options:
  - `Public`: Visible and accessible outside the module
  - `Private`: Visible only within the same module and its sub-modules
  - `Internal`: Visible within the module but not exposed externally
  - `Knowledge Base`: Visible across the knowledge base

# NOTES
Description: optional but recommended (source hint).
