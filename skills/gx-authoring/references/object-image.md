<!-- GENERATED from catalog/objects/image.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-image
description: Represents one logical image with interchangeable variants automatically applied by the given context
---

# DEFINITION
An `Image` object (or `IMG`) defines a container for several bitmaps. Each entry is one physical
image variant inside the logical image container; the runtime automatically applies the variant
matching the given context (density, language, style, direction).

## Entry
Syntax:
~~~
"<entry-name>"
[
	<properties>
]
~~~
- `<entry-name>`: Image entry name matching the physical file name
- `<properties>`: Image entry properties block; one `<prop-name> = '<prop-value>'` per property

## Output
Place physical image files under a `/<name>` folder next to the main artifact:
~~~
<name>.gx
<name>/
	<name>@1x.png
	<name>@2x.png
	<name>.svg
~~~

Variant resolution:
- By density; otherwise the closest is scaled
- By language; otherwise the base language is used
- By style; otherwise the base style is used

SVG entries are resolution-independent (no density variants) and styled at render time.

Use when:
- Group physical bitmap variants (density, language, style, RTL direction) under one logical image asset
- Provide static imagery referenced from Panel layouts (image source) or DesignSystem styles (gx-image)

# SYNTAX
~~~
Image <name>
{
	<entries>

	#Properties
		<properties>
	#End
}
~~~

Where:
- `<name>`: Object name using alphanumeric or underscore, starting with letter
- `<entries>`: Image entry definition list (see Entry in definition)
- `<properties>`: Optional object properties in TOML syntax

Sections:
| Section | Required |
|---|---|
| `#Properties` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: `#images/`
- Files:
  - `<name>.gx`
  - `<name>/<entry-file> (one physical image file per entry, under the /<name> folder)`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-image-entry](./properties-object-image-entry.md) — Image entry property blocks
- [properties-object-image](./properties-object-image.md) — Image objects

# CONSTRAINTS
Object-specific:
- `CON-IMG-001` Each image entry must have a unique property combination
- `CON-IMG-002` Each image entry name must be filename only; no path
- `CON-IMG-003` Only use supported formats per platform: .png, .jpeg, .bmp, .gif on all platforms; .svg on Web only
- `CON-IMG-004` Always define the variants required by context: by density (otherwise closest is scaled), by language (otherwise base language), by style (otherwise base style)
- `CON-IMG-005` Never define density or style variants for .svg format (resolution-independent)

All rules in [global-constraints](./global-constraints.md) apply in full.

# REQUIRES
Load these language modules together with this reference:
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Single bitmap with metadata
One logo entry with description, density, and rendering mode; requires the LogoApp/LogoApp.png physical file (`EX-IMG-001`, validated in CI)
`src/#images/LogoApp.gx`:
~~~
Image LogoApp
{
	"LogoApp.png"
	[
		Description = 'Primary application logo (1x)'
		Density = '100% (mdpi Android, 1x iOS, 1x Web)'
		RenderingMode = 'Original'
	]
}
~~~

## Example 2: Directional icon with RTL variant
SVG arrow icon with an RTL-flipped variant; entry names match the physical files NextArrow/NextArrow.svg and NextArrow/NextArrow_RTL.svg (`EX-IMG-002`, validated in CI)
`src/#images/NextArrow.gx`:
~~~
Image NextArrow
{
	"NextArrow.svg"
	[
		Description = 'Next arrow icon'
		RenderingMode = 'Template'
	]

	"NextArrow_RTL.svg"
	[
		Description = 'Next arrow icon (for RTL)'
		RenderingMode = 'Template'
		FlipsForRightToLeft = 'True'
	]

	#Properties
		Description = "Next arrow icon"
	#End
}
~~~

# RELATED OBJECTS
- [Panel](./object-panel.md)
- [DesignSystem](./object-design-system.md)
- [Language](./object-language.md)
