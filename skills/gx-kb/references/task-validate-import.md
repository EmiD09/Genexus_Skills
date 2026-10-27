---
name: task-validate-import
description: Validate written .gx artifacts, import them into the Knowledge Base, and run an integration check
---

# Goal
Guarantee that every written `.gx` artifact is syntactically valid, imported into the open Knowledge Base, and consistent with the rest of the model.

# Preconditions
- `scripts/detect-tooling.mjs` reports `interface != "none"`.
- `scripts/kb-info.mjs <dir>` reports `exists: true`; the Knowledge Base is open.
- One or more `.gx` files were written or modified during the current task.

# Steps
1. Discover the available operations:
   - With the `gxnext` CLI, run `gxnext list-tools --json` and identify the validate, import, and integration-check operations from the tool specs.
   - With the MCP server, use the equivalent tools from its tool list.
2. After each individual file write, run the validate operation on that artifact.
   - Fix any reported error in the artifact and re-validate before writing the next file.
3. After all files are written, run the import operation covering every written artifact.
   - This includes `#preferences` model files: importing `Environment` changes after any `*.env.gx` or `*.local.env.gx` write is mandatory.
4. Run the integration check operation to confirm cross-references, calls, and module/folder placement are consistent across the Knowledge Base.

# Postchecks
- Every written artifact passed the validate operation with no errors.
- The import operation completed without rejected artifacts.
- The integration check reports no unresolved references or inconsistencies.

# Failure branches
- Validate reports a syntax or constraint error → correct the artifact against its `object-*.md` or `model-*.md` reference and re-validate; never import an invalid artifact.
- Import rejects an artifact → read the rejection reason, fix the artifact or its references, and re-run the import for the affected artifacts.
- Integration check reports broken cross-references → locate the missing or renamed objects under `src/**`, fix the references, then repeat validate, import, and the integration check.
- The validate or import operation cannot be found in the tool list → re-run `gxnext list-tools --json` (or refresh the MCP tool list) and report to the user if the operation is genuinely unavailable; do not guess tool names.

# Caveats
- Repeatedly importing/validating the same object can duplicate entries in some sections (observed: `#Orders` entries duplicated and a stray `;` accumulated in `#Conditions` after ~5 imports of one DataSelector, engine 19.2.0.265). For repeated syncs of one object, export it back afterwards and diff against the intended text.
