#!/usr/bin/env node
// Minimal MCP stdio client for GX18 genexus-mcp (stdio, cmd.exe /c npx genexus-mcp)
// Usage: node gx-mcp-call.js <tool> '<json args>' [--schema <tool>] [--list]
const { spawn } = require('node:child_process');

const args = process.argv.slice(2);
const list = args[0] === '--list';
const schemaOf = args[0] === '--schema' ? args[1] : null;
const tool = list || schemaOf ? null : args[0];
const toolArgs = (!list && !schemaOf) ? (() => {
  const raw = args[1] || '{}';
  try { return JSON.parse(raw); } catch (e) { console.error('BAD JSON ARG: ' + raw); process.exit(2); }
})() : null;

const child = spawn('cmd.exe', ['/c', 'npx -y genexus-mcp@latest'], {
  cwd: '/mnt/c', // Windows-visible dir; '/' resolves to UNC and cmd.exe falls back weirdly
  stdio: ['pipe', 'pipe', 'pipe'],
});

let buf = '';
const pending = new Map();
let nextId = 1;
const TIMEOUT = parseInt(process.env.GX_MCP_TIMEOUT || '300', 10);
const TOOL_TIMEOUT = parseInt(process.env.GX_MCP_TOOL_TIMEOUT || '900', 10);

function send(obj) {
  child.stdin.write(JSON.stringify(obj) + '\n');
}

function request(method, params, timeoutSec) {
  return new Promise((resolve, reject) => {
    const id = nextId++;
    pending.set(id, { resolve, reject, timer: setTimeout(() => {
      pending.delete(id);
      reject(new Error('timeout on ' + method + ' after ' + timeoutSec + 's'));
    }, timeoutSec * 1000) });
    send({ jsonrpc: '2.0', id, method, params });
  });
}

child.stdout.on('data', (d) => {
  buf += d.toString();
  let idx;
  while ((idx = buf.indexOf('\n')) >= 0) {
    const line = buf.slice(0, idx).trim();
    buf = buf.slice(idx + 1);
    if (!line) continue;
    let msg;
    try { msg = JSON.parse(line); } catch (e) { continue; }
    if (msg.id && pending.has(msg.id)) {
      const p = pending.get(msg.id);
      clearTimeout(p.timer);
      pending.delete(msg.id);
      if (msg.error) p.reject(new Error(JSON.stringify(msg.error)));
      else p.resolve(msg.result);
    }
  }
});
child.stderr.on('data', (d) => process.stderr.write('[gx-mcp stderr] ' + d));

const initP = request('initialize', {
  protocolVersion: '2024-11-05',
  capabilities: {},
  clientInfo: { name: 'pi-gx-cli', version: '1.0' },
}, 120);

(async () => {
  const [portInit, listRes] = await Promise.all([initP, request('tools/list', {}, 180)]);
  send({ jsonrpc: '2.0', method: 'notifications/initialized' });

  const tools = listRes.tools || [];
  if (list) {
    for (const t of tools) console.log(t.name);
    child.kill('SIGTERM'); process.exit(0);
  }
  if (schemaOf) {
    const t = tools.find(t => t.name === schemaOf);
    if (!t) { console.error('TOOL NOT FOUND: ' + schemaOf); console.error('available: ' + tools.map(t => t.name).join(', ')); process.exit(3); }
    console.log(JSON.stringify(t, null, 2));
    child.kill('SIGTERM'); process.exit(0);
  }
  if (!tool) { console.error('usage: gx-mcp-call.js <tool> <json> | --list | --schema <tool>'); process.exit(2); }
  const t = tools.find(t => t.name === tool);
  if (!t) { console.error('TOOL NOT FOUND: ' + tool + '\navailable: ' + tools.map(t => t.name).join(', ')); process.exit(3); }

  const res = await request('tools/call', { name: tool, arguments: toolArgs }, TOOL_TIMEOUT);
  const out = [];
  for (const c of res.content || []) {
    if (c.type === 'text') out.push(c.text);
    else out.push(JSON.stringify(c));
  }
  console.log(out.join('\n'));
  if (typeof res.isError === 'boolean') console.log('\n[isError] ' + res.isError);
  child.kill('SIGTERM');
  process.exit(0);
})().catch((e) => {
  console.error('ERROR: ' + (e && e.message || e));
  child.kill('SIGTERM');
  process.exit(1);
});

setTimeout(() => { console.error('HARD TIMEOUT (total ' + (TOOL_TIMEOUT + 30) + 's)'); child.kill('SIGKILL'); process.exit(124); }, (TOOL_TIMEOUT + 30) * 1000);
