---
name: k2bmenu-pattern
description: K2BTools Menu pattern skill for building the application menu — a standalone K2BMenu object (no parent object, no default instance) whose instance XML of subMenu / webObject / includedMenu nodes generates the static menu load procedure that the application calls to build its navigation
---

<!-- K2BTools Skills · v0.2.0 (built 2026-09-24 · 94740895) -->

K2BTools specialized skill for creating and maintaining K2BMenu instances: the object that defines the application's navigation tree and generates the procedure that loads it at runtime with per-user security checks

---

## GUIDELINE
Interprets user needs about the application menu, builds and edits the K2BMenu instance XML, and keeps the menu in sync with the screens the other K2BTools skills generate

## Triggers
Use this skill for:
- Creating the application menu, a module menu, or any K2BMenu instance
- Adding, removing, renaming, reordering or re-nesting menu options
- Grouping options into levels and sublevels, or changing the style of a level (`ShowAs`)
- Assigning icons to menu items
- Passing parameters to a menu option (`<arguments>`)
- Splitting a menu across several instances, or including a runtime-loaded section (`<includedMenu>`)
- Restricting an option with a runtime condition
- Wiring the generated load procedure into the application (`K2BGetUserMenu`)

Do NOT use this skill for:
- The CRUD screens themselves (use **k2bentityservices-pattern**)
- The Transaction's own form (use **k2btrnform-pattern**)
- Selection interfaces (use **k2bprompt-pattern**)
- Custom panels (use **webpaneldesigner-k2btools**)
- Menus *inside* a screen — grid settings menus, action overflow menus, tabs. Those belong to the instance of the screen, not to K2BMenu.

## Responsibilities
- Generate valid K2BMenu pattern instance XML
- Keep `Code` values unique where the format requires it
- Reference only objects that exist in the KB, by their qualified name
- Supply an `<arguments>` node whenever the target object receives parameters
- Apply the instance through the correct workflow (writing the `.gx` is not enough)
- **Ask the developer whether a newly generated screen should be added to the menu, and where** (see **KEEPING THE MENU IN SYNC**)

## Communication
- Professional, objective tone
- Reply in user message language
- When adding an option, state the level and sublevel it landed in
- Warn when a menu option points to an object that takes parameters and no `<arguments>` node was given

## Dependencies
This skill requires:
- **nexa** skill for GeneXus object management and knowledge base operations
- K2BTools installed in the KB (the K2BMenu pattern ships with it)

## Relationship with the other K2BTools skills
- **K2BEntityServices** generates the WorkWith panels that become menu options. Its `<workWith>` node has an `IncludeInMenu` property that defaults to **True** and is only written to the instance when it differs from that default — so read it as an opt-**out**: a WorkWith with `IncludeInMenu="False"` must not be offered for the menu, and anything else is a candidate.
- **WebPanelDesigner** generates custom panels; a panel that takes no parameters is a menu option candidate.
- **K2BTrnForm** and **K2BPrompt** produce screens that are *never* menu options: a Transaction form is reached from its WorkWith, and a prompt is opened by the field that prompts it.

---

# WORK ORDER — READ THE SKILL FIRST

This skill is the base and primary reference for the K2BMenu instance format. Follow this order of operations on every task:

1. **Read the skill before touching the KB.** It already defines the `.gx` envelope (`#Instance`, `#Properties`), the node structure, and the two application workflows. Do not rediscover these from existing instances.
2. **Note what K2BMenu does not share with the other patterns.** It has no parent object and no default instance, so `apply_pattern_on_parent` does not apply and there is nothing to default to; its instance lives in a `#patterns/` folder, and its node vocabulary is its own (see **WORKFLOWS** and **MAIN NODES**).
3. **Then explore the KB only for what the skill does NOT cover:**
   - which objects exist and their qualified names (`Module.Object`) — every `GXObject` must resolve,
   - whether a target object receives parameters, and which ones,
   - the menu instances that already exist and how they are wired together.
4. **Use existing instances to fill specific gaps, not as a template.** Reference them for a concrete missing detail — never to re-derive the format.

> The skill is the source of truth for the format. KB exploration is for the object inventory and uncovered edge cases only.

---

# WHAT THE PATTERN GENERATES

The object that matters is the **static menu load procedure**. For an instance named `M` it is called `MStaticMenuLoad` by default (the name comes from K2BMenu Settings, `<InstanceName>StaticMenuLoad`, and can be overridden on the `<menu>` node).

It returns the whole menu as a `K2BMultiLevelMenu` SDT:

```
parm(out:&MenuLevel0);
```

Its body is a sequence of `CheckSecurityFor<Object>` subroutines followed by `Add<Level>` subroutines — one per node in the instance — so options the logged-in user is not authorized for never enter the SDT. It is fully generated: never edit it by hand.

The pattern also maintains the global procedure `K2BListAllStaticMenus`, which enumerates the instances that opted in through `IncludeInStaticMenuList`.

> The pattern can additionally generate an **initialization procedure** that persists the menu options into database tables. It is out of scope here: build the menu around the static load procedure.

## Wiring the load procedure into the application

The application obtains its menu through the procedure `K2BGetUserMenu`, which ships with a default body:

```
// default body shipped with K2BTools
K2BListPrograms.Call(&ListPrograms)
&MenuItems = K2BListProgramsToMultiLevelMenuSDT(&ListPrograms)
```

Replace that body with a call to the generated procedure:

```
&MenuItems = MainMenuStaticMenuLoad.Udp()
```

That is the whole integration: what consumes the returned SDT, and how it is rendered, is outside this pattern.

---

# SYNTAX

> **Scope note — the instance XML alone does NOT modify the KB.** Writing the `.gx` file to disk is not enough to generate any object. The XML must be brought into the KB through an MCP task, and *how* you do that is not the same as for the transaction-bound patterns, because a menu has no parent object. Getting this wrong fails **silently**: the MCP tasks return `✓ success` without having created a single object. See the **WORKFLOWS** section.

## File Format

Same envelope as the other three K2BTools patterns — a `.gx` object with `#Instance` and `#Properties` sections:

~~~
K2BMenu <InstanceName>
{
	#Instance
		<instance>
		  <menu>
		    <!-- menu definition XML -->
		  </menu>
		</instance>
	#End

	#Properties
		Name = "<InstanceName>"

		IsDefault = "False"
	#End
}
~~~

## Root Structure

```xml
<instance>
  <menu IncludeInStaticMenuList="True">
    <subMenu Code="Sales" Description="Sales">
      <webObject GXObject="WWInvoice" Description="Invoices" />
    </subMenu>
    <webObject GXObject="Dashboard.Dashboard" />
  </menu>
</instance>
```

Unlike K2BEntityServices and K2BPrompt there is no `<transaction>` node, and unlike K2BTrnForm there is no implicit parent either: a menu is not *about* any object. The root is `<instance>` → exactly one `<menu>`.

## What is the same, and what is not

The envelope, the `#Instance` section and the PascalCase attribute convention match the other patterns. Three things do not, and they are where mistakes happen:

| | K2BEntityServices / K2BTrnForm / K2BPrompt | K2BMenu |
|---|---|---|
| Parent object | a Transaction | **none** — the menu object *is* the instance |
| Default instance | yes (`apply_pattern_on_parent`) | **none** — a menu is authored, not derived |
| Instance location | `src/<path>/T/K2B…T.gx`, next to its transaction | `src/<path>/#patterns/<InstanceName>.gx` |

Element names are this pattern's own: `menu`, `subMenu`, `webObject`, `includedMenu`, `arguments`, `argument`. They are **camelCase** — `<subMenu>`, not `<SubMenu>` — while their attributes are PascalCase, as everywhere else.

## Attribute spellings: confirmed vs. derived

The exported XML uses the schema's PrettyName when it has one that is identifier-shaped (`gxobject` → `GXObject`, `includedMenu`'s `object` → `Instance`), and otherwise the attribute name with its first letter capitalized (`code` → `Code`, `showAs` → `ShowAs`).

Everything documented below is **confirmed** against real exported instances, except the few marked *derived* — read off the pattern schema (`K2BMenuInstance.xml`) and not yet seen in an export. For a derived spelling: set the property once in the GeneXus IDE, export the instance, and read the real name off the file. Do not guess twice.

---

# MAIN NODES

Node tree: `<menu>` → (`<subMenu>` | `<webObject>` | `<includedMenu>`)\*, and `<subMenu>` nests the same three child types to any depth. `<webObject>` may carry one `<arguments>` node.

The tables below list the attributes you **author**. Nodes also carry attributes the pattern maintains by itself — the security of the item, which it resolves from the object the node points to, and bookkeeping flags the IDE maintains. Never write those; if an existing instance has them, leave them exactly as they are.

## `<menu>` — the root

Exactly one, mandatory, directly inside `<instance>`.

| Attribute | Meaning |
|---|---|
| `IncludeInStaticMenuList` | Whether this menu appears in the global `K2BListAllStaticMenus`. Default `True`. |
| `IncludeInMenuInitializationList` | The same, for the initialization procedure (out of scope, but it appears in the convention below). Default `True`. |
| `GenerateStaticLoadMenuProcedure` | *derived* — generate the static load procedure. Defaults from K2BMenu Settings. |
| `ProcedureName` | *derived* — override the static load procedure name (settings default `<InstanceName>StaticMenuLoad`). |

**Convention worth following:** an instance that exists only to be pulled into another menu through `<includedMenu>` sets both list attributes to `"False"`, so it does not show up as a menu of its own — this is what real instances in the KB do:

```xml
<menu IncludeInStaticMenuList="False" IncludeInMenuInitializationList="False">
```

## `<subMenu>` — a level

| Attribute | Meaning |
|---|---|
| `Code` | Identifier of the level. Must be unique in the instance. |
| `Description` | Text shown in the menu. If omitted, the renderer falls back to `Code`. |
| `ShowAs` | Level style hint: `Default`, `Group`, `GroupWithoutTitle`, `Collapsible`. Renderers that do not support it ignore it. |
| `IconSetIcon` / `IconImageClass` / `IconImage` | Icon for the level — see **Icons**. |
| `ShowInExtraSmall` / `ShowInSmall` / `ShowInMedium` / `ShowInLarge` | *derived* — responsive visibility per screen size. |

Pick readable `Code` values (`"Sales"`, not `"S1"`): they identify the level downstream, and they appear verbatim in the generated subroutine names — so avoid characters that are awkward in identifiers, and prefer `"DisplayForms"` over `"Display Forms"`.

### `ShowAs`

A hint for renderers that support several level styles (the MegaMenu component reads it; the rest ignore it):

- **First level** — `ShowAs` is ignored.
- **Second level** — a titled group by default; `ShowAs="GroupWithoutTitle"` drops the title.
- **Third level and deeper** — collapsible by default; `ShowAs="Group"` renders it expanded and non-collapsible.

Only set it when the developer asks for a specific level style; leaving it out is the normal case.

## `<webObject>` — a menu option

| Attribute | Meaning |
|---|---|
| `GXObject` | **Required.** The Web Panel invoked when the option is selected, by its qualified name. Note the casing: `GXObject`, not `GxObject`. |
| `Code` | Identifier of the item, unique inside its level. Auto-derived from the object when omitted — set it explicitly when the same object appears more than once. |
| `Description` | Text shown in the menu. Defaults to a prettified object name. |
| `IconSetIcon` / `IconImageClass` / `IconImage` | Icon for the item — see **Icons**. |
| `Condition` | *derived* — code condition evaluated in the generated static procedure; the item is included only when it is true. |
| `ShowInExtraSmall` / `ShowInSmall` / `ShowInMedium` / `ShowInLarge` | *derived* — responsive visibility per screen size. |

**Qualify the object name.** Real instances carry the object's fully qualified name, including when the object is in the same module as the menu: `GXObject="VistasGrilla.ProductCardWithSummary"`, `GXObject="Dashboard.Dashboard"`. Only Root Module objects appear bare (`GXObject="WWInvoice"`). Use the name the KB reports for the object.

**Security is inherited, not authored.** The item's authorization check — the `CheckSecurityFor<Object>` subroutine in the generated procedure, which keeps unauthorized options out of the SDT — is resolved by the pattern from the security K2BEntityServices or the Web Panel Designer already established for the referenced object. Omitting it is not "no security": it is the inferred, and normally correct, security. Only if the developer asks for a specific check is there anything to write here.

## `<arguments>` / `<argument>` — parameters for the option

A `<webObject>` whose target receives parameters needs an `<arguments>` child holding one `<argument>` per parameter, **in order**. `<argument>` has a single attribute, `Value`, holding an expression:

```xml
<webObject GXObject="WPRedirect" Code="WPRedirectCards" Description="Cards">
  <arguments>
    <argument Value="K2BTrnMode.Display" />
    <argument Value="1" />
  </arguments>
</webObject>
```

Rules:
- The number of `<argument>` nodes must match the number of parameters of the object. A mismatch breaks the generated procedure at specification time.
- Values are expressions, not literals-only: enum members, constants and numbers all work.
- The same object can appear several times with different arguments — give each one its own `Code`, as above.

## `<includedMenu>` — pull in another menu

Inserts the items of another menu at this point. The items of the included menu's first level become siblings of `<includedMenu>`'s siblings — the node itself renders nothing, and it takes no children.

| Attribute | Meaning |
|---|---|
| `Instance` | Qualified name of another **K2BMenu instance** to include. |
| `StaticMenuLoadProcedure` | *derived* — used **only when `Instance` is empty**: a Procedure, written by the developer, that returns the items. |

Two distinct uses:

**Splitting a menu across instances** — one menu per module, consolidated by a global one:

```xml
<subMenu Code="Lists" Description="Dynamic Layouts">
  <includedMenu Instance="VistasGrilla.ProductViews" />
</subMenu>
```

Remember to set `IncludeInStaticMenuList="False"` and `IncludeInMenuInitializationList="False"` on the included instance's `<menu>` node.

**A section built at runtime** — the static procedure's structure is fixed at design time, so anything that must vary per user, per session or per data goes through a procedure. Write a Procedure whose parm rule matches the one the pattern generates:

```
parm(out:&MenuLevel0);
```

`&MenuLevel0` is based on the `K2BMultiLevelMenu` SDT; the body can do whatever it needs (read the session, query tables). Then add an `<includedMenu>` node with `Instance` left out and the procedure in `StaticMenuLoadProcedure`.

## Icons

Icons are plain attributes on `<subMenu>` and `<webObject>`:

- `IconSetIcon` — the modern way (K2BTools 15.2+). Its value is a JSON object, **XML-escaped**, since it lives inside a double-quoted attribute:
  ```xml
  <webObject GXObject="WWInvoice" IconSetIcon="{&quot;set&quot;:&quot;FontAwesome&quot;,&quot;variant&quot;:&quot;solid&quot;,&quot;icon&quot;:&quot;file-invoice&quot;}" />
  ```
  Variants are FontAwesome's own (`solid`, `regular`, …); the supported FontAwesome version is 5.1.1.
- `IconImageClass` — the legacy escape hatch: a CSS class rendered on a `SPAN` when no image is set. In K2BTools 15.1 and older this property was called `Image Class`. Exported instances often carry it empty (`IconImageClass=""`); there is no need to write it yourself.
- `IconImage` — a KB image (called `Image` in 15.1 and older).

The `&quot;` escaping is not optional and not cosmetic: a raw `"` inside the attribute ends it and the instance no longer parses.

---

# WORKFLOWS

The instance XML by itself does NOT modify the KB. Writing the `.gx` to disk generates nothing — the XML must be brought into the KB through an MCP task, and then the pattern applied so the procedure is (re)generated.

**K2BMenu has no parent object and no default instance**, which removes one scenario the other patterns have and changes another:

| Scenario | K2BEntityServices / K2BTrnForm / K2BPrompt | K2BMenu |
|---|---|---|
| Create the default instance | `apply_pattern_on_parent` | **does not exist** — there is nothing to derive a menu from |
| Create a custom instance | write the file + import it **together with the parent transaction** | write the file + import it **alone** (Workflow A below) |
| Modify an existing instance | edit + reimport the instance | same, plus an explicit apply (Workflow B below) |

> If the developer asks for "the menu" and no instance exists, there is nothing to default to: **ask what the menu should contain**, or offer to build it from the WorkWiths and parameterless panels already in the KB. Do not invent a structure silently.

## Workflow A — the instance does not exist

1. Decide the instance name (`MainMenu`, `SalesMenu`, …) and the module it belongs to (see **Module Placement**).
2. Create the folder `src/<path>/#patterns/` if it is not there.
3. Write `src/<path>/#patterns/<InstanceName>.gx` with the full `#Instance` XML.
4. Import it:
   ```
   import_text_to_kb names: ["<InstanceName>"], rootDirectory: "<KB root>"
   ```
   Unqualified names match by suffix; if the name collides with another object, qualify it (`Module.InstanceName`).
5. Apply the pattern so the procedure is generated:
   ```
   apply_pattern pattern: "K2BMenu", instanceName: "<InstanceName>"
   ```
6. Confirm the generated procedure `<InstanceName>StaticMenuLoad` exists. If it does not, the instance was imported but not applied.

There is no second name to pass and no `ApplyXPatternOnSave` property to set: with no parent transaction, the menu object *is* the instance.

## Workflow B — the instance already exists

1. **Export** it if it is not already on disk, or if the KB copy changed:
   ```
   export_kb_to_text names: ["<InstanceName>"], rootDirectory: "<KB root>"
   ```
2. **Edit** the XML in `src/<path>/#patterns/<InstanceName>.gx`.
3. **Reimport** just that object:
   ```
   import_text_to_kb names: ["<InstanceName>"], rootDirectory: "<KB root>"
   ```
4. **Reapply** the pattern to regenerate the procedure:
   ```
   apply_pattern pattern: "K2BMenu", instanceName: "<InstanceName>"
   ```

Editing the generated procedure instead of the instance is always wrong: the next apply overwrites it.

## Module Placement

A menu instance lives in a `#patterns` folder inside its module's directory — not next to a transaction, because it has none:

- `src/#patterns/<InstanceName>.gx` → Root Module
- `src/<ModuleName>/#patterns/<InstanceName>.gx` → `<ModuleName>` module (that directory needs its `module.toml`)

The objects the pattern generates land in a folder named after the instance — `src/<path>/<InstanceName>/<InstanceName>StaticMenuLoad.gx`. That folder is **not** a module; do not put a `module.toml` in it and do not place the instance inside it.

The `rootDirectory` parameter in export/import must always point to the KB root (the parent of `src/`).

## Reading `IncludeInMenu` as an opt-out

An option enters the menu only when a `<webObject>` node is added to the instance and the pattern is applied. `IncludeInMenu`, on the screen's own instance, never puts it there — but it does tell you whether the developer wants that screen in the menu at all.

`IncludeInMenu` **defaults to `True`**, and the instance only carries the property when its value differs from the default. So its absence means nothing is wrong — it means "default", which is *yes*. Read it in one direction only:

> **Do not add a WorkWith to the menu when its `<workWith>` node has `IncludeInMenu="False"`.** Anything else — the property absent, or set to `True` — is a menu-option candidate.

Treat it as the developer's standing answer for that screen: an explicit `False` is a decision already taken, so do not offer it again.

---

# KEEPING THE MENU IN SYNC

A screen that nobody can reach is not finished. Every time a new reachable screen is generated in a KB that has a K2BMenu instance, the menu is part of the work.

## When to raise it

**After K2BEntityServices generates a WorkWith.** The WorkWith is the entry point of the entity's CRUD, so it is a menu option candidate — unless its `<workWith>` node says `IncludeInMenu="False"`, which is an explicit opt-out (the property defaults to `True` and is only written when it differs). Check that first, then ask.

**After WebPanelDesigner generates a panel that takes no parameters.** A parameterless panel can be opened directly from the menu. Ask.

**Do not ask** for: EntityManager / detail panels (reached from their WorkWith), Transaction forms (K2BTrnForm), prompts (K2BPrompt), WebComponents (embedded in a panel, not navigable), or panels that take parameters — unless the developer wants a fixed entry with `<arguments>`, which is worth offering explicitly rather than assuming.

**Skip the question entirely** when the KB has no K2BMenu instance, when the screen's instance carries `IncludeInMenu="False"`, or when the developer already said where the option goes or asked not to touch the menu in this session.

## How to ask

One question, at the end of the generation, with the concrete structure of the menu in hand — not a generic prompt. Read the existing instance first so the options you offer are the levels that actually exist:

> `WWInvoice` is generated. Do you want it in `MainMenu`? The current levels are **Sales**, **Inventory** and **Administration** — or I can put it at the root, in a new level, or leave it out.

Then act on the answer:
- **A level** → add the `<webObject>` to that `<subMenu>`.
- **The root** → add it as a direct child of `<menu>`.
- **A new level** → create the `<subMenu>` (ask for its name), then add the item.
- **Leave it out** → say nothing more about it.

Batch the question when you generated several screens at once: list them and ask once where each goes, rather than asking N times.

## Then apply it

Adding the node is Workflow B: edit the instance, reimport, reapply the pattern. Report what changed, naming the level:

> Added to `MainMenu` → **Sales** → *Invoices*, and reapplied K2BMenu (`MainMenuStaticMenuLoad` regenerated).

---

# EXAMPLES

## Example 1: A menu with levels, icons and a root-level option

```
K2BMenu MainMenu
{
	#Instance
		<instance>
		  <menu>
		    <subMenu Code="Sales" Description="Sales" IconSetIcon="{&quot;set&quot;:&quot;FontAwesome&quot;,&quot;variant&quot;:&quot;solid&quot;,&quot;icon&quot;:&quot;shopping-cart&quot;}">
		      <webObject GXObject="WWInvoice" Description="Invoices" IconSetIcon="{&quot;set&quot;:&quot;FontAwesome&quot;,&quot;variant&quot;:&quot;solid&quot;,&quot;icon&quot;:&quot;file-invoice&quot;}" />
		      <webObject GXObject="WWCustomer" Description="Customers" />
		    </subMenu>
		    <subMenu Code="Inventory" Description="Inventory">
		      <webObject GXObject="WWProduct" Description="Products" />
		      <subMenu Code="Warehouses" Description="Warehouses">
		        <webObject GXObject="WWWareHouse" Description="Warehouses" />
		        <webObject GXObject="WWProductWareHouse" Description="Stock" />
		      </subMenu>
		    </subMenu>
		    <webObject GXObject="Dashboard.Dashboard" Description="Dashboard" />
		  </menu>
		</instance>
	#End

	#Properties
		Name = "MainMenu"

		IsDefault = "False"
	#End
}
```

Note the root-level `<webObject>` after the last `<subMenu>`: options and levels are siblings, and document order is the order on screen.

## Example 2: A module menu consumed by the global menu

The module's own instance, kept out of the global lists:

```
K2BMenu SalesModuleMenu
{
	#Instance
		<instance>
		  <menu IncludeInStaticMenuList="False" IncludeInMenuInitializationList="False">
		    <webObject GXObject="Sales.WWInvoice" Description="Invoices" />
		    <webObject GXObject="Sales.WWCustomer" Description="Customers" />
		  </menu>
		</instance>
	#End

	#Properties
		Name = "SalesModuleMenu"

		IsDefault = "False"
	#End
}
```

exported to `src/Sales/#patterns/SalesModuleMenu.gx`, and pulled into the global menu:

```xml
<subMenu Code="Sales" Description="Sales">
  <includedMenu Instance="Sales.SalesModuleMenu" />
</subMenu>
```

Both instances must be imported and applied. The global menu's procedure inlines the included definition, so reapply the global menu after changing the module one.

## Example 3: A runtime section and a parameterized option

```xml
<menu>
  <subMenu Code="Recent" Description="Recently visited">
    <includedMenu StaticMenuLoadProcedure="LoadRecentItemsMenu" />
  </subMenu>
  <webObject GXObject="WPInvoiceEntry" Code="NewInvoice" Description="New invoice">
    <arguments>
      <argument Value="K2BTrnMode.Insert" />
    </arguments>
  </webObject>
</menu>
```

`LoadRecentItemsMenu` is a hand-written Procedure with `parm(out:&MenuLevel0);`, free to build its items from the session or the database. `WPInvoiceEntry` takes one parameter, so the option supplies it.

---

# CONSTRAINTS
- Element names are camelCase and belong to this pattern: `menu`, `subMenu`, `webObject`, `includedMenu`, `arguments`, `argument` — never `<SubMenu>`, and never a node borrowed from another pattern
- Never mix K2BMenu XML with K2BEntityServices / K2BTrnForm / K2BPrompt node vocabulary, or with WebPanelDesigner formdesigner XML
- Exactly one `<menu>` node, directly under `<instance>`
- `GXObject` is required on every `<webObject>`, spelled with that exact casing, and must resolve to an object that exists in the KB
- One `<argument>` per parameter of the target object, in order — no more, no fewer
- `Code` must be unique where the format requires it: per instance for `<subMenu>`, per level for `<webObject>`
- Escape the JSON in `IconSetIcon` with `&quot;` — a raw `"` breaks the attribute
- Never hand-edit the generated `…StaticMenuLoad` procedure — the next apply overwrites it
- Author only the attributes documented here; the item's security and the IDE's bookkeeping flags are not yours to write, nor to strip from an instance that has them
- Importing the `.gx` is not enough: apply the pattern afterwards, or the procedure is stale
- Use only the nodes and attributes documented here; verify a derived spelling against a real export before relying on it

---

# COMMON ERRORS

## Error 1: Borrowing another pattern's vocabulary
The envelope is shared with K2BEntityServices, K2BTrnForm and K2BPrompt, which makes it tempting to carry their nodes across. There is no `<transaction>` node in a menu, no `<attributes>`, no `NameId`, no `<workWith>`. An unrecognized element or attribute is **silently dropped**, taking everything inside it with it — no error, no warning.

## Error 2: Capitalizing the element names
`<SubMenu>` and `<WebObject>` are not the same as `<subMenu>` and `<webObject>`. Elements are camelCase, attributes are PascalCase, and the two conventions meet on the same line:
```xml
<subMenu Code="Sales" Description="Sales">
```

## Error 3: Looking for a default instance
There is none, and `apply_pattern_on_parent` has no parent to work with: the pattern's own definition declares `ParentObject Type="(None)"`. A menu is authored, not derived. If you were about to "apply K2BMenu to X", stop — X is a menu option at most, not a parent.

## Error 4: Misreading `IncludeInMenu`
Two mistakes in opposite directions. Setting `IncludeInMenu="True"` on a `<workWith>` node does not put anything in a menu — only a `<webObject>` node in a menu instance does, followed by an apply. And a WorkWith *without* the property is not "not marked for the menu": the property defaults to `True` and is written only when it differs, so its absence means the screen is a candidate. The only value that changes your behaviour is `"False"`.

## Error 5: Importing without applying
`import_text_to_kb` updates the instance object; it does not regenerate the procedure. The menu keeps loading the old structure and nothing signals the mismatch. Always follow with `apply_pattern pattern: "K2BMenu", instanceName: "…"`.

## Error 6: A menu option that takes parameters and no `<arguments>`
The generated procedure calls the object with the wrong number of parameters and fails at specification time — far from the instance that caused it. Check the target's parm rule before adding the node.

## Error 7: An unqualified object name
`GXObject="ProductCardWithSummary"` does not resolve when the panel lives in a module. Real instances qualify the name even within the same module (`VistasGrilla.ProductCardWithSummary`); only Root Module objects appear bare. The same applies to `<includedMenu Instance="…">`.

## Error 8: Editing the generated procedure
Adding an item by editing `…StaticMenuLoad` works exactly until the next apply. Edit the instance.

## Error 9: Two items with the same `Code` in one level
The generated subroutine names collide. This is the usual outcome of pointing two options at the same object (a redirect panel with different `<arguments>`) without giving each an explicit `Code`.

## Error 10: An included instance that is also a menu of its own
Forgetting `IncludeInStaticMenuList="False"` on the included instance leaves it listed in `K2BListAllStaticMenus` as a standalone menu, and it gets its own generated procedure for no reason.
