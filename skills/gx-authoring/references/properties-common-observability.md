<!-- GENERATED from catalog/properties/properties-common-observability.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: properties-common-observability
description: Shared observability properties for object property definitions
---

Applies to: common definition for observability property groups

# OBSERVABILITY

## Generate Observability span
Enables generation of OpenTelemetry spans for runtime tracing
- Type: `enum{Yes,No}`
- Options:
  - `Yes`: Enables this behavior
  - `No`: Disables this behavior
- Default: `No`
