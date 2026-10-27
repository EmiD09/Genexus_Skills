<!-- GENERATED from catalog/objects/deployment-unit.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-deployment-unit
description: Defines a deployable group of objects to be packaged and deployed together
---

# DEFINITION
A `DeploymentUnit` object (or `DPU`), declared with the
`DeploymentUnitCategory` keyword, defines a set of objects to be deployed
together.

Typically, applications split deployment units by layers such as front
office, backend, and services.

Deploying a `DeploymentUnit` packages the objects defined in it and their
dependencies according to GeneXus deployment behavior.

Use when:
- Group main objects, file objects, and business process diagrams that must be deployed together
- Split application deployment by layers such as front office, backend, and services

# SYNTAX
~~~
DeploymentUnitCategory <name>
{
	<objects>

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
- `<objects>`: List of object names to deploy together, one per line
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation (exported to external `.doc.md` file)

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
- [properties-object-deployment-unit](./properties-object-deployment-unit.md) — Deployment Unit objects

# CONSTRAINTS
Object-specific:
- `CON-DPU-001` Include only deployable references supported by the GeneXus Deployment Unit object scope: main objects, file objects, and business process diagram objects
- `CON-DPU-002` Declare one referenced object per line
- `CON-DPU-003` Qualify object names by module when applicable
- `CON-DPU-004` Never duplicate object references inside the same deployment unit
- `CON-DPU-005` For updates, preserve unchanged object entries and modify only requested items
- `CON-DPU-006` A DeploymentUnit may be referenced by name in the #DeploymentUnits region of the Environment model file

All rules in [global-constraints](./global-constraints.md) apply in full.

# REQUIRES
Load these language modules together with this reference:
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Backend services unit
Deployment unit grouping backend procedures from the root module (`EX-DPU-001`, validated in CI)
`src/BackendServices.gx`:
~~~
DeploymentUnitCategory BackendServices
{
	AddProduct
	ListCustomers

	#Properties
	#End
}
~~~

# RELATED OBJECTS
- [BusinessProcessDiagram](./object-business-process-diagram.md)
- [File](./object-file.md)
