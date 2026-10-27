<!-- GENERATED from catalog/objects/language.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-language
description: Stores localized translations for one target language in a multilingual Knowledge Base
---

# DEFINITION
A `Language` object stores translations for one target language in a
multilingual Knowledge Base.

Each entry maps a stable string literal, shared across all languages, to its
language-specific translation:

	"<string-literal>" = "<localized-text>"

Entry rules:
- Encode localized text using UTF-8; the full Unicode character set is allowed
- Preserve placeholders and formatting tokens in translations
- Define only overrides; resolve missing entries through:
  * The fallback `Language` object named by the `ParentLanguage` property, if defined
  * The key name verbatim otherwise

At runtime, the active language is switched and queried with the
`SetLanguage()` and `GetLanguage()` functions:

	SetLanguage(!"Spanish")
	&CurrentLanguage = GetLanguage()

Use when:
- Add a new target language to a multilingual application
- Maintain or override translations for an existing target language
- Specialize an existing language through the ParentLanguage fallback chain
- Configure locale conventions (date/time format, decimal separator, codepage, RTL) for a language

# SYNTAX
~~~
Language <name>
{
	<translations>

	#Properties
		<properties>
	#End

	#Documentation
		<documentation>
	#End
}
~~~

Where:
- `<name>`: Language object name using alphanumeric or underscore, starting with letter
- `<translations>`: Localized entries using key-value pairs of the form `"<string-literal>" = "<localized-text>"`, where `<string-literal>` is the stable literal shared across all languages and `<localized-text>` is the translation for the target language
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation (exported to external `.doc.md` file)

Sections:
| Section | Required |
|---|---|
| `#Properties` | yes |
| `#Documentation` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: `#localization/`
- Files:
  - `<name>.gx`
  - `<name>.doc.md`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-language](./properties-object-language.md) — Language objects

# CONSTRAINTS
Object-specific:
- `CON-LNG-001` Encode localized text using UTF-8; allow the full Unicode character set
- `CON-LNG-002` Preserve placeholders and formatting tokens in translations
- `CON-LNG-003` Define only overrides; resolve missing entries through the fallback Language object named by the ParentLanguage property if defined, otherwise through the key name verbatim
- `CON-LNG-004` For translation keys, choose one strategy: UPPER_SNAKE_CASE keys (recommended for consistency), or natural-language keys in the Knowledge Base language (KbLanguage property of the *.kb.gx file); the base language may leave values empty so keys resolve verbatim
- `CON-LNG-005` Keep Language objects under the root src/#localization/ category directory only (never under modules)
- `CON-LNG-006` Keep runtime language names aligned with existing Language object names
- `CON-LNG-007` Keep translation keys stable across all target languages
- `CON-LNG-008` Set locale properties explicitly for custom languages, including RTL when applicable
- `CON-LNG-009` Warn the user before modifying translation keys with reserved prefixes; e.g. GX*, GAM*

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Use UPPER_SNAKE_CASE translation keys for consistency across all target languages

# REQUIRES
Load these language modules together with this reference:
- [lang-functions](./lang-functions.md)
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: Languages with constant keys
English, Spanish, and Arabic Language objects sharing stable UPPER_SNAKE_CASE keys, with locale properties per language (`EX-LNG-001`, validated in CI)
`src/#localization/English.gx`:
~~~
Language English
{
	"APP_TITLE" = "Customer Management"
	"APP_WELCOME" = "Welcome"
	"APP_SAVE_OK" = "Saved successfully"

	#Properties
		Description = "English localization"
		IsoLanguageCode = "EN"
		IsoCountryCode = "US"
		DateFormat = "ENG"
	#End
}
~~~
`src/#localization/Spanish.gx`:
~~~
Language Spanish
{
	"APP_TITLE" = "Gestión de clientes"
	"APP_WELCOME" = "Bienvenido"
	"APP_SAVE_OK" = "Guardado correctamente"

	#Properties
		Description = "Spanish localization"
		IsoLanguageCode = "ES"
		IsoCountryCode = "ES"
		DateFormat = "SPA"
		DecimalSeparator = "Comma"
	#End
}
~~~
`src/#localization/Arabic.gx`:
~~~
Language Arabic
{
	"APP_TITLE" = "ادارة العملاء"
	"APP_WELCOME" = "مرحبا"
	"APP_SAVE_OK" = "تم الحفظ بنجاح"

	#Properties
		Description = "Arabic localization"
		IsoLanguageCode = "AR"
		IsoCountryCode = "SA"
		Codepage = 1256
	#End
}
~~~

# RELATED OBJECTS
- [Image](./object-image.md)
