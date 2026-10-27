<!-- GENERATED from catalog/objects/transaction.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-transaction
description: Defines database entities with attributes, relationships, business rules, and automatic normalization
---

# DEFINITION
A `Transaction` object (or `TRN`) represents real-world entities mapping to database tables.
GeneXus automatically normalizes the data model to third normal form (3NF), and each
`Transaction` maps to one or more `Table` objects according to its level structure.

Relationships are modeled in two ways:

- **STRONG**: separate Transactions reference each other via Foreign Key (FK). Use when
  related entities have independent lifecycles and require separate Transactions. Model 1:N
  with the FK on the N-side Transaction, using `[]` for the inferred FK and extended
  attributes. Model 1:1 as 1:N plus a user `Index` defined as `Unique` on the FK key at the
  N-side table.
- **WEAK**: a sublevel (subordinate entity) defined inside the parent Transaction body. Use
  when the subordinate entity lifecycle depends on the parent Transaction; keep the
  subordinate structure coupled to the parent key context.

Enabling `DataProvider = true` associates a `DataProvider` child object
(`<name>/<name>_DataProvider.gx`) in one of two modes:

- **Populate Transaction** (`UsedTo = "Populate Data"`): loads seed/fixed data into physical
  tables; use when the entity must preload persistent data after build. Requires an
  idempotent DataProvider using explicit PKs or a stable matching key. Side effects:
  `BusinessComponent = true` on the Transaction and `MainProgram = true` on the DataProvider.
- **Dynamic Transaction** (`UsedTo = "Retrieve Data"`): retrieves data without creating
  physical tables; use when the entity acts as a retrieval contract. Requires explicit
  `Insert`/`Update`/`Delete` event coding.

Use when:
- Model a real-world entity that must persist as one or more database tables
- Model master-detail structures whose detail lifecycle depends on the parent (WEAK relationship via sublevels)
- Reference independent entities via Foreign Keys (STRONG relationship between separate Transactions)
- Preload seed/fixed data into physical tables after build (Populate Transaction via associated DataProvider)
- Expose a retrieval contract without creating physical tables (Dynamic Transaction via associated DataProvider)
- Expose the entity for programmatic access as a Business Component

# SYNTAX
~~~
Transaction <name>
{
	<attributes>

	#Rules
		<rules>
	#End

	#Events
		<events>
	#End

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
- `<name>`: Transaction name using alphanumeric or underscore, starting with letter
- `<attributes>`: Entity attributes with mandatory `DataType`
- `<rules>`: Business rules governing Transaction behavior
- `<events>`: Transaction lifecycle event handlers
- `<variables>`: Variable definitions with mandatory `DataType`
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation (exported to external `.doc.md` file)

Sections:
| Section | Required |
|---|---|
| `#Rules` | yes |
| `#Events` | yes |
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
- [properties-object-attribute](./properties-object-attribute.md) — Attribute definitions inside Transaction structures
- [properties-object-transaction](./properties-object-transaction.md) — Transaction objects

# CONSTRAINTS
Object-specific:
- `CON-TRN-001` Check Transaction existence before updating it
- `CON-TRN-002` Give every attribute either a DataType property or empty brackets []
- `CON-TRN-003` Prefix every attribute name with its owning Transaction or sublevel name
- `CON-TRN-004` Define a primary key: at least one attribute marked with *
- `CON-TRN-005` Allow only one description attribute (!) per Transaction, used for user-friendly record display
- `CON-TRN-006` Use a surrogate PK with the <name>Id name pattern only when no natural identifier exists
- `CON-TRN-007` Use Autonumber = 'True' only on first-level PK attributes with Numeric(X.0) data type
- `CON-TRN-008` Use the Serial rule only for autonumbering nested-level PK attributes
- `CON-TRN-009` Declare every extended attribute (including FK) with empty brackets []; its properties are inferred from the referenced transaction
- `CON-TRN-010` Never duplicate attribute names within a transaction, including its sublevels
- `CON-TRN-011` Never include properties for FK, Extended, or Subtyped attributes
- `CON-TRN-012` Determine STRONG vs WEAK relationship based on entity independence: STRONG uses separate transactions with FK references; WEAK uses a sublevel within the transaction
- `CON-TRN-013` Model STRONG 1:N relationships with the FK on the N-side Transaction, using [] for the inferred FK and extended attributes
- `CON-TRN-014` Model STRONG 1:1 relationships as 1:N plus a user Index defined as Unique on the FK key at the N-side table
- `CON-TRN-015` Model WEAK 1:N relationships by defining the subordinate level inside the parent Transaction body, keeping the subordinate structure coupled to the parent key context
- `CON-TRN-016` Include standard variables according to the transaction context
- `CON-TRN-017` Enable the Business Component property only for programmatic access
- `CON-TRN-018` Never place events, rules, or triggers outside the syntax scope
- `CON-TRN-019` Never define attribute properties with dot (.) notation; they are design-time only
- `CON-TRN-020` Never combine the Formula property and the Assign rule over the same attribute
- `CON-TRN-021` Restrict event names to Start, After Trn, Exit, '<custom-name>', and Insert/Update/Delete; Insert/Update/Delete apply to Dynamic Transactions only and accept an optional Messages argument
- `CON-TRN-022` After exporting, inspect src/#tables/*.gx artifacts matching the Transaction base table and update the #Indexes section if required, ensuring a Unique user index over the FKs of 1:1 relationships
- `CON-TRN-023` Never create user indexes without explicit confirmation
- `CON-TRN-024` Never create or update automatic indexes
- `CON-TRN-025` Stop the workflow if importing changes into the Knowledge Base fails
- `CON-TRN-026` For Populate Transaction mode, define UsedTo = "Populate Data" and make the associated DataProvider idempotent using explicit PKs or a stable matching key; this implies BusinessComponent = true on the Transaction and MainProgram = true on the DataProvider
- `CON-TRN-027` For Dynamic Transaction mode, define UsedTo = "Retrieve Data" and code the Insert/Update/Delete events explicitly
- `CON-TRN-028` Keep the associated DataProvider object structure aligned with the Transaction structure
- `CON-TRN-029` Save the associated DataProvider child object as <name>/<name>_DataProvider.gx next to <name>.gx

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Name Transactions as PascalCase singular nouns
- Name attributes in PascalCase, descriptive
- Name sublevels as PascalCase singular nouns
- Name FK attributes <ReferencedTransaction>Id and surrogate PKs <TransactionName>Id
- Order structure as: primary key attributes first, description attribute after the PK, foreign key attributes before extended ones, regular attributes in logical order, sublevels at the end

# REQUIRES
Load these language modules together with this reference:
- [lang-data](./lang-data.md)
- [lang-attribute-types](./lang-attribute-types.md)
- [lang-business-component](./lang-business-component.md)
- [lang-rules](./lang-rules.md)
- [lang-events](./lang-events.md)
- [lang-standard-variables](./lang-standard-variables.md)
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Simple Transaction
Single-level entity with autonumbered PK, description attribute, rules, and Business Component enabled (`EX-TRN-001`, validated in CI)
`src/Product.gx`:
~~~
Transaction Product
{
	ProductId* [ DataType = 'Numeric(10.0)', Autonumber = 'True' ]
	ProductName! [ DataType = 'VarChar(128)' ]
	ProductPrice [ DataType = 'Numeric(10.2)' ]
	ProductStock [ DataType = 'Numeric(5.0)' ]

	#Rules
		Error("Product price must be positive") IF ProductPrice <= 0;
		Default(ProductStock, 0);
	#End

	#Events
	#End

	#Variables
	#End

	#Properties
		BusinessComponent = true
	#End
}
~~~

## Example 2: Transaction with Sublevel
Master-detail (WEAK relationship) with formulas, Serial autonumbering, FK/extended attributes, and an After Trn event (`EX-TRN-002`, validated in CI)
`src/Order.gx`:
~~~
Transaction Order
{
	OrderId* [ DataType = 'Numeric(10.0)', Autonumber = 'True' ]
	CustomerId []
	CustomerName []
	OrderDate [ DataType = 'Date' ]
	OrderTotal
	[
		DataType = 'Numeric(10.2)',
		Formula = 'Sum(OrderLineTotal)'
	]
	OrderLastLine [ DataType = 'Numeric(10.0)' ]

	OrderLine
	{
		OrderLineId* [ DataType = 'Numeric(10.0)' ]
		ProductId []
		ProductName []
		OrderLineQuantity [ DataType = 'Numeric(5.0)' ]
		OrderLineUnitPrice [ DataType = 'Numeric(10.2)' ]
		OrderLineTotal
		[
			DataType = 'Numeric(10.2)',
			Formula = 'OrderLineQuantity * OrderLineUnitPrice'
		]
	}

	#Rules
		Default(OrderDate, Today());
		Serial(OrderLineId, OrderLastLine, 1);
	#End

	#Events
		Event After Trn
			If &Mode = TrnMode.Insert
				msg(format(!"[INFO] Inserted: %1", OrderId), status)
			EndIf
		EndEvent
	#End

	#Variables
	#End

	#Properties
		BusinessComponent = true
	#End
}
~~~

# RELATED OBJECTS
- [Table](./object-table.md)
- [DataProvider](./object-data-provider.md)
