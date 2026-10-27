<!-- GENERATED from catalog/objects/table.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-table
description: Defines the physical persistence structure derived from an owner Transaction, with explicit index definitions
---

# DEFINITION
A `Table` object (or `TBL`) defines the physical persistence structure. Each `Table`
depends on an owner `Transaction` defining each attribute, plus index definitions.
The attribute list is automatically derived from the owner `Transaction` (do not edit).
Attribute markers: `*` primary key, `!` description, `?` nullable.

The `#Indexes` section enables efficient data access, uniqueness, and referential
integrity. Index syntax:

	<name>
	[
		Type = '<type>',
		Source = '<source>',
		<properties>
	]
	{
		<attributes>
	}

- `<name>`: index name using alphanumeric or underscore, starting with `I` for automatic
  indexes (`Source = 'Automatic'`; forbid generating them) or `U` for user (custom)
  indexes (`Source = 'User'`)
- `<type>`: `Duplicate` (default, can have duplicated values) or `Unique` (cannot have
  duplicated values; represents a CK constraint)
- `<source>`: `Automatic` (default; automatically created, e.g. over PK attributes) or
  `User` (user custom index)
- `<properties>`: optional index properties in TOML syntax
- `<attributes>`: ordered index attribute composition, one attribute per line; order
  defines key precedence; attributes in `( )` indicate descending order

This object OWNS the user-index rules; every other object that defines or maps indexes
defers to them:
- Only create user indexes (`U`-prefixed) if justified
- Never create or update automatic indexes (`I`-prefixed)
- Never duplicate attributes in the same index
- Use only attributes from the owner table structure

Use when:
- Inspect derived physical tables (src/#tables/*.gx) after exporting a Transaction
- Add a justified user index (U-prefixed) for efficient data access or uniqueness
- Enforce a 1:1 relationship with a Unique user index over the FK attributes

# SYNTAX
~~~
Table <name>
{
	<attributes>

	#Indexes
		<indexes>
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
- `<name>`: Object name using alphanumeric or underscore, starting with letter; matches the owner `Transaction` or `Transaction + Level` name
- `<attributes>`: Attribute name list, one per line; automatically derived (do not edit); markers: `*` primary key, `!` description, `?` nullable
- `<indexes>`: Index definition list (see index syntax in definition)
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation (exported to external `.doc.md` file)

Sections:
| Section | Required |
|---|---|
| `#Indexes` | yes |
| `#Properties` | yes |
| `#Documentation` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: `#tables/`
- Files:
  - `<name>.gx (where <name> matches the owner Transaction or Transaction + Level name)`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-table-index](./properties-object-table-index.md) — Index definitions inside Table objects
- [properties-object-table](./properties-object-table.md) — Table objects

# CONSTRAINTS
Object-specific:
- `CON-TBL-001` Never create Table objects; they derive from their owner Transaction
- `CON-TBL-002` Never modify the <attributes> list; it is auto-derived from the owner Transaction object
- `CON-TBL-003` Only update the <indexes> list with user index definitions
- `CON-TBL-004` Never duplicate names in the <indexes> list
- `CON-TBL-005` Avoid redundant indexes; reduce maintenance cost
- `CON-TBL-006` Ensure a Unique user index for 1:1 relationships over FK attributes
- `CON-TBL-007` Only create user indexes (U-prefixed, Source = 'User') if justified
- `CON-TBL-008` Never create or update automatic indexes (I-prefixed, Source = 'Automatic')
- `CON-TBL-009` Never duplicate attributes in the same index
- `CON-TBL-010` Use only attributes from the owner table structure in index compositions

All rules in [global-constraints](./global-constraints.md) apply in full.

# REQUIRES
Load these language modules together with this reference:
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Justified Unique user index
Fixture Customer table extended with a U-prefixed Unique user index over CustomerEmail; the automatic ICustomer index is left untouched (`EX-TBL-001`, validated in CI)
`src/#tables/Customer.gx`:
~~~
Table Customer
{
	CustomerId*
	CustomerName
	CustomerEmail
	CustomerActive

	#Indexes
		ICustomer
		[
			Type = 'Unique',
			Source = 'Automatic'
		]
		{
			CustomerId
		}
		UCustomerByEmail
		[
			Type = 'Unique',
			Source = 'User'
		]
		{
			CustomerEmail
		}
	#End

	#Properties
	#End
}
~~~

# RELATED OBJECTS
- [Transaction](./object-transaction.md)
- [DataView](./object-data-view.md)
