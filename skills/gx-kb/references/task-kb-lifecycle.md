---
name: task-kb-lifecycle
description: Create, open, and close a GeneXus Knowledge Base, including src/ and ref/ directory conventions
---

# Goal
Ensure a Knowledge Base exists, is open, and follows the `src/` and `ref/` directory conventions before any other operation.

# Preconditions
- `scripts/detect-tooling.mjs` reports `interface != "none"`; all Knowledge Base operations go through `gxnext` or the MCP server.
- A target directory is known (ask the user for the output directory or default to the current directory).

# Steps
1. Run `scripts/kb-info.mjs <dir>` to inspect the target directory.
   - If `exists` is `true`, skip to step 3.
2. Create the Knowledge Base using the create operation, collecting all arguments from the user first:
   - `directory`: where generated files are saved.
   - `environment`: options `.NET`, `JAVA`.
   - `dbms`: options `SQL Server`, `PostgreSQL`, `MySQL`, `Oracle`, other.
   - `backendOnly`: `true` (reject UI objects) or `false` (allow UI objects).
3. Close any currently open Knowledge Base before opening another; only one Knowledge Base may be open at a time.
4. Open the target Knowledge Base before reading or editing any artifact.
5. Apply directory conventions:
   - Use `<dir>/src` as the base path of the `Root Module`; place all modeled artifacts under it.
   - Treat `<dir>/ref` as a read-only base path for external `Module` object references.
   - To use a referenced module, read its structure and object definitions from `ref/`, and run the install, update, or restore module operation as needed.
   - Never write into `ref/` and never change its structure.
6. Read `ProductVersion` from the `src/#preferences/*.kb.gx` file (format `<major>.<minor>.<patch>.<build>`); use it for feature-compatibility checks in later tasks.

# Postchecks
- `scripts/kb-info.mjs <dir>` reports `exists: true` and a non-empty `productVersion`.
- The Knowledge Base is open and `src/#preferences/` contains one `*.kb.gx` file and at least one `*.env.gx` file.
- No files under `ref/` were created, modified, or deleted.

# Failure branches
- `detect-tooling` reports `interface: "none"` → offer the user two options and wait for a choice: install the `gxnext` CLI (`dotnet tool install --global GeneXus.Next.CLI`) or use the GeneXus MCP server standalone.
- `gxnext` installation fails → offer fallback to the MCP server standalone, or stop until the CLI is installed.
- MCP server is unregistered or the handshake fails → warn the user, offer setup guidance, and wait; do not proceed without a working interface.
- Create operation fails (directory not writable, arguments rejected) → report the error, re-ask the failing argument, and retry.
- Open fails because another Knowledge Base is open → close it first, then retry the open.
