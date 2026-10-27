---
name: gx-authoring
description: Author GeneXus objects (Transactions, Procedures, Structured Data Types, ...) — object syntax, data modeling decisions, and best practices. Use when creating, modifying, or reviewing GeneXus objects (*.gx files) or answering questions about GeneXus syntax, rules, events, or modeling.
metadata:
  version: "0.1.0"
  dependencies: "skill:gx-kb@~0.1.0"
---

# Scope

GeneXus object authoring only. Knowledge Base operations (tooling, lifecycle, environments, connections, validate/import, builds) belong to the `gx-kb` skill — resolve the session bootstrap there first. Decline non-GeneXus requests politely.

# Protocol

1. Resolve KB context via the `gx-kb` bootstrap (`detect-tooling`, `kb-info`). If `backendOnly` is `true`, refuse to create or update UI-related objects.
2. Map the user intent to an object type using the index below.
   - No matching reference → reject the authoring request and state the object type is not supported; suggest the documented replacement when one is defined. Official documentation sites may be consulted to answer technical questions only, never to author objects.
   - A row whose Availability is not satisfied by `kb-info.productVersion` → reject and suggest the replacement; phrase the commercial product name, not the raw version number.
3. Load only what the task needs: the object reference, [global-constraints](references/global-constraints.md), [output](references/output.md), and the `requires:` modules listed in the object reference. When the task involves configuring object properties, also load the catalogs linked in the object reference's PROPERTIES section (index: [properties](references/properties.md)).
4. Search `src/**` for existing objects before creating new ones; reuse when purpose, meaning, and responsibility match.
5. Present an execution plan (objects: name, type, purpose, target module, cross-references) and wait for explicit user approval.
6. Write the artifacts, then validate and import every written file via the `gx-kb` [task-validate-import](../gx-kb/references/task-validate-import.md) flow.

# Object index

<!-- BEGIN GENERATED: object-index -->
| Object | Abbr | Use when | Reference | Availability |
|---|---|---|---|---|
| Agent | - | AI-powered content generation from input variables (features) | [object-agent](references/object-agent.md) | ProductVersion `>=19` |
| API | - | Expose Procedures, DataProviders, or other callable objects as REST services | [object-api](references/object-api.md) | - |
| BusinessProcessDiagram | BPD | Modeling a business process flow with BPMN 2.0 elements (tasks, gateways, events, connectors) | [object-business-process-diagram](references/object-business-process-diagram.md) | - |
| ColorPalette | - | - | legacy — Use DesignSystem color tokens instead | ProductVersion `<17.6` |
| DataProvider | DP | Hierarchical structured data must be produced declaratively, focusing on the output shape rather than retrieval logic | [object-data-provider](references/object-data-provider.md) | - |
| DataSelector | DS | The same filtering conditions must be reused across multiple For Each commands, DataProviders, or aggregate formulas | [object-data-selector](references/object-data-selector.md) | - |
| DataView | - | Access an external (non-GeneXus-managed) database table through GeneXus navigation | [object-data-view](references/object-data-view.md) | - |
| DeploymentUnit | DPU | Group main objects, file objects, and business process diagrams that must be deployed together | [object-deployment-unit](references/object-deployment-unit.md) | - |
| DesignSystem | DSO | Centralize visual styling (design tokens and style classes) across the application | [object-design-system](references/object-design-system.md) | - |
| Document | - | Storing documentation content inside the Knowledge Base | [object-document](references/object-document.md) | - |
| Domain | - | A specific concept (Price, Name, Id) must be typed consistently across multiple attributes and variables | [object-domain](references/object-domain.md) | - |
| ExternalObject | EO | Expose functionality implemented outside the Knowledge Base (native .NET/Java libraries) with a platform-mapped contract | [object-external-object](references/object-external-object.md) | - |
| File | - | Storing external text resources (JSON, XML, INI, TXT, scripts, source snippets) inside the Knowledge Base | [object-file](references/object-file.md) | - |
| Folder | - | Organizing Knowledge Base objects into a hierarchical tree without encapsulation needs | [object-folder](references/object-folder.md) | - |
| Image | IMG | Group physical bitmap variants (density, language, style, RTL direction) under one logical image asset | [object-image](references/object-image.md) | - |
| Language | LNG | Add a new target language to a multilingual application | [object-language](references/object-language.md) | - |
| Module | - | Grouping Knowledge Base objects and encapsulating functionality behind a controlled interface | [object-module](references/object-module.md) | - |
| Panel | SDP | Define an interactive screen for Android, Apple, Angular, or Web environments | [object-panel](references/object-panel.md) | - |
| Procedure | PRC | Implement server-side business logic or batch data manipulation (CRUD over Transaction tables) | [object-procedure](references/object-procedure.md) | - |
| Query | - | Retrieving data from multiple sources with joins, filters, and aggregations | [object-query](references/object-query.md) | - |
| StructuredDataType | SDT | Grouping related fields into a single reusable compound structure | [object-structured-data-type](references/object-structured-data-type.md) | - |
| SubTypeGroup | - | Model the same entity in different roles (e.g. Sender/Receiver, Departure/Arrival) | [object-sub-type-group](references/object-sub-type-group.md) | - |
| Table | TBL | Inspect derived physical tables (src/#tables/*.gx) after exporting a Transaction | [object-table](references/object-table.md) | - |
| Theme | - | - | legacy — Use DesignSystem style classes instead | ProductVersion `<17.6` |
| Transaction | TRN | Model a real-world entity that must persist as one or more database tables | [object-transaction](references/object-transaction.md) | - |
| URLRewrite | URW | Expose user-friendly URLs for web objects instead of default object URLs | [object-urlrewrite](references/object-urlrewrite.md) | - |
| WorkPanel | - | - | legacy — Use Panel or WebPanel instead | ProductVersion `<15` |
<!-- END GENERATED: object-index -->

Object types not listed here are not yet supported by this skill (Phase A pilot covers 3 of 24 planned types).

# Modeling principles

<!-- BEGIN GENERATED: modeling-principles -->
- `CON-MDL-001` Data Type Priority (canonical, 5 levels): Attribute > Domain > SDT > BusinessComponent > built-in. Use an existing Attribute when the element represents the same real-world concept; an existing Domain when it has a known reusable semantic meaning; an SDT or Business Component for structured data; a built-in type only when no additional semantics, formatting, or validation is required
- `CON-MDL-002` Follow a bottom-up design; derive objects from actual data and behavior needs
- `CON-MDL-003` Reuse an existing object when the purpose, meaning, and responsibility match the requirement; never create parallel or redundant objects with overlapping responsibility, meaning, or lifecycle
- `CON-MDL-004` Place reusable logic in Procedure objects and reusable data-loading logic in DataProvider objects; never duplicate logic across multiple objects
- `CON-MDL-005` Write all translatable literals in the language specified by the KbLanguage property of the *.kb.gx file; never mix languages in modeled content
- `CON-MDL-006` Create or update an object only when it has a generated object reference in this skill; reject requests for unsupported or legacy object types, suggesting the documented replacement when one is defined. Official websites may be consulted only to answer technical questions, never to author objects
<!-- END GENERATED: modeling-principles -->

# Output

Reply in the user's language. Provide the execution plan before acting and a concise summary after (actions, decisions, validations, errors, rejections). Use `genexus`-flavored code blocks for GeneXus code in replies, backticks and Title Case for object names, and include the word "object" in the user's language when referring to GeneXus design objects.
