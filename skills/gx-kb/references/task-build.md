---
name: task-build
description: Build artifacts, run database create/impact/reorg with a danger gate, and export artifacts
---

# Goal
Run build, database, and export operations safely, with explicit user confirmation for every dangerous operation.

# Preconditions
- `scripts/kb-info.mjs <dir>` reports `exists: true`; the Knowledge Base is open.
- All written artifacts have been validated and imported (see task-validate-import.md).
- For build, impact, reorg, and database create: `scripts/check-connection.mjs <dir>` reports `configured: true` (otherwise run task-connection.md first).

# Steps
1. Determine the requested operation: build (one artifact or all), database create/impact/reorg, or export.
2. For database `create`, `impact`, or `reorg`:
   - State clearly that the operation is DANGEROUS and may delete existing data.
   - Ask explicit user confirmation EVERY time, even if a similar operation was confirmed earlier in the session.
   - Verify `check-connection` reports `configured: true`; deny the operation otherwise.
   - Run the corresponding database operation only after confirmation.
3. For `build` (one artifact or all):
   - Ask explicit user confirmation before running.
   - Never skip reorganization implicitly; if the build requires a reorganization, surface it and apply the danger gate from step 2.
   - Run the build operation and report errors verbatim.
4. For `export`:
   - Ask explicit user confirmation before running.
   - Set `rootDirectory` to the output directory value.
   - Run the export operation.
5. To run a generated main `Procedure`: use the OS command line of the target environment, following the COMMAND LINE EXECUTION section of the `Procedure` reference; never run it through `gxnext` or the MCP server.

# Postchecks
- The operation completed without errors, or all errors were reported to the user verbatim.
- No database operation ran without a fresh, explicit user confirmation.
- Exported files exist under the configured `rootDirectory`.

# Failure branches
- `check-connection` reports `configured: false` → deny build/impact/reorg/create and run task-connection.md.
- User declines confirmation → cancel the operation, leave the Knowledge Base unchanged, and record the rejection in the summary.
- Build fails with compilation or specification errors → report the errors, fix the affected artifacts, re-run validate/import, then offer to rebuild.
- A required reorganization is detected during build → stop, present it as a dangerous operation, and apply the confirmation gate before continuing.
- User asks to run a built main `Procedure` via `gxnext` → decline and point to the OS command line of the target environment.
