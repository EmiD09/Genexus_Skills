<!-- GENERATED from catalog/objects/file.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: object-file
description: Stores external resources (JSON, XML, TXT, etc.) within the Knowledge Base
---

# DEFINITION
A `File` object stores external resources within the Knowledge Base for information exchange
or deployment packaging.

ENGINE-CONFIRMED (19.2.0.265): the object name does NOT include a file extension — a dot in
the header is parsed as a module qualifier (`File AppSettings.json` fails; `File AppConfig`
validates). The physical file (with its extension) is carried either inline as text content
or as a raw sibling artifact named with the physical file name; IDE exports of binary files
produce `<physical-file-name>.gx` plus the raw `<physical-file-name>` sibling.

Content is UTF-8 encoded (plain, JSON, XML, INI, etc.). Only text formats may be authored;
binary files are read-only and their content is never output.

File objects are stored only in module-level `#files/` category directories; they can never
be placed under folders.

Use when:
- Storing external text resources (JSON, XML, INI, TXT, scripts, source snippets) inside the Knowledge Base
- Exchanging information with external systems through packaged resource files
- Including resource files in deployment packaging

# SYNTAX
~~~
File <name>
{
	<content>

	#Properties
		<properties>
	#End

	#Documentation
		<documentation>
	#End
}
~~~

Where:
- `<name>`: Object name using alphanumeric or underscore, starting with letter; WITHOUT a file extension (a dot is parsed as a module qualifier)
- `<content>`: File content in UTF-8 encoding (plain, JSON, XML, INI, etc); omit when a raw sibling file holds the content
- `<properties>`: Optional object properties in TOML syntax
- `<documentation>`: Optional object documentation; exported to the external `.doc.md` artifact, never inline in `.gx`

Sections:
| Section | Required |
|---|---|
| `#Properties` | yes |
| `#Documentation` | no |

# OUTPUT
Resolve paths and artifacts per [output](./output.md) with:
- Category directory: `#files/`
- Files:
  - `#files/<name>.gx`
  - `#files/<physical-file-name> (raw sibling, only when content is not inline)`

# PROPERTIES
Load on demand for property names, defaults, and valid options:
- [properties-object-file](./properties-object-file.md) — File objects

# CONSTRAINTS
Object-specific:
- `CON-FIL-001` The object name must NOT include a file extension; dots in the header are parsed as module qualifiers (engine-confirmed)
- `CON-FIL-002` Author text formats only (.txt, .json, .xml, .ini, .bat, .sh, .cs, .java, etc.)
- `CON-FIL-003` Binary files (.mp3, .wav, .ttf, .otf, .dll, .exe, etc.) are read-only; never output binary content
- `CON-FIL-004` Avoid leading or trailing tabs/whitespace unless required by the format
- `CON-FIL-005` Use UTF-8 encoding
- `CON-FIL-006` Store File objects only in module #files/ directories
- `CON-FIL-007` Files cannot be specified under folders, only modules
- `CON-FIL-008` Omit <content> when a raw sibling artifact holds the content (the sibling is named with the physical file name, including its extension)

All rules in [global-constraints](./global-constraints.md) apply in full.

# BEST PRACTICES
- Set the Description property to document the resource purpose

# REQUIRES
Load these language modules together with this reference:
- [lang-markdown](./lang-markdown.md)

# EXAMPLES
## Example 1: JSON configuration file
Application settings stored as a JSON File object in the Root Module (`EX-FIL-001`, validated in CI)
`src/#files/AppSettings.gx`:
~~~
File AppSettings
{
	{
		"baseUrl": "https://api.example.com/v1/",
		"timeout": 30,
		"retries": 3,
		"logging": {
			"enabled": true,
			"level": "info"
		}
	}

	#Properties
		Description = "Application settings file"
	#End
}
~~~

## Example 2: INI configuration file
Application configuration stored as an INI File object (`EX-FIL-002`, validated in CI)
`src/#files/AppConfig.gx`:
~~~
File AppConfig
{
	[Database]
	Server=localhost
	Port=5432
	Database=mydb
	Username=admin

	[Logging]
	Level=INFO
	FilePath=./logs/app.log

	#Properties
		Description = "Application configuration file"
	#End
}
~~~

# RELATED OBJECTS
- [Module](./object-module.md)
- [Image](./object-image.md)
