---
name: k2btrnform-pattern
description: K2BTools TrnForm pattern skill for generating the Transaction Web Form — attribute layout with columns, groups, level grids, required fields, and control types
---

<!-- K2BTools Skills · v0.2.0 (built 2026-09-24 · 94740895) -->

K2BTools specialized skill for applying the K2BTrnForm pattern to GeneXus Transactions, generating the Transaction's Web Form (plus the UI-related rules and events) with a designed attribute layout instead of the default one-attribute-per-row form

---

## GUIDELINE
Interprets user needs for Transaction form design, validates the TrnForm instance structure, ensures K2BTools conventions, and generates correct pattern instance XML

## Triggers
Use this skill for:
- Applying the K2BTrnForm pattern to a GeneXus Transaction
- Designing or restyling the **Web Form of a Transaction** (the insert/update/display form)
- Arranging attributes in columns, groups, tabs or collapsible sections inside a Transaction
- Marking attributes as Required / ReadOnly / hidden in the Transaction form
- Changing the control type of an attribute in the Transaction form (combo, suggest, dynamic combo)
- Designing the grid of a Transaction **level** (second-level lines)
- Adding form variables or an extensibility (dynamic) form to a Transaction

Do NOT use this skill for:
- The listing/detail interfaces around the entity (use **k2bentityservices-pattern**)
- The selection interface for a foreign key (use **k2bprompt-pattern**)
- Custom WebPanels or WebComponents (use **webpaneldesigner-k2btools**)
- The Transaction **structure** (attributes, levels, data types) — that is plain GeneXus work
- Transaction business logic (rules and events logic is not designed here)

## Responsibilities
- Generate valid K2BTrnForm pattern instance XML
- Keep the layout container nodes (`Columns`, `Column`, `Group`) correctly nested
- Match `<levelGrid Name="...">` to the Transaction's real level name
- Use the pattern's `NameId` / `ControlNameId` / `BasedOn` conventions (NOT the WebPanelDesigner ones)
- Never invent unsupported nodes or attributes — an unrecognized tag is silently dropped
- Apply the instance through the correct workflow (writing the `.gx` is not enough)

## Communication
- Professional, objective tone
- Reply in user message language
- Provide examples when clarifying conventions
- Warn when a change to the Transaction form would be overwritten by the pattern

## Dependencies
This skill requires:
- **nexa** skill for GeneXus object management and knowledge base operations
- A valid GeneXus Transaction must exist before applying this pattern

## Relationship with the other K2BTools skills
- **K2BEntityServices** generates the objects *around* the entity (WorkWith grid, EntityManager) and embeds the Transaction inside them. **K2BTrnForm** designs the Transaction form itself. They are complementary and are normally applied to the same Transaction.
- **K2BPrompt** generates the selection panel used to fill a foreign key *from* a Transaction form.
- **WebPanelDesigner** is a different mechanism with a different XML (`<WebForm>` / `InternalName`). Do not mix its tags with pattern instance tags.

---

# WORK ORDER — READ THE SKILL FIRST

This skill is the base and primary reference for the K2BTrnForm instance format. Follow this order of operations on every task:

1. **Read the skill before touching the KB.** It already defines the `.gx` envelope (`#Instance`, `#Properties`), the instance node structure, and the three application workflows (see **WORKFLOWS**). Do not rediscover these from existing instances.
2. **Decide the workflow before writing anything.** Default instance, default-then-customized, or modifying an existing one — they are not interchangeable, and picking wrong fails silently. Note that for this pattern a customized instance cannot be hand-written from scratch (see **WORKFLOWS**).
3. **Then explore the KB only for what the skill does NOT cover:**
   - the Transaction being designed: its attributes, its **level names**, which attributes are inferred or formulas, its domains,
   - the objects the instance references (Images, DataProviders used by control types, WebComponents used by `Additemcomponent`),
   - a property or node not contemplated in this skill (see **NODES NOT COVERED HERE**).
4. **Use existing instances to fill specific gaps, not as a template.** Reference them for a concrete missing detail — never to re-derive the format, and never to check whether "it's already done".

> The skill is the source of truth for the format. KB exploration is for the Transaction, the referenced objects, and uncovered edge cases only.

---

# WHAT THE PATTERN GENERATES

K2BTrnForm does **not** create a new panel. It writes, inside the Transaction itself:

- the **Web Form** part (the whole layout: sections, columns, groups, level grids),
- the **rules and events** related to the user interface (control types, load of dynamic combos, required fields).

Helper objects are generated under `src/<path>/<T>/K2BTrnForm<T>/` only when a control needs them — e.g. `<T>_LoadValues` for attributes rendered with a values/descriptions control.

Two consequences:

- **Never hand-edit the Transaction's Web Form part.** The pattern overwrites everything outside the "Data Area" the next time it is applied. Design the form in the TrnForm instance instead.
- Rules and events you add by hand must live **outside the pattern's code slots** (the `//+ Name` … `//-` blocks) or they are removed on the next apply.

---

# SYNTAX

> **Scope note — the instance XML alone does NOT modify the KB.** Writing the `.gx` file to disk is not enough to generate anything. The XML must be brought into the KB through an MCP task, and *how* you do that depends on whether the instance already exists and whether you want the default or a customized instance. Getting this wrong fails **silently**: the MCP tasks return `✓ success` without having changed a single object. See the **WORKFLOWS** section for the exact procedure per scenario.

## File Format
The pattern instance is stored as a `.gx` file named after the Transaction:

~~~
K2BTrnForm K2BTrnForm<TransactionName>
{
	#Instance
		<instance>
		  <TrnForm>
		    <!-- form definition XML -->
		  </TrnForm>
		</instance>
	#End

	#Properties
		Name = "K2BTrnForm<TransactionName>"

		IsDefault = "False"
	#End
}
~~~

## Root Structure

```xml
<instance>
  <TrnForm>
    <attributes NameId="SectionId"> ... </attributes>
    <levelGrid Name="LevelName" Description="Lines"> ... </levelGrid>
    <attributes NameId="FooterId"> ... </attributes>
  </TrnForm>
</instance>
```

**The root is `<TrnForm>` — there is NO `<transaction Transaction="...">` node here.** Unlike K2BEntityServices and K2BPrompt, the target Transaction is not named inside the XML: it is determined by the instance name (`K2BTrnForm<T>`) and by the folder the file lives in. This is the single most common mistake when writing a TrnForm instance from memory.

Children of `<TrnForm>` are rendered **in document order**, so an `<attributes>` section placed after a `<levelGrid>` renders below that grid (that is how a level total is shown under the lines).

---

# MAIN NODES

## `<attributes>` — Form section

A section of the form holding fields and layout containers. One instance can have several sections.

| Attribute | Description |
|---|---|
| `NameId` | (required) Unique id of the section within the instance |
| `DescriptionsLayout` | `"Top"` / `"Left"` — where the field label is placed |
| `ResponsiveSizes` | JSON with row/cell widths per screen size (see **RESPONSIVE SIZES**) |

Children: `<attribute>`, `<variable>`, `<Columns>`, `<Group>`, `<extensionForm>`.

## `<attribute>` — A Transaction attribute in the form

```xml
<attribute Attribute="CustomerFirstName" Description="First Name"
           Visible="True|False"
           Required="True|False"
           ReadOnly="True|False"
           Autolink="True|False"
           ElementRelativePosition="New row|New cell|Same cell"
           Class="ThemeClassName"
           LeftText="$"
           AutomaticSummaryPopOver="True|False" />
```

- `Attribute` — (required) the attribute name, plain (no `:Attribute` suffix).
- `Description=""` (empty) removes the label — used for images and photos.
- `Visible="False"` keeps the attribute in the form but hidden (typical for autonumbered keys).
- `Required="True"` generates the "required field" UI and rule.
- `ElementRelativePosition` controls the flow — see **ELEMENT RELATIVE POSITION**.
- An optional `<controlInfo>` child overrides the control type.

## `<variable>` — A form variable

```xml
<variable Name="Categories" BasedOn="CategoryCode" Description="Categories"
          Iscollection="True|False"
          ReadOnly="True|False"
          ElementRelativePosition="New cell">
  <controlInfo ... />
</variable>
```

- `BasedOn` takes a **plain** attribute or domain name (`CategoryCode`, or a qualified domain such as `K2BTools.Controls.DynamicForm.ExtFormType`). This is the pattern convention — do **not** use the WebPanelDesigner `Name:Attribute` form here.
- Variables are the way to render data that is not an attribute of the Transaction (multi-select lists, pickers). Loading and consuming them is done in the Transaction's events, outside the pattern slots.

## `<Columns>` / `<Column>` — Multi-column layout

```xml
<Columns ControlNameId="ColumnsMain" Class="TableFillContainer" ResponsiveSizes="...">
  <Column ResponsiveSizes="...">
    <attribute Attribute="CustomerFirstName" Required="True" />
  </Column>
  <Column>
    <attribute Attribute="CustomerLastName" Required="True" />
  </Column>
</Columns>
```

- `<Columns>` requires a unique `ControlNameId`; `<Column>` has no id (it takes `ResponsiveSizes` only).
- `Columns` can be nested inside a `Column`, and can contain `Group`.

## `<Group>` — Titled box

```xml
<Group ControlNameId="GroupContact" Title="Contact">
  <attribute Attribute="CustomerEMail" Required="True" />
  <attribute Attribute="CustomerPhoneNumber" Required="True" />
</Group>
```

A group draws a border and shows its `Title` on top. Use it to box semantically related fields that must stay open; use a LineSeparator when the section should be collapsible.

## `<levelGrid>` — Second-level (lines) grid

```xml
<levelGrid Name="InvoiceLine" Description="Details">
  <Attributes>
    <attribute Attribute="InvoiceLineId" Visible="False" />
    <attribute Attribute="ProductId" Description="Product" Visible="True">
      <controlInfo InputType="Descriptions" ItemValues="ProductId:Attribute"
                   Itemdescriptions="ProductDescription:Attribute" Suggest="Incremental" />
    </attribute>
    <attribute Attribute="InvoiceLineTotal" Description="Total" />
  </Attributes>
</levelGrid>
```

- `Name` **must match the Transaction's level name** exactly (the identifier of the level in the Transaction structure — `InvoiceLine`, `Detail`, …), not the level's description.
- `Description` is the caption shown for the grid.
- The child container is `<Attributes>` with a **capital A** — a different tag from the `<attributes>` form section. Inside it, the field tag is `<attribute>` (lowercase), as everywhere else.
- One `<levelGrid>` per level; they render in the order they appear.
- The IDE offers a "Change Grid Layout" action to switch a level between a normal grid and a FreeStyleGrid. If you need the FreeStyleGrid variant, apply it in the IDE and export the instance to learn the resulting XML.

## `<controlInfo>` — Control type override

Placed as a child of `<attribute>` or `<variable>`. Two verified shapes:

```xml
<!-- Dynamic combo fed by the extended table (attributes) -->
<attribute Attribute="BrandId" Description="Brand">
  <controlInfo Controltype="Dynamic Combo Box" DataSourceFrom="Attributes"
               Itemdescriptions="BrandName:Attribute" />
</attribute>

<!-- K2BTools dynamic combo fed by a DataProvider, with search, images and add-item -->
<attribute Attribute="CustomerId" Description="Customer">
  <controlInfo Controltype="Dynamic Combo Box K2BTools" DataSourceFrom="DataProvider"
               Datasource="CustomerByCountry"
               ItemValue="CustomerId" ItemDescription="CustomerName"
               ItemValues="CustomerId:Attribute" ItemImages="CustomerPhoto:Attribute"
               ItemDetails="CustomerNumber:Attribute"
               Includesearch="True" EnableAddItem="True" Additemcomponent="Customer" />
</attribute>
```

Notes on the property spelling (it is inconsistent by design — copy it exactly):
- `Itemdescriptions` (lowercase `d`, plural) takes attribute references in `Name:Attribute` form.
- `ItemDescription` (capital `D`, singular) takes a plain field name of the DataProvider's SDT.
- `ItemValues`, `ItemImages`, `ItemDetails` take `Name:Attribute` references.
- `EnableAddItem="True"` + `Additemcomponent="<Transaction>"` lets the user create the referenced record from the combo.
- Multi-select: `Iscollection="True"` on the field plus `ShowSelectionAsTags="True"` on the controlInfo.
- For a grid column that must accept typed descriptions: `InputType="Descriptions"` + `Suggest="Incremental"`.

An empty `<controlInfo />` resets the attribute to its default control.

K2BTools control types carry the `K2BTools` suffix (`Dynamic Combo Box K2BTools`, `Suggest K2BTools`, `Datepicker K2BTools`, `Masked Input K2BTools`); the names without the suffix are the plain GeneXus controls.

## `<extensionForm>` — Extensibility (dynamic) form

```xml
<extensionForm Name="Product" SerializeInAttribute="ProductExtraData:Attribute" />
```

Embeds a K2BTools Extensibility Form in the Transaction, serializing the user-defined fields into the given attribute. Requires the K2BTools Extensibility Forms module in the KB.

---

# ELEMENT RELATIVE POSITION

By default every field is generated in **a new row**. `ElementRelativePosition` changes that:

| Value | Effect |
|---|---|
| `"New row"` | (default) the field starts a new row |
| `"New cell"` | the field goes in the same row, in a new cell |
| `"Same cell"` | the field goes in the same cell as the previous one |

Cells in the same row share the width defined by the container's `ResponsiveSizes`; with no `ResponsiveSizes`, two cells split 50/50. Cells in consecutive rows are vertically aligned by default, which is what makes a two-column form read as an aligned grid of labels and fields.

Supported by `<attribute>`, `<variable>` and the other element nodes of a section — **not** by fields inside `<levelGrid>`, where the position is the column order.

---

# RESPONSIVE SIZES

`ResponsiveSizes` is a JSON string, XML-escaped, describing rows and cell widths per breakpoint. It is accepted by `<attributes>`, `<Columns>`, `<Column>` and `<Group>`.

```xml
<Column ResponsiveSizes="[{&quot;scale&quot;:&quot;sm&quot;,&quot;rows&quot;:[[{&quot;width&quot;:100}],[{&quot;width&quot;:50},{&quot;width&quot;:50}]]}]">
```

- `scale`: `xs`, `sm`, `md`, `lg` — the breakpoint the entry applies to.
- `rows`: one array per row; one object per cell, with `width` (percentage), optional `offset`, optional `label` (label width when `DescriptionsLayout="Left"`), optional `"visible":false` to hide a row at that size.
- Entries apply upwards: define `sm` and it also covers `md`/`lg` unless those are overridden.

Always escape the quotes as `&quot;` — a raw `"` breaks the attribute.

---

# NODES NOT COVERED HERE

The pattern also supports **Tabs / Tab**, **LineSeparator** (collapsible section) and **Actions** inside the form — the K2BTools documentation lists them as available wherever attributes can be placed. They do not appear in the reference KB instances, so their exact tag and property spelling is not verified here.

If you need one of them: add the node once **in the GeneXus IDE**, export the instance (`export_kb_to_text`), and read the resulting XML to learn the exact spelling before hand-writing more of it. Do **not** guess the tag — an unrecognized tag is silently dropped and its whole subtree is lost.

---

<!-- shared-blocks: workflow-a-apply workflow-c module-placement -->
# WORKFLOWS

The instance XML by itself does NOT modify the KB. Writing the `.gx` to disk generates nothing — the XML must be brought into the KB through an MCP task. **Using the wrong procedure usually fails silently: the tasks return `✓ success` without creating or changing a single object.** The one exception is hand-writing a brand-new instance for this pattern, which fails loudly — see the callout below.

> **K2BTrnForm differs from the other two patterns here.** In K2BEntityServices and K2BPrompt you can hand-write a brand-new instance and bring it into the KB together with the transaction in a single import. **That does not work for K2BTrnForm:** the import fails with `[ERROR] Parent must be a Transaction`. To get a customized form you must first create the default instance (Workflow A) and only then edit it (Workflow C). There is no "write it from scratch" path for this pattern.

Pick the workflow that matches your scenario:

| Scenario | Workflow |
|---|---|
| The instance does NOT exist, you want the default instance | Workflow A |
| The instance does NOT exist, you want a customized instance | Workflow A, **then** Workflow C |
| The instance already exists and you want to modify it | Workflow C |

> **If you are unsure whether the developer wants the default form or a customized one, ask.** Do not guess: applying the default silently discards any layout intent the developer had in mind, and it is the starting point you cannot skip if they do want a custom layout.

## Workflow A — Instance does not exist, you want the default

### When the developer wants the default instance

Interpret the request as "the default instance" when the developer:
- says they need to **apply the TrnForm to a Transaction** — e.g. *"I need to apply the TrnForm to this transaction"*, *"apply K2BTrnForm to Customer"*,
- says they need to **create the web form of the Transaction** — e.g. *"I need to create the web form for this transaction"*,
- explicitly asks for the default instance of the pattern for that Transaction.

These phrasings state *that* the form should exist, not *how it should look*. In these cases, do NOT hand-write instance XML — use the dedicated task below.

### How to apply it

<!-- shared:workflow-a-apply — mirrored in K2BEntityServices/K2BTrnForm/K2BPrompt — edit all three; scripts/validate-skills.sh fails if they drift -->
Use the dedicated task. It creates the instance, links it, applies it, and sets `ApplyTrnFormPatternOnSave = "True"` on the transaction — all in one call, without touching any source file:

```
apply_pattern_on_parent
  pattern: "K2BTrnForm"
  parentName: "T"
  parentType: "Transaction"
```

This is the recommended path for this scenario.

> **Do NOT write the instance XML in this workflow — it is ignored.** Placing the instance on disk (in `src/<path>/T/` or in `src/#patterns/`) before importing the transaction alone does NOT work: the engine writes its own default and ignores the file.
<!-- /shared:workflow-a-apply -->

### What the default generates

- One `<attributes>` section with the attributes of the first level, **each one in its own row** (no columns, no groups), keys hidden.
- One `<levelGrid>` per Transaction level, with that level's attributes as columns.
- The Transaction's Web Form part rewritten from that layout, plus the UI rules and events.

## Workflow B — Not available for K2BTrnForm: run Workflow A, then Workflow C

### When the developer wants a customized instance

Use this path whenever the developer conveys *how* the form should look — i.e. gives any intent about its shape beyond "apply the pattern". Examples:
- two columns, a photo on the left and the data on the right,
- fields boxed in groups ("Contact", "Occupation"), or split into tabs,
- specific attributes required, read-only, or hidden,
- a specific control type for an attribute (combo, suggest, multi-select),
- a specific column set or order for the lines grid.

As soon as the developer expresses intent about the form's shape, you need a customized instance. In K2BEntityServices and K2BPrompt that means hand-writing the instance and importing it together with the transaction — **for K2BTrnForm that path does not work**, so use the sequence below instead.

### How to apply it: Workflow A, then Workflow C

1. **Create the default instance** with Workflow A — `apply_pattern_on_parent` with `pattern: "K2BTrnForm"`. This is what actually creates the instance and links it to the transaction; it cannot be skipped.
2. **Export it** so you have it on disk:
   ```
   export_kb_to_text names: ["K2BTrnFormT"], rootDirectory: "<KB root>"
   ```
3. **Edit** `src/<path>/T/K2BTrnFormT.gx`, reshaping the default layout into the one the developer asked for (columns, groups, required fields, control types).
4. **Reimport the instance alone**:
   ```
   import_text_to_kb names: ["K2BTrnFormT"], rootDirectory: "<KB root>"
   ```

Steps 2–4 are exactly **Workflow C**. The only difference is that here you always start from the default the pattern has just generated, instead of from an instance someone designed earlier.

> **Do NOT write `src/<path>/T/K2BTrnFormT.gx` before the instance exists.** Importing the transaction and the instance together — `names: ["transaction:T", "K2BTrnFormT"]`, the recipe the other two patterns rely on — fails for K2BTrnForm with:
>
> ```
> [ERROR] Parent must be a Transaction
> ```
>
> Nothing is created. If you hit that error, you took the Workflow B path by mistake: switch to the A-then-C sequence above.

> Starting from the default is not a handicap: the generated instance already lists every attribute of every level with the correct names, so customizing it is mostly rearranging and annotating existing nodes rather than writing them from scratch.

## Workflow C — Instance already exists and you want to modify it

<!-- shared:workflow-c — mirrored in K2BEntityServices/K2BTrnForm/K2BPrompt — edit all three; scripts/validate-skills.sh fails if they drift -->
The standard edit-and-reimport cycle: export the instance (only if it isn't already on disk or has changed in the KB), edit its nodes, and reimport only what you touched.

1. **Export** the instance if needed — if the instance is not already on disk, or the KB copy changed, export it first:
   ```
   export_kb_to_text names: ["K2BTrnFormT"], rootDirectory: "<KB root>"
   ```
2. **Edit** the nodes in `src/<path>/T/K2BTrnFormT.gx`.
3. **Reimport only what you modified.** If you touched only the instance, import the instance alone — the transaction does NOT need to be reimported:
   ```
   import_text_to_kb names: ["K2BTrnFormT"], rootDirectory: "<KB root>"
   ```
   Reimport `transaction:T` as well only if you also changed the transaction. Because the instance already exists and is linked, importing it alone is enough to apply the changes. That link is exactly what a brand-new instance lacks — which is why bringing one into existence is a different procedure, not just another import.
<!-- /shared:workflow-c -->

## Adding attributes to the Transaction later

An attribute added to the Transaction after the pattern was applied does **not** appear in the form on its own — the instance decides what the form contains. Add the corresponding `<attribute>` node to the instance and reimport (Workflow C).

## Module Placement

<!-- shared:module-placement — mirrored in K2BEntityServices/K2BTrnForm/K2BPrompt — edit all three; scripts/validate-skills.sh fails if they drift -->
The transaction's module is determined by the directory where its `.gx` file lives during import. The instance folder mirrors the transaction's location:
- `src/<ModuleName>/T.gx` → transaction belongs to `<ModuleName>` module (requires `module.toml` in that directory); place the instance in `src/<ModuleName>/T/K2BTrnFormT.gx`
- `src/T.gx` → transaction belongs to the Root Module; place the instance in `src/T/K2BTrnFormT.gx`

Important:
- Only directories with `module.toml` are real GeneXus modules
- The `<TransactionName>/` folder that K2BTrnForm uses to group its instance and generated objects is NOT a module
- The `rootDirectory` parameter in export/import must always point to the KB root (parent of `src/`)
<!-- /shared:module-placement -->

---

# EXAMPLES

These are **target shapes**, not files to create from scratch: for this pattern you reach them by
editing the instance the default apply generated (see **WORKFLOWS**), not by writing a new `.gx`.

## Example 1: Minimal — plain list of fields
```xml
<instance>
  <TrnForm>
    <attributes NameId="Category">
      <attribute Attribute="CategoryCode" Autolink="False" />
      <attribute Attribute="CategoryName" Autolink="False" Required="True" />
      <attribute Attribute="CategoryImage" Autolink="False" />
    </attributes>
  </TrnForm>
</instance>
```

## Example 2: Two columns
```xml
<instance>
  <TrnForm>
    <attributes NameId="Country">
      <Columns ControlNameId="columns0">
        <Column>
          <attribute Attribute="CountryId" Description="Id" />
          <attribute Attribute="CountryName" Description="Name" Required="True" />
        </Column>
        <Column>
          <attribute Attribute="CountryFlag" Description="Flag" />
        </Column>
      </Columns>
    </attributes>
  </TrnForm>
</instance>
```

## Example 3: Photo + two data columns + groups
```xml
<instance>
  <TrnForm>
    <attributes NameId="Customer">
      <Columns ControlNameId="Columns1">
        <Column>
          <attribute Attribute="CustomerPhoto" Description="" />
        </Column>
      </Columns>
      <Columns ControlNameId="Columns" Class="TableFillContainer">
        <Column ResponsiveSizes="[{&quot;scale&quot;:&quot;sm&quot;,&quot;rows&quot;:[[{&quot;width&quot;:100}],[{&quot;width&quot;:50},{&quot;width&quot;:50}]]}]">
          <attribute Attribute="CustomerFirstName" Required="True" />
          <attribute Attribute="CustomerNumber" Required="True" />
          <attribute Attribute="CustomerBirthDay" ElementRelativePosition="New cell" />
        </Column>
        <Column>
          <attribute Attribute="CustomerLastName" Required="True" ElementRelativePosition="New cell" />
          <attribute Attribute="CustomerSex" ElementRelativePosition="New row" />
          <attribute Attribute="CityId" Description="City" />
          <attribute Attribute="CountryName" Description="Country" ElementRelativePosition="New cell" />
        </Column>
      </Columns>
      <Columns ControlNameId="Columns2">
        <Column>
          <Group ControlNameId="GroupOccupation" Title="Occupation">
            <attribute Attribute="CustomerOccupation" Required="True" />
            <attribute Attribute="CustomerWorkHours" />
          </Group>
        </Column>
        <Column>
          <Group ControlNameId="GroupContact" Title="Contact">
            <attribute Attribute="CustomerEMail" Required="True" />
            <attribute Attribute="CustomerPhoneNumber" Required="True" />
          </Group>
        </Column>
      </Columns>
    </attributes>
  </TrnForm>
</instance>
```

## Example 4: Two-level Transaction (header + lines + total)
```xml
<instance>
  <TrnForm>
    <attributes NameId="Invoice">
      <attribute Attribute="InvoiceCode" Required="True" />
      <attribute Attribute="CustomerId" Description="Customer">
        <controlInfo Controltype="Dynamic Combo Box K2BTools" DataSourceFrom="DataProvider"
                     Datasource="CustomerByCountry" ItemValue="CustomerId" ItemDescription="CustomerName"
                     ItemValues="CustomerId:Attribute" ItemImages="CustomerPhoto:Attribute"
                     ItemDetails="CustomerNumber:Attribute" Includesearch="True"
                     EnableAddItem="True" Additemcomponent="Customer" />
      </attribute>
      <attribute Attribute="InvoiceDate" />
      <attribute Attribute="CountryName" Description="Country" AutomaticSummaryPopOver="False" />
    </attributes>
    <levelGrid Name="InvoiceLine" Description="Details">
      <Attributes>
        <attribute Attribute="InvoiceLineId" Visible="False" />
        <attribute Attribute="ProductId" Description="Product" Visible="True">
          <controlInfo InputType="Descriptions" ItemValues="ProductId:Attribute"
                       Itemdescriptions="ProductDescription:Attribute" Suggest="Incremental" />
        </attribute>
        <attribute Attribute="ProductPrice" Description="Price" />
        <attribute Attribute="InvoiceProductQuantity" />
        <attribute Attribute="InvoiceLineTotal" Description="Total" />
      </Attributes>
    </levelGrid>
    <attributes NameId="InvoiceLineSummary">
      <attribute Attribute="InvoiceTotal" />
    </attributes>
  </TrnForm>
</instance>
```

## Example 5: Read-only form
```xml
<instance>
  <TrnForm>
    <attributes NameId="Payment">
      <attribute Attribute="CustomerName" ReadOnly="True" Autolink="False" />
      <attribute Attribute="PaymentTotalAmount" />
      <attribute Attribute="PaymentDate" ReadOnly="True" Autolink="False" />
      <attribute Attribute="PaymentMethod" ReadOnly="True" Autolink="False" Required="False" />
    </attributes>
    <levelGrid Name="Detail" Description="Detail">
      <Attributes>
        <attribute Attribute="InvoiceCode" ReadOnly="True" />
        <attribute Attribute="PaymentTotal" ReadOnly="True" />
        <attribute Attribute="InvoiceTotal" />
      </Attributes>
    </levelGrid>
  </TrnForm>
</instance>
```

## Example 6: Multi-select variables and an extensibility form
```xml
<instance>
  <TrnForm>
    <attributes NameId="Product" DescriptionsLayout="Top">
      <attribute Attribute="ProductId" Description="Id" Visible="False">
        <controlInfo />
      </attribute>
      <attribute Attribute="ProductDescription" />
      <attribute Attribute="ProductType" ElementRelativePosition="New cell" />
      <attribute Attribute="ProductPrice" Description="Price" LeftText="$" ElementRelativePosition="New cell" />
      <variable Name="Units" BasedOn="UnitId" Description="Units" Iscollection="True">
        <controlInfo Controltype="Suggest K2BTools" DataSourceFrom="DataProvider" Datasource="DPUnitsSuggest" />
      </variable>
      <variable Name="Categories" BasedOn="CategoryCode" Description="Categories" Iscollection="True"
                ElementRelativePosition="New cell">
        <controlInfo Controltype="Dynamic Combo Box K2BTools" DataSourceFrom="DataProvider"
                     Datasource="GetCategories" ItemDescription="CategoryName"
                     ShowSelectionAsTags="True" ItemImages="CategoryImage:Attribute" Includesearch="True" />
      </variable>
      <extensionForm Name="Product" SerializeInAttribute="ProductExtraData:Attribute" />
    </attributes>
  </TrnForm>
</instance>
```

---

# CONSTRAINTS
- The root node is `<TrnForm>`; there is NO `<transaction Transaction="...">` wrapper in this pattern
- The file must be named `K2BTrnForm<TransactionName>.gx` and its `#Properties` `Name` must match the object name in the header
- Every `<attributes>` section requires a unique `NameId`; every `<Columns>` and `<Group>` requires a unique `ControlNameId`
- `<levelGrid Name="...">` must match a real level name of the Transaction
- Inside `<levelGrid>` the container is `<Attributes>` (capital A); everywhere else the section is `<attributes>` (lowercase)
- `Attribute` and `BasedOn` take plain names; only reference-typed properties (`ItemValues`, `ItemImages`, `ItemDetails`, `Itemdescriptions`, `SerializeInAttribute`) use the `Name:Attribute` form
- `ResponsiveSizes` must be XML-escaped JSON (`&quot;`)
- Do NOT mix WebPanelDesigner tags/properties (`<WebForm>`, `InternalName`, `IncludeInGridKey`) into a pattern instance
- Do NOT hand-edit the Transaction's Web Form part — the pattern overwrites it
- Writing the instance `.gx` to disk does NOT modify the KB — always apply it through the correct **WORKFLOWS** procedure
- A brand-new instance canNOT be hand-written for this pattern: create the default first (Workflow A), then export, edit and reimport it (Workflow C)
- `ApplyTrnFormPatternOnSave = "True"` goes in the Transaction's `#Properties`, NOT in the instance `.gx`

---

# COMMON ERRORS

## Error 1: Wrapping the form in a `<transaction>` node
```xml
<!-- ❌ Incorrect (that is the K2BEntityServices / K2BPrompt shape) -->
<instance>
  <transaction Transaction="Customer">
    <TrnForm> ... </TrnForm>
  </transaction>
</instance>

<!-- ✅ Correct -->
<instance>
  <TrnForm> ... </TrnForm>
</instance>
```

## Error 2: `<attributes>` vs `<Attributes>`
```xml
<!-- ❌ Incorrect: lowercase inside a levelGrid -->
<levelGrid Name="InvoiceLine">
  <attributes>
    <attribute Attribute="InvoiceLineId" />
  </attributes>
</levelGrid>

<!-- ✅ Correct -->
<levelGrid Name="InvoiceLine">
  <Attributes>
    <attribute Attribute="InvoiceLineId" />
  </Attributes>
</levelGrid>
```

## Error 3: Using the level's description instead of its name
```xml
<!-- ❌ Incorrect: "Invoice Line" is the description -->
<levelGrid Name="Invoice Line" />

<!-- ✅ Correct: "InvoiceLine" is the level name in the Transaction structure -->
<levelGrid Name="InvoiceLine" Description="Invoice Line" />
```

## Error 4: WebPanelDesigner conventions leaking in
```xml
<!-- ❌ Incorrect -->
<variable InternalName="Categories" BasedOn="CategoryCode:Attribute" />

<!-- ✅ Correct -->
<variable Name="Categories" BasedOn="CategoryCode" />
```

## Error 5: Expecting `ElementRelativePosition` to work in a level grid
Inside `<levelGrid>` the fields are grid **columns**: their position is the order in which they are declared. `ElementRelativePosition` has no effect there — it belongs to `<attributes>` sections.

## Error 6: Designing the form by editing the Transaction
Editing the Transaction's Web Form part (or importing a Transaction `.gx` with a hand-made form) is lost the next time the pattern is applied: everything outside the "Data Area" is regenerated from the instance. Put the layout in the TrnForm instance.

## Error 7: `[ERROR] Parent must be a Transaction`

The import of a **brand-new, hand-written** instance fails with this message:

```
import_text_to_kb names: ["transaction:T", "K2BTrnFormT"]
[ERROR] Parent must be a Transaction
```

This is the Workflow B path, which the other two patterns support and K2BTrnForm does not. It is consistent with the shape of the format: a TrnForm instance has no `<transaction Transaction="...">` node, so a file that does not yet correspond to an instance in the KB has nothing identifying the transaction it belongs to.

Nothing is created when this happens. The fix is the A-then-C sequence: create the default instance with `apply_pattern_on_parent`, export it, edit it, reimport it alone. See **WORKFLOWS**.

## Error 8: Unescaped JSON in `ResponsiveSizes`
```xml
<!-- ❌ Incorrect: raw quotes terminate the attribute -->
<Column ResponsiveSizes="[{"scale":"sm"}]" />

<!-- ✅ Correct -->
<Column ResponsiveSizes="[{&quot;scale&quot;:&quot;sm&quot;}]" />
```
