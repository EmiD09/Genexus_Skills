---
name: gx-kb
description: Operate GeneXus Knowledge Bases through the gxnext CLI or the GeneXus MCP server — create/open KBs, configure environments and database connections, validate and import artifacts, and run builds with safety gates. Use when the user works with a GeneXus Knowledge Base, *.gx files, gxnext, or asks to build, import, or reorganize a GeneXus application.
metadata:
  version: "0.1.0"
---

# Scope

Knowledge Base lifecycle and tooling only. For GeneXus object syntax, modeling, and authoring, use the `gx-authoring` skill. Decline non-GeneXus requests and never expose values read from `*.local.*` files.

# Session bootstrap (always, in order)

1. Run `node scripts/detect-tooling.mjs` → `{interface, version, server: {reachable, toolCount}, notes}`.
   - The gxnext CLI is a client for the GeneXus MCP server (`GeneXus.PIA.McpServer`, default `http://127.0.0.1:1989/mcp`); all real tools are loaded from that server. `server.reachable: false` means only `list-tools` exists — follow the notes to start or point at a server before any KB operation.
   - `interface: "none"` → offer the user: install the gxnext CLI (`dotnet tool install --global GeneXus.Next.CLI`) or use the GeneXus MCP server registered directly in the agent runtime (check the runtime tool registry). Wait for the choice; do not proceed without a working interface.
2. Run `node scripts/kb-info.mjs <dir>` → `{exists, productVersion, kbLanguage, backendOnly, currentEnvironment, environments}`.
   - `<dir>` is the user-provided output directory, defaulting to the current directory.
   - Keep `productVersion` for feature-availability checks; re-run when switching Knowledge Bases.
3. Get tool specifications from the tool itself — `gxnext --help` and `gxnext list-tools --json` (or the MCP tool list). Never rely on remembered tool names or flags.

# Task routing

| Intent | Reference |
|---|---|
| Create / open / close a Knowledge Base; `src/` and `ref/` conventions | [task-kb-lifecycle](references/task-kb-lifecycle.md) |
| Create or switch environments | [task-environment](references/task-environment.md) |
| Configure the database connection | [task-connection](references/task-connection.md) |
| Validate and import written `.gx` artifacts | [task-validate-import](references/task-validate-import.md) |
| Build, database create/impact/reorg, export | [task-build](references/task-build.md) |

Load only the reference for the task at hand.

# Safety gates (always in force)

- Database `create`/`impact`/`reorg` are DANGEROUS and may delete data: require explicit user confirmation every time, and require `scripts/check-connection.mjs` to report `configured: true`.
- Builds never skip a required reorganization implicitly; surface it and apply the confirmation gate.
- Never write into `ref/` (read-only module references).
- Connection values and credentials live only in `*.local.env.gx`; `CurrentEnvironment` lives only in `*.local.kb.gx`. Never echo credential values back to the user.
- Running a generated main `Procedure` happens via the OS command line of the target environment, never via gxnext or MCP (see the `gx-authoring` Procedure reference).
- Never commit or push changes unless explicitly requested.

# Output

Reply in the user's language with a focused plan before acting and a concise summary after acting (actions, decisions, validations, errors, rejections). Reference GeneXus objects in backticks and Title Case.
