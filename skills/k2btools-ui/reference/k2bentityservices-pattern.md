---
name: k2bentityservices-pattern
description: K2BTools Entity Services pattern skill for generating CRUD applications with WorkWith grids, EntityManager detail views, filters, orders, and actions
---

<!-- K2BTools Skills · v0.2.0 (built 2026-09-24 · 94740895) -->

K2BTools specialized skill for applying the K2BEntityServices pattern to GeneXus transactions, generating complete CRUD interfaces with listing grids, entity detail views, filters, ordering, and custom actions

---

## GUIDELINE
Interprets user needs for CRUD application generation using K2BEntityServices pattern, validates pattern instance structure, ensures K2BTools conventions, and generates correct pattern XML

## Triggers
Use this skill for:
- Applying the K2BEntityServices pattern to a GeneXus Transaction
- Generating WorkWith (listing/grid) views for entities
- Generating EntityManager (detail/edit) views for entities
- Adding filters, orders, or actions to a WorkWith
- Configuring subWorkWith (related entity grids inside EntityManager)
- Setting up LayoutContent (card-based views) in WorkWith
- Configuring Kanban views
- Setting up edit modes (Standard, PopUp, Inline, Master Detail)

Do NOT use this skill for:
- Custom WebPanel design (use **webpaneldesigner-k2btools** skill instead)
- WebComponent design without pattern context
- Non-K2BTools pattern instances
- Backend logic (Procedures, DataProviders)
- Transaction structure design

## Responsibilities
- Generate valid K2BEntityServices pattern instance XML
- Ensure all required nodes are present for the chosen configuration
- Apply correct attribute conventions (primary key hidden, IncludeInGridKey not used here)
- Select appropriate EditMode for the use case
- Validate filter, order, and action structure
- Never invent unsupported nodes or attributes

## Communication
- Professional, objective tone
- Reply in user message language
- Provide examples when clarifying conventions
- Warn about EditMode implications

## Dependencies
This skill requires:
- **nexa** skill for GeneXus object management and knowledge base operations
- A valid GeneXus Transaction must exist before applying this pattern

## Relationship with the other K2BTools skills
- **K2BEntityServices** is for standard CRUD interfaces: list + detail + edit for a Transaction
- **WebPanelDesigner** (`skills/WebPanelDesigner.md`) is for custom, more complex interfaces that don't follow the CRUD pattern
- Both can coexist on the same Transaction (different use cases)
- K2BEntityServices generates objects automatically; WebPanelDesigner requires manual design
- **K2BMenu** (`skills/K2BMenu.md`) decides which screens the user can reach. The WorkWith this pattern generates is a menu-option candidate — see **AFTER GENERATING: PUT THE WORKWITH IN THE MENU**

---

# WORK ORDER — READ THE SKILL FIRST

This skill is the base and primary reference for the K2BEntityServices instance format. Follow this order of operations on every task:

1. **Read the skill before touching the KB.** It already defines the `.gx` envelope (`#Instance`, `#Properties`), the instance node structure, and the three application workflows (see **WORKFLOWS**). Do not rediscover these from existing instances.
2. **Decide the workflow before writing anything.** Default instance, hand-written custom instance, or modifying an existing one — they are not interchangeable, and picking wrong fails silently (see **WORKFLOWS**).
3. **Then explore the KB only for what the skill does NOT cover:**
   - the data model the instance covers (the Transaction, its attributes, its related transactions, descriptor and summary attributes),
   - the objects the instance references (WebComponents, Procedures used by actions, Images, Query objects, DynamicLayout definitions),
   - a property or edge case not contemplated in the skill's examples.
4. **Use existing instances to fill specific gaps, not as a template.** Reference them for a concrete missing detail — never to re-derive the format, and never to check whether "it's already done".

> The skill is the source of truth for the format. KB exploration is for the data model, the referenced objects, and uncovered edge cases only.

---

# SYNTAX

> **Scope note — the instance XML alone does NOT modify the KB.** Writing the `.gx` file to disk is not enough to generate any object. The XML must be brought into the KB through an MCP task, and *how* you do that depends on whether the instance already exists and whether you want the default or a customized instance. Getting this wrong fails **silently**: the MCP tasks return `✓ success` without having created a single object. See the **WORKFLOWS** section for the exact procedure per scenario.

## File Format
The pattern instance is stored as a `.gx` file with the following structure:

~~~
K2BEntityServices K2BEntityServices<TransactionName>
{
	#Instance
		<instance>
		  <!-- pattern definition XML -->
		</instance>
	#End

	#Properties
		Name = "K2BEntityServices<TransactionName>"

		IsDefault = "False"
	#End
}
~~~

## Root Structure
The `<instance>` element contains one `<transaction>` node per target Transaction:

```xml
<instance EntityImage="imageObjectName">
  <transaction Transaction="TransactionName" ...>
    <entitySummary ... />
    <workWith ...> ... </workWith>
    <entityManager ...> ... </entityManager>
  </transaction>
</instance>
```

A transaction can have multiple `<workWith>` and multiple `<entityManager>` nodes, each generating a different view.

---

# MAIN NODES

## `<transaction>` — Root entity reference

| Attribute | Description |
|---|---|
| `Transaction` | (required) Name of the GeneXus Transaction |
| `UpdateTransaction` | Update strategy. Value: `"Apply ES Style"` to use pattern's own form |
| `AfterInsertMessage` | GeneXus expression for message after insert |
| `AfterUpdateMessage` | GeneXus expression for message after update |
| `AfterDeleteMessage` | GeneXus expression for message after delete |
| `AllowEventSubscription` | `"True"` / `"False"` — K2BTools notification subscriptions. Only used when the K2BTools Notifications and Collaboration module is enabled. |
| `AllowUserComments` | `"True"` / `"False"` — K2BTools comments system. Only used when the K2BTools Notifications and Collaboration module is enabled. |

## `<entitySummary>` — Optional summary panel
```xml
<entitySummary SummaryPanel="WebComponentName" />
```

---

## `<workWith>` — Listing/Grid View

Generates a grid-based listing panel for the entity. Allows viewing all instances, filtering, ordering, and performing actions (Insert, Update, Delete, Display, Export, Report).

| Attribute | Description |
|---|---|
| `ObjectName` | Generated WebPanel name (optional, auto-generated if omitted) |
| `Title` | Grid title displayed at the top of the interface |
| `FormCaption` | Browser tab title (static value) |
| `EditMode` | `"Standard"`, `"PopUp"`, `"Inline"`, `"Master Detail"` |
| `NoResultsLabel` | Text shown when grid is empty |
| `GenerateGridSettings` | `"True"` / `"False"` — include grid settings menu |
| `AllowGridViewPersistence` | `"True"` / `"False"` |
| `MasterPage` | MasterPage object for the generated panel |
| `IncludeInMenu` | `"True"` / `"False"` — whether this WorkWith belongs in the application menu. Defaults to `"True"` and is written only when it differs, so an absent property means yes. Set it to `"False"` when the developer says this listing should stay out of the menu |

### `<modes>` — Standard Actions configuration

Controls which CRUD actions are available and their behavior:

```xml
<modes
  Insertenabled="True|False"
  Updateenabled="True|False"
  Deleteenabled="True|False"
  Afterinsertnavigation="EntityManager|Return to Caller|None"
  Afterupdatenavigation="EntityManager|Return to Caller|None"
  Afterdeletenavigation="None"
  MultipleDelete="True|False"
  Exportenabled="True|False"
  Reportenabled="True|False"
  DisplayStandaloneAction="True|False"
  DisplayDescriptionAttribute="True|False"
  UsePopUpInDisplayMode="True|False"
  Reportlayout="ReportLayoutName"
/>
```

Standard actions generated by default: Insert, Update, Delete, Display, Export to Excel, PDF Report, Export to CSV, Import from CSV. Each can be enabled/disabled and have runtime conditions.

### `<attributes>` — Grid columns
```xml
<attributes RowsPerPage="10" PageOptions="5,10,20,50,100" AllowRuntimeColumnReorder="Yes" FreezeColumnTitles="Always" PagingMode="InfiniteScrolling">
  <attribute Attribute="AttrName" Description="Label" Visible="True|False" Autolink="True|False"
             HorizontalAlignment="Right|Left|Center"
             UseinCSVImportExport="True|False"
             AllowRuntimeColumnSelection="True|False"
             ShowInExtraSmall="True|False"
             AutoResize="True|False"
             AutomaticSummaryPopOver="True|False" />
</attributes>
```

Rules:
- Primary key attribute should have `Visible="False"` 
- At least one visible attribute should have `Autolink="True"` for navigation
- `ShowInExtraSmall="True"` marks columns visible on mobile

### `<filter>` — Filter definitions

Filters can be "detailed" (specific field filters) or "generic" (search across multiple fields). Both can coexist.

```xml
<filter IncludeGenericFilter="True|False"
        GenericFilterConditionAttributes="Attr1,Attr2,Attr3"
        GenericFilterInviteMessage="Search...">
  <filterAttribute NameId="UniqueFilterId" BasedOn="AttributeName" 
                   Description="Label"
                   FilterType="Standard|DateRange|NumericRange|StringSearch"
                   All="True|False"
                   DisplayIn="Column|DetailedFiltersSection" />
</filter>
```

**Generic Filter:** When `IncludeGenericFilter="True"`, a single search box searches across all attributes listed in `GenericFilterConditionAttributes`. Layout must support it. To disable the generic filter, set `IncludeGenericFilter="False"` on the `<filter>` node.

**Detailed Filters:** Individual filter controls per attribute, defined as `<filterAttribute>` children.

#### Filter types and specific attributes:

**DateRange:**
```xml
<filterAttribute NameId="DateFlt" BasedOn="InvoiceDate" FilterType="DateRange"
                 DateRangeType="Semantic|Manual"
                 IncludeManualOption="True|False"
                 DateRangeEmptyItem="True|False"
                 ManualInputType="TwoFields"
                 SemanticDateRangeSet="{&quot;defaultSetName&quot;:&quot;DaysPeriodsBackwards&quot;}" />
```

**Multiple (collection-based):**

To filter by multiple values, set `Iscollection="True"` on the filterAttribute and add a child `<controlInfo>` with a control type that supports multi-selection:
```xml
<filterAttribute NameId="TypeFlt" BasedOn="ProductType" Iscollection="True">
  <controlInfo Controltype="Dynamic Combo Box K2BTools" Itemdescriptions="ProductTypeName:Attribute" />
</filterAttribute>
```

**NumericRange:**
```xml
<filterAttribute NameId="PriceFlt" BasedOn="ProductPrice" FilterType="NumericRange"
                 NumericRangeType="Manual|DynamicRangeSet"
                 ManualInputType="Slider"
                 SliderMinimum="1" SliderMaximum="2000" SliderStep="10"
                 DefaultFrom="1" DefaultTo="2000" />
```

**StringSearch:**
```xml
<filterAttribute NameId="Search" BasedOn="ProductDescription" FilterType="StringSearch"
                 ConditionAttributes="ProductDescription,ProductType" />
```

**AdvancedFilters (collapsible panel):**
```xml
<filter>
  <AdvancedFilters>
    <filterAttribute NameId="Flt1" BasedOn="AttrName" />
  </AdvancedFilters>
</filter>
```

**Custom condition:**
```xml
<filterAttribute NameId="PriceFlt" BasedOn="ProductPrice" 
                 Condition="ProductPrice &gt;&amp;ProductPrice when not &amp;ProductPrice.IsEmpty();" />
```

### `<orders>` — Sort options
```xml
<orders>
  <simpleOrder Attribute="AttrName" Direction="Ascending|Descending|Both"
               AscendingCaption="Label (A » Z)"
               DescendingCaption="Label (Z » A)" />
</orders>
```

`Direction="Both"` generates the ascending and descending variants of the same order, so it is the value to use when both `AscendingCaption` and `DescendingCaption` are set. With `Ascending` or `Descending`, only the matching caption applies.

### `<actions>` — Custom actions
```xml
<actions>
  <!-- Button action in toolbar -->
  <action ActionNameId="UniqueId" GXObject="ProcOrPanelName"
          RowSelection="Single|Multiple|None"
          Type="Button" Caption="Label"
          Position="Grid-Associated (Left)|Grid-Associated (Right)"
          Security="True|False"
          Tooltip="Tooltip text">
    <arguments>
      <argument Value="AttributeName" />
    </arguments>
  </action>

  <!-- Image action in grid row -->
  <action ActionNameId="UniqueId" GXObject="ProcOrPanelName"
          Type="Image" Image="ImageObjectName"
          ImageClass="Image_Action"
          Position="InGrid"
          Tooltip="Tooltip"
          AlternateText="Alt text"
          MoveToOverflowMenu="Always|Never">
    <arguments>
      <argument Value="AttributeName" />
    </arguments>
  </action>

  <!-- Action group (dropdown) -->
  <actionGroup Name="GroupName" Caption="Group Label" Position="Grid-Associated (Left)">
    <action ActionNameId="SubAction1" ... />
    <action ActionNameId="SubAction2" ... />
  </actionGroup>
</actions>
```

### `<layoutContent>` — Card-based alternate view
```xml
<layoutContent Code="UniqueCode" ColumnsLarge="3|4"
               DynamicLayout="K2BTools.DesignSystems.Common.CardWithSummary">
  <layoutVariable Name="VarName" LayoutSlotName="Title" Source="Attribute" 
                  BasedOn="AttrName" Attribute="AttrName" />
  <layoutVariable LayoutSlotName="Summary" Source="Attribute" Attribute="AttrName" />
  <layoutVariable Name="PhotoVar" LayoutSlotName="Photo" Source="Attribute"
                  BasedOn="PhotoAttr" Attribute="PhotoAttr" />
  <layoutVariable Name="KeyVar" Source="Attribute" SelectedKey="True"
                  BasedOn="KeyAttr" Attribute="KeyAttr" />
  <layoutActions LayoutSlotName="BottomActions" />
  <layoutAttributes LayoutSlotName="SecondaryAttributes">
    <attribute Attribute="AttrName" />
  </layoutAttributes>
</layoutContent>
```

> Do NOT write `LastDynamicLayoutStructureVersionNumber` — the pattern engine sets it, and its value depends on the chosen `DynamicLayout` (it is not a fixed number). Exported instances will show it; leave it as exported.

### `<kanbanView>` — Kanban board view
```xml
<kanbanView ControlName="KanbanView"
            ColumnDefinitionAttribute="AttrName:Attribute"
            ColumnDefinitionConditions="[{&quot;code&quot;:&quot;Col1&quot;,&quot;description&quot;:&quot;Column 1&quot;,&quot;condition&quot;:&quot;Attr&lt;100&quot;}]"
            ItemDetails="AttrName:Attribute"
            ItemTrailingText="AttrName:Attribute"
            PrimaryPillProvider="PillProviderProcName"
            PrimaryPillProviderParameters="AttrName" />
```

### `<businessAnalysisView>` — Analytics integration
```xml
<businessAnalysisView Security="True|False">
  <queryObject Query="QueryObjectName" />
</businessAnalysisView>
```

---

## `<entityManager>` — Detail/Edit View

Generates the entity detail panel. Shows the transaction data (via General node) plus related transaction data (via SubWorkWith). The EntityManager is the "view" of the entity.

| Attribute | Description |
|---|---|
| `ObjectName` | Generated WebPanel name (optional) |
| `Title` | Panel title shown at the top |
| `FormCaptionAttribute` | Attribute value used in browser title |
| `FormCaptionExpression` | GeneXus expression for dynamic browser title (overrides FormCaptionAttribute) |
| `BackToWorkWith` | `"True"` / `"False"` — show back navigation link to WorkWith |
| `ComponentsUIGeneration` | `"DefinedInComponents"` (default) or `"TabbedView"` (legacy) |

### `<fixedData>` — Always-visible header attributes
```xml
<fixedData>
  <attributes>
    <attribute Attribute="AttrName" Description="Label" Visible="True" Autolink="True" />
  </attributes>
</fixedData>
```

### `<components>` — Component Group (Tab/Card sections)

The Component Group organizes entity information (General, SubWorkWith, nested groups) in the EntityManager. The `ComponentDistribution` property determines how children are displayed.

```xml
<components Code="UniqueCode" ComponentDistribution="Cards|Tabs|VerticalTabs|LinkList"
            ComponentGrouping="IndependentSections|OneSection"
            TabCodeIncludedInURL="True|False"
            ResponsiveSizes="[{&quot;scale&quot;:&quot;lg&quot;,&quot;rows&quot;:[[{&quot;width&quot;:58},{&quot;width&quot;:42}]]}]">
```

**ComponentDistribution values:**
- `"Cards"` — Each child is an independent card/section. Use `ComponentGrouping` and `Componentposition` to control layout.
- `"Tabs"` — Each child appears as a horizontal tab. Use `TabCodeIncludedInURL` to persist selected tab in URL.
- `"VerticalTabs"` — Each child appears in a vertical menu on the left side.
- `"LinkList"` — Children shown as links that open in popup. Use for infrequently accessed components.

**Cards-specific properties:**
- `ComponentGrouping="IndependentSections"` — each child gets its own card
- `ComponentGrouping="OneSection"` — all children in one card
- `Componentposition="SameRowAsPrevious"` — place component beside previous one (side by side)
- `Componentposition="NewRow"` — place component in a new row (default)
- `ResponsiveSizes` — JSON defining column widths per screen size

**Nesting:** Component Groups can be nested. E.g., a Cards group can contain a nested Tabs group for sub-organization.

```xml
<components Code="MainComponents" ComponentDistribution="Cards">
  <!-- General (main transaction content) — always first -->
  <general Code="General" Title="General"
           ObjectName="CustomObjectName"
           ContentWebComponent="WebComponentName"
           ContentInDisplayMode="Transaction|WebComponent|Attributes">
    <modes Update="True|False" Delete="True|False"
           EditModeInsert="InPlace|PopUp"
           EditModeUpdate="InPlace|PopUp"
           EditModeDelete="InPlace|PopUp" />
    <attributes />
    <actions />
  </general>

  <!-- Related entity grid -->
  <subWorkWith Code="UniqueCode" Title="Tab Title"
               ObjectName="CustomObjectName"
               TitleExpression="GeneXus expression"
               Icon="ImageObjectName"
               RelatedTransaction="TransactionName"
               EditMode="PopUp|Standard|Inline"
               GenerateGridSettings="True|False"
               Collapsible="True|False"
               StartCollapsed="True|False"
               Componentposition="SameRowAsPrevious|NewRow">
    <modes Exportenabled="True|False" Reportenabled="True|False" />
    <attributes RowsPerPage="10" AllowRuntimeColumnSelection="True|False">
      <attribute ... />
    </attributes>
    <layoutContent ... />
    <filter ... />
    <orders>
      <simpleOrder Attribute="AttrName" Direction="Ascending" />
      <!-- or complex order -->
      <order Name="OrderName">
        <attribute Attribute="AttrName" Description="Label" Ascending="True|False" />
      </order>
    </orders>
  </subWorkWith>

  <!-- Nested component distribution -->
  <components Code="NestedCode" ComponentDistribution="Tabs|VerticalTabs">
    <subWorkWith ... />
  </components>
</components>
```

---

# GENERAL NODE

The `<general>` node shows the main transaction data inside the EntityManager. By default, it embeds the Transaction as a WebComponent in display mode. From here the user can Update or Delete.

Key properties:
- `ContentWebComponent` — Custom WebComponent to show instead of the Transaction
- `ContentInDisplayMode` — What to show in Display: `"Transaction"` (default), `"WebComponent"`, or `"Attributes"`
- `ContentInEditModes` — What to show in Insert/Update/Delete: `"Transaction"` (default), `"WebComponent"`, or `"Attributes"`
- `ComponentLoadCondition` — Runtime condition to show/hide this component
- `Collapsible` / `StartCollapsed` — Allow collapsing in Cards distribution
- `Componentposition` — `"NewRow"` or `"SameRowAsPrevious"`

---

# SUBWORKWITH NODE

The `<subWorkWith>` shows a grid of related transaction instances inside the EntityManager. Same capabilities as `<workWith>` (filters, orders, actions, layoutContent) but scoped to a related transaction.

Key differences from `<workWith>`:
- Requires `RelatedTransaction` pointing to a Transaction related to the parent
- `Code` must be unique within the EntityManager
- Default parm rule is generated with the parent transaction's primary key
- If the relationship uses subtypes, add explicit `<parameters>` node with the subtype attribute
- Supports `Collapsible`, `StartCollapsed`, and `Componentposition` for Cards layout
- `EditMode` applies here too (Standard, PopUp, Inline, Master Detail)

---

# EDIT MODES

| Mode | Description | Use Case | EntityManager required? |
|---|---|---|---|
| `Standard` | Full-page navigation to Transaction form via EntityManager | Complex forms, many attributes, many related transactions | Yes (mandatory) |
| `PopUp` | Modal dialog with Transaction for edit | Quick edits, any amount of attributes | No (optional, used only for Autolinks if present) |
| `Inline` | Edit directly in the grid row using Business Component | Bulk data entry, few attributes per entity | No |
| `Master Detail` | Two-pane: grid on left, Transaction on right | Few attributes, browse + edit simultaneously | No (optional, accessible via "More Information" action) |

Guidelines for choosing EditMode:
- **Standard**: Best when entity has many attributes AND many related transactions (SubWorkWith). EntityManager is the main detail view.
- **PopUp**: Best for simple entities or when you want quick CRUD without leaving the grid.
- **Inline**: Best for simple entities with few attributes that fit in grid columns. Transaction must be a Business Component. Since K2BTools 13.0.
- **Master Detail**: Best for entities with few attributes. The Transaction appears in a side pane. Related transactions require navigating to EntityManager via "More Information".

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
- asks for a CRUD over a given transaction without specifying much detail (e.g. "I want a CRUD for this transaction"),
- directly says to apply the K2BEntityServices pattern to a transaction (e.g. "apply the K2BEntityServices pattern to this transaction"), or
- explicitly asks to create the default instance of the pattern for that transaction.

In these cases, do NOT hand-write instance XML — use the dedicated task below.

### How to apply it

<!-- shared:workflow-a-apply — mirrored in K2BEntityServices/K2BTrnForm/K2BPrompt — edit all three; scripts/validate-skills.sh fails if they drift -->
Use the dedicated task. It creates the instance, links it, applies it, and sets `ApplyEntityServicesPatternOnSave = "True"` on the transaction — all in one call, without touching any source file:

```
apply_pattern_on_parent
  pattern: "K2BEntityServices"
  parentName: "T"
  parentType: "Transaction"
```

This is the recommended path for this scenario.

> **Do NOT write the instance XML in this workflow — it is ignored.** Placing the instance on disk (in `src/<path>/T/` or in `src/#patterns/`) before importing the transaction alone does NOT work: the engine writes its own default and ignores the file.
<!-- /shared:workflow-a-apply -->

### What the default generates

- **workWith** — all attributes except FK ids, formulas, and Image/Address-typed attributes; PK hidden with `Autolink="True"`; a filter by the descriptor attribute; orders by PK and by descriptor.
- **entityManager** — `fixedData` with the descriptor, `<components ComponentDistribution="Cards">`, and a General node.
- **One subWorkWith per related transaction**, each with its own Export and Report.

> The per-related-transaction subWorkWith is easy to overlook: the default of a transaction with related transactions generates noticeably more objects than the WorkWith + EntityManager pair. Account for this when applying the default.

## Workflow B — Instance does not exist, you want a customized one

### When the developer wants a customized instance

Use this workflow whenever the developer conveys *how* the instance should look — i.e. gives any intent about its shape beyond "just a CRUD". Examples:
- asks for an instance without a WorkWith, or with only a component in the EntityManager,
- asks for an instance without reports (or without export),
- says to show only certain attributes (e.g. "I only want to show these attributes"),
- specifies filters, orders, layout, edit mode, or any other detail of the instance.

As soon as the developer expresses intent about the instance's shape, use Workflow B (hand-write the instance) — not Workflow A.

> A `workWith` is **optional**. An instance without a `workWith` is valid and useful for an entity that is only reached from another screen (e.g. via an Autolink or a subWorkWith). The EDIT MODES table notes that `Standard` requires an EntityManager, but the WorkWith itself is not mandatory — so "an instance without a WorkWith" is a legitimate Workflow B request.

### How to apply it

<!-- shared:workflow-b-apply — mirrored in K2BEntityServices/K2BTrnForm/K2BPrompt — edit all three; scripts/validate-skills.sh fails if they drift -->
`<path>` below is the module folder where the transaction lives (see **Module Placement**).

1. Create the folder `src/<path>/T/`.
2. Write `src/<path>/T/K2BEntityServicesT.gx` with the nodes you want — and only those.
3. Set `ApplyEntityServicesPatternOnSave = "True"` in the transaction source `src/<path>/T.gx` (in the transaction's `#Properties` section).
4. Run a **single import with both names together**, using `rootDirectory` pointing to the KB root:
   ```
   import_text_to_kb names: ["transaction:T", "K2BEntityServicesT"], rootDirectory: "<KB root>"
   ```

### The critical point: both names in the same `names`

Passing both names in the same `names` array is what makes the hand-written instance take effect:

| `names` | Result |
|---|---|
| `["transaction:T", "K2BEntityServicesT"]` | ✅ the hand-written instance is respected |
| `["transaction:T"]` alone | ❌ writes the default, ignores the file on disk |
| `["K2BEntityServicesT"]` alone | ❌ silent no-op: the import creates no objects |
<!-- /shared:workflow-b-apply -->

## Workflow C — Instance already exists and you want to modify it

<!-- shared:workflow-c — mirrored in K2BEntityServices/K2BTrnForm/K2BPrompt — edit all three; scripts/validate-skills.sh fails if they drift -->
The standard edit-and-reimport cycle: export the instance (only if it isn't already on disk or has changed in the KB), edit its nodes, and reimport only what you touched.

1. **Export** the instance if needed — if the instance is not already on disk, or the KB copy changed, export it first:
   ```
   export_kb_to_text names: ["K2BEntityServicesT"], rootDirectory: "<KB root>"
   ```
2. **Edit** the nodes in `src/<path>/T/K2BEntityServicesT.gx`.
3. **Reimport only what you modified.** If you touched only the instance, import the instance alone — the transaction does NOT need to be reimported:
   ```
   import_text_to_kb names: ["K2BEntityServicesT"], rootDirectory: "<KB root>"
   ```
   Reimport `transaction:T` as well only if you also changed the transaction. Because the instance already exists and is linked, importing it alone is enough to apply the changes. That link is exactly what a brand-new instance lacks — which is why bringing one into existence is a different procedure, not just another import.
<!-- /shared:workflow-c -->

## Module Placement

<!-- shared:module-placement — mirrored in K2BEntityServices/K2BTrnForm/K2BPrompt — edit all three; scripts/validate-skills.sh fails if they drift -->
The transaction's module is determined by the directory where its `.gx` file lives during import. The instance folder mirrors the transaction's location:
- `src/<ModuleName>/T.gx` → transaction belongs to `<ModuleName>` module (requires `module.toml` in that directory); place the instance in `src/<ModuleName>/T/K2BEntityServicesT.gx`
- `src/T.gx` → transaction belongs to the Root Module; place the instance in `src/T/K2BEntityServicesT.gx`

Important:
- Only directories with `module.toml` are real GeneXus modules
- The `<TransactionName>/` folder that K2BEntityServices uses to group its instance and generated objects is NOT a module
- The `rootDirectory` parameter in export/import must always point to the KB root (parent of `src/`)
<!-- /shared:module-placement -->
---

# AFTER GENERATING: PUT THE WORKWITH IN THE MENU

The WorkWith is the entity's entry point, so a WorkWith nobody can reach is not a finished
CRUD. If the KB has a K2BMenu instance, and the `<workWith>` node does **not** say
`IncludeInMenu="False"`, **ask the developer whether the new WorkWith should become a menu
option, and where** — read the menu instance first so the levels you offer are the ones that
actually exist:

> `WWInvoice` is generated. Do you want it in `MainMenu`? The current levels are **Sales**,
> **Inventory** and **Administration** — or at the root, in a new level, or left out.

Then add a `WebObject` node to the chosen level of the menu instance, reimport it and run
`apply_pattern pattern: "K2BMenu", instanceName: "<menu>"`. The format and the workflow are in
`skills/K2BMenu.md` — same `#Instance` envelope as here, but its own node vocabulary
(`<menu>`, `<subMenu>`, `<webObject>`), and no parent object to co-import.

**How to read `IncludeInMenu`.** The property defaults to **`True`** and is written to the
instance only when it differs from that default, so its absence means "yes, by default" — not
"not marked". Read it in one direction only: `IncludeInMenu="False"` is the developer opting
that WorkWith out of the menu, so do not add it and do not ask again. Setting it to `True`,
conversely, adds nothing by itself — an option enters the menu only when a `<webObject>` node
is added to the menu instance and the K2BMenu pattern is applied.

**The EntityManager and the Transaction form are never menu options.** They are reached from
the WorkWith. Only the WorkWith is a candidate.

Skip the question when the KB has no menu instance, when `IncludeInMenu="False"`, or when the
developer already said where the option goes or asked not to touch the menu.

---

# DYNAMIC LAYOUTS

**Name qualification.** In a K2BEntityServices instance the `DynamicLayout` value is always **fully qualified** with the `K2BTools.DesignSystems.Common.` prefix. WebPanelDesigner uses the bare name for the same layout (`CardWithSummary`, not `K2BTools.DesignSystems.Common.CardWithSummary`) — do not copy a value across the two formats without adjusting the prefix.

Layouts for the `<layoutContent>` `DynamicLayout` attribute:
- `K2BTools.DesignSystems.Common.CardWithSummary`
- `K2BTools.DesignSystems.Common.CardWithSummaryVariant1`
- `K2BTools.DesignSystems.Common.GenericEntityListWithImage`
- `K2BTools.DesignSystems.Common.StructuredList`
- `K2BTools.DesignSystems.Common.StructuredPeopleListNumeric`
- `K2BTools.DesignSystems.Common.Timeline`
- `K2BTools.DesignSystems.Common.CardPhotoActions`
- `K2BTools.DesignSystems.Common.PhotoWithTitle`
- `K2BTools.DesignSystems.Common.SimplePriceList`

The list is not exhaustive — the KB may define more, and a KB can add its own. To confirm which ones exist, look under `src/K2BTools/DesignSystems/Common/@DesignerLayouts/`.

## Layout slot names

Slots are **not a fixed list** — they depend on the chosen `DynamicLayout`. Discover them by reading the layout's `DynamicLayoutWeb` definition (e.g. `src/K2BTools/DesignSystems/Common/@DesignerLayouts/@GenericGrids/CardWithSummary.gx`) and taking the `InternalName` of each slot node under `LayoutDefinitionUIElements`. See **LayoutSlotName Values** in `skills/WebPanelDesigner.md` for the full discovery procedure and the slot-kind → consumer-node mapping.

Slots seen in practice: `Title`, `Summary`, `Photo`, `Icon`, `Date`, `Actions`, `BottomActions`, `SecondaryAttributes`. Consume them with `<layoutVariable>` (value slots), `<layoutActions>` (action containers) or `<layoutAttributes>` (attribute containers), plus one `<layoutVariable … SelectedKey="True">` for the primary key.

---

# EXAMPLES

## Example 1: Simple CRUD (minimal)
```xml
<instance>
  <transaction Transaction="City">
    <workWith>
      <modes />
      <attributes>
        <attribute Attribute="CityId" Visible="False" Autolink="True" />
        <attribute Attribute="CityName" Visible="True" Autolink="True" ShowInExtraSmall="True" />
        <attribute Attribute="CountryName" Visible="True" Autolink="True" />
      </attributes>
      <filter>
        <filterAttribute NameId="CityName_Filter" BasedOn="CityName" />
      </filter>
      <orders>
        <simpleOrder Attribute="CityName" />
      </orders>
    </workWith>
    <entityManager FormCaptionAttribute="CityName">
      <fixedData>
        <attributes>
          <attribute Attribute="CityName" Visible="True" Autolink="True" />
        </attributes>
      </fixedData>
      <components Code="Components">
        <general Code="General">
          <modes />
        </general>
      </components>
    </entityManager>
  </transaction>
</instance>
```

## Example 2: CRUD with filters and related entities
```xml
<instance>
  <transaction Transaction="Payment">
    <workWith>
      <modes />
      <attributes>
        <attribute Attribute="PaymentId" Visible="False" Autolink="True" />
        <attribute Attribute="PaymentMethod" Visible="True" Autolink="True" ShowInExtraSmall="True" />
        <attribute Attribute="PaymentDate" Visible="True" Autolink="True" />
        <attribute Attribute="CustomerName" Visible="True" Autolink="True" />
        <attribute Attribute="PaymentTotalAmount" Visible="True" Autolink="True" />
      </attributes>
      <filter>
        <filterAttribute NameId="PaymentMethod_Flt" BasedOn="PaymentMethod" All="True" />
        <filterAttribute NameId="PaymentDate_Flt" BasedOn="PaymentDate" FilterType="DateRange" />
        <filterAttribute NameId="CustomerName_Flt" BasedOn="CustomerName" />
      </filter>
      <orders>
        <simpleOrder Attribute="PaymentId" />
        <simpleOrder Attribute="PaymentDate" Direction="Descending" />
      </orders>
    </workWith>
    <entityManager FormCaptionAttribute="PaymentMethod">
      <fixedData>
        <attributes>
          <attribute Attribute="PaymentMethod" Visible="True" Autolink="True" />
        </attributes>
      </fixedData>
      <components Code="Components" ComponentDistribution="Cards">
        <general Code="General">
          <modes />
        </general>
      </components>
    </entityManager>
  </transaction>
</instance>
```

## Example 3: Full-featured with actions, card layout, and subWorkWith
```xml
<instance>
  <transaction Transaction="Customer"
               AfterInsertMessage="format('Customer %1 created', CustomerName)"
               AfterDeleteMessage="format('Customer %1 deleted', CustomerName)">
    <workWith Title="Customers" EditMode="Standard">
      <modes MultipleDelete="True" Exportenabled="False" />
      <attributes PageOptions="5,10,20,50,100">
        <attribute Attribute="CustomerId" Visible="False" Autolink="True" />
        <attribute Attribute="CustomerName" Visible="True" Autolink="True" ShowInExtraSmall="True" />
        <attribute Attribute="CustomerEMail" Description="Email" Visible="True" />
        <attribute Attribute="CountryName" Description="Country" Visible="True" />
      </attributes>
      <layoutContent Code="CardView" ColumnsLarge="4"
                     DynamicLayout="K2BTools.DesignSystems.Common.CardWithSummary">
        <layoutVariable Name="CustomerName" LayoutSlotName="Title" Source="Attribute"
                        BasedOn="CustomerName" Attribute="CustomerName" />
        <layoutVariable LayoutSlotName="Summary" Source="Attribute" Attribute="CustomerSearchResult" />
        <layoutVariable Name="CustomerPhoto" LayoutSlotName="Photo" Source="Attribute"
                        BasedOn="CustomerPhoto" Attribute="CustomerPhoto" />
        <layoutVariable Name="CustomerId" Source="Attribute" SelectedKey="True"
                        BasedOn="CustomerId" Attribute="CustomerId" />
        <layoutActions LayoutSlotName="BottomActions" />
      </layoutContent>
      <filter>
        <filterAttribute NameId="CustomerName_Flt" BasedOn="CustomerName" />
        <filterAttribute NameId="Country_Flt" BasedOn="CountryName" Iscollection="True">
          <controlInfo Controltype="Dynamic Combo Box K2BTools" Itemdescriptions="CountryName:Attribute" />
        </filterAttribute>
      </filter>
      <orders>
        <simpleOrder Attribute="CustomerName" AscendingCaption="Name (A » Z)" DescendingCaption="Name (Z » A)" />
      </orders>
      <actions>
        <action ActionNameId="BlockSales" GXObject="BlockSales" RowSelection="Multiple"
                Type="Button" Caption="Block Sales" Position="Grid-Associated (Left)" />
      </actions>
    </workWith>
    <entityManager Title="Customer" FormCaptionAttribute="CustomerName" BackToWorkWith="True">
      <fixedData>
        <attributes>
          <attribute Attribute="CustomerName" Description="Name" Visible="True" Autolink="True" />
        </attributes>
      </fixedData>
      <components Code="Components" ComponentDistribution="Cards">
        <general Code="General" Title="General">
          <modes Update="True" Delete="True" EditModeUpdate="PopUp" />
        </general>
        <subWorkWith Code="Invoices" Title="Invoices" RelatedTransaction="Invoice">
          <modes Exportenabled="False" Reportenabled="False" />
          <attributes RowsPerPage="10">
            <attribute Attribute="InvoiceCode" Visible="True" Autolink="True" />
            <attribute Attribute="InvoiceDate" Visible="True" />
            <attribute Attribute="InvoiceTotal" Visible="True" />
          </attributes>
          <filter>
            <filterAttribute NameId="InvoiceDate_Flt" BasedOn="InvoiceDate" FilterType="DateRange"
                             DateRangeType="Semantic" />
          </filter>
          <orders>
            <simpleOrder Attribute="InvoiceCode" Direction="Ascending" />
          </orders>
        </subWorkWith>
      </components>
    </entityManager>
  </transaction>
</instance>
```

## Example 4: Inline editing
```xml
<instance>
  <transaction Transaction="Product">
    <workWith ObjectName="WWProductInLine" Title="Products InLine" EditMode="Inline">
      <modes />
      <attributes>
        <attribute Attribute="ProductId" Visible="False" Autolink="True" />
        <attribute Attribute="ProductDescription" Visible="True" Autolink="True" />
        <attribute Attribute="ProductType" Visible="True" Autolink="True" />
        <attribute Attribute="ProductPrice" Visible="True" Autolink="True" />
      </attributes>
      <filter>
        <filterAttribute NameId="ProductDescription_Flt" BasedOn="ProductDescription" />
      </filter>
      <orders>
        <simpleOrder Attribute="ProductDescription" />
      </orders>
    </workWith>
  </transaction>
</instance>
```

## Example 5: Kanban view
```xml
<instance>
  <transaction Transaction="Task">
    <workWith>
      <modes />
      <attributes>
        <attribute Attribute="TaskId" Visible="False" Autolink="True" />
        <attribute Attribute="TaskSubject" Visible="True" Autolink="True" ShowInExtraSmall="True" />
        <attribute Attribute="TaskDueDate" Visible="True" />
        <attribute Attribute="CustomerName" Visible="True" />
      </attributes>
      <kanbanView ControlName="KanbanView"
                  ColumnDefinitionAttribute="TaskStatus:Attribute"
                  ColumnDefinitionConditions="[{&quot;code&quot;:&quot;Pending&quot;,&quot;description&quot;:&quot;Pending&quot;,&quot;condition&quot;:&quot;TaskStatus=TaskStatusDomain.Pending&quot;},{&quot;code&quot;:&quot;InProgress&quot;,&quot;description&quot;:&quot;In Progress&quot;,&quot;condition&quot;:&quot;TaskStatus=TaskStatusDomain.InProgress&quot;},{&quot;code&quot;:&quot;Done&quot;,&quot;description&quot;:&quot;Done&quot;,&quot;condition&quot;:&quot;TaskStatus=TaskStatusDomain.Done&quot;}]"
                  ItemDetails="CustomerName:Attribute"
                  ItemTrailingText="TaskDueDate:Attribute" />
      <filter>
        <filterAttribute NameId="TaskSubject_Flt" BasedOn="TaskSubject" />
      </filter>
      <orders>
        <simpleOrder Attribute="TaskId" />
      </orders>
    </workWith>
    <entityManager FormCaptionAttribute="TaskSubject">
      <fixedData>
        <attributes>
          <attribute Attribute="TaskSubject" Visible="True" Autolink="True" />
        </attributes>
      </fixedData>
      <components Code="Components">
        <general Code="General">
          <modes />
        </general>
      </components>
    </entityManager>
  </transaction>
</instance>
```

---

# CONSTRAINTS
- The `Transaction` attribute must reference an existing GeneXus Transaction
- Every `<workWith>` should have `<modes />` and `<orders>` nodes; it should have `<attributes>` unless the grid is rendered through `<layoutContent>` instead of columns
- Every `<entityManager>` should have `<fixedData>` and `<components>` with at least one `<general>` node (both are optional in practice: `<fixedData>` may be omitted, and the `<general>` may live in a nested `<components>` group instead of the outer one)
- Filter `NameId` values must be unique within the pattern instance
- Action `ActionNameId` values must be unique within the pattern instance
- `<subWorkWith>` must have `RelatedTransaction` pointing to a valid Transaction related to the parent
- When using `<layoutContent>`, the `DynamicLayout` must be a valid K2BTools layout name
- `Componentposition="SameRowAsPrevious"` places the component card beside the previous one
- `ComponentDistribution` values: `"Cards"`, `"Tabs"`, `"VerticalTabs"`, `"LinkList"`
- Do NOT mix K2BEntityServices with WebPanelDesigner formdesigner XML — they are separate mechanisms
- The file must be named `K2BEntityServices<TransactionName>.gx`
- The `#Properties` section `Name` must match the object name in the header
- Writing the instance `.gx` to disk does NOT modify the KB — always apply it through the correct **WORKFLOWS** procedure
- To respect a hand-written custom instance, import BOTH the transaction and the instance in the same `names` array (`["transaction:T", "K2BEntityServicesT"]`); importing the transaction alone writes the default and ignores the file
- `ApplyEntityServicesPatternOnSave = "True"` goes in the transaction's `#Properties`, NOT in the instance `.gx`

---

# COMMON ERRORS

## Error 1: Missing `<modes />` in workWith
Every `<workWith>` requires a `<modes />` element even if empty:
```xml
<!-- ❌ Incorrect -->
<workWith>
  <attributes>...</attributes>
</workWith>

<!-- ✅ Correct -->
<workWith>
  <modes />
  <attributes>...</attributes>
  <orders />
</workWith>
```

## Error 2: Missing `<general>` in components
The `<components>` node should have a `<general>` node as first child:
```xml
<!-- ❌ Incorrect -->
<components Code="Comp">
  <subWorkWith ... />
</components>

<!-- ✅ Correct -->
<components Code="Comp">
  <general Code="General">
    <modes />
  </general>
  <subWorkWith ... />
</components>
```

## Error 3: Using formdesigner XML instead of pattern XML
K2BEntityServices uses its own XML schema. Do NOT use WebPanelDesigner tags:
```xml
<!-- ❌ Incorrect (WebPanelDesigner format) -->
<WebForm InternalName="WebForm">
  <Grid InternalName="Grid" BaseTrn="Product">...</Grid>
</WebForm>

<!-- ✅ Correct (K2BEntityServices format) -->
<instance>
  <transaction Transaction="Product">
    <workWith>...</workWith>
  </transaction>
</instance>
```

## Error 4: Duplicate NameId in filters
Each `filterAttribute` needs a unique `NameId`:
```xml
<!-- ❌ Incorrect -->
<filterAttribute NameId="ProductName" BasedOn="ProductDescription" />
<filterAttribute NameId="ProductName" BasedOn="ProductType" />

<!-- ✅ Correct -->
<filterAttribute NameId="ProductDescription_Flt" BasedOn="ProductDescription" />
<filterAttribute NameId="ProductType_Flt" BasedOn="ProductType" />
```

## Error 5: Using IncludeInGridKey
Unlike WebPanelDesigner, K2BEntityServices does NOT use `IncludeInGridKey`. The pattern automatically identifies the primary key from the Transaction structure. Simply set the key attribute as `Visible="False"`.

## Error 6: Forgetting `Code` attribute in components
The `<general>`, `<subWorkWith>`, and `<components>` nodes require a `Code` attribute for identification:
```xml
<!-- ❌ Incorrect -->
<components>
  <general>...</general>
</components>

<!-- ✅ Correct -->
<components Code="MainComponents">
  <general Code="General">...</general>
</components>
```
