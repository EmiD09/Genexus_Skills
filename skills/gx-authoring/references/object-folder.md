<!-- GENERATED from catalog/objects/folder.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-folder
description: Container for organizing GeneXus objects in a hierarchical structure
---

# DEFINITION
A `Folder` object is a simple container used to organize GeneXus objects in a hierarchical
tree structure within the Knowledge Base.

Folders have no syntax (N/A) and export no artifacts of their own: a folder exists solely as
an `@`-prefixed directory (`@<name>/`) in the paths of the objects it contains. Folders
provide no encapsulation and no visibility control, and they are excluded from fully
qualified object names.

Hierarchy rules (containment):
- `Root Module` (always exists): can contain Modules, Folders, and Objects
- `Module`: can contain Modules, Folders, and Objects
- `Folder`: can contain Folders and Objects (NOT Modules)

Use when:
- Organizing Knowledge Base objects into a hierarchical tree without encapsulation needs
- Grouping related objects under a module (or under another folder) purely for navigation
- Structuring objects when visibility control and distribution are not required (otherwise use a Module)

# SYNTAX
~~~
(no syntax — a Folder is represented only by an @-prefixed directory in object paths)
~~~

Where:
- `@<name>/`: Directory name on disk for the folder; `<name>` uses alphanumeric or underscore, starting with letter

Sections:
| Section | Required |
|---|---|

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: none
- Files:
  - `@<name>/ (directory only; the folder itself exports no files)`

# CONSTRAINTS
Object-specific:
- `CON-FLD-001` Folders are simple organizational containers
- `CON-FLD-002` Folders cannot have modules as children (only other folders or objects)
- `CON-FLD-003` Folders can be children of modules or other folders
- `CON-FLD-004` Folders do not provide encapsulation or visibility control
- `CON-FLD-005` Folders are part of the hierarchical tree where the Root Module is the root
- `CON-FLD-006` Folders must use the @<name> directory name on disk
- `CON-FLD-007` Folders can be converted into Modules by removing the @ prefix from the target directory name and adding the associated .toml/.md files if required
- `CON-FLD-008` Folders have no SYNTAX and export no artifacts of their own; they appear only as @-prefixed directories in contained object paths
- `CON-FLD-009` Category directories (#-prefixed) must never exist under a Folder; they exist only under Modules
- `CON-FLD-010` Folders are excluded from fully qualified object names ([<module>.]*<name>)

All rules in [global-constraints](./global-constraints.md) apply in full.

# EXAMPLES
## Example 1: Procedure inside a folder
The fixture ListCustomers procedure saved under a Sales folder; the folder contributes only the @-prefixed path segment (`EX-FLD-001`, validated in CI)
`src/@Sales/SalesListCustomers.gx`:
~~~
Procedure SalesListCustomers
{
	For each Customer
		Where CustomerActive
		&Customer = new()
		&Customer.CustomerId = CustomerId
		&Customer.CustomerName = CustomerName
		&Customer.CustomerEmail = CustomerEmail
		&Customers.Add(&Customer)
	EndFor

	#Rules
		parm(out: &Customers);
	#End

	#Conditions
	#End

	#Variables
		Customers [ DataType = 'CustomerData', Collection = 'True' ]
		Customer [ DataType = 'CustomerData' ]
	#End

	#Properties
	#End
}
~~~

# RELATED OBJECTS
- [Module](./object-module.md)
