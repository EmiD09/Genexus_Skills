<!-- GENERATED from catalog/objects/module.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-module
description: Encapsulation container for grouping and organizing GeneXus objects with interface definition
---

# DEFINITION
A `Module` object is a GeneXus object designed to group objects from the Knowledge Base,
encapsulate functionalities, define interfaces, and facilitate understanding, maintenance,
and integration of objects among KBs.

The SYNTAX is a conceptual representation only: a Module never produces a `.gx` file. Its
`#Properties` content maps to a `module.toml` file and its `#Documentation` content maps to
a `README.md` file, both inside the module directory. README.md is created only when the
module has `#Documentation` content, and module.toml only when properties exist. Modules are
regular directories on disk with no special character prefix (folders, by contrast, use
`@`-prefixed directories).

AUTHORITATIVE visibility semantics (design decision D8). The `ObjectVisibility` property sets
the default visibility for objects in the module; the value `Knowledge Base` is written with
a space (never `KnowledgeBase`):
- `Public`: Accessible from any module, included in the module interface, can be distributed
- `Knowledge Base`: Accessible from any module in the same KB, cannot be distributed
- `Internal`: Only accessible by objects with a common root module, cannot be distributed
- `Private`: Only accessible within the same module and its sub-modules, cannot be distributed

Hierarchy: `src/` is the `Root Module` target directory; every object belongs to a module
(`Root Module` by default); objects in modules use the fully qualified name syntax
`[<module>.]*<name>`, excluding folders (e.g. `Sales.CreateOrder`).

Use when:
- Grouping Knowledge Base objects and encapsulating functionality behind a controlled interface
- Controlling object visibility (Public / Knowledge Base / Internal / Private)
- Packaging functionality for distribution and installation in other Knowledge Bases
- Reusing the same object name in different modules via fully qualified names

# SYNTAX
~~~
Module <name>
{
	#Properties
		Description = "<description>"
		Version = "<version>"
		ObjectVisibility = "<visibility>"
		<properties>
	#End

	#Documentation
		<documentation>
	#End
}
~~~

Where:
- `<name>`: Module name using alphanumeric or underscore, starting with letter
- `<description>`: Optional description of the module's purpose
- `<version>`: Optional version identifier
- `<visibility>`: Default visibility for objects in the module; values: `Public`, `Knowledge Base`, `Internal`, `Private` (see definition for authoritative semantics)
- `<properties>`: Optional module properties; exported to the `module.toml` artifact
- `<documentation>`: Optional module documentation; exported to the `README.md` artifact

Sections:
| Section | Required |
|---|---|
| `#Properties` | no |
| `#Documentation` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: none
- Files:
  - `<name>/module.toml (only when properties exist)`
  - `<name>/README.md (only when #Documentation content exists)`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-module](./properties-object-module.md) — Module objects

# CONSTRAINTS
Object-specific:
- `CON-MOD-001` Treat the Module SYNTAX as a conceptual representation; never produce a *.gx file for a Module
- `CON-MOD-002` Modules provide encapsulation and visibility control
- `CON-MOD-003` Modules can contain: sub-modules, folders, objects, and module-level category directories (# prefixed)
- `CON-MOD-004` Modules can be distributed and installed in other Knowledge Bases
- `CON-MOD-005` Modules allow the same object name in different modules
- `CON-MOD-006` Define module.toml only when properties exist
- `CON-MOD-007` Define README.md only when the module has #Documentation content; README.md holds that documentation content for the module
- `CON-MOD-008` Modules must be regular directories on disk; never prepend a special character prefix
- `CON-MOD-009` Modules can be converted into Folders by adding the @ prefix to the target directory name and removing the associated .toml/.md files if they exist
- `CON-MOD-010` Folders cannot contain modules; only modules can contain modules
- `CON-MOD-011` Define src/ as the Root Module module target directory
- `CON-MOD-012` All objects belong to a module; defaults to Root Module if not specified
- `CON-MOD-013` All objects in modules use the fully qualified name syntax [<module>.]*<name>, excluding folders (e.g. Sales.CreateOrder)
- `CON-MOD-014` Write the ObjectVisibility value Knowledge Base with a space, never KnowledgeBase

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- For distributable modules, set ObjectVisibility = "Private" as the module default and mark only the interface objects as Public
- Use folders (@-prefixed) inside a module for simple organization when no additional encapsulation or visibility control is needed

# REQUIRES
Load these language modules together with this reference:
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Module with properties and documentation
Sales module grouping the fixture Customer and Order transactions; only module.toml and README.md are exported, never a .gx file (`EX-MOD-001`, validated in CI)
`src/Sales/module.toml`:
~~~
Description = "Sales management module"
Version = "1.0.0"
ObjectVisibility = "Knowledge Base"
~~~
`src/Sales/README.md`:
~~~
# Sales

Groups the Customer and Order transactions and their supporting logic.
Objects are referenced with fully qualified names, e.g. Sales.Order.
~~~

## Example 2: Distributable module with Public interface
Catalog module packaged for distribution; Private default visibility with interface objects exposed as Public (`EX-MOD-002`, validated in CI)
`src/Catalog/module.toml`:
~~~
Description = "Product catalog SDK"
Version = "2.1.0"
ObjectVisibility = "Private"
~~~
`src/Catalog/README.md`:
~~~
# Catalog SDK

Product catalog services for third-party integration.

## Version History
- 2.1.0: Added product maintenance support
- 2.0.0: Initial release
~~~

# RELATED OBJECTS
- [Folder](./object-folder.md)
