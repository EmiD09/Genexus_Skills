<!-- GENERATED from catalog/objects/external-object.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-external-object
description: Defines a wrapper over external resources so they can be used as GeneXus objects
---

# DEFINITION
An `External Object` (or `EO`) exposes functionality implemented outside the Knowledge Base through a
platform-mapped contract.

Design model:
- `#GenericTypes`: Generic placeholders used by members and signatures
- `#ExternalProperties`: Read or write members mapped to external runtime properties
- `#ExternalMethods`: Operations mapped to external runtime methods
- `#ExternalEvents`: Notifications raised by external runtime components

## REGION PROPERTIES (shared native mapping)
Use whenever a member requires explicit native mapping:
- `NetFrameworkExternalName` / `NetFrameworkExternalType`: .NET Framework external member name/type
- `NetExternalName` / `NetExternalType`: Modern .NET external member name/type
- `JavaExternalName` / `JavaExternalType`: Java external member name/type

## GENERIC TYPE
`<name> [ <properties> ]` with properties: `Description`, `PropertyName` (semantic metadata name for the
placeholder), `ValidTypes` (comma-separated valid GeneXus data types), `AllowCollection` (`True`/`False`),
`DefaultType` (used when no explicit specialization is provided).
Generic placeholders are reusable across `#External*` regions.

## EXTERNAL PROPERTY
`<name> [ <properties> ]` with properties: `PropertyType` (`Read`, `Write`, `ReadWrite`), `Description`,
`Type` (GeneXus-facing type), `IsStatic` (`True`/`False`), `ControlType` (UI control when applicable),
`JavaExternalGetMethod` / `JavaExternalSetMethod` (optional explicit Java getter/setter names), plus shared
mapping properties when required.

## EXTERNAL METHOD
`<name> [ <properties> ] { Parameters { <parameters> } }` with properties: `Description`, `Type` (return
type, only when returning a value), `BasedOn`, `XMLName`, `IsStatic`, `ExternalMemberType` (`Default`,
`Static`, `Instance`), `JavaMethodThrowsExceptions` (`Yes`/`No`), plus shared mapping properties.

Method parameter: `<name> [ <properties> ]` with `AccessType` (`In`, `Out`, `InOut`), `Description`,
`Type`, `ExternalType` (generic external parameter type mapping), plus shared mapping properties.
Data type resolution reuses the canonical Data Type Priority (defined in lang-data).

## EXTERNAL EVENT
`<name> [ <properties> ] { Parameters { <parameters> } }` with properties: `Description`, `IsStatic`,
plus shared mapping properties. Event parameter: `<name> [ <properties> ]` with `Description`, `Type`,
`ExternalType`.

## NATIVE CODE MAPPING (C#/Java)
Object-level `#Properties` bind the EO to the native class: `".NET Framework External Name"`,
`".NET External Name"`, `JavaExternalName` (class name) and `ExternalPackageName` (namespace/package).
- C#: the EO maps to a class (typically static) whose property, method, and event names match the
  `NetFrameworkExternalName`/`NetExternalName` values
- Java: members map through `JavaExternalName`/`JavaExternalType`; properties bind via explicit accessors
  given by `JavaExternalGetMethod`/`JavaExternalSetMethod` (e.g. `isEnabled`/`setEnabled`); events bind via
  a static registration method named after the event that receives a handler interface implementing a
  method named after the event

Use when:
- Expose functionality implemented outside the Knowledge Base (native .NET/Java libraries) with a platform-mapped contract
- Bind external runtime properties, methods, and events so any GeneXus object can consume them like native members

# SYNTAX
~~~
ExternalObject <name>
{
	#GenericTypes
		<generic-types>
	#End

	#ExternalProperties
		<external-properties>
	#End

	#ExternalMethods
		<external-methods>
	#End

	#ExternalEvents
		<external-events>
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
- `<generic-types>`: Generic type definition list (see GENERIC TYPE in definition)
- `<external-properties>`: External property definition list (see EXTERNAL PROPERTY in definition)
- `<external-methods>`: External method definition list (see EXTERNAL METHOD in definition)
- `<external-events>`: External event definition list (see EXTERNAL EVENT in definition)
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation (external `.doc.md` artifact)

Sections:
| Section | Required |
|---|---|
| `#GenericTypes` | yes |
| `#ExternalProperties` | yes |
| `#ExternalMethods` | yes |
| `#ExternalEvents` | yes |
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
- [properties-object-external-object](./properties-object-external-object.md) — External Object objects

# CONSTRAINTS
Object-specific:
- `CON-EXO-001` Keep one clear mapping per member for each target platform
- `CON-EXO-002` Every value inside [...] blocks must use 'single-quoted' strings without ! prefix
- `CON-EXO-003` Every method parameter must define AccessType and Type
- `CON-EXO-004` Every event parameter must define Type
- `CON-EXO-005` Every method must define Type only when returning a value
- `CON-EXO-006` Keep signatures synchronized with external contracts to avoid runtime binding errors
- `CON-EXO-007` Keep EO spec names in PascalCase and mapping properties exactly as defined in syntax
- `CON-EXO-008` Avoid platform-specific assumptions in GeneXus-facing names
- `CON-EXO-009` For Type = 'Native Object', set events as static
- `CON-EXO-010` Keep generic type names stable because member signatures depend on them
- `CON-EXO-011` Keep event names stable because consumer source binds by event name

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Use external properties for lightweight state access; use external methods for operations with side effects or validation logic

# REQUIRES
Load these language modules together with this reference:
- [lang-data](./lang-data.md)
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Telemetry external object
EO mapping a native telemetry bridge with properties, methods, and an event for .NET and Java (`EX-EXO-001`, validated in CI)
`src/DeviceTelemetryEO.gx`:
~~~
ExternalObject DeviceTelemetryEO
{
	#GenericTypes
	#End

	#ExternalProperties
		Enabled
		[
			PropertyType = 'ReadWrite',
			Description = 'Indicates whether telemetry tracking is enabled.',
			Type = 'Boolean',
			NetFrameworkExternalName = 'Enabled',
			NetFrameworkExternalType = 'bool',
			JavaExternalName = 'enabled',
			JavaExternalType = 'boolean',
			JavaExternalGetMethod = 'isEnabled',
			JavaExternalSetMethod = 'setEnabled'
		]

		LastMetric
		[
			PropertyType = 'Read',
			Description = 'Returns the last tracked metric.',
			Type = 'VarChar(200)',
			NetFrameworkExternalName = 'LastMetric',
			NetFrameworkExternalType = 'string',
			JavaExternalName = 'lastMetric',
			JavaExternalType = 'String',
			JavaExternalGetMethod = 'getLastMetric'
		]
	#End

	#ExternalMethods
		Track
		[
			Description = 'Tracks a telemetry metric.',
			NetFrameworkExternalName = 'Track',
			NetFrameworkExternalType = 'void',
			JavaExternalName = 'track',
			JavaExternalType = 'void'
		]
		{
			Parameters
			{
				MetricName
				[
					AccessType = 'In',
					Type = 'VarChar(80)'
				]

				Value
				[
					AccessType = 'In',
					Type = 'Numeric(10.2)'
				]
			}
		}

		GetLastMetric
		[
			Description = 'Gets the last tracked metric value.',
			Type = 'VarChar(200)',
			NetFrameworkExternalName = 'GetLastMetric',
			NetFrameworkExternalType = 'string',
			JavaExternalName = 'getLastMetric',
			JavaExternalType = 'String'
		]
	#End

	#ExternalEvents
		MetricTracked
		[
			Description = 'Raised when a metric is tracked.',
			NetFrameworkExternalName = 'MetricTracked',
			JavaExternalName = 'metricTracked'
		]
		{
			Parameters
			{
				MetricName
				[
					Type = 'VarChar(80)'
				]

				Value
				[
					Type = 'Numeric(10.2)'
				]
			}
		}
	#End

	#Properties
		Name = "DeviceTelemetryEO"
		Description = "Telemetry bridge for tracking and querying device metrics"
		".NET Framework External Name" = "TelemetryBridge"
		JavaExternalName = "TelemetryBridge"
		ExternalPackageName = "com.contoso.telemetry"
	#End
}
~~~

## Example 2: Consuming EO in Procedure
Procedure setting an EO property, calling its methods, and reading the result (`EX-EXO-002` — engine validation pending)
`src/TelemetrySample.gx`:
~~~
Procedure TelemetrySample
{
	DeviceTelemetryEO.Enabled = True
	DeviceTelemetryEO.Track(!"SyncElapsed", 125.40)
	&LastMetric = DeviceTelemetryEO.GetLastMetric()
	msg(&LastMetric, status)

	#Rules
	#End

	#Conditions
	#End

	#Variables
		LastMetric [ DataType = 'VarChar(200)' ]
	#End

	#Properties
	#End
}
~~~

# RELATED OBJECTS
- [Procedure](./object-procedure.md)
