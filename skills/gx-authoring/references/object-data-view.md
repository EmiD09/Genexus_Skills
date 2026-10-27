<!-- GENERATED from catalog/objects/data-view.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-data-view
description: Maps an external table to internal Knowledge Base attribute names for GeneXus navigation
---

# DEFINITION
A `Data View` object maps an external table to internal attributes for GeneXus
navigation.

Source model:
- The physical source is an external table
- Internal association uses the `Associated table` property pointing to a
  transaction-backed internal table

ATTRIBUTES — defines the external structure exposed with internal Knowledge Base
attribute names:

	<name> [ ExternalName = '<field>' ]

- `<name>`: attribute name used in the Knowledge Base
- `<field>`: physical field name in the external source; omit when it matches `<name>`
- The composition may be empty when `AssociatedTable` is defined; an empty composition
  implies dynamic association with the associated table structure and indexes

INDEX — maps one internal index to one external index plus platform-specific metadata:

	<index>
	[
		Type = '<type>',
		ExternalName = '<external-index>',
		<properties>
	]
	{
		Composition
		{
			<attributes>
		}

		Platforms
		{
			<definition>
		}
	}

- `<type>`: `Duplicate` (default), `Primary Key`, or `Unique`
- Index creation and updates follow the user-index rules of the `Table` object
  reference, with the composition restricted to attributes of the owner Data View

PLATFORM — defines one target platform entry for the external table:

	<platform>
	[
		<properties>
	]

Allowed `<platform>` values: `Access`, `AS400`, `DB2Common`, `DB2400`, `DBFCDX`,
`DBFIDX`, `Informix`, `Oracle`, `SQLServer`, `SQLCE`, `PostgreSQL`, `MySQL`, `SQLite`,
`Service`, `HANA`, `Dameng`. The platform name must be consistent between the
object-level `#Platforms` section and the index-level `Platforms { ... }` blocks.

Navigation:
- With an associated table, navigate with standard `For each` over the internal name
- Without an associated table, navigate with `XFor Each` / `XFor First` plus an
  explicit `Index` clause, e.g. `XFor Each CustomerExternal Index ICustomer`;
  `XFor First` supports a `When none` branch

Use when:
- Access an external (non-GeneXus-managed) database table through GeneXus navigation
- Map external field, table, and index names to internal Knowledge Base names
- Define platform-specific metadata for an external table across supported DBMS targets

# SYNTAX
~~~
DataView <name>
{
	<attributes>

	#Platforms
		<platforms>
	#End

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
- `<name>`: Object name using alphanumeric or underscore, starting with letter
- `<attributes>`: Internal attribute mapping list (see ATTRIBUTES in definition)
- `<platforms>`: Platform-specific external table mapping list (see PLATFORM in definition)
- `<indexes>`: External index mapping list (see INDEX in definition)
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation (exported to external `.doc.md` file)

Sections:
| Section | Required |
|---|---|
| `#Platforms` | yes |
| `#Indexes` | yes |
| `#Properties` | yes |
| `#Documentation` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: `#dataviews/`
- Files:
  - `<name>.gx`
  - `<name>.doc.md`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-data-view-platform](./properties-object-data-view-platform.md) — Platform entries inside DataView objects
- [properties-object-data-view](./properties-object-data-view.md) — DataView objects

# CONSTRAINTS
Object-specific:
- `CON-DVW-001` Apply the Table object as the Associated table concept
- `CON-DVW-002` Define one Data View per external table
- `CON-DVW-003` Keep one Data View per Associated table when required
- `CON-DVW-004` Keep the Composition aligned with the Associated table attributes when defined
- `CON-DVW-005` Only use attributes already defined in the Data View composition when defining an index composition
- `CON-DVW-006` Keep external names in metadata and internal names in source
- `CON-DVW-007` When defining or updating indexes, follow the user-index rules of the Table object reference
- `CON-DVW-008` Restrict #Platforms entries to the allowed platform keywords (Access, AS400, DB2Common, DB2400, DBFCDX, DBFIDX, Informix, Oracle, SQLServer, SQLCE, PostgreSQL, MySQL, SQLite, Service, HANA, Dameng)
- `CON-DVW-009` Keep the platform name consistent between the object-level #Platforms section and the index-level Platforms blocks

All rules in [global-constraints](./global-constraints.md) apply in full.

# REQUIRES
Load these language modules together with this reference:
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: External customer table with explicit composition
Maps an external CUSTOMER table to the fixture Customer table, with the PK index mapped to its external name and SQL Server platform metadata (`EX-DVW-001`, validated in CI)
`src/#dataviews/CustomerExternal.gx`:
~~~
DataView CustomerExternal
{
	CustomerId [ ExternalName = 'id' ]
	CustomerName [ ExternalName = 'name' ]
	CustomerEmail [ ExternalName = 'email' ]
	CustomerActive [ ExternalName = 'active' ]

	#Platforms
		SQLServer [ Name = 'CUSTOMER', SchemaName = 'dbo' ]
	#End

	#Indexes
		ICustomerExternal
		[
			Type = 'Primary Key',
			ExternalName = 'PK_CUSTOMER'
		]
		{
			Composition
			{
				CustomerId
			}

			Platforms
			{
				SQLServer [ SchemaName = 'dbo' ]
			}
		}
	#End

	#Properties
		AssociatedTable = "Customer"
	#End
}
~~~

## Example 2: Dynamic association with empty composition
Empty attribute composition with AssociatedTable defined, implying dynamic association with the fixture Product table structure and indexes (`EX-DVW-002`, validated in CI)
`src/#dataviews/ProductExternal.gx`:
~~~
DataView ProductExternal
{
	#Platforms
		SQLServer [ Name = 'PRODUCT', SchemaName = 'dbo' ]
	#End

	#Indexes
	#End

	#Properties
		AssociatedTable = "Product"
	#End
}
~~~

# RELATED OBJECTS
- [Table](./object-table.md)
- [Transaction](./object-transaction.md)
