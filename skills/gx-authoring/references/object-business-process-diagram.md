<!-- GENERATED from catalog/objects/business-process.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-business-process-diagram
description: Defines business process flows using the BPMN 2.0 standard with tasks, gateways, events, and connectors
---

# DEFINITION
A `Business Process Diagram` object (or `BPD`) represents a business process flow using the BPMN 2.0 standard.

When creating system-interaction tasks, request definition of:
- Most suitable objects: Transaction, WebPanel, Procedure, Agent
- Required parameters with data types and accessors
- Fully qualified object names

## Objects in Tasks
Tasks reference objects (WebPanels, Procedures, Transactions, Agents).
Relevant data must include: accessor (`in`, `out`, `inout`), parameter name, compatible type (UPPER CASE), and value without ampersand.
Required parameters in objects are defined in the `Parm` rule; relevant data must be reused across tasks
(e.g. task chain: "Write Article" (out: Article) -> "Review Article" (in: Article)).

## Element Distribution
Element coordinates `<x,y>` represent the shape top-left corner.
Element sizes: `StartEvent` 36x36, `EndEvent` 36x36, `Gateway` 40x40, `Task` 187x67, `IntermediateEvent` 36x36.
Space elements to avoid overlaps.

## Connector Rules
A port cannot be reused as both from and to simultaneously.
Path routing priorities: 1) straight line; 2) L-shaped (one intermediate point); 3) U-shaped (two intermediate points). Avoid more than two bends.
The `points` attribute is used only when the connector is not straight; the first point matches `fromPort` and the last point matches `toPort`.
Multiple connectors from a gateway use the same `fromPort`, separated visually with the points attribute; multiple incoming connectors can use the same `toPort`. Avoid reusing a `toPort` as a `fromPort` in another connector.

## Conditionals in Connectors
Rule-type conditions use `conditionType: 'Rule'` with `conditionRule` set.
Condition syntax: `<prefix><name> <operator> <value>` — ampersand prefix for relevant data, no prefix for transaction attributes.
Grouping with `( )`; operators `=`, `>`, `<`, `>=`, `<=`, `!=`; logical `AND`, `OR`, `NOT`.
Type compatibility: NUMERIC values unquoted (`&OrderTotal > 1000`); CHARACTER values quoted (`&Status = 'Open'`); BOOLEAN true/false, case-insensitive.
Use `conditionType: 'Default'` for fallback paths; gateways should have at least two outgoing connectors, one of which may be default.
The `text` attribute is for documentation only.

Use when:
- Modeling a business process flow with BPMN 2.0 elements (tasks, gateways, events, connectors)
- Orchestrating tasks executed by users, batch procedures, or AI agents (including conversational agents)
- Routing flow conditionally through gateways with rule-based or default conditions

# SYNTAX
~~~
BPDiagram <name>
{
	#Diagram
		<diagram>
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
- `<diagram>`: Diagram definition in XML form (engine-confirmed; an empty diagram is `<Properties />`); the inner XML schema is undocumented — the JSON model below describes the diagram's logical structure
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation (exported to external `.doc.md` file)

Diagram logical model (JSON representation from the source; element semantics):
- `<element-id>`: Numeric element identifier
- `<element-name>`: Descriptive element name (not used for connectors)
- `<element-x>`, `<element-y>`: Coordinates of shape top-left corner (ignored for connectors)
- `<element-type>`: `StartEvent` (entry point), `EndEvent` (exit point), `Task` (unit of work), `Gateway` (conditional flow control), `Connector` (flow between elements), `IntermediateEvent` (mid-flow trigger)
- `<element-task-type>`: `None` (default, automatic), `User` (person), `Script` (batch process), `Agent` (AI agent), `Conversational` (AI agent in chat interaction)
- `<element-gateway-type>`: `Exclusive` (default, one path), `Inclusive` (one or more), `Parallel` (all paths), `Event` (event-triggered)
- `<element-event-trigger>`: `None` (default), `Timer`, `Cancel`, `Message`, `Error`, `Signal`, `Compensate`, `Conditional`, `Link`
- `<element-connector-condition-type>`: `Rule` (rule-based) or `Default` (fallback path)
- `<element-connector-condition-rule>`: Condition rule (if type is `Rule`)
- `<element-connector-condition-text>`: Condition description (documentation only)
- `<element-connector-from>`, `<element-connector-to>`: Source and target element identifiers
- `<element-connector-from-port>`, `<element-connector-to-port>`: Port values: `top`, `bottom` (default), `left`, `right`
- `<element-connector-point-x/y>`: Connector line point coordinates (for non-straight lines)
- `<element-intermediate-event>`: Intermediate event (same structure as elements)
- `<element-object-type>`: Object type by task type — `User`: WebPanel, SDPanel, Transaction; `Script`: Procedure; `Agent`: Agent
- `<element-object-name>`: Fully qualified object name using dot notation
- `<element-object-relevant-accessor>`: `in` (read-only), `out` (write-only), `inout` (default, by reference)
- `<element-object-relevant-param-name>`: Parameter name as defined in object (no ampersand)
- `<element-object-relevant-param-type>`: Parameter type (UPPER CASE): `CHARACTER`, `NUMERIC`, `DATE`, `BOOLEAN`
- `<element-object-relevant-param-length/decimals/signed/isCollection>`: Type metadata
- `<element-object-relevant-value>`: Parameter value: constant, enum domain reference, variable, or transaction attribute

Sections:
| Section | Required |
|---|---|
| `#Diagram` | yes |
| `#Properties` | yes |
| `#Documentation` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: none
- Files:
  - `<name>.gx`

# CONSTRAINTS
Object-specific:
- `CON-BPD-001` Entry in JSON can be omitted when value is default
- `CON-BPD-002` Relevant-data parameter types must be UPPER CASE
- `CON-BPD-003` Relevant-data parameter names and accessors must not have ampersand
- `CON-BPD-004` Only create/update BusinessProcessDiagram objects unless other object types explicitly requested
- `CON-BPD-005` Check target module exists before creating object
- `CON-BPD-006` Verify all referenced objects exist (WebPanel, Procedure, Agent, Transaction)

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Space elements to avoid overlaps, using known element sizes (events 36x36, gateways 40x40, tasks 187x67)
- Prefer straight connectors, then L-shaped (one point), then U-shaped (two points); avoid more than two bends
- Never use the same port as both from and to simultaneously; avoid reusing a toPort as a fromPort in another connector
- Give gateways at least two outgoing connectors, one of which may be the Default fallback path
- Reuse relevant data across tasks; parameters must mirror each object's Parm rule
- Use ampersand prefix for relevant data in conditions, no prefix for transaction attributes

# REQUIRES
Load these language modules together with this reference:
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Minimal process diagram
Engine-confirmed canonical text form with an empty diagram definition (`EX-BPD-001`, validated in CI)
`src/SimpleProcess.gx`:
~~~
BPDiagram SimpleProcess
{
	#Diagram
		<Properties />
	#End

	#Properties
		Description = "Simple process diagram"
	#End
}
~~~

# RELATED OBJECTS
- [Transaction](./object-transaction.md)
- [Procedure](./object-procedure.md)
- [Agent](./object-agent.md)
- [Panel](./object-panel.md)
