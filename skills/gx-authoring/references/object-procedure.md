<!-- GENERATED from catalog/objects/procedure.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-procedure
description: Executable code for business logic, data manipulation, and service implementation
---

# DEFINITION
A `Procedure` object (or `PRC`) contains executable code for business logic, data manipulation,
and service implementation.

Its body holds procedural code (`For each`, `New`, `Sub`, `Do`, object calls, etc.), complemented by
business rules (`parm`, `error`, `default`, etc.), conditional rules (`when` clauses), variable
definitions, an optional report layout, object properties (TOML syntax), and documentation.

**Attribute parameters.** PK/FK attributes can be passed directly in the `parm` rule (without `&`)
as `in:` parameters to create an implicit navigation context: the attribute becomes instantiated
with the received value and every `For each` automatically filters by it, with no explicit `Where`
needed. Attributes must never be `out:` or `inout:` parameters.

**Web service exposure.** By default a Procedure is referenced from an API object; only when
explicitly requested is it configured as a Web Service (`Expose as Web Service` property enabled
plus `Web Service Protocol` set to the requested protocol).

**Embedded native code.** Target-specific code can be embedded with `JAVA` / `CSHARP` directives
(one per line) using `[!&Var!]` syntax to reference GeneXus variables. Use only when strictly
required for exceptional generator-specific logic.

**Report layout.** A declarative XML-based schema used in the `#Layout` section when the source
uses `Print`, `Header`, or `Footer`. Hierarchy: `layout` root, then one `printBlock` band per
printed section (its `name` matches the `Print` command), then report controls (`label`,
`attribute`, `image`, `line`, `rectangle`) with position/size, font, color, border, alignment,
format, and word-wrap attributes. When the `Output_File` rule is used, the `Print` command is
required and the object must set `MainProgram = true` with `CallProtocol = "HTTP"`.

Use when:
- Implement server-side business logic or batch data manipulation (CRUD over Transaction tables)
- Implement service operations, referenced from an API object by default or exposed as a Web Service when explicitly requested
- Generate printed reports (PDF output) using Print commands with a declarative
- Build command-line main programs (MainProgram = true, CallProtocol = "Command Line")

# SYNTAX
~~~
Procedure <name>
{
	<code>

	#Rules
		<rules>
	#End

	#Conditions
		<conditions>
	#End

	#Variables
		<variables>
	#End

	#Layout
		<layout>
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
- `<code>`: Procedural code (For each, New, Sub, calls, etc.)
- `<rules>`: Business rules (parm, error, default, etc.)
- `<conditions>`: Conditional rules with when clauses
- `<variables>`: Variable definitions with `DataType`
- `<layout>`: Optional report layout definition; only when using `Print`, `Header`, or `Footer`
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation; exported to the external `.doc.md` artifact

Sections:
| Section | Required |
|---|---|
| `#Rules` | yes |
| `#Conditions` | yes |
| `#Variables` | yes |
| `#Layout` | no |
| `#Properties` | yes |
| `#Documentation` | no |

# COMMAND LINE EXECUTION
Running a generated main Procedure is done via the OS command line for the target environment,
NOT via gxnext or MCP tooling. Direct command-line execution is possible after build
(specification, generation, and compilation) using the target environment runtime.

Requires:
- `MainProgram = true`
- `CallProtocol = "Command Line"`

Working directory resolution in order:
1. Read `src/#preferences/<ver-name>.kb.gx` file
2. Read `CurrentEnvironment` (from `<ver-name>.local.kb.gx` override when present) as `<env-name>`
3. Read `src/#preferences/<env-name>.env.gx` file
4. Get the `TargetPath` property value as `<target-path>`
5. Navigate to `<kb-root>/<target-path>/web` as working directory

## JAVA environment
~~~
java -cp "build/classes/java/main;build/resources/main;lib/*;build/dependency/*" com.<package>.<prc-name>
~~~
Where `<package>` is derived from `gradle.properties` (`JAVA_PACKAGE_NAME_FOLDER`, replacing `\` with `.`)
and `<prc-name>` is the Procedure name in lowercase. On Unix/Linux use `:` instead of `;` as
classpath separator.

## .NET environment
~~~
dotnet ./bin/a<prc-name>.dll
~~~
GeneXus prefixes the assembly with `a`; e.g. `LoadTestData` -> `aloadtestdata.dll`.

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: none
- Files:
  - `<name>.gx`
  - `<name>.doc.md`
  - `<name>.report.xml (only when the procedure defines a report layout)`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-procedure](./properties-object-procedure.md) — Procedure objects

# CONSTRAINTS
Object-specific:
- `CON-PRC-001` Define parameters with the Parm rule using in:, out:, inout: accessors
- `CON-PRC-002` Use For each exclusively for data filtering, never for navigating or linking tables (SQL JOINs are invalid)
- `CON-PRC-003` Choose CRUD strategy by Transaction definition: use Business Components only if the transaction has BC enabled; use For each / New / Delete commands otherwise
- `CON-PRC-004` Include standard variables according to procedure context; for DB/runtime error handling, include the procedure error variables from the standard variables reference
- `CON-PRC-005` When the Output_File rule is used, require Print command usage and set MainProgram = true with CallProtocol = "HTTP"
- `CON-PRC-006` Include a /* signature */ comment for each Sub definition
- `CON-PRC-007` Invoke subroutines via the Do command without parameters; subroutines share the procedure's variables
- `CON-PRC-008` Pass PK/FK attributes directly in parm (without &) only as in: parameters for implicit navigation context; never define attributes as out: or inout: parameters
- `CON-PRC-009` When an attribute parameter is received, rely on the implicit For each filter; do not add a redundant explicit Where on that attribute
- `CON-PRC-010` For web service exposure, reference the procedure from an API object by default; enable Expose as Web Service plus Web Service Protocol only when explicitly requested
- `CON-PRC-011` Embedded native code supports only JAVA and CSHARP directives, one per line, using [!&Var!] syntax to embed GeneXus variables; apply it only when strictly required
- `CON-PRC-012` Command-line execution requires MainProgram = true and CallProtocol = "Command Line"
- `CON-PRC-013` Define #Layout only when the source uses Print, Header, or Footer; declare one printBlock per printed section with name matching the Print command
- `CON-PRC-014` In report layout XML: numeric values carry no unit suffix; colors are hex #RRGGBB or Transparent with no alpha; escape XML special characters
- `CON-PRC-015` Format report layout XML with tab indentation only; indent attributes one tab deeper than the element; expand element tags as multiline when more than two attributes, one attribute per line

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Prefer referencing the procedure from an API object over direct Web Service exposure
- Prefer attribute parameters for PK/FK inputs so every For each filters implicitly, avoiding explicit Where clauses
- Issue Commit after data-modifying For each blocks
- Use embedded native code only as a last resort for logic that cannot be expressed in GeneXus code
- Document each Sub's implicit inputs and outputs in its /* signature */ comment, since Do passes no parameters

# REQUIRES
Load these language modules together with this reference:
- [lang-commands](./lang-commands.md)
- [lang-business-component](./lang-business-component.md)
- [lang-standard-variables](./lang-standard-variables.md)
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Create with New command
Simple data procedure inserting a record with the New command (`EX-PRC-001`, validated in CI)
`src/AddProduct.gx`:
~~~
Procedure AddProduct
{
	New
		ProductName = &Name
		ProductPrice = &Price
	EndNew

	#Rules
		parm(in: &Name, in: &Price);
	#End

	#Conditions
	#End

	#Variables
		Name [ DataType = 'Attribute:ProductName' ]
		Price [ DataType = 'Attribute:ProductPrice' ]
	#End

	#Properties
	#End
}
~~~

## Example 2: Query with parameters and For each
Filters customers with For each and returns a collection output parameter (`EX-PRC-002`, validated in CI)
`src/ListCustomers.gx`:
~~~
Procedure ListCustomers
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
- [Transaction](./object-transaction.md)
- [StructuredDataType](./object-structured-data-type.md)
- [DataProvider](./object-data-provider.md)
