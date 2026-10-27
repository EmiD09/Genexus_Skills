<!-- GENERATED from catalog/properties/properties-object-module.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: properties-object-module
description: Configurable module properties
---

Applies to: Module objects ([object-module](./object-module.md))

# GENERAL
Includes [properties-common](./properties-common.md).

# MODULE MANAGER INFORMATION

## Package Name
Package identifier used for module publishing
- Type: `string`

## ModuleVersion
Module semantic version used for packaging and distribution
- Type: `string`
- Default: `1.0`

## ModuleDescription
Functional description used as metadata
- Type: `string`

## ModuleAuthor
Author metadata published with the module
- Type: `string`

## Module License URL
License reference URL for the module
- Type: `string`

## Module Project URL
Project homepage URL for the module
- Type: `string`

## Module Server URL
GeneXus Server URL associated to the module
- Type: `string`

## ModuleTags
Tags used to categorize and discover the module
- Type: `string`

## ModuleOwner
Owner metadata for governance and maintenance
- Type: `string`

## ModuleResources
File object resources packaged with the module
- Type: `string`

## ModuleIdentifier
Stable module identifier used for packaging, import resolution, and references
- Type: `Guid`

# NOTES
ModuleIdentifier rules: required for publishable modules only; preserve value across exports and releases.
Object Visibility is inherited from the GENERAL include (properties-common); per design decision D8 its values use "Knowledge Base" with a space.
