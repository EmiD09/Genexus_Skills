<!-- GENERATED from catalog/objects/query.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-query
description: Defines complex queries for data retrieval from multiple sources with joins, filters, and aggregations
---

# DEFINITION
A `Query` object defines complex queries for data retrieval from multiple sources.

## Parameters
Every parameter follows `<param-name> [ <param-properties> ]`, where:
- `<param-name>`: Parameter name without any prefix, but referenced with ampersand (&) prefix from other sections
- `<param-properties>`: ENGINE-CONFIRMED (19.2.0.265): attribute-derived parameters use `BasedOn = '<attribute>'` (the parameter takes its type from the referenced attribute); primitive-typed parameters carry NO type property in the text format — declare them with an optional `Description` only (`pMinTotal [ Description = 'Minimum total' ]`) and the engine accepts them with usage-based typing (the IDE-side primitive type and collection flag are not serialized to text). `DataType = '...'` on a Query parameter is invalid

## Expressions
Every expression follows `<element-name-alias> = <element-expression> [ <element-properties> ]`, where:
- `<element-name-alias>`: optional alias name for the computed element
- `<element-expression>`: single attribute, function, or formula
- `<element-properties>`: comma-separated element properties

Element properties: `Name`, `Description`, `Type` ('Axis' default | 'Datum'), `Picture`,
`Visible` ('Yes' default | 'No' | 'Never'), `ShowAllValues` ('True' | 'False' default),
`RaiseItemClickEvent` ('True' | 'False').
Only when the `OutputType` object property is 'Pivot Table' and the `Type` element property is
'Axis': `Axis` ('Rows' default | 'Columns' | 'Pages'), `Subtotals` ('Yes' default | 'No' | 'Hidden'),
`ExpandCollapse`, `CanDragToPages`.

## Clauses
Use clauses only inside `<element-expression>` formulas:
- `BY`: groups data before applying the formula (`Average`, `Count`, `Min`, `Max`)
- `DEFINED BY`: counts records from another transaction context (`Count`)
- `WEIGHTED BY`: computes weighted averages (`Average`)
- `FOR EACH`: splits a formula result by one attribute (any formula)
- `WHERE`: filters records used by one formula only (any formula); global filters go in `#Filters`

Use when:
- Retrieving data from multiple sources with joins, filters, and aggregations
- Feeding Query Viewer outputs such as Card, Chart, or Pivot Table
- Computing grouped, weighted, segmented, or formula-locally filtered aggregates over Transaction attributes

# SYNTAX
~~~
Query <name>
{
	<expressions>

	#Parameters
		<parameters>
	#End

	#Filters
		<filters>
	#End

	#Orders
		<orders>
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
- `<expressions>`: Non-empty list combining attributes, operators, formulas, functions, methods, and clauses
- `<parameters>`: Input parameter list, possibly empty
- `<filters>`: Boolean filters; elements are implicitly combined with AND
- `<orders>`: Sorting expression; elements may include `[ Order = 'Descending' ]`
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation in Markdown

Notes:
- Attributes in `<expressions>`, `<filters>`, and `<orders>` must be defined in Transaction objects
- Elements are separated by line breaks

Sections:
| Section | Required |
|---|---|
| `#Parameters` | yes |
| `#Filters` | yes |
| `#Orders` | yes |
| `#Properties` | no |
| `#Documentation` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: none
- Files:
  - `<name>.gx`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-query](./properties-object-query.md) — Query objects

# CONSTRAINTS
Object-specific:
- `CON-QRY-001` Define join path in the expressions section for multi-table Query objects
- `CON-QRY-002` Define filters only in #Filters section
- `CON-QRY-003` Define sort only in #Orders section
- `CON-QRY-004` Allowed aggregation formulas: Count, Sum, Average, Min, Max
- `CON-QRY-005` Allowed clause set: BY, DEFINED BY, WEIGHTED BY, FOR EACH, WHERE
- `CON-QRY-006` Query parameters are declared WITHOUT the & prefix and referenced WITH the & prefix from other sections
- `CON-QRY-007` Type attribute-derived Query parameters with BasedOn = '<attribute>'; declare primitive-typed parameters without any type property (Description only) — DataType is invalid on Query parameters (engine-confirmed)
- `CON-QRY-008` #Filters lines do NOT end with semicolons (unlike rule/condition sections of other objects; engine-confirmed)

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Rely on the implicit AND combination of #Filters elements; use the WHERE clause for filters that apply to a single formula only
- Use [ Order = 'Descending' ] on an order element to sort descending
- Use BY for grouped aggregates, WEIGHTED BY for weighted averages, DEFINED BY for counts driven by defining attributes, and FOR EACH for segmented formula results
- Restrict Axis, Subtotals, ExpandCollapse, and CanDragToPages element properties to Pivot Table output with Axis elements

# REQUIRES
Load these language modules together with this reference:
- [lang-formulas](./lang-formulas.md)
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Order count per customer
Groups order counts by customer with the BY clause (`EX-QRY-001`, validated in CI)
`src/OrdersPerCustomer.gx`:
~~~
Query OrdersPerCustomer
{
	Element1 = CustomerName [ Description = 'Customer' ]
	Element2 = Count(OrderId) BY CustomerName [ Description = 'Orders' ]

	#Parameters
	#End

	#Filters
	#End

	#Orders
		CustomerName
	#End

	#Properties
		Title = "Orders per customer"
		OutputType = "Pivot Table"
	#End
}
~~~

## Example 2: Order totals per year split by customer
Uses the FOR EACH clause to segment a sum by customer and a descending order criterion (`EX-QRY-002`, validated in CI)
`src/OrderTotalsPerYearAndCustomer.gx`:
~~~
Query OrderTotalsPerYearAndCustomer
{
	Element1 = Year(OrderDate) [ Description = 'Year' ]
	Element2 = Sum(OrderTotal) FOR EACH CustomerName [ Description = 'Customers' ]

	#Parameters
	#End

	#Filters
	#End

	#Orders
		Year(OrderDate) [ Order = 'Descending' ]
	#End

	#Properties
		Title = "Total order amount by year and customer"
		OutputType = "Chart"
	#End
}
~~~

## Example 3: Parameterized query with BasedOn
Date-range parameter typed via BasedOn and referenced with the ampersand prefix in the filter (`EX-QRY-003`, validated in CI)
`src/OrdersSince.gx`:
~~~
Query OrdersSince
{
	Element1 = OrderDate [ Description = 'Date' ]
	Element2 = Sum(OrderTotal) [ Description = 'Total amount' ]

	#Parameters
		FromDate [ BasedOn = 'OrderDate' ]
	#End

	#Filters
		OrderDate >= &FromDate
	#End

	#Orders
		OrderDate
	#End

	#Properties
		Title = "Orders since date"
	#End
}
~~~

## Example 4: Primitive-typed parameter
Primitive parameter declared without a type property (text format carries none) and used in a numeric filter (`EX-QRY-004`, validated in CI)
`src/OrdersAboveTotal.gx`:
~~~
Query OrdersAboveTotal
{
	Element1 = OrderDate [ Description = 'Date' ]
	Element2 = Sum(OrderTotal) [ Description = 'Total amount' ]

	#Parameters
		pMinTotal [ Description = 'Minimum total' ]
	#End

	#Filters
		OrderTotal >= &pMinTotal
	#End

	#Orders
		OrderDate
	#End

	#Properties
		Title = "Orders above a minimum total"
	#End
}
~~~

# RELATED OBJECTS
- [Transaction](./object-transaction.md)
- [DataSelector](./object-data-selector.md)
