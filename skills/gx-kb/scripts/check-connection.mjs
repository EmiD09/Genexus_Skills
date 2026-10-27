#!/usr/bin/env node
// Deterministic connection-readiness probe. Usage: node check-connection.mjs [dir] [environment]
// Prints JSON: {configured, environment, generator, missing[], leaks[]}
// SECURITY: reports only which keys are present/missing — never prints credential values.
import fs from "node:fs";
import path from "node:path";

const dir = path.resolve(process.argv[2] ?? ".");
const prefs = path.join(dir, "src", "#preferences");
const out = { configured: false, environment: null, generator: null, missing: [], leaks: [] };

const prop = (text, name) => {
  const m = text.match(new RegExp(`\\b${name}\\s*=\\s*["']([^"']*)["']`));
  return m && m[1] !== "" ? m[1] : null;
};

if (!fs.existsSync(prefs)) {
  out.missing.push("src/#preferences directory");
  console.log(JSON.stringify(out, null, 2));
  process.exit(0);
}
const files = fs.readdirSync(prefs);

// resolve target environment: argv[3] > CurrentEnvironment in *.local.kb.gx > single env file
let env = process.argv[3] ?? null;
if (!env) {
  for (const lf of files.filter((f) => f.endsWith(".local.kb.gx"))) {
    env = prop(fs.readFileSync(path.join(prefs, lf), "utf8"), "CurrentEnvironment") ?? env;
  }
}
const envFiles = files.filter((f) => f.endsWith(".env.gx") && !f.endsWith(".local.env.gx"));
if (!env && envFiles.length === 1) env = envFiles[0].replace(/\.env\.gx$/, "");
out.environment = env;
if (!env) {
  out.missing.push("CurrentEnvironment (no environment resolved)");
  console.log(JSON.stringify(out, null, 2));
  process.exit(0);
}

const sharedPath = path.join(prefs, `${env}.env.gx`);
const localPath = path.join(prefs, `${env}.local.env.gx`);
const shared = fs.existsSync(sharedPath) ? fs.readFileSync(sharedPath, "utf8") : "";
const local = fs.existsSync(localPath) ? fs.readFileSync(localPath, "utf8") : "";

const gen = shared.match(/\bGenerator\s*=\s*["']([^"']+)["']/);
out.generator = gen ? gen[1] : null;
const isJava = /java/i.test(out.generator ?? "");

// credentials must NOT be in the shared file
for (const key of ["DatabaseName", "ServerName", "UserId", "UserPassword", "UseTrustedConnection"]) {
  if (prop(shared, key) !== null) out.leaks.push(`${key} found in shared ${env}.env.gx — move it to ${env}.local.env.gx`);
}

if (!fs.existsSync(localPath)) {
  out.missing.push(`${env}.local.env.gx`);
} else {
  const has = (k) => prop(local, k) !== null;
  if (!has("DatabaseName")) out.missing.push("DatabaseName");
  if (!has("ServerName")) out.missing.push("ServerName");
  const trusted = /\bUseTrustedConnection\s*=\s*["']?Yes["']?/i.test(local);
  if (isJava || !trusted) {
    if (!has("UserId")) out.missing.push("UserId");
    if (!has("UserPassword")) out.missing.push("UserPassword");
  }
}

out.configured = out.missing.length === 0 && out.leaks.length === 0;
console.log(JSON.stringify(out, null, 2));
