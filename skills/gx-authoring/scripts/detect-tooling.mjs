// GENERATED copy from gx-kb/scripts/detect-tooling.mjs — edit there and run `npm run build`.
#!/usr/bin/env node
// Deterministic tooling probe. Prints JSON:
//   {interface: "gxnext"|"none", version, server: {reachable, toolCount}, notes[]}
// Architecture (confirmed against GeneXus.Next.CLI 1.0.0): gxnext is a thin CLI client for the
// GeneXus MCP server (GeneXus.PIA.McpServer). Its only built-in command is `list-tools`; all
// real tools are loaded dynamically from the server (default URL: $GXNEXT_MCP_SERVER or
// http://127.0.0.1:1989/mcp). gxnext auto-starts the server when its executable is on PATH,
// next to gxnext, or pointed to by $GXNEXT_MCP_SERVER_EXE.
import { spawnSync } from "node:child_process";

const isWin = process.platform === "win32";
const notes = [];
const result = { interface: "none", version: null, server: { reachable: false, toolCount: null }, notes };

const probe = spawnSync("gxnext", ["--version"], { encoding: "utf8", shell: isWin });
if (!probe.error && probe.status === 0) {
  result.interface = "gxnext";
  result.version = String(probe.stdout || probe.stderr).trim();

  const tools = spawnSync("gxnext", ["list-tools", "--json"], { encoding: "utf8", shell: isWin, timeout: 30000 });
  try {
    const parsed = JSON.parse(String(tools.stdout).replace(/^[^[{]*/, ""));
    if (Array.isArray(parsed)) {
      result.server.reachable = true;
      result.server.toolCount = parsed.length;
    }
  } catch {
    /* server unreachable or non-JSON output */
  }
  if (!result.server.reachable) {
    notes.push("gxnext CLI is installed but the GeneXus MCP server is not reachable (default http://127.0.0.1:1989/mcp).");
    notes.push("Start the server: ensure GeneXus.PIA.McpServer is on PATH or set GXNEXT_MCP_SERVER_EXE to its full path (gxnext auto-starts it), or point gxnext at a running server with -s/$GXNEXT_MCP_SERVER.");
    notes.push("Without the server only the built-in `list-tools` command exists; KB operations are unavailable.");
  }
} else {
  notes.push("gxnext not found on PATH. Install with: dotnet tool install --global GeneXus.Next.CLI");
  const dotnet = spawnSync("dotnet", ["--version"], { encoding: "utf8", shell: isWin });
  if (dotnet.error || dotnet.status !== 0) {
    notes.push("dotnet SDK not found either — installing the .NET SDK is a prerequisite for the gxnext CLI.");
  }
  notes.push("If the GeneXus MCP server is registered directly in the agent runtime, it can be used without gxnext; check the runtime tool registry (not probeable from this script).");
}

console.log(JSON.stringify(result, null, 2));
