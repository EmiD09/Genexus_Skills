<!-- GENERATED from catalog/properties/properties-object-data-provider.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: properties-object-data-provider
description: Configurable data provider properties
---

Applies to: Data Provider objects ([object-data-provider](./object-data-provider.md))

# GENERAL
Includes [properties-common](./properties-common.md).

## Expose as Web Service
Publishes the object as a web service endpoint
- Type: `boolean`
- Default: `false`

## Main program
To specify that the object is main. That is: it can be executed as standalone application
- Type: `boolean`
- Default: `false`

## Call protocol
Define how the object is invoked, and its output
- Type: `enum{Internal,HTTP,Command Line,SOAP,Enterprise Java Bean}`
- Options:
  - `Internal`: Executes internally within the application runtime
  - `HTTP`: Exposes or invokes behavior over HTTP
  - `Command Line`: Enables command-line invocation
  - `SOAP`: Exposes or invokes behavior as SOAP service
  - `Enterprise Java Bean`: Uses Enterprise Java Bean integration mode
- Default: `Internal`

# OUTPUT

## Infer Structure
Infers output SDT from assignment structure
- Type: `enum{Yes\, if SDT is dynamic,No}`
- Options:
  - `Yes, if SDT is dynamic`: Enables this behavior
  - `No`: Disables this behavior
- Default: `No`

## Output
Type
- Type: `string`

## Collection
Indicates whether output is a collection
- Type: `boolean`
- Default: `false`

# NETWORK
Includes [properties-common-network](./properties-common-network.md).

# OBSERVABILITY
Includes [properties-common-observability](./properties-common-observability.md).

# INTEGRATED SECURITY
Includes [properties-common-integrated-security](./properties-common-integrated-security.md).

# WARNING MESSAGES
Includes [properties-common-warning-messages](./properties-common-warning-messages.md).
