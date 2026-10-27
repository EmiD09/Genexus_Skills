<!-- GENERATED from catalog/properties/properties-object-design-system.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: properties-object-design-system
description: Configurable design system properties
---

Applies to: Design System objects ([object-design-system](./object-design-system.md))

# GENERAL
Includes [properties-common](./properties-common.md).

## Folder
Folder where the object is organized in the KB
- Type: `string`

## Base CSS
A CSS library to include as a base style
- Type: `enum{None,Bootstrap v3,Bootstrap v3 RTL}`
- Options:
  - `None`: Disables additional behavior for this setting
  - `Bootstrap v3`: Uses the Bootstrap v3 design system
  - `Bootstrap v3 RTL`: Uses the Bootstrap v3 RTL design system
- Default: `None`

## Default Template Layout
Specifies a template used to generate default Transactions and WorkWith web layouts
- Type: `enum{FlatTemplate,UnanimoTemplate,CarmineTemplate,FioriTemplate}`
- Options:
  - `FlatTemplate`: Uses the FlatTemplate form layout
  - `UnanimoTemplate`: Uses the UnanimoTemplate form layout
  - `CarmineTemplate`: Uses the CarmineTemplate form layout
  - `FioriTemplate`: Uses the FioriTemplate form layout
- Default: `UnanimoTemplate`

# NOTES
Use this file to select editable properties, defaults, and valid options for this target.
