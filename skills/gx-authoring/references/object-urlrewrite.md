<!-- GENERATED from catalog/objects/url-rewrite.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-urlrewrite
description: Maps user-friendly URL patterns to target web object invocations
---

# DEFINITION
A `URLRewrite` object maps user-friendly URL patterns to target web object
calls. It centralizes route definitions and parameter extraction for web
navigation.

Each rewrite rule maps a source URL path to a GeneXus object or invocation:

	<source> => <target>;

Route placeholders (e.g. `{&CustomerId}`) bind to variables declared in the
`#Variables` section.

Use when:
- Expose user-friendly URLs for web objects instead of default object URLs
- Centralize route definitions and URL parameter extraction for web navigation

# SYNTAX
~~~
URLRewrite <name>
{
	<rewrites>

	#Variables
		<variables>
	#End

	#Properties
		<properties>
	#End

	#Documentation
		<documentation>
	#End
}
~~~

Where:
- `<name>`: Object name using alphanumeric or underscore, starting with a letter
- `<rewrites>`: Rewrite rules `<source> => <target>;` mapping URL paths to GeneXus objects or invocations
- `<variables>`: Variable definitions used by route placeholders, with mandatory `DataType`
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation (exported to external `.doc.md` file)

Sections:
| Section | Required |
|---|---|
| `#Variables` | yes |
| `#Properties` | yes |
| `#Documentation` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: none
- Files:
  - `<name>.gx`
  - `<name>.doc.md`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-url-rewrite](./properties-object-url-rewrite.md) — URL Rewrite objects

# CONSTRAINTS
Object-specific:
- `CON-URW-001` Define each rewrite rule with arrow (=>) and terminal semicolon (;)
- `CON-URW-002` Keep route placeholders aligned with #Variables section declarations; e.g. Id -> {&Id}
- `CON-URW-003` Ensure each target object is web-callable and exists
- `CON-URW-004` Never duplicate source patterns in the same URLRewrite object
- `CON-URW-005` Never use an API object as the target of a URLRewrite object
- `CON-URW-006` Target objects must set Encrypt URL Parameters = No
- `CON-URW-007` The Environment must use Parameters Style = Named
- `CON-URW-008` Affected web objects should use Web User Experience = Smooth
- `CON-URW-009` Treat Link() output as server-relative (/path) when any URLRewrite object exists
- `CON-URW-010` Never overlap source patterns across URLRewrite objects
- `CON-URW-011` Preserve unchanged rules and variables on updates

All rules in [global-constraints](./global-constraints.md) apply in full.

# REQUIRES
Load these language modules together with this reference:
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Parameterized route
Route with a placeholder bound to a typed variable extracted from the URL path (`EX-URW-001`, validated in CI)
`src/CustomerRoutes.gx`:
~~~
URLRewrite CustomerRoutes
{
	customers/{&CustomerId} => ViewCustomer(&CustomerId);

	#Variables
		CustomerId [ DataType = 'Attribute:CustomerId' ]
	#End

	#Properties
	#End
}
~~~

# RELATED OBJECTS
- [Panel](./object-panel.md)
- [API](./object-api.md)
