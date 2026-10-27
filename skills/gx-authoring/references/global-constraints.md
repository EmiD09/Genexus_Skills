<!-- GENERATED from catalog/constraints/*.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: global-constraints
description: Shared coding and modeling constraints applied to every authored object
---

# CODING CONSTRAINTS

## structure
- `CON-GLB-001` Write the body block `{...}` with one-tab indented content
- `CON-GLB-002` Write section blocks `#<name>...#End` with extra-tab indented content; sections may appear in any order; yield all sections defined by the object syntax, even if empty, unless a section is explicitly excluded by the object reference
- `CON-GLB-003` Write properties blocks `[...]` inline or multiline with extra-tab indented content
- `CON-GLB-004` Indent code with tabs; never with whitespaces
- `CON-GLB-005` Follow formatting conventions from the provided examples

## definition
- `CON-GLB-006` Prefer semantically compatible reuse before creating new definitions
- `CON-GLB-007` Define the Description property on all supported objects, attributes, variables, members, and parameters
- `CON-GLB-008` Follow the canonical Data Type Priority when defining any DataType value (see modeling constraints)
- `CON-GLB-009` Ensure the standard variables baseline unless explicitly restricted

## statements
- `CON-GLB-010` Use positional arguments only for object calls; named arguments are forbidden
- `CON-GLB-011` Use semicolons only in rules, conditions, and orders; never on assignments or commands
- `CON-GLB-012` Write one statement per line

## literals
- `CON-GLB-013` Forbid non-syntactic characters in assigned values: emojis, control characters, Unicode escapes, curly quotes

## naming
- `CON-GLB-014` Forbid cryptic abbreviations
  - `CstTrx` (✘) → `CustomerTransaction` (✓)
- `CON-GLB-015` Forbid transaction-qualified attribute names
  - `User.UserId` (✘) → `UserId` (✓)

## literals
- `CON-GLB-016` Forbid verbatim string literals
  - `"""Hello"""` (✘) → `!"Hello"` (✓)
- `CON-GLB-017` Forbid escaped quote delimiters in literals
  - `\"message\"` (✘) → `"message"` (✓)
- `CON-GLB-018` Forbid escape characters in literals; compose with chr() and Newline() instead
  - `!"\t•X\n"` (✘) → `chr(9) + !"•X" + Newline()` (✓)
- `CON-GLB-019` Forbid apostrophes in literals; rephrase the text
  - `"User's name"` (✘) → `"Name of the user"` (✓)
- `CON-GLB-020` Forbid the ! prefix in translatable literals
  - `!"APP_SAVE"` (✘) → `"APP_SAVE"` (✓)
- `CON-GLB-021` Use the ! prefix for non-translatable literals only
  - `"www.example.com"` (✘) → `!"www.example.com"` (✓)
- `CON-GLB-022` Use enum domain dot notation only; never raw underlying values or literal stand-ins
  - `!"COSMETICS"` (✘) → `ProductCategoryType.Cosmetics` (✓)

## properties
- `CON-GLB-023` Define all properties in .gx files using PascalCase without quotes around the property name
  - `"Maximum numeric length"` (✘) → `MaximumNumericLength` (✓)
- `CON-GLB-024` Use single quotes for all property values inside `[...]` blocks

## safety
- `CON-GLB-025` Forbid UI-related object changes when Backend Only is enabled in the *.kb.gx file
- `CON-GLB-026` Read and write object properties via .gx files only; never use tools for that purpose
- `CON-GLB-027` Sync changes after any .gx file modification (validate and import; see gx-kb task-validate-import)

# MODELING CONSTRAINTS
- `CON-MDL-001` Data Type Priority (canonical, 5 levels): Attribute > Domain > SDT > BusinessComponent > built-in. Use an existing Attribute when the element represents the same real-world concept; an existing Domain when it has a known reusable semantic meaning; an SDT or Business Component for structured data; a built-in type only when no additional semantics, formatting, or validation is required
- `CON-MDL-002` Follow a bottom-up design; derive objects from actual data and behavior needs
- `CON-MDL-003` Reuse an existing object when the purpose, meaning, and responsibility match the requirement; never create parallel or redundant objects with overlapping responsibility, meaning, or lifecycle
- `CON-MDL-004` Place reusable logic in Procedure objects and reusable data-loading logic in DataProvider objects; never duplicate logic across multiple objects
- `CON-MDL-005` Write all translatable literals in the language specified by the KbLanguage property of the *.kb.gx file; never mix languages in modeled content
- `CON-MDL-006` Create or update an object only when it has a generated object reference in this skill; reject requests for unsupported or legacy object types, suggesting the documented replacement when one is defined. Official websites may be consulted only to answer technical questions, never to author objects
