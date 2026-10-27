---
name: k2bprompt-pattern
description: K2BTools Prompt pattern skill for generating selection interfaces (prompts) over a Transaction — the panel that lets the end user pick an instance to fill a foreign key, with filters, orders, return-on-click and insert-from-prompt
---

<!-- K2BTools Skills · v0.2.0 (built 2026-09-24 · 94740895) -->

K2BTools specialized skill for applying the K2BPrompt pattern to GeneXus Transactions, generating the selection panel (`Prompt<Transaction>`) that returns a chosen record to the caller

---

## GUIDELINE
Interprets user needs for selection interfaces, validates the Prompt instance structure, ensures K2BTools conventions, and generates correct pattern instance XML

## Triggers
Use this skill for:
- Applying the K2BPrompt pattern to a GeneXus Transaction
- Generating the **selection interface** used to fill a foreign key from another Transaction
- Choosing which attributes the prompt shows, and which one selects the row on click
- Adding filters or orders to a prompt
- Enabling record creation from inside the prompt (Insert) and its after-insert navigation
- Changing what the prompt returns to the caller (its output parameter)

Do NOT use this skill for:
- The CRUD interfaces of the entity (use **k2bentityservices-pattern**)
- The Transaction's own form (use **k2btrnform-pattern**)
- Custom WebPanels or WebComponents (use **webpaneldesigner-k2btools**)
- A listing that is browsed rather than selected from — that is a WorkWith, not a prompt

## Responsibilities
- Generate valid K2BPrompt pattern instance XML
- Keep the prompt's output parameter consistent with the attribute the prompt is attached to
- Ensure exactly one meaningful `ReturnOnClick="True"` attribute
- Validate filter and order structure
- Never invent unsupported nodes or attributes
- Apply the instance through the correct workflow (writing the `.gx` is not enough)

## Communication
- Professional, objective tone
- Reply in user message language
- Provide examples when clarifying conventions
- Warn when the prompt's parameter does not match the attribute being prompted

## Dependencies
This skill requires:
- **nexa** skill for GeneXus object management and knowledge base operations
- A valid GeneXus Transaction must exist before applying this pattern

## Relationship with the other K2BTools skills
- The prompt instance spec is **almost the same as the `<workWith>` node** of K2BEntityServices: attributes, filters and orders follow the same rules. For the full detail of filter types, order nodes and grid column properties, see `skills/K2BEntityServices.md` — this skill documents only what is specific to prompts.
- **K2BEntityServices** is what wires the prompt into the Transactions that reference the entity (it generates the `prompt(...)` rules).
- **K2BTrnForm** designs the form the prompt is invoked from.
- A prompt has **no EntityManager and no subWorkWith** — it is a single selection panel.

---

# WORK ORDER — READ THE SKILL FIRST

This skill is the base and primary reference for the K2BPrompt instance format. Follow this order of operations on every task:

1. **Read the skill before touching the KB.** It already defines the `.gx` envelope (`#Instance`, `#Properties`), the instance node structure, and the three application workflows (see **WORKFLOWS**). Do not rediscover these from existing instances.
2. **Decide the workflow before writing anything.** Default instance, hand-written custom instance, or modifying an existing one — they are not interchangeable, and picking wrong fails silently (see **WORKFLOWS**).
3. **Then explore the KB only for what the skill does NOT cover:**
   - the Transaction the prompt selects from: its primary key, its descriptor attribute, the attributes worth showing and filtering by,
   - **which attribute the caller actually prompts** (the `prompt(...)` rule in the calling Transaction) — this determines the output parameter,
   - a property or edge case not contemplated here (filter details live in `skills/K2BEntityServices.md`).
4. **Use existing instances to fill specific gaps, not as a template.** Reference them for a concrete missing detail — never to re-derive the format.

> The skill is the source of truth for the format. KB exploration is for the data model, the calling Transactions, and uncovered edge cases only.

---

# WHAT THE PATTERN GENERATES

Applying K2BPrompt to Transaction `T` generates a single WebPanel, `Prompt<T>` (the name is configurable), under `src/<path>/T/K2BPromptT/`:

```
WebPanel PromptCustomer
{
	#Rules
		parm(Out: &pCustomerId);
	#End
	...
}
```

- The panel shows a grid of the entity's records with the configured filters and orders.
- Clicking the attribute marked `ReturnOnClick="True"` closes the panel and returns the record.
- The `parm` rule is built from the `<parameters>` node — by default, the primary key as an **output** parameter.

## How the prompt gets wired to a Transaction

The K2BEntityServices pattern generates the `prompt(...)` rules in the Transactions that reference the entity, inside a code slot:

```
//+ K2BES.PromptRules.Fixed
[web]
{
prompt(PromptCustomer, CustomerId);
prompt(PromptProduct, ProductDescription);

}
//-
```

Consequences:

- **The prompt's output parameter must be the attribute being prompted.** `prompt(PromptProduct, ProductDescription)` only works because `K2BPromptProduct` declares `<parameter Name="ProductDescription" />`. If the caller prompts the descriptor attribute (typical when the key is autonumbered and the user types a description), the prompt must return that descriptor, not the key.
- If the calling Transaction is not managed by K2BEntityServices, add the `prompt()` rule yourself — outside the pattern's code slots, so it is not overwritten.

---

# SYNTAX

> **Scope note — the instance XML alone does NOT modify the KB.** Writing the `.gx` file to disk is not enough to generate any object. The XML must be brought into the KB through an MCP task, and *how* you do that depends on whether the instance already exists and whether you want the default or a customized instance. Getting this wrong fails **silently**: the MCP tasks return `✓ success` without having created a single object. See the **WORKFLOWS** section for the exact procedure per scenario.

## File Format

~~~
K2BPrompt K2BPrompt<TransactionName>
{
	#Instance
		<instance>
		  <transaction Transaction="<TransactionName>">
		    <prompt ...>
		      <!-- prompt definition XML -->
		    </prompt>
		  </transaction>
		</instance>
	#End

	#Properties
		Name = "K2BPrompt<TransactionName>"

		IsDefault = "False"
	#End
}
~~~

## Root Structure

```xml
<instance>
  <transaction Transaction="Customer">
    <prompt Title="Select Customer" FormCaption="Select Customer">
      <modes ... />
      <parameters> ... </parameters>
      <attributes> ... </attributes>
      <filter> ... </filter>
      <orders> ... </orders>
    </prompt>
  </transaction>
</instance>
```

Unlike K2BTrnForm, the Transaction **is** named here, in the `<transaction Transaction="...">` node — same as K2BEntityServices.

---

# MAIN NODES

## `<prompt>` — The selection panel

| Attribute | Description |
|---|---|
| `ObjectName` | Generated WebPanel name (optional; defaults to `Prompt<TrnName>` per K2BPrompt Settings) |
| `Title` | Title shown at the top of the prompt |
| `FormCaption` | Browser tab title |
| `IsMain` | `"True"` / `"False"` — whether the generated panel is a main object. Its default comes from K2BPrompt Settings |

Child nodes, in this order: `<modes>`, `<parameters>`, `<attributes>`, `<filter>`, `<orders>`.

## `<modes>` — Standard actions

In a prompt, **only the Insert action exists** — there is no update, delete, export or report.

```xml
<modes Insertenabled="True|False" AfterInsert="ReturnToTransaction|ReturnToPrompt" />
```

| Property | Description |
|---|---|
| `Insertenabled` | Whether the user can create a new record from the prompt. Default comes from K2BPrompt Settings |
| `AfterInsert` | What happens after the new record is confirmed (only meaningful with `Insertenabled="True"`) |

`AfterInsert` values:
- `"ReturnToTransaction"` — the prompt closes and the newly inserted record is returned to the caller. Use it for the common "the record didn't exist, create it and pick it" flow.
- `"ReturnToPrompt"` — the prompt stays open. If the Transaction's descriptor attribute is present as a filter, that filter is initialized with the new record's value, so the user sees it immediately. Use it when the user may create several records in a row, or must confirm the choice.

An insert **condition** (evaluated at runtime to show or hide the Insert action) also exists on this node. Note that such conditions are a usability aid, not a security mechanism — a user reaching the Transaction directly is not stopped by them; use the K2BTools security model for that. If you need the condition, set it once in the IDE and export the instance to learn its exact XML property name rather than guessing it.

## `<parameters>` — What the prompt returns

```xml
<parameters>
  <parameter Name="CustomerId" />
</parameters>
```

- Each `<parameter Name="...">` names an attribute; these become the `parm` rule of the generated panel.
- By default the pattern generates the **primary key as an output parameter**.
- Input parameters are also supported (to open the prompt pre-filtered by a context value). Their XML spelling is not verified here — add one in the IDE and export the instance before hand-writing it.
- **This node must agree with the caller.** See *How the prompt gets wired to a Transaction* above.

## `<attributes>` — Grid columns

```xml
<attributes>
  <attribute Attribute="CustomerId" Description="Id" Visible="True" Autolink="True" ReturnOnClick="False" />
  <attribute Attribute="CustomerName" ReturnOnClick="True" />
  <attribute Attribute="CustomerNumber" Description="DNI" Visible="True" Autolink="True" ReturnOnClick="False" />
</attributes>
```

Same column properties as a K2BEntityServices `<workWith>` (`Visible`, `Description`, `Autolink`, `HorizontalAlignment`, `ShowInExtraSmall`, …) plus the prompt-specific one:

| Property | Description |
|---|---|
| `ReturnOnClick` | `"True"` makes clicking that column select the row and return it to the caller |

Rules:
- **Exactly one column should carry `ReturnOnClick="True"`** — the one the user reads to identify the record. By default the pattern puts it on the descriptor attribute.
- Set `ReturnOnClick="False"` explicitly on the other columns; a grid where every column returns is confusing and makes the row impossible to inspect.
- Paging and column properties can be declared on the `<attributes>` node itself (`RowsPerPage`, `PageOptions`, …) exactly as in a WorkWith.

## `<filter>` and `<orders>`

Identical in structure and semantics to the WorkWith nodes of K2BEntityServices:

```xml
<filter>
  <filterAttribute NameId="CustomerFirstName" BasedOn="CustomerFirstName" Description="First Name" FilterType="Standard" />
  <filterAttribute NameId="CityName" BasedOn="CityName" Description="City" />
</filter>
<orders>
  <simpleOrder Attribute="CustomerId" Direction="Ascending" AscendingCaption="Id" />
</orders>
```

For the full reference — generic filter, `DateRange`, `NumericRange`, `StringSearch`, multiple/collection filters with `<controlInfo>`, advanced filters, complex orders — see the **`<filter>`** and **`<orders>`** sections of `skills/K2BEntityServices.md`. The same `NameId` uniqueness rule applies.

Prompt-specific guidance:
- Filter by what the user actually knows when searching (name, code, document number), not by the surrogate key.
- If `AfterInsert="ReturnToPrompt"` is used, include the descriptor attribute as a filter — that is what the pattern initializes with the newly created record.

---

<!-- shared-blocks: workflow-intro workflow-a-apply workflow-b-apply workflow-c module-placement -->
# WORKFLOWS

<!-- shared:workflow-intro — mirrored in K2BEntityServices/K2BTrnForm/K2BPrompt — edit all three; scripts/validate-skills.sh fails if they drift -->
The instance XML by itself does NOT modify the KB. Writing the `.gx` to disk generates nothing — the XML must be brought into the KB through an MCP task. **This step fails silently: the tasks return `✓ success` without creating or changing a single object when the wrong procedure is used.** How to apply the instance depends on whether it already exists and whether you want the default instance or a customized one.

Pick the workflow that matches your scenario:

| Scenario | Workflow |
|---|---|
| The instance does NOT exist, you want the default instance | Workflow A |
| The instance does NOT exist, you want a customized instance | Workflow B |
| The instance already exists and you want to modify it | Workflow C |

> **If you are unsure whether the developer wants Workflow A or Workflow B, ask.** Pose the question clearly: do they want the **default instance** of the pattern, or a **customized instance** they describe themselves? Do not guess — the two workflows produce very different results.
<!-- /shared:workflow-intro -->

## Workflow A — Instance does not exist, you want the default

### When the developer wants the default instance

Interpret the request as "the default instance" when the developer:
- says they need to **apply the prompt to a Transaction** — e.g. *"I need to apply the prompt to this transaction"*, *"apply K2BPrompt to Customer"*,
- says they need to **create the prompt interface associated with a Transaction** — e.g. *"I need to create the prompt interface for this transaction"*,
- explicitly asks for the default instance of the pattern for that Transaction.

These phrasings state *that* the prompt should exist, not *how it should look*. In these cases, do NOT hand-write instance XML — use the dedicated task below.

### How to apply it

<!-- shared:workflow-a-apply — mirrored in K2BEntityServices/K2BTrnForm/K2BPrompt — edit all three; scripts/validate-skills.sh fails if they drift -->
Use the dedicated task. It creates the instance, links it, applies it, and sets `ApplyPromptPatternOnSave = "True"` on the transaction — all in one call, without touching any source file:

```
apply_pattern_on_parent
  pattern: "K2BPrompt"
  parentName: "T"
  parentType: "Transaction"
```

This is the recommended path for this scenario.

> **Do NOT write the instance XML in this workflow — it is ignored.** Placing the instance on disk (in `src/<path>/T/` or in `src/#patterns/`) before importing the transaction alone does NOT work: the engine writes its own default and ignores the file.
<!-- /shared:workflow-a-apply -->

### What the default generates

- The `Prompt<T>` WebPanel, with the entity's attributes as grid columns (keys hidden), the **descriptor attribute carrying `ReturnOnClick="True"`**, a filter by the descriptor, and an order by the primary key.
- `<parameters>` with the **primary key as output parameter**.
- Insert enabled or not, and the after-insert navigation, according to K2BPrompt Settings.

## Workflow B — Instance does not exist, you want a customized one

### When the developer wants a customized instance

Use this workflow whenever the developer conveys *how* the prompt should behave or look:
- which columns to show, or which column selects the row,
- what the prompt must return (e.g. the description instead of the key),
- specific filters or orders,
- whether the user may create a record from the prompt, and where to go afterwards,
- a specific panel name or title.

As soon as the developer expresses intent about the prompt's shape, use Workflow B — not Workflow A.

### How to apply it

<!-- shared:workflow-b-apply — mirrored in K2BEntityServices/K2BTrnForm/K2BPrompt — edit all three; scripts/validate-skills.sh fails if they drift -->
`<path>` below is the module folder where the transaction lives (see **Module Placement**).

1. Create the folder `src/<path>/T/`.
2. Write `src/<path>/T/K2BPromptT.gx` with the nodes you want — and only those.
3. Set `ApplyPromptPatternOnSave = "True"` in the transaction source `src/<path>/T.gx` (in the transaction's `#Properties` section).
4. Run a **single import with both names together**, using `rootDirectory` pointing to the KB root:
   ```
   import_text_to_kb names: ["transaction:T", "K2BPromptT"], rootDirectory: "<KB root>"
   ```

### The critical point: both names in the same `names`

Passing both names in the same `names` array is what makes the hand-written instance take effect:

| `names` | Result |
|---|---|
| `["transaction:T", "K2BPromptT"]` | ✅ the hand-written instance is respected |
| `["transaction:T"]` alone | ❌ writes the default, ignores the file on disk |
| `["K2BPromptT"]` alone | ❌ silent no-op: the import creates no objects |
<!-- /shared:workflow-b-apply -->

## Workflow C — Instance already exists and you want to modify it

<!-- shared:workflow-c — mirrored in K2BEntityServices/K2BTrnForm/K2BPrompt — edit all three; scripts/validate-skills.sh fails if they drift -->
The standard edit-and-reimport cycle: export the instance (only if it isn't already on disk or has changed in the KB), edit its nodes, and reimport only what you touched.

1. **Export** the instance if needed — if the instance is not already on disk, or the KB copy changed, export it first:
   ```
   export_kb_to_text names: ["K2BPromptT"], rootDirectory: "<KB root>"
   ```
2. **Edit** the nodes in `src/<path>/T/K2BPromptT.gx`.
3. **Reimport only what you modified.** If you touched only the instance, import the instance alone — the transaction does NOT need to be reimported:
   ```
   import_text_to_kb names: ["K2BPromptT"], rootDirectory: "<KB root>"
   ```
   Reimport `transaction:T` as well only if you also changed the transaction. Because the instance already exists and is linked, importing it alone is enough to apply the changes. That link is exactly what a brand-new instance lacks — which is why bringing one into existence is a different procedure, not just another import.
<!-- /shared:workflow-c -->

## Changing what the prompt returns

Changing `<parameters>` changes the generated `parm` rule, so every caller that prompts this entity must still match. If the calling Transactions are managed by K2BEntityServices, reapply that pattern on them so their `prompt(...)` rules are regenerated; otherwise fix the rules by hand.

## Module Placement

<!-- shared:module-placement — mirrored in K2BEntityServices/K2BTrnForm/K2BPrompt — edit all three; scripts/validate-skills.sh fails if they drift -->
The transaction's module is determined by the directory where its `.gx` file lives during import. The instance folder mirrors the transaction's location:
- `src/<ModuleName>/T.gx` → transaction belongs to `<ModuleName>` module (requires `module.toml` in that directory); place the instance in `src/<ModuleName>/T/K2BPromptT.gx`
- `src/T.gx` → transaction belongs to the Root Module; place the instance in `src/T/K2BPromptT.gx`

Important:
- Only directories with `module.toml` are real GeneXus modules
- The `<TransactionName>/` folder that K2BPrompt uses to group its instance and generated objects is NOT a module
- The `rootDirectory` parameter in export/import must always point to the KB root (parent of `src/`)
<!-- /shared:module-placement -->

---

# EXAMPLES

## Example 1: Prompt returning the primary key
```xml
<instance>
  <transaction Transaction="Customer">
    <prompt Title="Select Customer" FormCaption="Select Customer">
      <modes Insertenabled="True" />
      <parameters>
        <parameter Name="CustomerId" />
      </parameters>
      <attributes>
        <attribute Attribute="CustomerId" Description="Id" Visible="True" Autolink="True" ReturnOnClick="False" />
        <attribute Attribute="CustomerName" ReturnOnClick="True" />
        <attribute Attribute="CustomerNumber" Description="DNI" Visible="True" Autolink="True" ReturnOnClick="False" />
        <attribute Attribute="CustomerPrefix" Description="Prefix" Visible="True" Autolink="True" ReturnOnClick="False" />
      </attributes>
      <filter>
        <filterAttribute NameId="CustomerFirstName" BasedOn="CustomerFirstName" Description="First Name" FilterType="Standard" />
        <filterAttribute NameId="CityName" BasedOn="CityName" Description="City" />
      </filter>
      <orders>
        <simpleOrder Attribute="CustomerId" Direction="Ascending" AscendingCaption="Id" />
      </orders>
    </prompt>
  </transaction>
</instance>
```

Caller rule: `prompt(PromptCustomer, CustomerId);`

## Example 2: Prompt returning the descriptor, staying open after insert
```xml
<instance>
  <transaction Transaction="Product">
    <prompt Title="Select Product" FormCaption="Select Product">
      <modes Insertenabled="True" AfterInsert="ReturnToPrompt" />
      <parameters>
        <parameter Name="ProductDescription" />
      </parameters>
      <attributes>
        <attribute Attribute="ProductId" Description="Id" Visible="True" Autolink="True" ReturnOnClick="False" />
        <attribute Attribute="ProductDescription" Description="Description" Visible="True" Autolink="True" ReturnOnClick="True" />
        <attribute Attribute="ProductPrice" Description="Price" Visible="True" Autolink="True" ReturnOnClick="False" />
      </attributes>
      <filter>
        <filterAttribute NameId="ProductDescription" BasedOn="ProductDescription" Description="Description" />
      </filter>
      <orders>
        <simpleOrder Attribute="ProductId" Direction="Ascending" AscendingCaption="Id" />
      </orders>
    </prompt>
  </transaction>
</instance>
```

Caller rule: `prompt(PromptProduct, ProductDescription);` — the prompt returns the description because that is the attribute the user types in the invoice line. The descriptor is also a filter, so `ReturnToPrompt` can initialize it with a freshly created product.

## Example 3: Read-only prompt (no creation from the prompt)
```xml
<instance>
  <transaction Transaction="Country">
    <prompt ObjectName="SelectCountry" Title="Select Country" FormCaption="Select Country">
      <modes Insertenabled="False" />
      <parameters>
        <parameter Name="CountryId" />
      </parameters>
      <attributes>
        <attribute Attribute="CountryId" Description="Id" Visible="False" ReturnOnClick="False" />
        <attribute Attribute="CountryName" Description="Name" Visible="True" ReturnOnClick="True" />
      </attributes>
      <filter>
        <filterAttribute NameId="CountryName_Flt" BasedOn="CountryName" />
      </filter>
      <orders>
        <simpleOrder Attribute="CountryName" Direction="Ascending" />
      </orders>
    </prompt>
  </transaction>
</instance>
```

---

# CONSTRAINTS
- The `Transaction` attribute must reference an existing GeneXus Transaction
- One `<prompt>` node per transaction node; a prompt has no `<entityManager>`, no `<subWorkWith>`, no `<layoutContent>`-based alternate views
- `<modes>` in a prompt only supports the Insert action (`Insertenabled`, `AfterInsert`, insert condition) — Update/Delete/Export/Report properties do not belong here
- Exactly one `<attribute>` should have `ReturnOnClick="True"`
- `<parameters>` must match the attribute the caller prompts, or the `prompt(...)` rule will not compile
- Filter `NameId` values must be unique within the instance
- The file must be named `K2BPrompt<TransactionName>.gx`, and its `#Properties` `Name` must match the object name in the header
- Do NOT mix WebPanelDesigner formdesigner XML (`<WebForm>`, `InternalName`) with pattern instance XML
- Writing the instance `.gx` to disk does NOT modify the KB — always apply it through the correct **WORKFLOWS** procedure
- To respect a hand-written custom instance, import BOTH the Transaction and the instance in the same `names` array
- `ApplyPromptPatternOnSave = "True"` goes in the Transaction's `#Properties`, NOT in the instance `.gx`

---

# COMMON ERRORS

## Error 1: Output parameter that does not match the caller
```xml
<!-- Caller: prompt(PromptProduct, ProductDescription); -->

<!-- ❌ Incorrect: the prompt returns the key, the caller prompts the description -->
<parameters>
  <parameter Name="ProductId" />
</parameters>

<!-- ✅ Correct -->
<parameters>
  <parameter Name="ProductDescription" />
</parameters>
```

## Error 2: No column returns the row
```xml
<!-- ❌ Incorrect: nothing selects the record — the prompt is a dead end -->
<attributes>
  <attribute Attribute="CustomerId" ReturnOnClick="False" />
  <attribute Attribute="CustomerName" ReturnOnClick="False" />
</attributes>

<!-- ✅ Correct -->
<attributes>
  <attribute Attribute="CustomerId" ReturnOnClick="False" />
  <attribute Attribute="CustomerName" ReturnOnClick="True" />
</attributes>
```

## Error 3: Using WorkWith standard actions in a prompt
```xml
<!-- ❌ Incorrect: a prompt has no update/delete/export -->
<modes Insertenabled="True" Updateenabled="True" Deleteenabled="True" Exportenabled="True" />

<!-- ✅ Correct -->
<modes Insertenabled="True" AfterInsert="ReturnToTransaction" />
```

## Error 4: `AfterInsert="ReturnToPrompt"` without the descriptor as a filter
`ReturnToPrompt` initializes the descriptor filter with the newly created record so the user can see and select it. Without that filter the user lands on an unfiltered grid and has to search for what they just created. Add the descriptor as a `<filterAttribute>`, or use `ReturnToTransaction`.

## Error 5: Building the prompt as a WebPanel by hand
A hand-written selection panel loses the pattern's filters, paging, security integration and the automatic `prompt(...)` wiring generated by K2BEntityServices. When the KB has K2BTools, generate prompts with this pattern.

## Error 6: Confusing a prompt with a WorkWith
If the user needs to browse, edit and delete records, that is a WorkWith (**k2bentityservices-pattern**). A prompt is only for picking one record and returning it to a caller.
