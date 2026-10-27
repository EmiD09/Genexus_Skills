<!-- GENERATED from catalog/properties/properties-object-file.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: properties-object-file
description: Configurable file properties
---

Applies to: File objects ([object-file](./object-file.md))

# GENERAL
Includes [properties-common](./properties-common.md).

## External File Name
Name of the file when it is extracted from the Knowledge Base to the file system
- Type: `string`

## Extract for Java Generator
Includes this file in Java generator output
- Type: `boolean`

## Extract for .Net Generator
Includes this file in .NET generator output
- Type: `boolean`

## Extract for .Net Core Generator
Includes this file in .NET Core generator output
- Type: `boolean`

## Extract for iOS Generator
Includes this file in iOS generator output
- Type: `boolean`

## Extract for Android Generator
Includes this file in Android generator output
- Type: `boolean`

## Extract Zip
Extract zip file content when copying
- Type: `boolean`

# NOTES
File object names do not include a file extension (engine-confirmed); the extension belongs to the External File Name used when extracting to the file system.
