---
name: task-environment
description: Create a new environment or switch the current environment of a Knowledge Base
---

# Goal
Create an `Environment` definition or change which environment is current, keeping the current-environment setting local to the machine.

# Preconditions
- `scripts/detect-tooling.mjs` reports `interface != "none"`.
- `scripts/kb-info.mjs <dir>` reports `exists: true`; the Knowledge Base is open.

# Steps
1. List available environments by reading the file names of `src/#preferences/*.env.gx`; `scripts/kb-info.mjs <dir>` returns the same list in `environments[]` and the active one in `currentEnvironment`.
2. When creating a new environment:
   - Write `src/#preferences/<name>.env.gx` with the shared configuration only (`#Properties`, `#Backend` generators and data stores, `#Frontend`, `#DeploymentUnits`); never put credentials or server names in this file.
   - Set the `CurrentEnvironment` property in `src/#preferences/<kbname>.local.kb.gx` to `<name>` if the new environment should become current.
   - Import the `Environment` changes using the import operation.
3. When switching the current environment:
   - Verify the target name matches an existing `src/#preferences/<name>.env.gx` file.
   - Set the `CurrentEnvironment` property in `src/#preferences/<kbname>.local.kb.gx`; create the local file if it does not exist.
   - Never write `CurrentEnvironment` into the shared `<kbname>.kb.gx` file; it is a local-only setting.
   - Import the change using the import operation.

# Postchecks
- `scripts/kb-info.mjs <dir>` reports `currentEnvironment` equal to the intended environment name.
- The shared `<kbname>.kb.gx` file does not contain a `CurrentEnvironment` property.
- For a new environment, `<name>.env.gx` validates and the import operation succeeded.

# Failure branches
- Target environment name has no matching `*.env.gx` file → list the names found in `src/#preferences/` and ask the user to choose one or create it.
- `CurrentEnvironment` is found in the shared `<kbname>.kb.gx` → raise a warning, move the property to `<kbname>.local.kb.gx`, and remove it from the shared file.
- Import fails after writing `*.env.gx` → report the validation errors, fix the artifact, and re-import before any further operation.
- `kb-info` reports `exists: false` → run the KB lifecycle task first (see task-kb-lifecycle.md).
