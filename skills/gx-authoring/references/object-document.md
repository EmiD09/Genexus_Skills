<!-- GENERATED from catalog/objects/document.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-document
description: Stores Markdown documentation content within the Knowledge Base
---

# DEFINITION
A `Document` object stores information within the Knowledge Base.

Its body is documentation content written in Markdown syntax; KB objects can be referenced
from the content using wiki-style links such as `[[Transaction.Customer]]` or
`[[Procedure.AddProduct]]`.

Use when:
- Storing documentation content inside the Knowledge Base
- Maintaining KB object inventories or tables of contents
- Recording functional or technical specifications alongside KB objects

# SYNTAX
~~~
Document <name>
{
	<documentation>

	#Properties
		<properties>
	#End
}
~~~

Where:
- `<name>`: Object name using alphanumeric or underscore, starting with letter
- `<documentation>`: Documentation content with Markdown syntax (see lang-markdown)
- `<properties>`: Optional object properties in TOML syntax

Sections:
| Section | Required |
|---|---|
| `#Properties` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: `#documentation/`
- Files:
  - `<name>.gx`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-documentation](./properties-object-documentation.md) — Document objects

# CONSTRAINTS
Object-specific:
- `CON-DOC-001` Define Document objects only in Root Module; no folders or named modules

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Use Markdown headings, lists, and tables to structure the content
- Reference KB objects from the content with wiki-style links such as [[Transaction.Customer]]

# REQUIRES
Load these language modules together with this reference:
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Knowledge Base object inventory
Document listing KB objects by type with wiki-style links and tables (`EX-DOC-001`, validated in CI)
`src/#documentation/Structure_Objects.gx`:
~~~
Document Structure_Objects
{
	# GeneXus Knowledge Base: Object Inventory

	This document lists all **objects** defined in the Knowledge Base (KB), organized by type

	## Transactions

	| Name                     | Description                           |
	|:-------------------------|:--------------------------------------|
	| [[Transaction.Product]]  | Manages the product catalog.          |
	| [[Transaction.Customer]] | Manages customer information.         |
	| [[Transaction.Order]]    | Manages orders and their order lines. |

	## Procedures

	| Name                        | Description                        |
	|:----------------------------|:-----------------------------------|
	| [[Procedure.AddProduct]]    | Adds a new product to the catalog. |
	| [[Procedure.ListCustomers]] | Lists registered customers.        |

	#Properties
		Description = "Object table of contents"
	#End
}
~~~

# RELATED OBJECTS
- [Module](./object-module.md)
