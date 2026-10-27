<!-- GENERATED from catalog/objects/data-provider.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-data-provider
description: Declarative definition of hierarchical structured data output
---

# DEFINITION
A `DataProvider` object (or `DP`) is a declarative construction used to define hierarchical
structured data output, focusing strictly on defining the output data instead of how to
retrieve or transform it.

The structure has three main components: `Groups`, `Elements`, and `Variables`.

Structural rules:
- Groups must always be defined in terms of an existing SDT or BC structure; the root group
  must correspond to an existing SDT or Business Component (BC), or a synthetic container
  group representing a collection whose items match an SDT or BC structure
- Elements must always correspond to SDT members or BC properties
- Variables must always be declared in `#Variables`
- An item group may be defined multiple times to serve different purposes
- Maintain strict hierarchical nesting; groups contain elements or other groups
- Recursive calls to the DataProvider are allowed when the SDT or BC is recursively defined
- Clauses, if defined, must always be written immediately after the group name (not at the end)
- Multimedia elements are assigned using a same-type variable loaded with `FromUrl` before
  each item subgroup
- `<assignments>` are statements assigning values to previously declared variables;
  compound assignment operators (including `+=`, `-=`) are not allowed
- Expressions may include functions, formulas, and operators supported by GeneXus

Clauses (valid only within inner groups) control data retrieval and structure:
- `<output>` (only one allowed per group):
  * `[Default]`: Output group only if previous group with same name is absent
  * `[NoOutput]`: Exclude group, include only its subelements
  * `[OutputIfDetail]`: Output collection with header and detail lines
  * `[Count = N]` `[Skip = M]`: Limit results; either or both allowed
  * `[One]`: Return only first record
- `From <transactions>`: One or more base Transactions or Transaction.Levels, comma-separated
- `Order <criteria> [When <condition>]`: Sorting attributes; parentheses indicate descending;
  may include functions, procedures, methods, properties, or the keyword `none`
- `Unique <attributes>`: Comma-separated attributes enforcing uniqueness
- `Using <dataselectors>`: Comma-separated Data Selector invocations, including required
  parameters when applicable
- `Input <iterator>`: For-To form `<var> = <start> to <end> [step <leap>]` or
  For-In form `<var> in <collection>`
- `Where <conditions>`: Boolean expression for filtering

Web service exposure (choose one mode):
- Reference this object from an API object by default
- Configure as a `Web Service` only when explicitly requested: enable the
  `Expose as Web Service` property and set the `Web Service Protocol` property

Use when:
- Hierarchical structured data must be produced declaratively, focusing on the output shape rather than retrieval logic
- An SDT or Business Component collection must be loaded from the database, constants, procedures, or other collections
- Structured data must be exposed through an API object or as a web service

# SYNTAX
~~~
DataProvider <name>
{
	<group>
	{
		<assignments>

		<item>
		<clauses>
		{
			<elements>
		}
	}

	#Rules
		<rules>
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

Clauses (strict order):
[<output>]
[From <transactions>]
[Order <criteria> [When <condition>]]
[Unique <attributes>]
[Using <dataselectors>]
[Input <iterator>]
[Where <conditions>]
~~~

Where:
- `<name>`: Object name using alphanumeric or underscore, starting with letter
- `<group>`: Root structure of the output; an existing SDT or BC, or a synthetic container group for a collection whose items match an SDT or BC structure
- `<assignments>`: Statements assigning values to previously declared variables
- `<item>`: Subgroup representing an SDT or BC element, or each item structure when the root is a collection
- `<clauses>`: Optional retrieval/structure clauses; must appear immediately after the group name
- `<elements>`: Assignments to SDT members or BC properties; must belong to the corresponding structure
- `<rules>`: Business rules globally applied; includes parameter definitions
- `<variables>`: All variables used in the object; each must define the mandatory `DataType` property
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation (external `.doc.md` artifact)

Sections:
| Section | Required |
|---|---|
| `#Rules` | yes |
| `#Variables` | yes |
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
- [properties-object-data-provider](./properties-object-data-provider.md) — Data Provider objects

# CONSTRAINTS
Object-specific:
- `CON-DPR-001` Groups must correspond to existing SDT or BC structures
- `CON-DPR-002` Elements must belong to SDT or BC members or levels
- `CON-DPR-003` Variables must be defined in the `#Variables` section
- `CON-DPR-004` Include the standard variables (lang-standard-variables) according to the DataProvider context
- `CON-DPR-005` Clauses must appear immediately after the group name
- `CON-DPR-006` Maintain strict hierarchical nesting; groups contain elements or other groups
- `CON-DPR-007` Recursive calls to the DataProvider are allowed only when the SDT or BC is recursively defined
- `CON-DPR-008` Only one `<output>` clause per group
- `CON-DPR-009` Clause order must be strictly respected: Output, From, Order, Unique, Using, Input, Where; any deviation is a syntax error
- `CON-DPR-010` Compound assignment operators (including `+=`, `-=`) are not allowed in `<assignments>`
- `CON-DPR-011` `From` must be omitted if the base table is implicitly defined
- `CON-DPR-012` `Order` may appear multiple times and is applied by order of appearance; omit it if satisfied by `Using`
- `CON-DPR-013` `Input` may appear multiple times (nested or sequential)
- `CON-DPR-014` `Where` may appear multiple times (AND condition); omit it if satisfied by `Using`
- `CON-DPR-015` Assign multimedia elements via a same-type variable loaded with `FromUrl` before each item subgroup

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Expose a DataProvider by referencing it from an API object by default; enable `Expose as Web Service` plus `Web Service Protocol` only when explicitly requested
- Define an item group multiple times when it must serve different purposes (e.g. alternative `Using`/`Where` branches)

# REQUIRES
Load these language modules together with this reference:
- [lang-operators](./lang-operators.md)
- [lang-standard-variables](./lang-standard-variables.md)
- [lang-data](./lang-data.md)
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Database-backed collection
Loads active customers into a collection of CustomerData SDT items, ordered by name (`EX-DPR-001`, validated in CI)
`src/ActiveCustomers.gx`:
~~~
DataProvider ActiveCustomers
{
	Customers
	{
		CustomerData
		Order CustomerName
		Where CustomerActive = true
		{
			CustomerId = CustomerId
			CustomerName = CustomerName
			CustomerEmail = CustomerEmail
		}
	}

	#Rules
	#End

	#Variables
		Today [ DataType = 'Date' ]
		Time [ DataType = 'Character(8)' ]
		Pgmname [ DataType = 'Character(128)' ]
		Pgmdesc [ DataType = 'Character(256)' ]
	#End

	#Properties
		Output = "CustomerData"
		Collection = true
		CollectionName = "Customers"
	#End
}
~~~

## Example 2: Collection populated from a procedure with Input iteration
Retrieves customers via the ListCustomers procedure and iterates the result with the Input clause (`EX-DPR-002`, validated in CI)
`src/CustomerDirectory.gx`:
~~~
DataProvider CustomerDirectory
{
	Customers
	{
		&Customers = ListCustomers()

		CustomerData
		Input &Customer in &Customers
		{
			CustomerId = &Customer.CustomerId
			CustomerName = &Customer.CustomerName
			CustomerEmail = &Customer.CustomerEmail
		}
	}

	#Rules
	#End

	#Variables
		Today [ DataType = 'Date' ]
		Time [ DataType = 'Character(8)' ]
		Pgmname [ DataType = 'Character(128)' ]
		Pgmdesc [ DataType = 'Character(256)' ]
		Customer [ DataType = 'CustomerData' ]
		Customers
		[
			DataType = 'CustomerData',
			Collection = 'True'
		]
	#End

	#Properties
		Output = "CustomerData"
		Collection = true
		CollectionName = "Customers"
	#End
}
~~~

# RELATED OBJECTS
- [StructuredDataType](./object-structured-data-type.md)
- [Transaction](./object-transaction.md)
- [DataSelector](./object-data-selector.md)
- [API](./object-api.md)
- [Procedure](./object-procedure.md)
