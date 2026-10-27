<!-- GENERATED from catalog/objects/subtype-group.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-sub-type-group
description: Defines object specialization through subtype aliases, enabling type hierarchies and polymorphism without data duplication
---

# DEFINITION
A `SubType Group` is a logical container of `SubType` items derived from the same or
related supertypes.

Purpose:
- Acts as a "virtual" transaction: defines structure and semantics but is not
  physically stored
- Each SubType is an alias of an existing Attribute or SubType, enabling reuse with a
  new name without duplicating data

SUBTYPE — defines one subtype alias entry:

	<name> : <base-type>
	[
		<properties>
	]

- `<name>`: subtype alias derived from `<base-type>` with a contextual/role prefix
- `<base-type>`: existing `Attribute` or `SubType` object name
- `<properties>`: overridden supertype properties; omit the block if none

Once a SubType Group is defined, any Transaction can reference its subtype attributes
without properties; the SubType Group defines them implicitly.

Use when:
- Model the same entity in different roles (e.g. Sender/Receiver, Departure/Arrival)
- Model hierarchical self-relationships (e.g. a record referencing another record of the same entity)
- Model inheritance relationships (specialized entities sharing a supertype key)
- Preserve semantic clarity without data duplication

# SYNTAX
~~~
Group <name>
{
	<subtypes>

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
- `<subtypes>`: Subtype definition list (see SUBTYPE in definition)
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation (exported to external `.doc.md` file)

Sections:
| Section | Required |
|---|---|
| `#Properties` | yes |
| `#Documentation` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: `#subtypes/`
- Files:
  - `<name>.gx`
  - `<name>.doc.md`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-subtype-group](./properties-object-subtype-group.md) — Subtype Group objects

# CONSTRAINTS
Object-specific:
- `CON-STG-001` Each subtype name must be unique
- `CON-STG-002` Each subtype inherits from an existing attribute or other subtype
- `CON-STG-003` Define the subtype [ ... ] property block only to override supertype properties; omit it when none are overridden

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Name each subtype alias as the base attribute name with a contextual/role prefix (e.g. ReferrerCustomerId from CustomerId)

# REQUIRES
Load these language modules together with this reference:
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Self-relationship role aliases
Aliases the fixture Customer key and name so a customer can reference the customer who referred them, overriding the Description of each subtype (`EX-STG-001` — engine validation pending)
`src/#subtypes/ReferrerCustomer.gx`:
~~~
Group ReferrerCustomer
{
	ReferrerCustomerId : CustomerId
	[
		Description = 'Identifier of the referring customer'
	]

	ReferrerCustomerName : CustomerName
	[
		Description = 'Name of the referring customer'
	]

	#Properties
		Description = "Represents the customer who referred another customer"
	#End
}
~~~

## Example 2: Role aliases without property overrides
Aliases the fixture Product key and name for a substitute-product role, omitting the per-subtype property blocks because no supertype properties are overridden (`EX-STG-002` — engine validation pending)
`src/#subtypes/SubstituteProduct.gx`:
~~~
Group SubstituteProduct
{
	SubstituteProductId : ProductId
	SubstituteProductName : ProductName

	#Properties
		Description = "Represents the product offered as a substitute"
	#End
}
~~~

# RELATED OBJECTS
- [Transaction](./object-transaction.md)
