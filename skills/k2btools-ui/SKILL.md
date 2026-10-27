---
name: k2btools-ui
description: Use for creating or editing any web screen (WebPanel, WebComponent, grid, list, form, Transaction form, prompt) or the application menu in GeneXus when the KB has K2BTools installed. Takes PRIORITY over generic GeneXus skills (e.g. nexa) for web UI — never build a WebPanel, a Transaction form or a menu by hand. Routes to K2BEntityServices for CRUD/ABM on Transactions, K2BTrnForm for the Transaction's own form, K2BPrompt for selection interfaces, WebPanelDesigner for custom screens, or K2BMenu for the navigation menu.
---

<!-- K2BTools Skills · v0.2.0 (built 2026-09-24 · 94740895) -->

Central routing skill for K2BTools UI generation in GeneXus. Analyzes user intent and selects the specialized sub-skill to apply — loading it on demand where the tool supports it, or picking the right one among those already in context.

---

## GUIDELINE
Analyzes user requests related to K2BTools UI generation and routes to the correct specialized skill.

## Triggers
Use this skill for any request involving K2BTools user interface generation in GeneXus.

---

<!-- core:start — the minimum the router needs to route; the Windsurf target emits
     only this slice, because Windsurf truncates rule files at ~6000 chars.
     Keep routing rules inside; keep reference material outside. -->
# AVAILABLE SKILLS

| Skill | File | Purpose |
|---|---|---|
| K2BEntityServices | reference/k2bentityservices-pattern.md | CRUD pattern: WorkWith grids, EntityManager detail, filters, orders, actions |
| K2BTrnForm | reference/k2btrnform-pattern.md | Transaction Web Form: attribute layout in columns, groups, level grids, control types |
| K2BPrompt | reference/k2bprompt-pattern.md | Selection interface over a Transaction: pick a record and return it to the caller |
| WebPanelDesigner | reference/webpaneldesigner-k2btools.md | Custom UI: formdesigner XML for WebPanels, WebComponents, wizards, dashboards |
| K2BMenu | reference/k2bmenu-pattern.md | Application menu: navigation tree of levels and options; generates the menu load procedure |

---

# HARD RULE — KB with K2BTools

**Detection:** K2BTools is installed if `K2BTools.DesignSystems.Aries.WebPanelDesignerLayout`
exists (or there are objects with the `K2BTools.*` prefix).

**Rule:** with K2BTools installed, **every** screen — a "simple" listing, a grid that
navigates to a Transaction, the Transaction's own form, a selection popup, the
application menu — is built with these skills, never as a hand-written plain WebPanel,
a hand-edited Transaction Web Form or a hand-coded menu loader. Exception: honor an
explicit request for a plain WebPanel or to build it without K2BTools.

---

# ROUTING RULES

## → K2BEntityServices
Use when the user wants:
- A **CRUD** for a Transaction (list + detail + edit)
- A listing/grid tied to a Transaction with standard Insert/Update/Delete
- A detail view with related entity tabs or cards (subWorkWith)
- Kanban view for an entity
- "Apply the pattern" to a Transaction
- Anything that follows: grid → select → view/edit

**Keywords:** CRUD, WorkWith, EntityManager, Entity Services, list, detail, pattern

## → K2BTrnForm
Use when the user wants:
- To **apply the TrnForm** to a Transaction, or to **create the Transaction's web form**
- To arrange the attributes of a Transaction (columns, groups, tabs, collapsible sections)
- Attributes marked as required, read-only or hidden **in the Transaction form**
- A different control type for an attribute of the Transaction (combo, suggest, multi-select)
- To design the grid of a Transaction **level** (the lines of a two-level Transaction)

**Keywords:** TrnForm, transaction form, transaction web form, form layout, required, level grid, lines

## → K2BPrompt
Use when the user wants:
- To **apply the prompt** to a Transaction, or to **create the prompt interface** associated with it
- A **selection** screen to fill a foreign key from another Transaction
- To choose which column selects the row (return on click), or what the prompt returns
- To let the user create a record from inside the selection screen

**Keywords:** prompt, selection interface, select a record, foreign key lookup, return on click

## → WebPanelDesigner
Use when the user wants:
- A **custom panel** not tied to a single Transaction's CRUD
- A dashboard, wizard, or multi-grid panel
- A form with custom layout (groups, columns, tabs)
- LayoutGrid with cards (outside Entity Services)
- Mixed data sources (DataProvider, SDT, multiple Transactions)
- Full control over UI structure
- Full control over **how a grid loads** — manual `For Each`, computed/derived rows, mixed or external data (the "Grid with No Base Table" pattern)

**Keywords:** WebPanel, WebComponent, formdesigner, dashboard, wizard, custom, form, Grid.Load, load For Each

## → K2BMenu
Use when the user wants:
- The **application menu** or a module menu: create it, or add/move/remove options
- Levels and sublevels, icons, or parameters for a menu option
- To wire the generated menu into the application (`K2BGetUserMenu`)

**Keywords:** menu, main menu, navigation, menu option, level, sublevel, K2BMenu

## Decision Table

| User says... | Route to |
|---|---|
| "Create a CRUD for X" | K2BEntityServices |
| "Apply Entity Services to X" | K2BEntityServices |
| "List of X with filters" (single Transaction) | K2BEntityServices |
| "Add an invoices tab to the detail" | K2BEntityServices |
| "Apply the TrnForm to X" / "Create the web form of X" | K2BTrnForm |
| "Put these attributes of X in two columns / in a group" | K2BTrnForm |
| "Make CustomerName required in the transaction" | K2BTrnForm |
| "Apply the prompt to X" / "Create the prompt interface for X" | K2BPrompt |
| "I need to select a customer from the invoice" | K2BPrompt |
| "Create a WebPanel with..." | WebPanelDesigner |
| "I need a dashboard" | WebPanelDesigner |
| "I want a payment wizard" | WebPanelDesigner |
| "Grid based on DataProvider" | WebPanelDesigner |
| "Panel with two unrelated grids" | WebPanelDesigner |
| "List with full control of the grid load" | WebPanelDesigner |
| "Create the application menu" / "Add X to the menu" | K2BMenu |
| "Put Invoices under Sales" / "Add a level to the menu" | K2BMenu |

## When ambiguous
- Prefer **K2BEntityServices** if the primary entity is a Transaction with standard CRUD needs
- Prefer **K2BTrnForm** if the request is about how the **Transaction itself** looks when inserting or editing
- Prefer **K2BPrompt** if the end goal is **picking one record** and giving it back to a caller
- Prefer **WebPanelDesigner** if the user needs full layout control or non-CRUD patterns
- Prefer **K2BMenu** if the goal is how the user *reaches* a screen, not what the screen shows
- "Form" is ambiguous on its own: a form **of a Transaction** is K2BTrnForm; a form in a custom panel is WebPanelDesigner
- When in doubt, ask the user

<!-- core:end -->

## Patterns that combine
The three transaction-bound patterns apply to the same Transaction and cover different
parts of the experience. A complete entity usually gets K2BEntityServices (list + detail),
K2BTrnForm (the form embedded in that detail) and K2BPrompt (how other entities
select it). If the user asks for "the whole UI of this entity", apply them in that
order and say which ones you applied.

K2BMenu sits one level above: it does not shape a screen, it decides which screens the
user can reach. Whenever K2BEntityServices generates a WorkWith, or WebPanelDesigner
generates a panel that takes no parameters, ask the developer whether it should become
a menu option and at which level — see **KEEPING THE MENU IN SYNC** in `skills/K2BMenu.md`.

---

# TWO XML FAMILIES — SIMILAR, NOT INTERCHANGEABLE

The five skills produce **two different XML dialects**, and they describe many of the
same UI concepts with different spellings. Mixing them is the most common failure
mode: an unrecognized tag or property is **silently dropped** and everything inside
it is lost — no error, no warning.

- **Pattern instances** — K2BEntityServices, K2BTrnForm, K2BPrompt, K2BMenu. A `.gx` object
  with an `#Instance` section; reaches the KB through the pattern workflows.
- **WebPanelDesigner** — a WebPanel/WebComponent with a `#Designer` section.

Within the pattern-instance family, **K2BMenu is the odd one**: it has no parent object and
no default instance, its instance lives in `src/<path>/#patterns/`, and its elements are
camelCase (`<subMenu>`, `<webObject>`) with PascalCase attributes. It is authored, imported,
and then applied with `apply_pattern` — there is no `apply_pattern_on_parent` for it.

| Concept | Pattern instance | WebPanelDesigner |
|---|---|---|
| Root element | `<instance>` | `<WebForm>` |
| Node identifier | `NameId` (sections), `ControlNameId` (containers) | `InternalName` — required on **every** node |
| Field | `<attribute Attribute="X">` | `<Attribute InternalName="a1" Attribute="X">` |
| Variable | `<variable Name="V" BasedOn="Attr">` | `<Variable InternalName="v1" BasedOn="Attr:Attribute">` |
| Filters | `<filter><filterAttribute NameId="f1" BasedOn="Attr">` | `<Filters><Variable InternalName="f1" BasedOn="Attr:Attribute">` |
| Layout containers | `<Columns ControlNameId>`, `<Column>`, `<Group ControlNameId>` | `<Columns InternalName>`, `<Column InternalName>`, `<Group InternalName>` |
| Grid primary key | automatic, taken from the Transaction | explicit `IncludeInGridKey="True"` |
| Dynamic layout name | qualified: `K2BTools.DesignSystems.Common.CardWithSummary` | bare: `CardWithSummary` |

Note the two traps in the middle rows: `BasedOn` is a **plain** name in pattern
instances and a `Name:Attribute` reference in WebPanelDesigner, and the field tag is
lowercase `<attribute>` in one family and capitalized `<Attribute>` in the other.

`ElementRelativePosition` (`"New row"` / `"New cell"` / `"Same cell"`) is one of the
few things that works identically in both.

---

# CONSTRAINTS
- Never mix pattern instance XML with WebPanelDesigner formdesigner XML
- K2BEntityServices uses `#Instance` with `<instance>` / `<transaction>` / `<workWith>` / `<entityManager>` XML
- K2BTrnForm uses `#Instance` with `<instance>` / `<TrnForm>` XML — no `<transaction>` node
- K2BPrompt uses `#Instance` with `<instance>` / `<transaction>` / `<prompt>` XML
- WebPanelDesigner uses `#Designer` section or `formdesigner` parameter with `<WebForm>` XML
- K2BMenu uses `#Instance` with `<instance>` / `<menu>` / `<subMenu>` / `<webObject>` XML — no `<transaction>` node, and camelCase element names
- The three patterns use `NameId` / `ControlNameId`; WebPanelDesigner uses `InternalName` — they are not interchangeable
- Always identify and apply the correct sub-skill before generating output (load it on demand where supported; otherwise select it among those in context)
- All of them can coexist on the same Transaction for different use cases

---

## Cómo usar (Claude Code)

Esta skill es el **orquestador**. Los patrones están bundleados como archivos
en `reference/` (ver la columna *File* de la tabla de arriba).
Elegí el patrón según las reglas de ruteo y **leé su archivo `reference/*.md`
antes de generar la salida.**
