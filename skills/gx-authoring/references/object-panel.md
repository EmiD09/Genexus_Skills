<!-- GENERATED from catalog/objects/panel.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-panel
description: Defines user interface screens for multiple platforms with layout, events, and data binding
---

# DEFINITION
A `Panel` object defines a screen for Android, Apple, Angular, or Web environments.

Type variants and environment applicability:
- `SDPanel` (IDE name: `Panel`): screen for native (Android/Apple) and Angular front ends; layout artifact `<name>.panel.xml`
- `WebPanel`: screen for Web environments; layout artifact `<name>.web.xml`
- `WebComponent`: embeddable web component; layout artifact `<name>.web.xml`
- `MasterPage`: master layout for Web environments; layout artifact `<name>.web.xml`
- `MasterPanel`: master layout for panels; layout artifact `<name>.panel.xml`
- `Stencil`: reusable layout fragment usable in both families; allows only `#Layout`, `#Variables`, `#Properties`, `#Documentation` sections

## Events
Allowed event names: `Start`, `ClientStart` (non-web), `[<grid-name>.]Refresh`, `[<grid-name>.]Load`,
`Enter` (web only), `Back` (non-web only), `'<custom-name>'` (buttons), `<control-name>.<event-name>` (non-buttons).

Control event names:
- Web: `Click`, `DblClick`
- Native: `Tap`, `DoubleTap`, `LongTap`, `Swipe`, `SwipeTop`, `SwipeLeft`, `SwipeRight`, `SwipeBottom`,
  `Drag`, `Drop(&arg)`, `DropAccepted`, `DragCanceled`
- Common: `IsValid`, `ControlValueChanged`, `ControlValueChanging(&arg)`

Execution order:
1. `Start`
2. `Refresh`, then each `<grid>.Refresh`
3. `Load` after `Refresh`, and `<grid>.Load` after each `<grid>.Refresh` (one execution per loaded row)
4. User interaction events: `Enter`, `Back`, `'<custom-name>'`, `<control-name>.<event-name>`

Notes:
- Use `Composite ... EndComposite` blocks in non-web client-side events with multiple actions
- Navigation to other screens is done by calling the target Panel with its parameters from an event

## Layout
Declarative XML-based screen layout schema used in the `#Layout` section. It defines hierarchical
structure and control composition; visual styling belongs to `DesignSystem` object classes.

Elements: `<smart>` (modern div-based responsive layout), `<table>` (legacy), `<canvas>` (absolute
positioning with overlapping), `<grid>` (data grid with items), `<input>`, `<label>`, `<button>`,
`<image>` (UI controls), `<stencil>` (embedded reusable layout).

## Contract
A `Panel` object must expose semantic hooks styled by a `DesignSystem` object. The semantic class
contract is OWNED by the `DesignSystem` object (see its reference): page shell, surfaces,
typography, actions (btn-primary/btn-secondary/btn-ghost/btn-danger), controls, and feedback classes.

## Patterns
Structure patterns for modern screens: Hero + Action + Content; Form + Live Feedback;
List + Detail (responsive); Bottom Navigation + Top Context; List + Filters + Refresh;
Multi-step Flow; Offline + Retry.

Use when:
- Define an interactive screen for Android, Apple, Angular, or Web environments
- Build shared master layouts (MasterPage for web, MasterPanel for panels)
- Create reusable layout fragments (Stencil) or embeddable web components (WebComponent)

# SYNTAX
~~~
<type> <name>
{
	#Events
		<events>
	#End

	#Rules
		<rules>
	#End

	#Conditions
		<conditions>
	#End

	#Variables
		<variables>
	#End

	#Layout
		<layout>
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
- `<type>`: Object type keyword: `SDPanel` (default), `WebPanel`, `WebComponent`, `MasterPage`, `MasterPanel`, `Stencil`
- `<name>`: Object name using alphanumeric or underscore, starting with letter
- `<events>`: Event handlers triggered by user actions
- `<rules>`: Business rules (parm, etc.)
- `<conditions>`: Boolean filters; multiple lines imply `AND`
- `<variables>`: Variable definitions with `DataType`
- `<layout>`: XML layout definition for structure and control composition; exported to the layout XML artifact
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation; exported to the documentation artifact

Sections:
| Section | Required |
|---|---|
| `#Events` | yes |
| `#Rules` | yes |
| `#Conditions` | yes |
| `#Variables` | yes |
| `#Layout` | yes |
| `#Properties` | no |
| `#Documentation` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: none
- Files:
  - `<name>.gx`
  - `<name>.doc.md`
  - `<name>.panel.xml (Panel, MasterPanel, Stencil)`
  - `<name>.web.xml (WebPanel, WebComponent, MasterPage, Stencil)`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-panel](./properties-object-panel.md) — Panel objects

# CONSTRAINTS
Object-specific:
- `CON-PNL-001` Place code only inside Panel object sections
- `CON-PNL-002` Stencil objects allow only #Layout, #Variables, #Properties, #Documentation; any other section is forbidden
- `CON-PNL-003` Events use qualifiers when needed: [WEB], [WIN], [TEXT]
- `CON-PNL-004` Include common standard variables according to panel context
- `CON-PNL-005` Layout XML: escape XML special characters
- `CON-PNL-006` Layout XML: indent with tabs only; indent attributes one tab deeper than the element; expand element tags as multiline when more than two attributes, element name alone on the opening line and one attribute per line
- `CON-PNL-007` Layout sizes only use px (Web) or dip (native) for absolute and % for relative; any other unit is strictly forbidden
- `CON-PNL-008` Each direct child of canvas must define both width and height, at least one horizontal anchor (left or right), and at least one vertical anchor (top or bottom)
- `CON-PNL-009` For smart and table, columnsStyle and rowsStyle must not overflow or underflow the container size
- `CON-PNL-010` Each mapped child of stencil must define controlNameForStencil
- `CON-PNL-011` For image controls, use source for static Image objects and attribute for bound data

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Define screen purpose, primary actions, and navigation path before #Layout
- Define UI states per screen: Default, Loading, Empty, Error, Success
- Define layout structure in Panel; define visual styling in DesignSystem; reference only pre-defined DesignSystem style classes
- Set Style property to the target DesignSystem object when the style contract applies, and verify all referenced classes exist
- Use semantic class names in layout; avoid visual names; avoid hardcoded colors or spacing
- Keep progressive disclosure: show primary action first, defer secondary actions; keep one dominant CTA per section
- Prefer smart, use table for legacy, and canvas for absolute/overlap only
- Reserve Refresh event for recalculation/filtering; reserve Load/Grid.Load event for row-by-row population
- Bind every action to an explicit event that shows user feedback after execution
- Reuse repeated screens through Stencil with controlNameForStencil mappings
- For multi-language apps, add a VarChar combo-box variable with Values set to supported languages, initialize it with GetLanguage in Start, and switch with SetLanguage in ControlValueChanged

# REQUIRES
Load these language modules together with this reference:
- [lang-events](./lang-events.md)
- [lang-standard-variables](./lang-standard-variables.md)
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Panel with Grid
Customer list panel loading a grid from the ListCustomers procedure with semantic page structure (`EX-PNL-001` — engine validation pending)
`src/CustomerList.gx`:
~~~
SDPanel CustomerList
{
	#Events
		Event Start
			&Customers.Clear()
		EndEvent

		Event Load
			ListCustomers(&AllCustomers)
			For &Customer in &AllCustomers
				&Customers.Add(&Customer)
				Load
			EndFor
		EndEvent

		Event GridCustomers.ItemClick
			msg(&Customer.CustomerName, status)
		EndEvent
	#End

	#Rules
	#End

	#Conditions
	#End

	#Variables
		AllCustomers [ DataType = 'CustomerData', Collection = 'True' ]
		Customers [ DataType = 'CustomerData', Collection = 'True' ]
		Customer [ DataType = 'CustomerData' ]
	#End

	#Properties
		Caption = "Customer List"
	#End
}
~~~
`src/CustomerList.panel.xml`:
~~~
<layout>
	<view>
		<smart
			name="MainTable"
			class="page"
			width="100%"
			height="100%"
			columnsStyle="100%"
			rowsStyle="96dip;100%">
			<row>
				<cell
					class="page-header"
					hAlign="Left"
					vAlign="Middle">
					<label
						name="Title"
						caption="Customers"
						class="text-title"/>
				</cell>
			</row>
			<row>
				<cell class="page-content">
					<grid
						name="GridCustomers"
						class="surface"
						autoGrow="True">
						<smart
							name="GridCustomerItem"
							width="100%"
							height="88dip"
							class="surface-muted">
							<row>
								<cell>
									<input
										attribute="&amp;Customer.CustomerName"
										readonly="True"
										class="text-body"/>
								</cell>
							</row>
						</smart>
					</grid>
				</cell>
			</row>
		</smart>
	</view>
</layout>
~~~

## Example 2: Panel with parameter and Refresh
Product detail panel receiving a parameter and refreshing from the Product transaction (`EX-PNL-002` — engine validation pending)
`src/ProductDetail.gx`:
~~~
SDPanel ProductDetail
{
	#Events
		Event Refresh
			For Each Product
				Where ProductId = &ProductId
				&ProductName = ProductName
				&ProductPrice = ProductPrice
				&ProductStock = ProductStock
			EndFor
		EndEvent

		Event 'Reload'
			Refresh
			msg(!"Reloaded", status)
		EndEvent
	#End

	#Rules
		parm(in: &ProductId);
	#End

	#Conditions
	#End

	#Variables
		ProductId [ DataType = 'Numeric(10.0)' ]
		ProductName [ DataType = 'VarChar(128)' ]
		ProductPrice [ DataType = 'Numeric(10.2)' ]
		ProductStock [ DataType = 'Numeric(5.0)' ]
	#End

	#Properties
		Caption = "Product Detail"
	#End
}
~~~
`src/ProductDetail.panel.xml`:
~~~
<layout>
	<view>
		<smart
			name="Container"
			class="page"
			width="100%"
			height="100%"
			columnsStyle="100%"
			rowsStyle="60dip;60dip;60dip;100%">
			<row>
				<cell>
					<input
						attribute="&amp;ProductName"
						readonly="True"
						class="text-title"/>
				</cell>
			</row>
			<row>
				<cell>
					<input
						attribute="&amp;ProductPrice"
						readonly="True"
						class="text-body"/>
				</cell>
			</row>
			<row>
				<cell>
					<input
						attribute="&amp;ProductStock"
						readonly="True"
						class="text-body"/>
				</cell>
			</row>
			<row>
				<cell hAlign="Center" vAlign="Middle">
					<button
						name="BtnReload"
						caption="Reload"
						event="'Reload'"
						class="btn-primary"/>
				</cell>
			</row>
		</smart>
	</view>
</layout>
~~~

# RELATED OBJECTS
- [DesignSystem](./object-design-system.md)
