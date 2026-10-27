<!-- GENERATED from catalog/objects/data-selector.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-data-selector
description: Reusable filter definition applied to data queries
---

# DEFINITION
A `DataSelector` object (or `DS`) defines a reusable filter applied to data queries.

Rules:
- Attributes in `<conditions>`, `<orders>`, and `<attributes>` must exist in Transactions
- `<conditions>`, `<orders>`, `<attributes>` section lines must end with `;` + line break
- In `#Orders`, attributes in `( )` indicate descending order (e.g. `(CustomerName)` = Z to A)
- `#DefinedBy` must be empty if the base table is unambiguous; it lists attributes defining
  the base table when not inferred
- Multiple `#Conditions` lines imply `AND`

DataSelector objects can be invoked with `USING` in:
- `For Each` commands; e.g. `For Each Customer Using SelectPremiumCustomers() ... EndFor`
- `DataProvider` objects; e.g. `Customer Using SelectPremiumCustomers() { ... }`
- Aggregates; e.g. `Average(CustomerAge, SelectPremiumCustomers(), 0)`

Use when:
- The same filtering conditions must be reused across multiple For Each commands, DataProviders, or aggregate formulas
- A query filter needs input parameters for dynamic filtering
- Common ordering criteria should be centralized alongside the filter

# SYNTAX
~~~
DataSelector <name>
{
	#Parameters
		<parameters>
	#End

	#Conditions
		<conditions>
	#End

	#Orders
		<orders>
	#End

	#DefinedBy
		<attributes>
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
- `<parameters>`: Input parameters (name starts with `&`, mandatory `DataType`); omit if none
- `<conditions>`: Boolean filters (comparisons, operators, functions, formulas); multiple lines imply `AND`
- `<orders>`: Sorting attributes (comma-separated; compound allowed; parentheses indicate descending)
- `<attributes>`: Attributes defining the base table when not inferred
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation (external `.doc.md` artifact)

Sections:
| Section | Required |
|---|---|
| `#Parameters` | yes |
| `#Conditions` | yes |
| `#Orders` | yes |
| `#DefinedBy` | yes |
| `#Properties` | no |
| `#Documentation` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: none
- Files:
  - `<name>.gx`
  - `<name>.doc.md`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-data-selector](./properties-object-data-selector.md) — Data Selector objects

# CONSTRAINTS
Object-specific:
- `CON-DSL-001` Attributes in `#Conditions`, `#Orders`, and `#DefinedBy` must exist in Transactions
- `CON-DSL-002` `#Conditions`, `#Orders`, and `#DefinedBy` section lines must end with `;` followed by a line break
- `CON-DSL-003` Parameter names start with `&` and each parameter must define the mandatory `DataType` property
- `CON-DSL-004` Define the `#Parameters` section content only for dynamic filters; leave it empty otherwise
- `CON-DSL-005` Define one condition per `#Conditions` line; all lines combine with implicit `AND`
- `CON-DSL-006` `#DefinedBy` must be empty if the base table is unambiguous
- `CON-DSL-007` In `#Orders`, wrap an attribute in parentheses to indicate descending order

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Reuse a DataSelector across caller objects (For Each, DataProvider, aggregates) instead of duplicating conditions

# REQUIRES
Load these language modules together with this reference:
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Simple DataSelector
Filters active customers and orders them by name; no parameters needed (`EX-DSL-001`, validated in CI)
`src/SelectActiveCustomers.gx`:
~~~
DataSelector SelectActiveCustomers
{
	#Parameters
	#End

	#Conditions
		CustomerActive = true;
	#End

	#Orders
		CustomerName;
	#End

	#DefinedBy
	#End

	#Properties
	#End
}
~~~

## Example 2: Parameterized DataSelector
Filters orders within a date range, newest first, using two input parameters (`EX-DSL-002`, validated in CI)
`src/SelectOrdersInRange.gx`:
~~~
DataSelector SelectOrdersInRange
{
	#Parameters
		&StartDate [ DataType = 'Date' ]
		&EndDate [ DataType = 'Date' ]
	#End

	#Conditions
		OrderDate >= &StartDate;
		OrderDate <= &EndDate;
	#End

	#Orders
		(OrderDate);
	#End

	#DefinedBy
	#End

	#Properties
	#End
}
~~~

# RELATED OBJECTS
- [DataProvider](./object-data-provider.md)
- [Query](./object-query.md)
- [Procedure](./object-procedure.md)
- [Transaction](./object-transaction.md)
