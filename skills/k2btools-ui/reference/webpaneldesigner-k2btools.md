---
name: webpaneldesigner-k2btools
description: K2BTools WebPanel designer skill for creating and editing WebPanels and WebComponents using the simplified XML designer format
---

<!-- K2BTools Skills · v0.2.0 (built 2026-09-24 · 94740895) -->

K2BTools specialized skill for designing WebPanel and WebComponent user interfaces through the simplified XML formdesigner format

---

## GUIDELINE
Interprets user needs for WebPanel/WebComponent UI design, validates designer XML structure, ensures K2BTools conventions, and generates correct formdesigner content

## Triggers
Use this skill for:
- Creating or editing WebPanel or WebComponent UI layouts using K2BTools designer
- Generating formdesigner XML for grids, forms, tabs, wizards
- Adding filters, actions, or controls to K2BTools panels
- Using K2BTools-specific controls (Dynamic Combo Box K2BTools, Suggest K2BTools, Datepicker K2BTools, etc.)
- LayoutGrid card-based designs
- WizardMain multi-step flows

Do NOT use this skill for:
- Native Panel layout (GXML with `<smart>`, `<table>`, `<canvas>`)
- Non-K2BTools WebPanel design
- Transaction form patterns (K2BTrnForm)
- Backend logic (Procedures, DataProviders)
- General GeneXus questions unrelated to UI design
- Standard CRUD interfaces (use `skills/K2BEntityServices.md` instead)

## Responsibilities
- Generate valid K2BTools formdesigner XML
- Ensure all nodes use valid tags from the recognized set
- Enforce unique `InternalName` across the entire XML
- Apply correct `BasedOn` format convention in filter variables
- Select appropriate K2BTools controls for each use case
- Validate XML structure before output
- Never use invented or unsupported tags

## Communication
- Professional, objective tone
- Reply in user message language
- Provide examples when clarifying conventions
- Warn explicitly about common pitfalls

## Dependencies
This skill requires:
- **nexa** skill for GeneXus object management and knowledge base operations
- **object-panel** reference from nexa for WebPanel object syntax (events, rules, variables, properties)

This skill extends the `#Designer` section specific to K2BTools WebPanels and WebComponents. The `#Layout` section from object-panel does NOT apply here; K2BTools generates it automatically from the designer XML.

**K2BMenu** (`skills/K2BMenu.md`) decides which screens the user can reach. A panel generated here that takes no parameters is a menu-option candidate — see **AFTER GENERATING: PUT THE PANEL IN THE MENU**.

---

# WORK ORDER — READ THE SKILL FIRST

This skill is the base and primary reference for the WebPanelDesigner format. Follow this order of operations on every task:

1. **Read the skill before touching the KB.** It already defines the `.gx` envelope (`#Designer`, `#Events`, `#Variables`, `#Properties`, `#Rules`) and the mandatory 4-step import/export workflow. Do not rediscover these from existing objects.
2. **Then explore the KB only for what the skill does NOT cover:**
   - the data model the panel consumes (Transactions, attributes, Data Providers, SDTs),
   - a formatting detail or edge case not contemplated in the skill's examples.
3. **Use existing objects to fill specific gaps, not as a template.** Reference them for a concrete missing detail — never to re-derive the format, and never to check whether "it's already done".

> The skill is the source of truth for the format. KB exploration is for the data model and uncovered edge cases only.

---

# SYNTAX

## Designer Section
For WebPanel and WebComponent objects using K2BTools, an additional section `#Designer` is used:

~~~
#Designer
<designer>
#End
~~~

The `<designer>` content defines the user interface as simplified XML. All UI modifications are made here. The `#Layout` section is auto-generated and must NOT be modified or interpreted.

## Root Element
The XML MUST have `<WebForm>` as root tag:

```xml
<WebForm InternalName="WebForm" Title="My Panel Title">
  <!-- content goes here -->
</WebForm>
```

Note: `<WebForm>` is an XML tag name inside the XML content — it is NOT a tool parameter. The tool parameter is `formdesigner`.

---

# VALID NODE TYPES

These are the ONLY tags the K2B designer recognizes. Any other tag (like `<ContentLayout>`, `<Section>`, `<Row>`, `<Cell>`, `<Panel>`, `<Container>`, etc.) will be **silently ignored** and everything inside will be lost.

| Tag | Parent(s) | Description |
|---|---|---|
| `WebForm` | (root) | Root element — REQUIRED |
| `Tabs` | `WebForm` | Tab container |
| `Tab` | `Tabs` | Individual tab |
| `Grid` | `Tab`, `WebForm` | Data grid |
| `LayoutGrid` | `Tab`, `WebForm` | Card-based data grid (K2BTools) |
| `Columns` | `Grid`, `Group` | Column container (grid columns or multi-column layout) |
| `Column` | `Columns` (inside Group) | Single column in a multi-column layout |
| `Attribute` | `Columns`, `Group`, `Column`, `Tab`, `Attributes` | Data column or field |
| `Action` | `Columns`, `Actions` | Row action or toolbar action |
| `Filters` | `Grid`, `LayoutGrid` | Filter container |
| `Variable` | `Filters`, `Columns`, `Group`, `Column`, `Tab`, `Attributes` | Filter variable, grid column variable, or form variable |
| `Orders` | `Grid`, `LayoutGrid` | Sort order container |
| `SimpleOrder` | `Orders` | Sort order definition |
| `Order` | `Orders` | Named order for DataProvider/Procedure grids |
| `Actions` | `Grid`, `Tab`, `WebForm`, `Group`, `LayoutContent` | Action/toolbar container |
| `Attributes` | `Tab`, `WebForm`, `LayoutContent` | Attribute group container |
| `Group` | `Tab`, `WebForm` | Field group with title |
| `TextBlock` | `Tab`, `WebForm`, `Group` | Static text/title |
| `ControlInfo` | `Attribute`, `Variable` | Control type override (combo box, etc.) |
| `LayoutContent` | `LayoutGrid` | Card layout definition (K2BTools) |
| `LayoutVariableNode` | `LayoutContent` | Card field mapping (K2BTools) |
| `WizardMain` | `WebForm` | Wizard container (K2BTools) |
| `WizardSteps` | `WizardMain` | Wizard step container |
| `WizardStep` | `WizardSteps` | Individual wizard step |
| `WebComponent` | `Tab`, `WebForm`, `Group`, `Attributes` | Embedded WebComponent |
| `LineSeparator` | `Tab`, `WebForm`, `Group`, `Attributes` | Visual line separator |
| `SDTVariable` | `Columns`, `LayoutContent` | SDT field column (for SDT/BC grids) |

---

# ATTRIBUTES PER NODE

**WebForm:** `InternalName` (required), `Title`

**Tabs:** `InternalName` (required)

**Tab:** `InternalName` (required), `Caption`

**Grid:** `InternalName` (required), `BaseTrn` (transaction name), `Datasource` (DataProvider or Procedure name), `SDTorBC` (SDT or Business Component name), `SDTorBCLevel` (SDT level name), `Title` (when set, displays as a card), `Collapsible`, `StartCollapsed`, `Conditions`, `AdvancedConditions`, `Unique`, `GenerateSelectionSummary`, `AllowSelection`, `GenerateOnLineActivateEvent`, `ForceMultirow`, `PersistSelectedRows`, `LoadEventScheme` (`"ManagedByDeveloper"`)

**LayoutGrid:** `InternalName` (required), `BaseTrn`, `Datasource`, `SDTorBC`, `SDTorBCLevel`, `Title`

**LayoutContent:** `InternalName` (required), `DynamicLayout`, `DefaultSource`, `ColumnsLarge`

**LayoutVariableNode:** `InternalName` (required), `Source`, `Attribute`, `LayoutSlotName`, `IncludeInGridKey`

**Attribute (in Columns):** `InternalName` (required), `Attribute` (attribute name), `Visible`, `Description`, `UseinCSVImportExport`, `IncludeInGridKey`, `ConditionalPills`, `ShowPillsOnly`

**Attribute (in Group/form):** `InternalName` (required), `Attribute` (attribute name), `Description`, `ElementRelativePosition` (`"New row"`, `"New cell"`, `"Same cell"`)

**Action (in Columns — row action):** `InternalName` (required), `Type` (`"Image"`), `Image` (e.g. `K2BActionDisplay`, `K2BActionUpdate`, `K2BActionDelete`, `K2BActionInsert`), `Condition`, `DisableType` (`"Hide"` or `"Disable"`), `AlternateText`

**Action (in Actions — toolbar):** `InternalName` (required), `Caption`, `Position` (`"Top (Right)"`, `"Top (Left)"`), `Condition`, `DisableType`

**Variable (in Filters):** `InternalName` (required), `BasedOn` (format: `AttributeName:Attribute`), `Type` (e.g. `"DateRange"`, `"Multiple"`, `"StringSearch"`), `Description`

**Variable (in Grid Columns):** `InternalName` (required), `BasedOn` (format: `AttributeName:Attribute`), `Visible`, `LoadFromAttribute` (`"True"` for inferred for each grids), `Loadfromdatasource` (`"True"` for DataProvider/Procedure grids), `IncludeInGridKey`, `AllowRuntimeColumnSelection`

**ControlInfo:** `InternalName` (required), `Controltype` (`"Combo Box"`, `"Dynamic Combo Box"`, `"Dynamic Combo Box K2BTools"`, etc.), `Values` (for static combo: `"Label1:Value1,Label2:Value2"`), `ItemValues`, `Itemdescriptions` (for dynamic combo: `"AttrName:Attribute"`)

**SimpleOrder:** `InternalName` (required), `Attribute` (attribute name)

**Order:** `InternalName` (required), `Name` (order name matching DataProvider/Procedure order parameter values)

**SDTVariable:** `InternalName` (required), `SDT` (SDT name), `Field` (field name within the SDT), `Description`, `Class`, `DescriptionClass`

**WebComponent:** `InternalName` (required)

**Group:** `InternalName` (required), `Title`, `Collapsible`, `StartCollapsed`, `ShowBorders`, `DescriptionsLayout` (`"Top"`, `"Left"`)

**Attributes (section node):** `InternalName` (required), `Title`, `Collapsible`, `StartCollapsed`, `ShowBorders`, `SDTorBC`, `SDTorBCLevel`, `DescriptionsLayout` (`"Top"`, `"Left"`)

**Columns (multi-column layout):** `InternalName` (required), `ContentDistribution` (`"ColumnPercentages"`, `"Flow"`), `ResponsiveSizes`

**Columns (grid columns):** `InternalName` (required), `RowsPerPage`, `PageOptions`, `AllowRuntimeColumnSelection`, `ConditionalRowClasses`, `RowDetailWebComponent`, `RowDetailWebComponentParameters`

**TextBlock:** `InternalName` (required), `Caption`, `ElementRelativePosition`

---

# CONVENTIONS

## BasedOn Format
In filter `Variable` nodes, the `BasedOn` attribute uses **reversed** format compared to the variable `Type` field:
- Variable Type: `Attribute:ProductName` (prefix:name)
- Designer BasedOn: `ProductName:Attribute` (name:suffix)

This is a K2B designer convention. Do NOT use the `Attribute:Name` format in BasedOn.

## InternalName Rule
Every node MUST have a unique `InternalName` attribute. The API uses it to identify and match nodes. Use descriptive, unique names. Each `InternalName` must be unique across the entire XML.

## Grid Data Sources
The grid type is determined by its properties and column contents. See the **GRID TYPES** section for full details on each type (Base Table, Inferred For Each, DataProvider/Procedure, No Base Table, SDT/BC).

## Primary Key
Always include the primary key attribute with `IncludeInGridKey="True"` in grid columns.

## K2BTools Control Suffix
All K2BTools-specific controls carry the suffix "K2BTools" in the `Controltype` value:
- `"Dynamic Combo Box K2BTools"` (NOT `"Dynamic Combo Box"`)
- `"Suggest K2BTools"`
- `"Datepicker K2BTools"`
- `"Masked Input K2BTools"`

## LayoutSlotName Values
Slots depend on the chosen `DynamicLayout` — they are NOT a fixed list. Discover them by reading the layout's `DynamicLayoutWeb` definition (e.g. `src/K2BTools/DesignSystems/Common/@DesignerLayouts/@GenericGrids/CardPhotoActions.gx`) and taking the `InternalName` of each slot node under `LayoutDefinitionUIElements` — this includes `LayoutDefinitionVariable`, `Action`, `LayoutDefinitionActions` and `LayoutDefinitionAttributes` (e.g. the `MainAction` slot is an `<Action>` node, not a `LayoutDefinitionVariable`).

For `CardPhotoActions` the slots are: `Key`, `Title`, `Photo`, `MainAction`, `Actions`, `SecondaryAttributes`.

### Consumer node type per slot
Inside a grid's `<LayoutContent>`, the node you write depends on the slot's kind in the definition. Map it as follows:

| Slot kind in the layout definition | Node to write in `<LayoutContent>` | Notes |
|---|---|---|
| `LayoutDefinitionVariable` (e.g. `Title`, `Photo`, `Key`) | `<LayoutVariableNode … LayoutSlotName="X" />` | Bind with `Source="Attribute"` + `Attribute="…"` (or a variable). |
| `Action` (e.g. `MainAction`) | `<Action … Type="Button" LayoutSlotName="X" />` | Single action; not a `LayoutVariableNode`. |
| `LayoutDefinitionActions` (e.g. `Actions`) | `<Actions … LayoutSlotName="X"> … </Actions>` | Container; holds child `<Action>` elements. |
| `LayoutDefinitionAttributes` (e.g. `SecondaryAttributes`) | `<Attributes … LayoutSlotName="X"> … </Attributes>` | Container; holds child `<Attribute>` elements. |

**Key slot (MANDATORY when the layout has a PK slot).** Any `DynamicLayout` whose definition declares a slot with `PreferPrimaryKey="True"` (CardPhotoActions, CardWithSummary, PhotoWithTitle, …) REQUIRES a `LayoutVariableNode` mapped to `LayoutSlotName="Key"` with `IncludeInGridKey="True"`. If it is missing, the text-format parser throws `NullReferenceException` in `SyncPropertiesToNode`, or the MCP import reports `Unknown Variable '&Variable_Key'`. Node order inside `<LayoutContent>` does not matter (the generated `CustomerList` places the `Key` node third, mirroring the layout definition).

---

# GRID TYPES

Grids obtain their data from different sources. The type is determined by the properties and column contents:

## 1. Grid with Base Table
Contains at least one `Attribute` node in its `Columns`. GeneXus determines the base table automatically.

**Specific properties:**
- `BaseTrn` — Specifies a base transaction to optimize navigation
- `Conditions` — Grid conditions placed in GeneXus grid condition property
- `Unique` — Avoids repeated rows

**User subroutines:**
- `U_LoadRowVars({InternalName})` — Load variables or actions per row

## 2. Grid with Inferred For Each
Does NOT contain Attribute nodes. Has at least one Variable with `LoadFromAttribute="True"`. Generates a `For Each` command in the load event.

Use when:
- Conditions can't be placed in grid conditions
- Complex filtering logic is needed
- Need to selectively skip rows

**Specific properties:**
- `Conditions` — Placed in the For Each `where` clause (separated by `;`)
- `AdvancedConditions` — Conditions not valid in grid conditions but valid in `For Each where` (e.g., `in` operator, aggregates)
- `BaseTrn` — Base transaction for navigation
- `Unique` — Unique clause

**Generated variables:**
- `&I_LoadCount_{InternalName}` — Record count (read-only)
- `&HasNextPage_{InternalName}` — Whether next page exists (read-only)
- `&LoadRow_{InternalName}` — Set to `False` in `U_LoadRowVars` to skip current row
- `&Reload_{InternalName}` — Set to `True` in action code to force grid reload

**User subroutines:**
- `U_LoadRowVars({InternalName})` — Load variables, set `&LoadRow_{InternalName} = False` to skip a row
- `U_WhenNone({InternalName})` — Executed when no records match

## 3. Grid based on DataProvider or Procedure
Does NOT contain Attribute nodes. Has the `Datasource` property set to a DataProvider or Procedure name.

The object receives parameters mapped from K2BTools variables. K2BTools auto-maps:
- **Filters:** Parameter named same as filter variable (or with `_Filter` suffix)
- **OrderBy:** Parameter named ending in `OrderBy` or named `OrderedBy`
- **Paging:** Parameters named `&Count` and `&Skip`

If automatic mapping fails, use `U_PrepareDataProvider` to set parameter values manually.

**Specific properties:**
- `Datasource` — DataProvider or Procedure object name

**Generated variables:**
- `&I_LoadCount_{InternalName}` — Record count (read-only)
- `&HasNextPage_{InternalName}` — Whether next page exists (read-only)
- `&LoadRow_{InternalName}` — Skip row (only when DataProvider does NOT handle paging)
- `&DP_Filter_{ParameterName}_{InternalName}` — Maps to each DataProvider/Procedure IN parameter

**User subroutines:**
- `U_LoadRowVars({InternalName})` — Load additional variables per row
- `U_PrepareDataProvider({InternalName})` — Manually map filter variables to DataProvider/Procedure parameters before invocation

## 4. Grid with No Base Table
Does NOT contain Attribute nodes. All variables have `LoadFromAttribute="False"`. No Datasource property set.

**Use when you need full manual control of HOW the grid loads** — you write the load logic yourself: arbitrary `For Each`, multiple/mixed data sources, computed or derived rows, selectively skipping rows, or data from web services / external APIs. Any request for "maximum flexibility in the grid load" / "100% control of Grid.Load" / "I write the load For Each myself" maps to THIS grid type. It is the WebPanelDesigner equivalent of a plain variable-grid with a manual `Event Load`, and is the preferred way to get that control while keeping K2BTools styling and features.

Always set `LoadEventScheme="ManagedByDeveloper"` on the `<Grid>` — it is the default value, but write it explicitly. With this scheme the Designer calls `U_LoadEvent`, where the developer loads rows by populating the row variables and calling the generated `LoadRow` subroutine for each row.

**Example — designer XML for a no-base-table grid** (variables only, `LoadFromAttribute="False"`, key hidden):
```xml
<Grid InternalName="GridActiveCustomers" LoadEventScheme="ManagedByDeveloper">
  <Columns InternalName="Columns">
    <Variable InternalName="CustomerId" BasedOn="CustomerId:Attribute" LoadFromAttribute="False" IncludeInGridKey="True" Visible="False" />
    <Variable InternalName="CustomerName" BasedOn="CustomerName:Attribute" LoadFromAttribute="False" Visible="True" />
  </Columns>
</Grid>
```
Write the actual load logic (your own `For Each`, external calls, computed rows) inside the generated `U_LoadEvent` subroutine **after** the import/export step — never in the initial `.gx` (see the 4-step import/export workflow). Populate the row variables and call the generated `LoadRow` subroutine once per row:
```
Sub 'U_LoadEvent(GridActiveCustomers)'
	// ---- K2BTools - To Be Completed By User ----
	For Each Customer
		Where CustomerStatus = 'A'
		&CustomerId = CustomerId
		&CustomerName = CustomerName
		Do 'LoadRow(GridActiveCustomers)'
	EndFor
EndSub
```
The `LoadRow` subroutine is generated by K2B — do not write it; just call it. Alternatively the `Load` command can be used instead of `LoadRow`, but then some Designer features (paging, counters) may not work.

**Generated variables:**
- `&I_LoadCount_{InternalName}` — Record count (read-only)
- `&HasNextPage_{InternalName}` — Whether next page exists (read-only)
- `&Exit_{InternalName}` — Set to `True` when no more records (legacy scheme only)
- `&Reload_{InternalName}` — Force grid reload from action code

**User subroutines:**
- `U_LoadEvent({InternalName})` — (ManagedByDeveloper) Full control of grid loading; call `LoadRow` subroutine for each row
- `U_LoadRowVars({InternalName})` — (legacy scheme) Load variables per row, set `&Exit_{InternalName} = True` when done

## 5. Grid based on SDT or Business Component
Has the `SDTorBC` property set. Contains SDTVariable nodes instead of Attribute nodes.

Use when data comes from an SDT that is loaded programmatically (e.g., from a web service call or external object).

**Specific properties:**
- `SDTorBC` — SDT or Business Component name
- `SDTorBCLevel` — SDT level (for nested structures)
- `GetSDTorBCongridpaging` — `"True"` / `"False"`. When `True`, `U_LoadSDT` is called every time the user changes page (the developer must handle paging logic using `&CurrentPage_{GridName}` and `RowsPerPage`). When `False` (default), the SDT is loaded once and K2BTools handles paging internally. Set to `True` when the SDT is loaded with server-side paging.

**User subroutines:**
- `U_LoadSDT({InternalName})` — Load the SDT contents (only for root-level grids)
- `U_LoadRowVars({InternalName})` — Load additional variables per row (access current item via `.CurrentItem`)

**Notes:**
- Filters can be added but K2BTools does NOT auto-filter; use filter variables in `U_LoadSDT`
- Nested SDT grids do not have paging or `U_LoadSDT`; paging only works at root level

---

# ELEMENT RELATIVE POSITION

Controls the position of elements (attributes, variables, textblocks, actions) when they are NOT inside Grid Columns.

| Value | Behavior |
|---|---|
| `New row` | (default) Element placed in a new row |
| `New cell` | Same row as previous element, in a new cell. Cells are vertically aligned across rows. Width configured via `ResponsiveSizes` on the container. |
| `Same cell` | Same row AND same cell as previous element. Elements placed adjacent. Responsive sizes treat them as one unit. |

```xml
<Group InternalName="GrpProduct" Title="Product">
  <Attribute InternalName="ProductId" Attribute="ProductId" Description="Id" />
  <Attribute InternalName="ProductDescription" Attribute="ProductDescription" Description="Description"
             ElementRelativePosition="New cell" />
  <Attribute InternalName="ProductType" Attribute="ProductType" Description="Type" />
  <Attribute InternalName="ProductPrice" Attribute="ProductPrice" Description="Price"
             ElementRelativePosition="New cell" />
</Group>
```

This produces a 2-column layout: ProductId | ProductDescription in first row, ProductType | ProductPrice in second row, with columns vertically aligned.

---

# ALLOW SELECTION

When `AllowSelection="True"` on a Grid, clicking a row selects it visually. The developer handles selection logic in the generated subroutine.

```xml
<Grid InternalName="GridProducts" BaseTrn="Product" AllowSelection="True" GenerateOnLineActivateEvent="True">
  ...
</Grid>
```

When `GenerateOnLineActivateEvent="True"`, K2BTools generates a call to `U_OnLineActivate({InternalName})` inside the `Grid.OnLineActivate` event. The developer implements this subroutine to react to row selection.

---

# SELECTION SUMMARY

When a grid has multi-row selection enabled (via `ForceMultirow="True"` or an action with `RowSelection="Multiple"`), set `GenerateSelectionSummary="True"` to display selected items in a persistent list alongside the grid.

Display modes (configured via the grid's `ResponsiveLayoutObject`):
- **Below** — Summary list below the grid
- **Tab** — Summary as a tab next to grid content
- **Right** — Summary panel on the right side

---

# ATTRIBUTES NODE (Section)

The `<Attributes>` node (not to be confused with individual `<Attribute>` elements) creates a section displaying variables and/or attributes — showing a **single instance** (unlike grids that show multiple rows).

Use cases:
- Display result of an operation
- Custom view of a transaction (different from display mode)
- Insert/Update/Delete using a Business Component
- Parameter selection before calling a procedure

**Key properties:**
- `Title` — When set, displays the section as a card
- `Collapsible` / `StartCollapsed` — Allow collapsing (only when Title is set)
- `SDTorBC` / `SDTorBCLevel` — Bind to an SDT or Business Component
- `DescriptionsLayout` — `"Top"` (labels above fields) or `"Left"` (labels to the left)
- `ShowBorders` — Show card borders

**Child nodes:** Columns, Variable, Attribute, Group, Tabs, LineSeparator, Action, ActionGroups, TextBlock, WebComponent

---

# COLUMNS NODE (Multi-Column Layout)

When `<Columns>` is used **outside** a Grid (inside Group, Tab, or Attributes), it divides the screen vertically into `<Column>` children.

**Properties:**
- `ContentDistribution`:
  - `"ColumnPercentages"` — Each column sized via `ResponsiveSizes` (responsive table, widths adapt per screen size)
  - `"Flow"` — Columns sized by intrinsic content width (flex layout)
- `ResponsiveSizes` — JSON defining column widths per screen breakpoint (only for ColumnPercentages)

```xml
<Columns InternalName="TwoColLayout" ContentDistribution="ColumnPercentages">
  <Column InternalName="ColLeft">
    <Attribute InternalName="ProductName" Attribute="ProductName" />
    <Attribute InternalName="ProductCategory" Attribute="ProductCategory" />
  </Column>
  <Column InternalName="ColRight">
    <Attribute InternalName="ProductPrice" Attribute="ProductPrice" />
    <Attribute InternalName="ProductStock" Attribute="ProductStock" />
  </Column>
</Columns>
```

---

# USER SUBROUTINES (GENERAL)

K2BWebPanelDesigner generates subroutines that the developer can extend. The `{InternalName}` is replaced with the grid's or node's `InternalName`.

**IMPORTANT:** All custom code MUST be placed inside `U_` subroutines (e.g., `U_LoadRowVars`, `U_PrepareDataProvider`, `U_OnLineActivate`, etc.). Code placed in any other event (Start, Refresh, Load, Grid.Load, etc.) will be **overwritten** by the WebPanelDesigner when regenerating the panel. Only `U_` subroutines are preserved across regeneration cycles.

| Subroutine | Grid Type | Purpose |
|---|---|---|
| `U_OpenPage` | — (page level) | Executed once on first page load. Use for one-time initialization. |
| `U_StartPage` | — (page level) | Executed on every page load (GET and POST). Use for per-request setup. |
| `U_RefreshPage` | — (page level) | Executed on every postback. Use for post-action logic. |
| `U_<ActionId>` | Any | Action implementation. Called when user clicks the action. |
| `U_LoadRowVars({InternalName})` | All grid types | Load variables/actions per row. Set `&LoadRow_` to skip rows. |
| `U_WhenNone({InternalName})` | Inferred For Each | Called when no records exist |
| `U_PrepareDataProvider({InternalName})` | DataProvider/Procedure | Map filter variables to DP parameters before invocation |
| `U_LoadSDT({InternalName})` | SDT/BC (root level) | Load SDT contents |
| `U_LoadEvent({InternalName})` | No base table (ManagedByDeveloper) | Full iteration control |
| `U_OnLineActivate({InternalName})` | Any (with AllowSelection) | Handle row selection click |
| `U_Search({InternalName})` | Any | Executed when search button is pressed |
| `U_PagingFirst({InternalName})` | Any (with paging subroutines enabled) | Before navigating to first page |
| `U_PagingPrevious({InternalName})` | Any (with paging subroutines enabled) | Before navigating to previous page |
| `U_PagingNext({InternalName})` | Any (with paging subroutines enabled) | Before navigating to next page |
| `U_PagingLast({InternalName})` | Any (with paging subroutines enabled) | Before navigating to last page |

---

# ACTIONS

Action nodes define clickable elements. Their behavior is implemented by the developer in a generated `U_` subroutine.

## Action Classes

1. **In-grid actions** — Placed inside `<Columns>` (grid columns). Appear per-row (typically as icons).
2. **Standalone actions** — Placed inside `<Actions>`. Appear in the toolbar area (buttons, text links, or images).
3. **Combobox actions** — Placed inside an `<ActionGroup>`. Appear as items in a dropdown menu.

## Action Implementation

When an action is clicked, K2BTools executes the subroutine `U_<ActionId>` where `<ActionId>` is the action's `InternalName`. **All action logic MUST be placed in this subroutine.**

```xml
<Action InternalName="ExportPDF" Caption="Export PDF" Position="Top (Right)" />
```
→ Implement logic in subroutine: `Sub 'U_ExportPDF'`

## Action Properties (Complete)

| Property | Description |
|---|---|
| `InternalName` | (required) Unique identifier. Used as subroutine name: `U_<InternalName>` |
| `Type` | `"Button"`, `"Text"`, `"Image"`. Button not available in grid columns. Image not available in action groups. |
| `Caption` | Display text (for Button and Text types) |
| `Image` | Image object name (for Image type). Common: `K2BActionDisplay`, `K2BActionUpdate`, `K2BActionDelete`, `K2BActionInsert` |
| `Position` | Standalone: `"Top (Right)"`, `"Top (Left)"`. In-grid: `"InGrid"` (implicit) |
| `Condition` | Runtime expression to disable/hide the action |
| `DisableType` | `"Disable"` (greyed out) or `"Hide"` (invisible) when condition is false |
| `Tooltip` | Tooltip text (not available in combobox actions) |
| `AlternateText` | Alt text for Image actions (accessibility) |
| `Confirm` | `"True"` / `"False"` — Prompt user for confirmation before executing |
| `ConfirmMessageExpression` | Confirmation message (must be between quotes) |
| `RowSelection` | `"None"`, `"Single"`, `"Multiple"` — Receive info about selected grid rows. Only for actions in `<Actions>` inside a Grid. |
| `MoveToOverflowMenu` | `"Never"`, `"InExtraSmall"`, `"InSmallAndLower"`, `"InMediumAndLower"`, `"Always"` — Responsive overflow behavior (in-grid only) |
| `ElementRelativePosition` | `"New row"`, `"New cell"`, `"Same cell"` — Only for actions inside Attributes nodes |
| `BeforeCaptionIconSource` | `"Image"` or `"Iconset"` — Icon before caption (Button only) |
| `BeforeCaptionIconImage` | Image name for before-caption icon |
| `AfterCaptionIconSource` | `"Image"` or `"Iconset"` — Icon after caption (Button only) |
| `AfterCaptionIconImage` | Image name for after-caption icon |
| `Class` | Theme class for the action control |

## Action Subroutines

| Subroutine | When |
|---|---|
| `U_<ActionId>` | Executed when user clicks the action. Place all action logic here. |
| `U_ConfirmationRequired(<ActionId>)` | Before execution, when `Confirm="True"`. Use to dynamically decide if confirmation is needed. |

---

# K2BTOOLS CONTROLS

## Available Controls
- Dynamic Combo Box K2BTools
- Suggest K2BTools
- Masked Input K2BTools
- Numeric Input K2BTools
- Phone Input K2BTools
- Datepicker K2BTools
- Split Datepicker K2BTools
- Image Region Selector K2BTools
- Stepper K2BTools
- Switch

## Dynamic Layouts
- CardPhotoActions
- CardWithSummary
- PhotoWithTitle
- SimplePriceList
- StructuredList
- Timeline

---

# ADVANCED FEATURES

## Conditional Pills (Dynamic Badges)
```xml
<Attribute InternalName="InvoiceTotal" Attribute="InvoiceTotal" Visible="True"
           ConditionalPills="[{&quot;condition&quot;:&quot;InvoicePaymentReceived&quot;,&quot;text&quot;:&quot;Paid&quot;,&quot;class&quot;:&quot;K2BT_PillLightSuccess&quot;}]" />
```
Classes: `K2BT_PillError` (red), `K2BT_PillLightSuccess` (green), `K2BT_PillLightError` (orange)

### ShowPillsOnly
Controls what the column renders when it has pills attached:
- `ShowPillsOnly="True"` — shows **only the pill(s)**, hiding the column's field value. Use it when the pill fully replaces the value (e.g. a status/type column rendered as a badge).
- `ShowPillsOnly="False"` (default) — shows the **field value together with the pill** next to it.

```xml
<Attribute InternalName="ProductType" Attribute="ProductType" Visible="True"
           ConditionalPills="[{&quot;condition&quot;:&quot;ProductTypeIsPremium&quot;,&quot;text&quot;:&quot;Premium&quot;,&quot;class&quot;:&quot;K2BT_PillLightSuccess&quot;}]"
           ShowPillsOnly="True" />
```

## Row Detail (Expandable Detail)
```xml
<Columns InternalName="Columns"
         RowDetailWebComponent="InvoiceComponent"
         RowDetailWebComponentParameters="InvoiceCode">
  <!-- columns -->
</Columns>
```

## Conditional Row Classes
```xml
<Columns InternalName="Columns"
         ConditionalRowClasses="[{&quot;condition&quot;:&quot;InvoiceExpired&quot;,&quot;className&quot;:&quot;Row_Red&quot;}]">
  <!-- columns -->
</Columns>
```

## Wizard Step WebComponent Pattern

A Wizard (`WizardMain`) is a WebPanel that contains multiple steps, each implemented as a separate WebComponent. Data flows between steps via a shared SDT serialized as JSON.

### Wizard Host (WebPanel)
The host contains the `<WizardMain>` designer node and manages step navigation. Key properties:
- `SDT` — The shared SDT type used across all steps
- Each `<WizardStep>` references a WebComponent by name

Key `U_` subroutines in the host:
- `U_InitializeWizardSDT(WizardMain)` — Pre-load the shared SDT before the first step
- `U_LoadStep(WizardMain)` — Executed after each step is loaded (customize per-step behavior)
- `U_WizardNext` — Executed after the Next action advances a step
- `U_BeforeComplete(WizardMain)` — Final validation/action before wizard finishes (set `&IsValid_WizardMain = False` to block)
- `U_AfterComplete(WizardMain)` — Executed after all steps are completed (redirect, show message, etc.)

### Wizard Step (WebComponent)
Each step is a `WebComponent` with:
- `WizardMainPanel` property on `<WebForm>` pointing to the host WebPanel name
- Rule: `parm(In:&WizardData);` — receives the shared SDT as JSON
- An `<Attributes>` section bound to the shared SDT via `SDTorBC`
- `U_WizardConfirm` subroutine for step validation

The step receives the SDT data, displays/edits it, and passes it back to the host on "Next".

### Step WebComponent Template
```
WebComponent MyWizardStep
{
	#Designer
		<WebForm InternalName="WebForm" WizardMainPanel="MyWizardHost">
		  <Attributes InternalName="StepData" SDTorBC="MySharedSDT">
		    <SDTVariable SDT="MySharedSDT" Field="FieldA" InternalName="FieldA" />
		    <SDTVariable SDT="MySharedSDT" Field="FieldB" InternalName="FieldB" />
		  </Attributes>
		</WebForm>
	#End

	#Rules
		//+ K2BTools.WPD.Fixed
		parm(In:&WizardData);
		//-
	#End

	#Events
	#End

	#Variables
		WizardData [ DataType = 'Character(20)', Collection = 'False' ]
	#End

	#Properties
		Name = "MyWizardStep"
		Type = "Component"
	#End
}
```

After importing and exporting, K2B generates `U_WizardConfirm`:
```genexus
Sub 'U_WizardConfirm'
    // Validate step data. Set &WizardStepCompleted = False to stay on this step.
    If &StepData_SDT.FieldA.IsEmpty()
        &WizardStepCompleted = False
        K2BToolsMsg.Call("Field A is required", K2BToolsMessageType.Error)
    EndIf
EndSub
```

### Wizard Subroutines Summary

| Subroutine | Location | Purpose |
|---|---|---|
| `U_InitializeWizardSDT(WizardMain)` | Host WebPanel | Pre-load shared SDT before first step |
| `U_LoadStep(WizardMain)` | Host WebPanel | After each step loads (customize UI per step) |
| `U_WizardNext` | Host WebPanel | After advancing to next step |
| `U_BeforeComplete(WizardMain)` | Host WebPanel | Final validation/processing before completion |
| `U_AfterComplete(WizardMain)` | Host WebPanel | After wizard completes (redirect, message) |
| `U_WizardConfirm` | Step WebComponent | Validate step data; set `&WizardStepCompleted = False` to block navigation |

---

# EXAMPLES

## Example 1: Grid with filters, orders, and actions
```xml
<WebForm InternalName="WebForm" Title="Product List">
  <Grid InternalName="GridProducts" BaseTrn="MyTransaction">
    <Columns InternalName="GridCols">
      <Attribute InternalName="ColId" Attribute="ProductId" Visible="False" IncludeInGridKey="True" />
      <Attribute InternalName="ColName" Attribute="ProductName" Visible="True" />
      <Attribute InternalName="ColPrice" Attribute="ProductPrice" Visible="True" />
      <Action InternalName="ActView" Type="Image" Image="K2BActionDisplay" />
      <Action InternalName="ActEdit" Type="Image" Image="K2BActionUpdate" />
      <Action InternalName="ActDelete" Type="Image" Image="K2BActionDelete" />
    </Columns>
    <Filters InternalName="GridFilters">
      <Variable InternalName="FilterName" BasedOn="ProductName:Attribute" />
      <Variable InternalName="FilterStatus" BasedOn="ProductStatus:Attribute">
        <ControlInfo InternalName="CIStatus" Controltype="Combo Box" Values="All:,Active:ACTIVE,Inactive:INACTIVE" />
      </Variable>
    </Filters>
    <Orders InternalName="GridOrders">
      <SimpleOrder InternalName="OrderProductName" Attribute="ProductName" />
      <SimpleOrder InternalName="OrderProductPrice" Attribute="ProductPrice" />
    </Orders>
    <Actions InternalName="GridActions">
      <Action InternalName="ActInsert" Position="Top (Right)" Caption="New" />
      <Action InternalName="ActExport" Position="Top (Right)" Caption="Export" />
    </Actions>
  </Grid>
</WebForm>
```

## Example 2: Form with groups and columns
```xml
<WebForm InternalName="WebForm" Title="Product Detail">
  <Group InternalName="GrpBasic" Title="Basic Information">
    <Columns InternalName="ColsBasic">
      <Column InternalName="ColLeft">
        <Attribute InternalName="AttrName" Attribute="ProductName" Description="Name" />
        <Attribute InternalName="AttrCategory" Attribute="CategoryId" Description="Category">
          <ControlInfo InternalName="CICat" Controltype="Dynamic Combo Box" ItemValues="CategoryId:Attribute" Itemdescriptions="CategoryName:Attribute" />
        </Attribute>
      </Column>
      <Column InternalName="ColRight">
        <Attribute InternalName="AttrPrice" Attribute="ProductPrice" Description="Price" />
        <Attribute InternalName="AttrStock" Attribute="ProductStock" Description="Stock" />
      </Column>
    </Columns>
  </Group>
  <Actions InternalName="FormActions">
    <Action InternalName="ActSave" Caption="Save" />
    <Action InternalName="ActCancel" Caption="Cancel" />
  </Actions>
</WebForm>
```

## Example 3: Tabs with grid + form
```xml
<WebForm InternalName="WebForm" Title="Product Management">
  <Tabs InternalName="MainTabs">
    <Tab InternalName="TabList" Caption="Listing">
      <Grid InternalName="GridProducts" BaseTrn="Product">
        <Columns InternalName="GridCols">
          <Attribute InternalName="ColId" Attribute="ProductId" Visible="False" IncludeInGridKey="True" />
          <Attribute InternalName="ColName" Attribute="ProductName" Visible="True" />
          <Action InternalName="ActView" Type="Image" Image="K2BActionDisplay" />
        </Columns>
      </Grid>
    </Tab>
    <Tab InternalName="TabDetail" Caption="Detail">
      <Group InternalName="GrpInfo" Title="Product Info">
        <Attribute InternalName="AttrName" Attribute="ProductName" Description="Name" />
        <Attribute InternalName="AttrPrice" Attribute="ProductPrice" Description="Price" />
      </Group>
      <Actions InternalName="DetailActions">
        <Action InternalName="ActSave" Caption="Save" />
      </Actions>
    </Tab>
  </Tabs>
</WebForm>
```

## Example 4: Grid with Combo Box and Dynamic Combo Box
```xml
<WebForm InternalName="WebForm" Title="Listado de Productos">
  <Grid InternalName="GridProductos" GenerateSelectionSummary="False" BaseTrn="Producto">
    <Columns InternalName="Columns">
      <Attribute InternalName="ProductoId" Attribute="ProductoId" Visible="False" IncludeInGridKey="True" />
      <Attribute InternalName="ProductoCodigo" Attribute="ProductoCodigo" Visible="True" />
      <Attribute InternalName="ProductoNombre" Attribute="ProductoNombre" Visible="True" />
      <Attribute InternalName="CategoriaId" Attribute="CategoriaId" Visible="True">
        <ControlInfo InternalName="CICat" Controltype="Dynamic Combo Box" ItemValues="CategoriaId:Attribute" Itemdescriptions="CategoriaNombre:Attribute" />
      </Attribute>
      <Attribute InternalName="ProductoEstado" Attribute="ProductoEstado" Visible="True">
        <ControlInfo InternalName="CIEstado" Controltype="Combo Box" Values="Activo:ACTIVO,Inactivo:INACTIVO" />
      </Attribute>
      <Action InternalName="Ver" Type="Image" Image="K2BActionDisplay" />
      <Action InternalName="Modificar" Type="Image" Image="K2BActionUpdate" />
      <Action InternalName="Eliminar" Type="Image" Image="K2BActionDelete" />
    </Columns>
    <Actions InternalName="Actions">
      <Action InternalName="Ingresar" Position="Top (Right)" />
    </Actions>
  </Grid>
</WebForm>
```

## Example 5: Action with condition
```xml
<Action InternalName="Imprimir"
        Type="Image"
        Position="Top (Right)"
        Image="Impresora"
        AlternateText=""
        Condition="Estado = 'A' and not ProductoId.IsEmpty()"
        DisableType="Hide" />
```

## Example 6: LayoutGrid with cards
> The `Key` node is REQUIRED (see "LayoutSlotName Values"). Omitting it crashes the text-format parser. Node order does not matter — it is shown first here only for emphasis.
This example maps all four slot kinds of `CardPhotoActions` (see the node-type table under "LayoutSlotName Values"): `LayoutVariableNode` for `Title`/`Photo`/`Key`, `<Action>` for `MainAction`, the `<Actions>` container for `Actions`, and the `<Attributes>` container for `SecondaryAttributes`.
```xml
<LayoutGrid InternalName="GridProduct" BaseTrn="Product">
  <LayoutContent InternalName="LayoutContent" DynamicLayout="CardPhotoActions" DefaultSource="Attribute" ColumnsLarge="3">
    <LayoutVariableNode InternalName="ProductId" Source="Attribute" Attribute="ProductId" IncludeInGridKey="True" LayoutSlotName="Key" />
    <LayoutVariableNode InternalName="ProductDescription" Source="Attribute" Attribute="ProductDescription" LayoutSlotName="Title" />
    <LayoutVariableNode InternalName="ProductPhoto" Source="Attribute" Attribute="ProductPhoto" LayoutSlotName="Photo" />
    <Action InternalName="Action" Type="Button" LayoutSlotName="MainAction" />
    <Actions InternalName="Actions" LayoutSlotName="Actions" />
    <Attributes InternalName="SecondaryAttributes" LayoutSlotName="SecondaryAttributes" DescriptionsLayout="Top">
      <Attribute InternalName="ProductPrice" Attribute="ProductPrice" Visible="True" />
      <Attribute InternalName="ProductStock" Attribute="ProductStock" Description="Stock" />
    </Attributes>
  </LayoutContent>
  <Filters InternalName="Filters" Includegenericfilter="True">
    <Variable InternalName="ProductDescription_Filter" BasedOn="ProductDescription:Attribute" />
  </Filters>
</LayoutGrid>
```

## Example 7: Grid with advanced filters
```xml
<Grid InternalName="GridInvoice" BaseTrn="Invoice">
  <Columns InternalName="Columns">
    <Attribute InternalName="InvoiceCode" Attribute="InvoiceCode" Visible="True" />
    <Attribute InternalName="InvoiceDate" Attribute="InvoiceDate" Visible="True" />
  </Columns>
  <Filters InternalName="Filters" Includegenericfilter="True">
    <Variable InternalName="InvoiceDate_Filter" BasedOn="InvoiceDate:Attribute" Type="DateRange" DateRangeType="Semantic" />
    <Variable InternalName="CustomerId_Filter" BasedOn="CustomerId:Attribute" Type="Multiple" MultipleFilterType="MultipleCombo">
      <ControlInfo InternalName="ControlInfo" Controltype="Dynamic Combo Box K2BTools" Itemdescriptions="CustomerName:Attribute" />
    </Variable>
  </Filters>
  <Orders InternalName="Orders">
    <SimpleOrder InternalName="OrderInvoiceCode" Attribute="InvoiceCode" />
  </Orders>
</Grid>
```

## Example 8: WizardMain (multi-step flow)
```xml
<WizardMain InternalName="WizardMain" SDT="PaymentInvoiceSDT">
  <WizardSteps InternalName="WizardSteps">
    <WizardStep InternalName="WizardStep" WebComponent="SelectInvoice" Title="Select Invoice" />
    <WizardStep InternalName="InvoicePaymentDetails" WebComponent="InvoicePaymentDetails" Title="Payment Details" />
    <WizardStep InternalName="PaymentConfirmation" WebComponent="PaymentConfirmation" />
  </WizardSteps>
</WizardMain>
```

## Example 9: K2BTools controls
### Dynamic Combo Box K2BTools
```xml
<Variable InternalName="CustomerId" BasedOn="CustomerId:Attribute">
  <ControlInfo InternalName="ControlInfo" Controltype="Dynamic Combo Box K2BTools"
               Itemdescriptions="CustomerName:Attribute"
               ItemImages="CustomerPhoto:Attribute"
               Includesearch="True"
               EnableAddItem="True"
               Additemcomponent="Customer" />
</Variable>
```

### Suggest K2BTools
```xml
<Variable InternalName="CustomerId" BasedOn="CustomerId:Attribute">
  <ControlInfo InternalName="ControlInfo" Controltype="Suggest K2BTools"
               Itemdescriptions="CustomerName:Attribute"
               ItemImages="CustomerPhoto:Attribute"
               ItemDetails="CustomerNumber:Attribute" />
</Variable>
```

### Datepicker K2BTools
```xml
<Variable InternalName="InvoiceDate" BasedOn="InvoiceDate:Attribute">
  <ControlInfo InternalName="ControlInfo" Controltype="Datepicker K2BTools"
               MinimumDateExpression="Date.New(2020, 1, 1)"
               MaximumDateExpression="ServerDate()"
               FieldControlType="ComboBox" />
</Variable>
```

### Masked Input K2BTools
```xml
<Variable InternalName="CreditCard" BasedOn="Character(20)">
  <ControlInfo InternalName="ControlInfo" Controltype="Masked Input K2BTools"
               Mask="9999 9999 9999 9999" />
</Variable>
```

## Example 10: Advanced filters
### Date range with semantic ranges
```xml
<Variable InternalName="InvoiceDate_Filter" BasedOn="InvoiceDate:Attribute"
         Type="DateRange"
         DateRangeType="Semantic"
         SemanticDateRangeSet="{&quot;defaultSetName&quot;:&quot;DaysPeriodsBackwards&quot;}"
         DateRangeManualInputType="TwoFields" />
```

### Multiple filter (collection-based)
To filter by multiple values, set `Iscollection="True"` and add a `<ControlInfo>` with a multi-selection control:
```xml
<Variable InternalName="CustomerId_Collection" BasedOn="CustomerId:Attribute"
         Iscollection="True">
  <ControlInfo InternalName="ControlInfo" Controltype="Dynamic Combo Box K2BTools"
               Itemdescriptions="CustomerName:Attribute" />
</Variable>
```

### String Search (multi-field search)
```xml
<Variable InternalName="StringSearch" BasedOn="Character(100)"
         Type="StringSearch"
         ConditionAttributes="ProductDescription,ProductType,ProductPrice" />
```

## Example 11: Grid based on DataProvider
```xml
<WebForm InternalName="WebForm" Title="Products (DataProvider)">
  <Grid InternalName="GridProducts" Datasource="ProductDataProvider">
    <Columns InternalName="Columns">
      <Variable InternalName="ProductId" BasedOn="ProductId:Attribute" Visible="False" IncludeInGridKey="True" Loadfromdatasource="True" />
      <Variable InternalName="ProductDescription" BasedOn="ProductDescription:Attribute" Visible="True" Loadfromdatasource="True" />
      <Variable InternalName="ProductPrice" BasedOn="ProductPrice:Attribute" Visible="True" Loadfromdatasource="True" />
    </Columns>
    <Filters InternalName="Filters">
      <Variable InternalName="ProductDescription_Filter" BasedOn="ProductDescription:Attribute" />
    </Filters>
    <Orders InternalName="Orders">
      <Order InternalName="Order" Name="Description" />
      <Order InternalName="Order1" Name="Price" />
    </Orders>
  </Grid>
</WebForm>
```
Variables with `Loadfromdatasource="True"` are automatically matched to the DataProvider's output SDT fields by name. Filter variables are auto-mapped to DataProvider parameters with matching names. Use `<Order>` nodes (with `Name` matching the DataProvider's order parameter values) instead of `<SimpleOrder>`.

## Example 12: Grid with inferred For Each
```xml
<WebForm InternalName="WebForm" Title="Active Products">
  <Grid InternalName="GridProducts" Conditions="ProductStatus = ProductStatusDomain.Active">
    <Columns InternalName="Columns">
      <Variable InternalName="ProductId" BasedOn="ProductId:Attribute" Visible="False" IncludeInGridKey="True" LoadFromAttribute="True" />
      <Variable InternalName="ProductName" BasedOn="ProductName:Attribute" Visible="True" LoadFromAttribute="True" />
      <Variable InternalName="ProductPrice" BasedOn="ProductPrice:Attribute" Visible="True" LoadFromAttribute="True" />
    </Columns>
    <Filters InternalName="Filters">
      <Variable InternalName="ProductName_Filter" BasedOn="ProductName:Attribute" />
    </Filters>
    <Orders InternalName="Orders">
      <SimpleOrder InternalName="OrderProductName" Attribute="ProductName" />
    </Orders>
  </Grid>
</WebForm>
```
All columns use `Variable` nodes with `LoadFromAttribute="True"` — this makes the grid an "inferred for each" type. K2BTools generates a `For Each` with the specified `Conditions`.

## Example 13: Attributes section with Business Component
```xml
<WebForm InternalName="WebForm" Title="Edit Product">
  <Attributes InternalName="AttrSection" Title="Product Data" SDTorBC="Product" Collapsible="True" DescriptionsLayout="Left">
    <Attribute InternalName="ProductName" Attribute="ProductName" Description="Name" />
    <Attribute InternalName="ProductPrice" Attribute="ProductPrice" Description="Price"
               ElementRelativePosition="New cell" />
    <Attribute InternalName="ProductCategory" Attribute="ProductCategory" Description="Category" />
    <Attribute InternalName="ProductStock" Attribute="ProductStock" Description="Stock"
               ElementRelativePosition="New cell" />
  </Attributes>
  <Actions InternalName="FormActions">
    <Action InternalName="ActSave" Caption="Save" />
    <Action InternalName="ActCancel" Caption="Cancel" />
  </Actions>
</WebForm>
```
Uses `DescriptionsLayout="Left"` for label-left layout and `ElementRelativePosition="New cell"` for 2-column form arrangement.

## Example 14: Master-Detail with AllowSelection and WebComponent
A Customers grid on the left with AllowSelection. When a row is clicked, a detail WebComponent shows on the right and a related Invoices grid is filtered.
```xml
<WebForm InternalName="WebForm">
  <Columns InternalName="Columns1">
    <Column InternalName="Column">
      <Grid InternalName="GridCustomer" AllowSelection="True" Title="Customers" Collapsible="True" BaseTrn="Customer">
        <Columns InternalName="Columns" RowsPerPage="10">
          <Attribute InternalName="CustomerId" Attribute="CustomerId" Visible="True" />
          <Attribute InternalName="CustomerFirstName" Attribute="CustomerFirstName" Visible="True" />
          <Attribute InternalName="CustomerLastName" Attribute="CustomerLastName" Visible="True" />
        </Columns>
        <Filters InternalName="Filters" Includegenericfilter="True">
          <Variable InternalName="CustomerName_Filter" BasedOn="CustomerName:Attribute" />
        </Filters>
        <Orders InternalName="Orders">
          <SimpleOrder InternalName="OrderCustomerId" Attribute="CustomerId" />
        </Orders>
      </Grid>
    </Column>
    <Column InternalName="Column1">
      <Attributes InternalName="DetailSection" Title="Detail" Collapsible="True">
        <WebComponent InternalName="WebComponent" />
      </Attributes>
    </Column>
  </Columns>
  <Grid InternalName="GridInvoice" Title="Invoices" Collapsible="True" StartCollapsed="True" BaseTrn="Invoice">
    <Columns InternalName="Columns2" RowsPerPage="10">
      <Attribute InternalName="InvoiceCode" Attribute="InvoiceCode" Visible="True" />
      <Attribute InternalName="InvoiceDate" Attribute="InvoiceDate" Visible="True" />
      <Attribute InternalName="InvoiceTotal" Attribute="InvoiceTotal" Visible="True" />
    </Columns>
    <Filters InternalName="Filters1">
      <Variable InternalName="CustomerId_Filter" BasedOn="CustomerId:Attribute" Visible="False" />
    </Filters>
    <Orders InternalName="Orders1">
      <SimpleOrder InternalName="OrderInvoiceCode" Attribute="InvoiceCode" />
    </Orders>
  </Grid>
</WebForm>
```
The developer implements the selection logic in `U_OnLineActivate(GridCustomer)`:
```genexus
Sub 'U_OnLineActivate(GridCustomer)'
    &CustomerId_Filter = CustomerId
    WebComponent.Object = CustomerDetail2.Create(K2BTrnMode.Display, &CustomerId_Filter)
    GridInvoice.Refresh()
EndSub
```

## Example 15: LayoutGrid with card actions
```xml
<WebForm InternalName="WebForm">
  <LayoutGrid InternalName="GridProduct" BaseTrn="Product">
    <LayoutContent InternalName="LayoutContent" DynamicLayout="CardPhotoActions" DefaultSource="Attribute">
      <LayoutVariableNode InternalName="ProductDescription" Source="Attribute" Attribute="ProductDescription" LayoutSlotName="Title" />
      <LayoutVariableNode InternalName="ProductPhoto" Source="Attribute" Attribute="ProductPhoto" LayoutSlotName="Photo" />
      <LayoutVariableNode InternalName="ProductId" Source="Attribute" Attribute="ProductId" IncludeInGridKey="True" LayoutSlotName="Key" />
      <Action InternalName="Action" Type="Button" LayoutSlotName="MainAction" />
      <Actions InternalName="Actions" LayoutSlotName="Actions">
        <Action InternalName="Update" Image="K2BActionUpdate" />
        <Action InternalName="Delete" Image="K2BActionDelete" />
      </Actions>
      <Attributes InternalName="SecondaryAttrs" LayoutSlotName="SecondaryAttributes">
        <Attribute InternalName="ProductType" Attribute="ProductType" Visible="True" />
        <Attribute InternalName="ProductPrice" Attribute="ProductPrice" Visible="True" />
      </Attributes>
    </LayoutContent>
    <Filters InternalName="Filters" Includegenericfilter="True">
      <Variable InternalName="ProductDescription_Filter" BasedOn="ProductDescription:Attribute" />
    </Filters>
    <Orders InternalName="Orders">
      <SimpleOrder InternalName="OrderProductId" Attribute="ProductId" />
      <SimpleOrder InternalName="OrderProductDescription" Attribute="ProductDescription" />
    </Orders>
  </LayoutGrid>
</WebForm>
```
Each action generates a `U_<ActionId>` subroutine. Implement the logic there:
```genexus
Sub 'U_Action'
    // Main action on card click
    Product.Call(K2BTrnMode.Display, &ProductId)
EndSub

Sub 'U_Update'
    Product.Call(K2BTrnMode.Update, &ProductId)
EndSub

Sub 'U_Delete'
    Product.Call(K2BTrnMode.Delete, &ProductId)
EndSub
```

---

# CONSTRAINTS
- Use ONLY tags from the valid node types table; any other tag is silently ignored and children are lost
- Every node MUST have a unique `InternalName` attribute across the entire XML
- The root element MUST be `<WebForm>`
- Use `BasedOn` in reversed format: `AttributeName:Attribute` (NOT `Attribute:AttributeName`)
- K2BTools controls MUST include the "K2BTools" suffix in `Controltype`
- Do NOT modify or interpret the `#Layout` section; it is auto-generated from the designer
- Do NOT use invented tags (`<ContentLayout>`, `<Section>`, `<Row>`, `<Cell>`, `<Panel>`, `<Container>`)
- Do NOT encode XML with HTML entities (`&lt;`, `&gt;`); send plain XML
- Do NOT declare standard variables (Err, Errmsg, Msg, Window, HttpRequest, Pgmname, Pgmdesc); they are automatic
- Do NOT place rule-syntax code (`Error(...) if ...`) inside events; use the `#Rules` section
- Do NOT use complex `For Each` inside WebPanel events; delegate to Procedures
- Always include the primary key in grid columns with `IncludeInGridKey="True"`
- All custom event code MUST go inside `U_` subroutines only; any code in other events (Start, Refresh, Load, Grid.Load) will be overwritten by the WebPanelDesigner on regeneration
- Do NOT include `#Layout` section in the `.gx` file; it is exported as `<Name>.web.xml` automatically
- Do NOT write user event code in the initial import file; follow the 4-step workflow
- Do NOT create `U_` subroutines manually; they are generated by K2B after the first import
- Do NOT modify code sections marked "Do Not Change" — only edit "To Be Completed By User" subroutines
- Always use `rootDirectory` parameter when exporting/importing to ensure correct file resolution

---

# COMMON ERRORS

## Error 1: Encoded formdesigner XML
**Error:** `Data at the root level is invalid. Line 1, position 1.`
**Cause:** XML sent with HTML entities (`&lt;`, `&gt;`) instead of plain XML.
```json
// ❌ Incorrect
{ "formdesigner": "&lt;WebForm&gt;..." }

// ✅ Correct
{ "formdesigner": "<WebForm InternalName=\"WebForm\" Title=\"Mi Panel\">...</WebForm>" }
```

## Error 2: Standard variables declared
Standard variables (Err, Errmsg, Msg, Window, HttpRequest, Pgmname, Pgmdesc) are available automatically. Declaring them causes errors.

## Error 3: Rule code in Events
```genexus
// ❌ Incorrect
Event Start
  Error('Invalid data') if &Data.IsEmpty();
Endevent

// ✅ Correct — place in Rules section
Rules:
  Error('Invalid data') if &Data.IsEmpty();
```

## Error 4: Complex For Each in WebPanel
```genexus
// ❌ Incorrect
For Each Table
  Where Field1 = &Value1 when not &Value1.IsEmpty()
  Where Field2 = &Value2 when not &Value2.IsEmpty()
EndFor

// ✅ Correct — delegate to Procedure
ProcedureList.Call(&Value1, &Value2, &Result)
```

## Error 5: Missing WebForm root
The XML MUST start with `<WebForm>` and end with `</WebForm>`. Without it, nothing works.

## Error 6: Using invented tags
Tags like `<ContentLayout>`, `<Section>`, `<Row>`, `<Cell>`, `<Panel>`, `<Container>` do NOT exist. They are silently ignored and all children are lost.

## Error 7: Wrong BasedOn format
In designer XML it's `AttrName:Attribute` (reversed). NOT `Attribute:AttrName`.

## Error 8: Duplicate InternalName
Each `InternalName` must be unique across the entire XML. Duplicates cause unpredictable behavior.

## Error 9: K2BTools Controltype without suffix
```xml
<!-- ❌ Incorrect -->
<ControlInfo Controltype="Dynamic Combo Box">

<!-- ✅ Correct -->
<ControlInfo Controltype="Dynamic Combo Box K2BTools">
```

## Error 10: Writing events before first import
**Error:** `src0265: Invalid attribute 'WCProduct'` / `src0216: 'Object' invalid property`
**Cause:** User code references layout controls (WebComponent, Grid controls) in the `.gx` before the layout has been generated by K2B.
**Solution:** Follow the 4-step import/export workflow. Never write event code that references layout controls in the initial `.gx` file.

## Error 11: SimpleOrder without InternalName
**Error:** `Missing internal name in node SimpleOrder`
**Cause:** The `InternalName` attribute was omitted from a `<SimpleOrder>` node.
**Solution:** Every node in the designer XML requires a unique `InternalName`, including `SimpleOrder`.
```xml
<!-- ❌ Incorrect -->
<SimpleOrder Attribute="ProductName" />

<!-- ✅ Correct -->
<SimpleOrder InternalName="OrderProductName" Attribute="ProductName" />
```

---

# AFTER GENERATING: PUT THE PANEL IN THE MENU

A panel nobody can reach is not a finished panel. If the KB has a K2BMenu instance and the
panel you just generated is **navigable on its own**, ask the developer whether it should
become a menu option, and where — read the menu instance first so the levels you offer are
the ones that actually exist:

> `SalesDashboard` is generated. Do you want it in `MainMenu`? The current levels are
> **Sales**, **Inventory** and **Administration** — or at the root, in a new level, or left out.

Which panels qualify:

| Generated object | Menu option? |
|---|---|
| WebPanel with **no parameters** | Yes — ask |
| WebPanel **with parameters** | Only with fixed values; offer it explicitly, never assume. The menu node then needs an `Arguments` child, one `Argument` per parameter, in order |
| **WebComponent** | No — it is embedded in a panel, not navigated to |

Then add a `WebObject` node to the chosen level of the menu instance, reimport it and run
`apply_pattern pattern: "K2BMenu", instanceName: "<menu>"`. The format and the workflow are in
`skills/K2BMenu.md` — it is pattern instance XML in an `#Instance` section, so none of the
`formdesigner` spellings (`InternalName`, `<Attribute>`, `BasedOn="X:Attribute"`) apply to it.

Skip the question when the KB has no menu instance, or when the developer already said where
the option goes or asked not to touch the menu.

---

# MODIFICATION WORKFLOW

## Changing designer properties that affect generated events

When a user requests a change to a property defined in the `#Designer` XML (e.g., `RowsPerPage`, grid title, filter defaults), follow this process:

1. **Modify ONLY the `#Designer` section** — update the XML attribute value
2. **Do NOT manually edit `#Events` or `#Variables`** — even if you see the old value hardcoded in generated code
3. **Import the file** — K2B will regenerate all "Do Not Change" events with the new values
4. **Export the file** — retrieve the cleanly regenerated version with consistent values

## Why

K2B auto-generates event code FROM the designer XML. Values like `RowsPerPage`, grid conditions, filter defaults, etc. appear both in the designer and in generated events. The designer is the single source of truth. Manually patching generated code creates inconsistency and will be overwritten on next regeneration.

## Rule

> If a requested change maps to a designer XML attribute, modify ONLY the designer. Never patch the derived value in generated events.

---

# IMPORT/EXPORT WORKFLOW

## File Structure
K2BWebPanelDesigner produces two files per object:
- `<Name>.gx` — Main artifact with `#Designer`, `#Events`, `#Variables`, `#Properties`, `#Rules`
- `<Name>.web.xml` — Layout artifact auto-generated by K2B from the designer XML

The `#Layout` section is FORBIDDEN inside the `.gx` file. K2B generates it automatically as `.web.xml`.

## The Problem
When a WebPanel has `U_` subroutines that reference controls from the generated layout (e.g., `WCProduct.Object = ...`), the import validator rejects the code because:
- On first import, the layout doesn't exist yet — controls are unknown
- K2B generates framework events internally (Start, Refresh, Grid.Load, OnLineActivate, etc.) and empty `U_` stub subroutines
- User code MUST be placed inside these generated `U_` stubs, not written from scratch

## Mandatory 4-Step Process

| Step | Action | Details |
|------|--------|---------|
| 1 | **Create** `.gx` with designer only | Include `#Designer`, `#Variables`, `#Properties`, `#Rules`. Leave `#Events` section EMPTY. |
| 2 | **Import** | K2B generates the layout (`.web.xml`) and internal framework events with empty `U_` subroutines. |
| 3 | **Export** with `rootDirectory` | Produces `src/<Name>.gx` at the module root with ALL generated events and empty `U_` stubs visible. |
| 4 | **Edit + Reimport** | Place user code inside existing `U_` subroutines (marked "To Be Completed By User") in the exported file. Reimport. |

## Rules
- NEVER write event code in the initial `.gx` file — the validator will reject layout control references
- ALWAYS use the exported `src/<Name>.gx` (at module root) as source of truth for reimport
- ONLY modify subroutines marked `// ---- K2BTools - To Be Completed By User ----`
- NEVER touch code marked `// ---- K2BTools - Do Not Change, Native Method ----` or `// ---- K2BTools - Do Not Change, Editor Method ----`
- The `.web.xml` is auto-generated — never create or modify it manually
- Use `rootDirectory` parameter (pointing to KB root) in both export and reimport operations
- Errors "Control Name required in [var:XX]" and "subroutine not used" are non-blocking K2B internal warnings — they do not prevent a successful import

## Example: WebPanel with WebComponent

Step 1 — Initial `.gx` (events empty):
```
WebPanel MyPanel
{
	#Designer
		<WebForm InternalName="WebForm" Title="My Panel">
		  <Grid InternalName="GridItems" BaseTrn="Item" AllowSelection="True" GenerateOnLineActivateEvent="True">
		    <Columns InternalName="Columns">
		      <Attribute InternalName="ItemId" Attribute="ItemId" Visible="False" IncludeInGridKey="True" />
		      <Attribute InternalName="ItemName" Attribute="ItemName" Visible="True" />
		    </Columns>
		  </Grid>
		  <Attributes InternalName="DetailSection" Title="Detail">
		    <WebComponent InternalName="WCDetail" />
		  </Attributes>
		</WebForm>
	#End

	#Events
	#End

	#Variables
		ItemId [ DataType = 'Attribute:ItemId' ]
	#End

	#Properties
		Name = "MyPanel"
		Style = "AriesCustom"
	#End
}
```

Step 3 — After export, K2B generates (among many events):
```genexus
Event GridItems.OnLineActivate
    // ---- K2BTools - Do Not Change, Editor Method ----
    Do 'U_OnLineActivate(GridItems)'
EndEvent

Sub 'U_OnLineActivate(GridItems)'
    // ---- K2BTools - To Be Completed By User ----
EndSub
```

Step 4 — Edit the exported file, fill the sub:
```genexus
Sub 'U_OnLineActivate(GridItems)'
    // ---- K2BTools - To Be Completed By User ----
    &ItemId = ItemId
    WCDetail.Object = Item.Create(K2BTrnMode.Display, &ItemId)
EndSub
```

Then reimport with `rootDirectory`.

## Module Placement
The object's module is determined by the directory where the `.gx` file is located during import:
- `src/<ModuleName>/<Name>.gx` → Object belongs to `<ModuleName>` module (requires `module.toml` in that directory)
- `src/<Name>.gx` → Object belongs to Root Module

Important:
- Only directories with `module.toml` are real GeneXus modules
- Directories without `module.toml` (like pattern-generated folders: `Product/`, `Customer/`) are grouping folders, NOT modules
- K2BEntityServices creates `<TransactionName>/` folders for its generated objects — these are NOT modules
- When creating a WebPanel in a specific module, place the initial `.gx` in that module's directory
- The export will produce the complete `.gx` (with events) and `.web.xml` in the same module directory
- The `rootDirectory` parameter in export/import must always point to the KB root (parent of `src/`)
