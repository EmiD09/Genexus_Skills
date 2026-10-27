<!-- GENERATED from catalog/objects/design-system.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-design-system
description: Defines a UI design system with tokens, styles, themes, and components for consistent application styling
---

# DEFINITION
A `DesignSystem` object (or `DSO`) defines a UI design system with styles, themes, and components.

## Tokens
Reusable design variables grouped by category and optionally scoped by argument value.

Definition syntax:
~~~
@<arg-name> = <arg-value>
{
	#<token-group>
	{
		<token-name>: <token-value>;
	}
}
~~~

Reference syntax: `$<token-group>.<token-name>`

Token groups: `colors`, `spacing`, `fonts`, `fontSizes`, `borders`, `radius`, `shadows`, `times`,
`mediaQueries`, `zIndex`, `opacity`. Token names use kebab-case; token values are concrete.

Notes:
- Omit `@<arg-name> = <arg-value>` for global (always-on) tokens
- Declare the default argument value using `[<default>]` in the `tokens <name>(...)` argument list
- Re-defining the same token in a conditional block overrides it only for that context

## Styles
Style classes/selectors, font-face declarations, and inheritance/composition rules:
- `@import <object-name>;` extends an existing DesignSystem object (fully-qualified name)
- `@font-face { ... }` declares fonts (required: `src`, `font-family`; optional: `font-weight`, `font-style`, `font-display`); reference font files with `gx-file(<file-object-name>)`
- `#region <name> ... #endregion` optionally groups selectors
- `<style-name> { @include <base-styles>; <prop>: <value>; ... }` composes classes
- Token references use `$<token-group>.<token-name>`
- Use `gx-image(<image-object-name>)` for Image object references
- Map style classes from Panel object layout controls; set the panel Style property to activate the target DesignSystem object
- Web accepts full CSS selector/function capabilities; mobile has a restricted subset
- Both tokens and styles support `//` and `/* */` comments

## Contract (authoritative)
The DesignSystem object OWNS the semantic class contract consumed by Panel layouts:
- Page shell: `.page`, `.page-header`, `.page-content`, `.page-footer`
- Surfaces: `.surface`, `.surface-elevated`, `.surface-muted`
- Typography: `.text-title`, `.text-subtitle`, `.text-body`, `.text-caption`
- Actions: `.btn-primary`, `.btn-secondary`, `.btn-ghost`, `.btn-danger`
- Forms/feedback: `.field`, `.field-label`, `.field-help`, `.field-error`, `.state-loading`, `.state-empty`, `.state-error`, `.state-success`

Use when:
- Centralize visual styling (design tokens and style classes) across the application
- Define the semantic class contract consumed by Panel object layouts
- Provide theme variants (e.g. light/dark color schemes) through token arguments

# SYNTAX
~~~
DesignSystem <name>
{
	#DesignTokens
		tokens <name>[(<arguments>)]
		{
			<tokens>
		}
	#End

	#DesignStyles
		styles <name>
		{
			<styles>
		}
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
- `<name>`: Object name (alphanumeric or `_`, starting with a letter); keep all `<name>` values in header, tokens, and styles identical
- `<tokens>`: Object tokens (see Tokens in definition)
- `<styles>`: Object styles (see Styles in definition)
- `<arguments>`: Optional token arguments; syntax `<arg>:[<default>]|<value-1>|<value-2>|...`
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation; exported to the documentation artifact

Sections:
| Section | Required |
|---|---|
| `#DesignTokens` | yes |
| `#DesignStyles` | yes |
| `#Properties` | no |
| `#Documentation` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: `#designsystems/`
- Files:
  - `<name>.gx`
  - `<name>.doc.md`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-design-system](./properties-object-design-system.md) — Design System objects

# CONSTRAINTS
Object-specific:
- `CON-DSO-001` Keep tokens definition before style classes
- `CON-DSO-002` Keep include order deterministic; local classes override included classes
- `CON-DSO-003` Keep all <name> values in object header, tokens block, and styles block identical
- `CON-DSO-004` All referenced objects must use fully-qualified names (@import rule, gx-image(...) and gx-file(...) functions)
- `CON-DSO-005` @font-face requires src and font-family; only font-weight, font-style, and font-display are optional
- `CON-DSO-006` Token references must use $<token-group>.<token-name> syntax with one of the defined token groups
- `CON-DSO-007` Web accepts full CSS selector/function capabilities; mobile has a restricted subset

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Define visual direction before tokens: style, mood, and accessibility target
- Define styling contract in DesignSystem; keep screen structure in Panel
- Use %/dip for mobile-oriented styles; use any web standard unit otherwise
- Reference tokens from style classes; avoid hardcoded repeated values
- Define component variants and states: Default, Hover, Active, Focused, Disabled
- Keep color tokens consistent across style groups; use contrast-safe token pairs
- Keep one spacing scale across all components (4/8/12/16/24/32...)
- Define consistent focus ring styles for keyboard accessibility

# REQUIRES
Load these language modules together with this reference:
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Design system with theme variants
Light/dark token scheme with semantic button, layout, and typography classes (`EX-DSO-001`, validated in CI)
`src/#designsystems/MyDesignSystem.gx`:
~~~
DesignSystem MyDesignSystem
{
	#DesignTokens
		tokens MyDesignSystem(color-scheme:[light]|dark)
		{
			#colors // applies globally
			{
				brand-primary: #1c6ef2;
				brand-primary-strong: #0d4fba;
				state-success: #0f8a5f;
				state-error: #c23030;
			}

			@color-scheme = light // applies only on light-mode
			{
				#colors
				{
					page-bg: #eef3f9;
					surface-1: #ffffff;
					surface-2: #f6f8fb;
					text-primary: #1b2430;
					text-secondary: #526173;
					border-default: #d9e1ea;
				}
			}

			@color-scheme = dark // applies only on dark-mode
			{
				#colors
				{
					page-bg: #10151d;
					surface-1: #16202c;
					surface-2: #1c2836;
					text-primary: #f4f7fb;
					text-secondary: #b8c3d3;
					border-default: #2b3c50;
				}
			}

			#spacing
			{
				xs: 8px;
				sm: 12px;
				md: 16px;
				lg: 24px;
			}

			#fontSizes
			{
				title: 24px;
				body: 14px;
			}

			#radius
			{
				md: 10px;
				lg: 16px;
			}

			#times
			{
				fast: 120ms;
			}
		}
	#End

	#DesignStyles
		styles MyDesignSystem
		{
			#region Buttons

				.btn-primary
				{
					font-size: $fontSizes.body;
					text-color: #ffffff;
					background-color: $colors.brand-primary;
					border-color: $colors.brand-primary;
					border-width: 1px;
					border-radius: $radius.md;
					padding: $spacing.sm $spacing.lg;
					transition: background-color $times.fast ease;
				}

				.btn-primary:hover
				{
					background-color: $colors.brand-primary-strong;
				}

				.btn-secondary
				{
					@include btn-primary;
					text-color: $colors.brand-primary;
					background-color: transparent;
					border-color: $colors.border-default;
				}

			#endregion

			#region LayoutAndTypography

				.page
				{
					background-color: $colors.page-bg;
					padding: $spacing.lg;
				}

				.surface
				{
					background-color: $colors.surface-1;
					border-color: $colors.border-default;
					border-width: 1px;
					border-radius: $radius.lg;
					padding: $spacing.md;
				}

				.surface-muted
				{
					background-color: $colors.surface-2;
					border-radius: $radius.md;
					padding: $spacing.md;
				}

				.text-title
				{
					font-size: $fontSizes.title;
					text-color: $colors.text-primary;
				}

				.text-body
				{
					font-size: $fontSizes.body;
					text-color: $colors.text-secondary;
				}

			#endregion
		}
	#End

	#Properties
		Description = "Design system defined for the fixture application"
	#End
}
~~~

# RELATED OBJECTS
- [Panel](./object-panel.md)
- [Image](./object-image.md)
- [File](./object-file.md)
