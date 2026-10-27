<!-- GENERATED from catalog/objects/structured-data-type.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-structured-data-type
description: Compound data type grouping members, sub-items, and collections for data transfer and manipulation
---

# DEFINITION
A `Structured Data Type` object (or `SDT`) is a compound type that groups members of other
types and collections.

The object body contains a root item (typically named the same as the SDT) holding member
definitions and optional nested sub-items. Any item or member may be marked as a collection
via the `Collection` property (only written when `True`). Each member is defined with a
mandatory `DataType` property and may carry the same complementary properties available to
`Attribute` definitions (e.g. `Description`).

An SDT can be used as a variable type in a Procedure or Transaction, and SDT instances
support serialization.

Use when:
- Grouping related fields into a single reusable compound structure
- Modeling repeated groups of data as collections (lists of items)
- Defining nested substructures (sub-items) inside a parent structure
- Typing variables in Procedures or Transactions with structured data
- Serializing structured data (e.g. to JSON) for data transfer

# SYNTAX
~~~
SDT <name>
{
	<item-name>
	[
		Collection = '<collection>'
	]
	{
		<member> | <sub-item>
	}

	#Properties
		<properties>
	#End

	#Documentation
		<documentation>
	#End
}

// Member syntax
<member-name>
[
	Description = '<description>',
	DataType = '<type>',
	Collection = '<collection>',
	<complement>
]
~~~

Where:
- `<name>`: Object name using alphanumeric or underscore, starting with letter
- `<item-name>`: Item name (typically same as `<name>`)
- `<member>`: Member definition with `DataType` property
- `<sub-item>`: Nested substructure following `<item-name>` syntax
- `<collection>`: True if item/member is collection, False otherwise (omit brackets if False)
- `<member-name>`: Member name using alphanumeric or underscore, starting with letter
- `<description>`: Purpose of member (optional but recommended)
- `<type>`: Mandatory data type; resolve via the canonical Data Type Priority (defined in lang-data)
- `<complement>`: Other relevant properties (same as `Attribute` available properties)
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation; exported to the external `.doc.md` artifact, never inline in `.gx`

Sections:
| Section | Required |
|---|---|
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
- [properties-object-structured-data-type](./properties-object-structured-data-type.md) — Structured Data Type objects and their items

# CONSTRAINTS
Object-specific:
- `CON-SDT-001` Check SDT existence before updating it
- `CON-SDT-002` Write one member per line and use tabs for indentation
- `CON-SDT-003` Every member must have the DataType property
- `CON-SDT-004` Name the root item the same as the SDT name
- `CON-SDT-005` Write the Collection property only when its value is True; omit the property (and its brackets, if otherwise empty) when False
- `CON-SDT-006` Member names must start with a letter and use only alphanumeric characters or underscore
- `CON-SDT-007` Nested sub-items follow the same syntax as the root item
- `CON-SDT-008` When choosing a member DataType, follow the canonical Data Type Priority (defined in lang-data)
- `CON-SDT-009` Never duplicate member names within an SDT, including across its sub-items
- `CON-SDT-010` An SDT may be used as a variable type in Procedure or Transaction objects (declare the variable DataType as the SDT name; use '<SdtName>.<ItemName>' for nested collection item types)
- `CON-SDT-011` SDTs support serialization (e.g. ToJson()); keep structures serializable

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Define the Description property on every member to document its purpose
- Prefer Attribute or Domain references over raw built-in types when a member shares meaning with an existing definition
- Reuse existing SDTs as member types (structured reference) instead of redefining equivalent substructures
- Use nested sub-items for one-to-one groupings and Collection = 'True' items for repeated groups
- Use concise meaningful names without cryptic abbreviations

# REQUIRES
Load these language modules together with this reference:
- [lang-data](./lang-data.md)
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Flat SDT
Simple flat structure grouping customer fields with domain references (`EX-SDT-001`, validated in CI)
`src/CustomerData.gx`:
~~~
SDT CustomerData
{
	CustomerData
	{
		CustomerId
		[
			Description = 'Customer identifier',
			DataType = 'Numeric(10.0)'
		]
		CustomerName
		[
			Description = 'Customer full name',
			DataType = 'VarChar(128)'
		]
		CustomerEmail
		[
			Description = 'Customer email address',
			DataType = 'Email, GeneXus'
		]
		CustomerPhone
		[
			Description = 'Customer phone number',
			DataType = 'Phone, GeneXus'
		]
	}

	#Properties
	#End
}
~~~

## Example 2: SDT with nested collection
Order header with a nested OrderItems collection of line items (`EX-SDT-002`, validated in CI)
`src/OrderInfo.gx`:
~~~
SDT OrderInfo
{
	OrderInfo
	{
		OrderId
		[
			Description = 'Order identifier',
			DataType = 'Numeric(10.0)'
		]
		OrderDate
		[
			Description = 'Order date',
			DataType = 'Date'
		]
		CustomerId
		[
			Description = 'Customer identifier',
			DataType = 'Numeric(10.0)'
		]
		CustomerName
		[
			Description = 'Customer full name',
			DataType = 'VarChar(128)'
		]

		OrderItems
		[
			Collection = 'True'
		]
		{
			ProductId
			[
				Description = 'Product identifier',
				DataType = 'Numeric(10.0)'
			]
			ProductName
			[
				Description = 'Product name',
				DataType = 'VarChar(128)'
			]
			Quantity
			[
				Description = 'Ordered quantity',
				DataType = 'Numeric(5.0)'
			]
			UnitPrice
			[
				Description = 'Unit price of the product',
				DataType = 'Numeric(10.2)'
			]
			LineTotal
			[
				Description = 'Total amount for the line',
				DataType = 'Numeric(10.2)'
			]
		}

		OrderTotal
		[
			Description = 'Total amount of the order',
			DataType = 'Numeric(10.2)'
		]
	}

	#Properties
	#End
}
~~~

# RELATED OBJECTS
- [Transaction](./object-transaction.md)
- [Procedure](./object-procedure.md)
- [DataProvider](./object-data-provider.md)
