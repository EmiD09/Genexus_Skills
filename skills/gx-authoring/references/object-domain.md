<!-- GENERATED from catalog/objects/domain.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-domain
description: Global reusable data type definition ensuring consistency across attributes and variables
---

# DEFINITION
A `Domain` object is a reusable element based on a built-in type or an existing domain,
representing a specific concept (Price, Name, Id) with optional constraints
(format, validation, default values).

Key properties:
- `Data Type`: Mandatory base type: built-in type or existing domain
- `Length`: For string/numeric types
- `Decimals`: For numeric types
- `Signed`: For numeric types (allows negative values)
- `EnumValues`: For enumeration domains (see lang-enum-domain for syntax)
- `Regular Expression`: POSIX BRE or ERE pattern for validation
- `Picture`: Display formatting pattern (see lang-data-picture for syntax)
- `Default`: Default value

Use when:
- A specific concept (Price, Name, Id) must be typed consistently across multiple attributes and variables
- A type needs attached constraints or formatting (regular expression validation, picture, default value)
- A closed set of values must be modeled as an enumerated type instead of raw string literals

# SYNTAX
~~~
Domain <name>
{
	#Properties
		<properties>
	#End

	#Documentation
		<documentation>
	#End
}
~~~

Where:
- `<name>`: Object name using alphanumeric or underscore, starting with letter
- `<properties>`: Object properties in TOML syntax; `DataType` is mandatory
- `<documentation>`: Optional object documentation (external `.doc.md` artifact)

Sections:
| Section | Required |
|---|---|
| `#Properties` | yes |
| `#Documentation` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: `#domains/`
- Files:
  - `<name>.gx`
  - `<name>.doc.md`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-domain](./properties-object-domain.md) — Domain objects

# CONSTRAINTS
Object-specific:
- `CON-DOM-001` Body block must be empty `{ }`; only properties are available (no rules, variables, or source)
- `CON-DOM-002` Resolve the `DataType` property using the data type resolution rules in lang-data-types
- `CON-DOM-003` Define the `EnumValues` property for enumerated Domain objects
- `CON-DOM-004` Use POSIX BRE or ERE syntax for `Regular Expression` property values
- `CON-DOM-005` Define Domain objects only under modules in `#domains/`; folders are forbidden
- `CON-DOM-006` Extend a Domain only from another domain; self-reference is forbidden
- `CON-DOM-007` Reuse built-in Semantic Domain objects; do not create custom duplicates
- `CON-DOM-008` `Autonumber` is NOT a valid Domain property; it is only available on Attribute definitions within a Transaction

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Name domains after context-agnostic concepts (Price, Quantity, Email), not the entities that use them
- Never add the redundant suffix `Domain` to a domain name (no `NameDomain`)
- Avoid prefix specializations such as `UserName`; prefer the generic concept (`Name`) reusable across contexts
- Do not create meaningless data-type overlays (a domain that only restates a built-in type adds no semantic value)
- Never use reserved keywords, built-in type names, or built-in domain names as a domain name
- Model closed value sets as enumerated domains instead of scattering raw string literals through code

# REQUIRES
Load these language modules together with this reference:
- [lang-data-types](./lang-data-types.md)
- [lang-enum-domain](./lang-enum-domain.md)
- [lang-data-picture](./lang-data-picture.md)
- [lang-semantic-types](./lang-semantic-types.md)
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Simple numeric domain
Context-agnostic unsigned price concept reusable by attributes such as ProductPrice (`EX-DOM-001`, validated in CI)
`src/#domains/Price.gx`:
~~~
Domain Price
{
	#Properties
		DataType = "Numeric(10.2)"
		Signed = false
	#End
}
~~~

## Example 2: Enumerated domain
Closed set of order states modeled as an enumerated domain instead of raw string literals (`EX-DOM-002`, validated in CI)
`src/#domains/OrderStatus.gx`:
~~~
Domain OrderStatus
{
	#Properties
		DataType = "Character(20)"
		EnumValues = "Pending, Order is pending, Pending; Confirmed, Order confirmed, Confirmed; Shipped, Order shipped, Shipped; Delivered, Order delivered, Delivered; Cancelled, Order cancelled, Cancelled"
	#End
}
~~~

# RELATED OBJECTS
- [Transaction](./object-transaction.md)
- [StructuredDataType](./object-structured-data-type.md)
