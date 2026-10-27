<!-- GENERATED from catalog/properties/properties-object-url-rewrite.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: properties-object-url-rewrite
description: Configurable url rewrite properties
---

Applies to: URL Rewrite objects ([object-urlrewrite](./object-urlrewrite.md))

# GENERAL
Includes [properties-common](./properties-common.md).

## Encrypt URL parameters
Keep target web objects with URL parameter encryption disabled
- Type: `enum{Use Environment property value,No,Session key,Site key}`
- Options:
  - `Use Environment property value`: Inherit encryption behavior from environment
  - `No`: Disable URL parameter encryption for rewrite compatibility
  - `Session key`: Encrypt URL parameters with session-scoped key
  - `Site key`: Encrypt URL parameters with site-scoped key

## Parameters Style
Use named parameters in environment routing configuration
- Type: `enum{Use Environment property value,Named,Positional}`
- Options:
  - `Use Environment property value`: Inherit parameter style from environment
  - `Named`: Use named parameters required by URL rewrite mappings
  - `Positional`: Use ordered parameters without explicit names

## Web User Experience
Prefer smooth navigation mode on affected web objects
- Type: `enum{Smooth,Previous versions compatible}`
- Options:
  - `Smooth`: Use modern navigation behavior compatible with URL rewrite
  - `Previous versions compatible`: Keep legacy navigation compatibility mode

# NOTES
Property dependencies declared in the source:
- Encrypt URL parameters: dependants are Parameters Style and Web User Experience.
- Parameters Style: dependant is Encrypt URL parameters.
- Web User Experience: dependant is Encrypt URL parameters.
No defaults are declared for these properties in the source.
