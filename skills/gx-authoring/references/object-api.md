<!-- GENERATED from catalog/objects/api.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-api
description: Defines API services delegating implementation to callable objects, with REST as default protocol
---

# DEFINITION
An `API` object consists of entry points defining services delegating implementation to callable objects.

Protocol guidance:
- Prefer `REST` as default protocol
  - Applies to public/external integrations and standard HTTP clients
  - Set `CallProtocol = "HTTP"`
  - Set `GRPCProtocol = false`
- Choose `gRPC` only when explicitly requested
  - Applies to internal service-to-service contracts with strict typing
  - Set `GRPCProtocol = true`
  - Set `GenerateOpenAPIInterface = "No"`
- Keep one service definition mode:
  - Prefer `API` object exposure layer with reference to implementation objects
  - Define `Web Service` exposure in target object only when explicitly requested

## SERVICE
Defines one exposed service delegated to one implementation call.

Syntax:
~~~
<annotations>
<name>(<parameters>)
	=> <implementation>(<arguments>);
~~~

Where:
- `<annotations>`: Breakline-separated annotations written immediately before the service declaration
- `<name>`: Service exposed name with parameters
- `<parameters>`: Comma-separated variable parameters with operator (`in`, `out`, `inout`); optional parameters in brackets
- `<implementation>`: Implementation object (`Procedure`, `DataProvider`, or other callable object)
- `<arguments>`: Comma-separated variables or constants for implementation call

Keep one implementation call per service.

## ANNOTATIONS
Optional protocol-specific metadata for a service declaration:
- `[RestMethod(<method>)]`: HTTP verb (`GET`, `POST`, `PUT`, `DELETE`); default `GET` if omitted
- `[RestPath(<path>)]`: Custom REST path with variable interpolation using `{&varname}`; default is service name if omitted; start paths with `/` and use plural resource names consistently across all verbs
- `[Header(<name>, <value>)]`: Service parameter received from an HTTP header; `<name>` is a constant string, `<value>` the variable receiving the header value; e.g. `[Header('Logged-User', &UserId)]`
- `[Description(<description>)]`: Short, simple, concise service description; strongly recommended; mandatory when `Included in MCP Server` property enabled
- `[SecurityLevel(<level>)]`: Access requirement — `None` (default, no authentication), `Authentication` (user authenticated), `Authorize` (authenticated and authorized)
- `[SecurityPermission(<permission>)]`: Permission name or role required for executing the service

## EVENTS
Allowed event names: `Before`, `<service>.Before`, `<service>.After`, `After`.

Execution sequence:
1. `Before`
2. `<service>.Before`
3. Service implementation call
4. `<service>.After`
5. `After`

Notes:
- Service `in` parameters can be initialized in `Before`
- Service `out` parameters can be initialized in `After`
- API event code must not use direct DB access commands (`For each`, `New`, `Delete`, `Commit`, `Rollback`)

Use when:
- Expose Procedures, DataProviders, or other callable objects as REST services
- Public/external integrations and standard HTTP clients (REST default)
- Internal service-to-service contracts with strict typing when gRPC is explicitly requested
- Centralize an exposure layer (paths, verbs, security, headers) decoupled from implementation objects

# SYNTAX
~~~
API <name>
{
	<name>
	{
		<services>
	}

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
- `<name>`: Object name using alphanumeric or underscore, starting with letter
- `<services>`: Service definition list (see SERVICE in definition)
- `<events>`: Event handlers (Before, After, service-specific)
- `<variables>`: Variable definitions with mandatory `DataType`
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation (external `.doc.md` artifact)

Sections:
| Section | Required |
|---|---|
| `#Events` | yes |
| `#Variables` | yes |
| `#Properties` | yes |
| `#Documentation` | no |

# COMMAND LINE EXECUTION
Guideline for building the invocation URL for an `API` object service.

Pattern:
~~~
<host>:<port>/<name><path>
~~~

Where:
- `<host>:<port>`: Host and port where the app is deployed; e.g. `http://localhost:8080`
- `<name>`: Name from the target `API` object
- `<path>`: Path given by `RestPath` annotation value for the target service

Steps:
1. Read the `API` object definition
2. Take `<name>` from `API <name>` header
3. Find target service
4. Read `<method>` from `[RestMethod(<method>)]`
5. Read `<path>` from `[RestPath(<path>)]`
6. Fill `{&VarName}` placeholders in `<path>` with proper values
7. Build `<host>:<port>/<name><path>` as invocation URL

Example: for service `[RestMethod(GET)] [RestPath('/customers/{&CustomerId}')]` in `API CustomerAPI`,
the runtime URL for getting customer with Id 5 is:
~~~
GET http://localhost:8080/CustomerAPI/customers/5
~~~

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: none
- Files:
  - `<name>.gx`
  - `<name>.doc.md`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-api](./properties-object-api.md) — API objects

# CONSTRAINTS
Object-specific:
- `CON-API-001` Implementation calls match implementation object Parm rule signature
- `CON-API-002` Annotations are written immediately before the service declaration
- `CON-API-003` Keep one implementation call per service
- `CON-API-004` Service parameters can omit in params (initialized in Before event)
- `CON-API-005` Service can define out params not in implementation (initialized in After event)
- `CON-API-006` Event code must be orchestration only; never include direct DB access commands (For each, New, Delete, Commit, Rollback)
- `CON-API-007` Keep API execution under HTTP semantics by setting CallProtocol = "HTTP" when exposing REST behavior
- `CON-API-008` Keep either API object references or object-level Web Service definition, never both
- `CON-API-009` For gRPC (only when explicitly requested) set GRPCProtocol = true and GenerateOpenAPIInterface = "No"
- `CON-API-010` Description annotation is mandatory when Included in MCP Server property is enabled
- `CON-API-011` RestMethod defaults to GET and RestPath defaults to the service name when omitted

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Prefer REST as default protocol; choose gRPC only when explicitly requested
- Start every RestPath with `/` and use plural resource names consistently across all HTTP verbs (including DELETE)
- Provide a Description annotation for every service
- Include standard variables (Pgmname, Pgmdesc, RestMethod, RestCode) according to API context

# REQUIRES
Load these language modules together with this reference:
- [lang-events](./lang-events.md)
- [lang-standard-variables](./lang-standard-variables.md)
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Simple API
API exposing one list service delegating to the ListCustomers procedure (`EX-API-001`, validated in CI)
`src/CustomerAPI.gx`:
~~~
API CustomerAPI
{
	CustomerAPI
	{
		[Description("List all customers")]
		ListCustomers(out: &Customers)
			=> ListCustomers(&Customers);
	}

	#Events
	#End

	#Variables
		Pgmname [ DataType = 'Character(128)' ]
		Pgmdesc [ DataType = 'Character(256)' ]
		RestMethod [ DataType = 'HttpMethod, GeneXus' ]
		RestCode [ DataType = 'Numeric(3.0)' ]
		Customers
		[
			DataType = 'CustomerData',
			Collection = 'True'
		]
	#End

	#Properties
		MainProgram = true
	#End
}
~~~

## Example 2: CRUD API with custom paths
Full CRUD exposure for Customer with consistent plural REST paths and HTTP verbs (`EX-API-002`, validated in CI)
`src/CustomerCrudAPI.gx`:
~~~
API CustomerCrudAPI
{
	CustomerCrudAPI
	{
		[Description("List all customers")]
		[RestPath('/customers')]
		ListCustomers(out: &Customers)
			=> ListCustomers(&Customers);

		[Description("Get information on a particular customer")]
		[RestMethod(GET)]
		[RestPath('/customers/{&CustomerId}')]
		GetCustomer(in: &CustomerId, out: &CustomerData)
			=> GetCustomer(&CustomerId, &CustomerData);

		[Description("Add a new customer")]
		[RestMethod(POST)]
		[RestPath('/customers')]
		AddCustomer(in: &CustomerData, out: &CustomerId)
			=> CreateCustomer(&CustomerData, &CustomerId);

		[Description("Update an existing customer")]
		[RestMethod(PUT)]
		[RestPath('/customers/{&CustomerId}')]
		UpdateCustomer(in: &CustomerId, in: &CustomerData)
			=> UpdateCustomer(&CustomerId, &CustomerData);

		[Description("Delete a customer")]
		[RestMethod(DELETE)]
		[RestPath('/customers/{&CustomerId}')]
		DeleteCustomer(in: &CustomerId)
			=> DeleteCustomer(&CustomerId);
	}

	#Events
	#End

	#Variables
		Pgmname [ DataType = 'Character(128)' ]
		Pgmdesc [ DataType = 'Character(256)' ]
		RestMethod [ DataType = 'HttpMethod, GeneXus' ]
		RestCode [ DataType = 'Numeric(3.0)' ]
		Customers
		[
			DataType = 'CustomerData',
			Collection = 'True'
		]
		CustomerData [ DataType = 'CustomerData' ]
		CustomerId [ DataType = 'Attribute:CustomerId' ]
	#End

	#Properties
	#End
}
~~~

# RELATED OBJECTS
- [Procedure](./object-procedure.md)
- [DataProvider](./object-data-provider.md)
- [StructuredDataType](./object-structured-data-type.md)
