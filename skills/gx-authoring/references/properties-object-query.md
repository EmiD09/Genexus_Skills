<!-- GENERATED from catalog/properties/properties-object-query.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: properties-object-query
description: Configurable query properties
---

Applies to: Query objects ([object-query](./object-query.md))

# GENERAL
Includes [properties-common](./properties-common.md).

## Title
Label shown in generated UI and tooling
- Type: `string`

## Output Type
Type selector that controls generation behavior
- Type: `enum{Card,Chart,Pivot Table}`
- Options:
  - `Card`: Displays results in card layout
  - `Chart`: Displays results in chart layout
  - `Pivot Table`: Displays results in pivot table layout

## Cache expiration lapse
Cache validity duration before refresh
- Type: `string`

# NOTES
Use this file to select editable Query properties.
