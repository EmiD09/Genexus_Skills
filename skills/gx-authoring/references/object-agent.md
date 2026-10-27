<!-- GENERATED from catalog/objects/agent.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-agent
description: Generates content or infers information using natural language instructions and context
---

# AVAILABILITY
- ProductVersion: `>=19`

# DEFINITION
An `Agent` object (or assistant) is capable of generating content or inferring information based on
multiple inputs (features) and extra context.

The object body is a natural language prompt supporting:
- Variable interpolation: `{{&<variable-name>}}`
- Context placeholder: `$context` when a `Context` rule is defined
- Document references: `{{Document:<document-name>}}`
- File references: `{{File:<file-name>}}`

## PROMPT TEXT
Simple tasks use a short instruction:
`<action-verb> <task-description> using (<variables>|<context>), specifying <constraints>, optionally leveraging <tools> to produce <output>`

Complex tasks use structured sections:
- `ROLE`: Agent's role or perspective
- `TASK`: What agent must do with input
- `STEPS`: Ordered actions for multi-step tasks
- `GUIDE`: Limits, formats, guidelines to follow
- `OUTPUT`: Sample outputs illustrating expected result

## RULES
Business logic rules: `parm` (parameter signature), `context` (context source, e.g. a DataProvider call
whose result fills `$context`), `use` (external agents/tools declaration).

When the `use` rule declares tools, the prompt text must contain the corresponding tool instructions, e.g.:
`Use "ExternalAgent:com.globant.geai.cultural_explorer" to discover cultural attractions` paired with
`use(ExternalAgent:com.globant.geai.cultural_explorer, ExternalTool:com.globant.geai.travel_api_connector);`

Use when:
- AI-powered content generation from input variables (features)
- Question answering grounded on knowledge-base context (context rule with $context placeholder)
- Multi-step assistants leveraging external agents/tools (use rule)
- Prompts grounded on Document or File objects via {{Document:...}} / {{File:...}} references

# SYNTAX
~~~
Agent <name>
{
	<prompt>

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
~~~

Where:
- `<name>`: Object name using alphanumeric or underscore, starting with letter
- `<prompt>`: Natural language instructions with variable interpolation `{{&<variable-name>}}`,
  context placeholder `$context` (when Context rule defined), document references
  `{{Document:<document-name>}}`, and file references `{{File:<file-name>}}`
- `<rules>`: Business logic rules (parm, context, use)
- `<variables>`: Variable definitions with mandatory `DataType`
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation (external `.doc.md` artifact)

Sections:
| Section | Required |
|---|---|
| `#Rules` | yes |
| `#Variables` | yes |
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
- [properties-object-agent](./properties-object-agent.md) — Agent objects

# CONSTRAINTS
Object-specific:
- `CON-AGT-001` Variable interpolation uses {{&varname}} syntax
- `CON-AGT-002` Context rule requires $context placeholder in prompt text
- `CON-AGT-003` Use rule requires tool instructions in prompt text
- `CON-AGT-004` Never use reserved keywords for Agent names

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Use a short single instruction for simple tasks; use structured ROLE/TASK/STEPS/GUIDE/OUTPUT sections for complex tasks
- State fallback behavior in GUIDE (e.g., declare explicitly when context lacks enough information)

# REQUIRES
Load these language modules together with this reference:
- [lang-rules](./lang-rules.md)
- [lang-agent-invocation](./lang-agent-invocation.md)
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Simple Agent
Generates an attractive product description from product features via variable interpolation (`EX-AGT-001`, validated in CI)
`src/ProductDescriptionAgent.gx`:
~~~
Agent ProductDescriptionAgent
{
	Create an attractive and persuasive product description for online shoppers based on the product name {{&ProductName}} and its price {{&ProductPrice}}

	#Rules
		parm(in: &ProductName, in: &ProductPrice, out: &ProductDescription);
	#End

	#Variables
		ProductName [ DataType = 'Attribute:ProductName' ]
		ProductPrice [ DataType = 'Attribute:ProductPrice' ]
		ProductDescription [ DataType = 'LongVarChar(1K)' ]
		Pgmname [ DataType = 'Character(128)' ]
		Pgmdesc [ DataType = 'Character(256)' ]
	#End

	#Properties
	#End
}
~~~

## Example 2: Agent with Context
Answers user questions grounded on customer data injected through the context rule (`EX-AGT-002`, validated in CI)
`src/CustomerSupportAgent.gx`:
~~~
Agent CustomerSupportAgent
{
	TASK:
	Answer the user question {{&UserQuestion}} based on the customer information provided in $context

	GUIDE:
	Ensure the answer is clear, concise, and directly addresses the question
	If the context does not contain enough information, state that explicitly

	#Rules
		parm(in: &UserQuestion, out: &Answer);
		context(ActiveCustomers());
	#End

	#Variables
		UserQuestion [ DataType = 'VarChar(256)' ]
		Answer [ DataType = 'LongVarChar(2K)' ]
		Pgmname [ DataType = 'Character(128)' ]
		Pgmdesc [ DataType = 'Character(256)' ]
	#End

	#Properties
	#End
}
~~~

# RELATED OBJECTS
- [Procedure](./object-procedure.md)
- [DataProvider](./object-data-provider.md)
- [Document](./object-document.md)
- [File](./object-file.md)
