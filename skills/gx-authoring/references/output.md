<!-- GENERATED from catalog/artifacts/output-rules.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: output
description: Output contract for path resolution and artifact naming
---

# DIRECTORIES
| Pattern | Meaning |
|---|---|
| `src/` | Root Module directory; all exported artifacts live under it |
| `ref/` | Package directory exposing read-only Module object references |
| `<name>/` | Module directory |
| `@<name>/` | Folder directory |
| `#<name>/` | Category directory |

Rules:
- The Root Module follows the same artifact rules as any other Module object
- ref/ is read-only: never update, regenerate, or extend contained objects; consider only fully-qualified names and signatures
- Category directories must exist only under a Module object (Root Module included), never under a Folder object
- Each name binds to a single object under a category directory

# CATEGORY DIRECTORIES
Root-level:
- `#preferences/`: Model configuration (KB, Versions, Environments)
- `#attributes/`: Attribute artifacts
- `#tables/`: Physical Table and related Index artifacts
- `#subtypes/`: SubTypeGroup artifacts aliasing Attribute groups
- `#categories/`: Category artifacts
- `#localization/`: Language artifacts
- `#themes/`: Theme artifacts
- `#documentation/`: Document artifacts for KB documentation

Module-level:
- `#dataviews/`: DataView artifacts
- `#domains/`: Domain artifacts
- `#images/`: Image artifacts
- `#files/`: File artifacts
- `#designsystems/`: DesignSystem artifacts
- `#patterns/`: Pattern-specific artifacts

# PATH RESOLUTION
1. Start at the src/ directory
2. Append every parent Module as <name>/ directory
3. Then either append every parent Folder as @<name>/ directory, or append the category directory if the object type requires one
4. Create the target artifacts in the resulting directory

Patterns:
- `src/[<module-1>/...][@<folder-1>/...]  (uncategorized)`
- `src/[<module-1>/...]#<category>/  (categorized)`

Rules:
- Resolve category directories to the nearest allowed Module path
- Resolve the containing Module before appending any category directory
- Apply rooted or containment restrictions from the object reference

# ARTIFACT SET
## main
Pattern: `<name>.gx`
Rules:
- Never encode segments in the file name using dot notation
- Infer object type from the file content header

## local
Pattern: `<name>.local.*.gx`
Rules:
- Model definitions only; typically listed in .gitignore
- Must include properties with Scope set to .local; may override or extend the main file definition

## properties
Pattern: `module.toml`
Rules:
- Module objects only; keep #Properties inline in the .gx main artifact by default
- Forbid duplicate property definitions across artifacts

## documentation
Pattern: `README.md (Module) | <name>.doc.md (other objects)`
Rules:
- The #Documentation section in object syntax is reference-only; its content goes to the external .md file
- Forbid #Documentation definition inside the .gx main file

## layout
Pattern: `<name>.report.xml (Procedure) | <name>.web.xml (WebPanel, WebComponent, MasterPage) | <name>.panel.xml (Panel, MasterPanel)`
Rules:
- Derive the supported layout family from the object type; for Stencil, derive the family from the consuming context (open question inherited from the source — verify against product behavior)
- The #Layout section in object syntax is reference-only; its content goes to the external .xml file
- Forbid #Layout definition inside the .gx main file

# GLOBAL RULES
- Output path resolution governs artifact selection
- Never override object syntax or completeness rules; allow only stricter object-specific rules
- Keep one canonical artifact set per target and keep path resolution deterministic
- Never create extra files for other object sections

# EXAMPLES
- Root Module definition -> src/module.toml, src/README.md
- Commerce module -> src/Commerce/module.toml, src/Commerce/README.md
- Customer object in Root Module -> src/Customer.gx, src/Customer.doc.md
- MonthlySales in Reports folder of Sales module -> src/Sales/@Reports/MonthlySales.gx (+ .doc.md)
- CustomerStatus domain in Sales module -> src/Sales/#domains/CustomerStatus.gx (+ .doc.md)
- InvoiceReport procedure with report layout -> src/Reports/InvoiceReport.gx, .doc.md, .report.xml
- KB model files -> src/#preferences/MyKB.kb.gx, NETSQLServer.env.gx, NETSQLServer.local.env.gx
