<!-- GENERATED from catalog/properties/properties-object-domain.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: properties-object-domain
description: Configurable domain properties
---

Applies to: Domain objects ([object-domain](./object-domain.md))

# GENERAL
Includes [properties-common](./properties-common.md).

## Data Type
Logical type used for storage and validation
- Type: `string`

## Length
Maximum length for character or numeric values
- Type: `integer`

## Decimals
Decimal precision for numeric values
- Type: `integer`

## Signed
Allow negative numeric values
- Type: `boolean`

## Default
Default value used when no input value is provided
- Type: `string`

# VALIDATION

## Regular Expression
Validation pattern applied to accepted values
- Type: `string`

## Picture
Format mask used for display and parsing
- Type: `string`

## EnumValues
Allowed literals and labels for enumeration domains
- Type: `string`
