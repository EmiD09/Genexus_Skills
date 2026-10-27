// GENERATED copy from gx-kb/scripts/kb-info.mjs — edit there and run `npm run build`.
#!/usr/bin/env node
// Deterministic Knowledge Base state probe. Usage: node kb-info.mjs [dir]
// Prints JSON: {exists, kbFile, productVersion, kbLanguage, backendOnly, currentEnvironment, environments[]}
// Reads only src/#preferences/*.gx model files; never prints values from connection credentials.
import fs from "node:fs";
import path from "node:path";

const dir = path.resolve(process.argv[2] ?? ".");
const prefs = path.join(dir, "src", "#preferences");

const out = {
  exists: false,
  kbFile: null,
  productVersion: null,
  kbLanguage: null,
  backendOnly: null,
  currentEnvironment: null,
  environments: [],
};

const prop = (text, name) => {
  const m = text.match(new RegExp(`\\b${name}\\s*=\\s*["']([^"']*)["']`));
  return m ? m[1] : null;
};
const boolProp = (text, name) => {
  const m = text.match(new RegExp(`\\b${name}\\s*=\\s*["']?(true|false)["']?`, "i"));
  return m ? m[1].toLowerCase() === "true" : null;
};

if (fs.existsSync(prefs)) {
  const files = fs.readdirSync(prefs);
  const kbFiles = files.filter((f) => f.endsWith(".kb.gx") && !f.includes(".local."));
  const localKbFiles = files.filter((f) => f.endsWith(".local.kb.gx"));
  out.environments = files
    .filter((f) => f.endsWith(".env.gx") && !f.endsWith(".local.env.gx"))
    .map((f) => f.replace(/\.env\.gx$/, ""));

  if (kbFiles.length > 0) {
    out.exists = true;
    out.kbFile = path.join("src", "#preferences", kbFiles[0]);
    const text = fs.readFileSync(path.join(prefs, kbFiles[0]), "utf8");
    out.productVersion = prop(text, "ProductVersion");
    out.kbLanguage = prop(text, "KbLanguage");
    out.backendOnly = boolProp(text, "BackendOnly");
    out.currentEnvironment = prop(text, "CurrentEnvironment"); // legacy placement; local file wins below
    for (const lf of localKbFiles) {
      const ltext = fs.readFileSync(path.join(prefs, lf), "utf8");
      out.currentEnvironment = prop(ltext, "CurrentEnvironment") ?? out.currentEnvironment;
      out.backendOnly = boolProp(ltext, "BackendOnly") ?? out.backendOnly;
    }
  }
}

console.log(JSON.stringify(out, null, 2));
