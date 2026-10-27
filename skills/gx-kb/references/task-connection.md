---
name: task-connection
description: Configure the database connection for the current environment in the local environment file
---

# Goal
Define database connection values for the current environment so that build and database operations can run, storing all machine-specific values and credentials only in `*.local.env.gx`.

# Preconditions
- `scripts/kb-info.mjs <dir>` reports `exists: true`; the Knowledge Base is open.
- A current environment is set (`currentEnvironment` is non-empty).
- `scripts/check-connection.mjs <dir>` reports `configured: false` (otherwise this task is a no-op).

# Steps
1. Run `scripts/check-connection.mjs <dir>` and note `environment`, `generator`, and `missing[]`.
2. Ask the user to confirm connection setup; if declined, skip this task and record that build/impact/reorg remain blocked.
3. Ask the user for `DatabaseName` and `ServerName`.
4. Collect authentication values according to the generator:
   - `.NET`: ask the authentication type.
     - `Integrated Security`: set `UseTrustedConnection = 'Yes'` and leave `UserId` and `UserPassword` empty.
     - `SQL Server Authentication`: ask `UserId` and `UserPassword`.
   - `JAVA`: ask `UserId` and `UserPassword`.
5. Write or update `src/#preferences/<environment>.local.env.gx`, placing the values in the default `DataStore` of the `#Backend` section.
   - Never write `DatabaseName`, `ServerName`, `UserId`, `UserPassword`, or `UseTrustedConnection` into the shared `<environment>.env.gx` file.
6. Validate the artifact and import the `Environment` changes using the import operation.

# Postchecks
- `scripts/check-connection.mjs <dir>` reports `configured: true` and an empty `missing[]`.
- The shared `<environment>.env.gx` contains no credentials or server names.
- Credentials from `*.local.*` files are never echoed back to the user or included in summaries.

# Failure branches
- `check-connection` still reports values in `missing[]` after the write → re-ask only the missing values and rewrite the local file.
- Credentials or server names are found in the shared `*.env.gx` → raise a warning, move them to `*.local.env.gx`, remove them from the shared file, and re-import.
- User declines setup → skip configuration; deny any build, impact, or reorg request until `check-connection` reports `configured: true`.
- Import fails → report the errors, fix `*.local.env.gx`, and re-import before proceeding.
