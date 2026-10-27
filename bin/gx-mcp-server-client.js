#!/usr/bin/env node
// Persistent MCP stdio client for GX18 genexus-mcp.
// Reads requests from /tmp/gx-req.json:  {"id":"n1","tool":"genexus_read","args":{...}}
// Writes response to /tmp/gx-res-<id>.json (atomic-ish), also logs to /tmp/gx-mcp-pc.log
const { spawn } = require('node:child_process');
const fs = require('node:fs');

const REQ = '/tmp/gx-req.json';
const LOG = '/tmp/gx-mcp-pc.log';
const CMD_DIR = '/tmp/gx-mcp-cmds';

const log = (m) => { try { fs.appendFileSync(LOG, new Date().toISOString() + ' ' + m + '\n'); } catch (e) {} };

fs.mkdirSync(CMD_DIR, { recursive: true });
try { fs.unlinkSync(REQ); } catch (e) {}

const child = spawn('cmd.exe', ['/c', 'npx -y genexus-mcp@latest'], { stdio: ['pipe', 'pipe', 'pipe'] });
let buf = '';
const pending = new Map();
let nextId = 1;

function send(obj) { child.stdin.write(JSON.stringify(obj) + '\n'); log('SEND ' + obj.method); }
function request(method, params, timeoutSec) {
  return new Promise((resolve, reject) => {
    const id = nextId++;
    pending.set(id, { resolve, reject, timer: setTimeout(() => { pending.delete(id); reject(new Error('timeout ' + method)); }, timeoutSec * 1000) });
    send({ jsonrpc: '2.0', id, method, params });
  });
}

child.stdout.on('data', (d) => {
  buf += d.toString();
  let idx;
  while ((idx = buf.indexOf('\n')) >= 0) {
    const line = buf.slice(0, idx).trim(); buf = buf.slice(idx + 1);
    if (!line) continue;
    let msg; try { msg = JSON.parse(line); } catch (e) { continue; }
    if (msg.id && pending.has(msg.id)) {
      const p = pending.get(msg.id); clearTimeout(p.timer); pending.delete(msg.id);
      msg.error ? p.reject(new Error(JSON.stringify(msg.error))) : p.resolve(msg.result);
    }
  }
});
child.stderr.on('data', (d) => log('STDERR ' + d.toString().trim()));
child.on('exit', (c) => { log('SERVER EXIT ' + c); process.exit(3); });

async function main() {
  let tools = [];
  const toolsP = request('tools/list', {}, 300).then(r => { tools = r.tools || []; log('TOOLS ' + tools.length); });
  send(await request('initialize', { protocolVersion: '2025-06-18', capabilities: {}, clientInfo: { name: 'pi-gx-pc', version: '1.0' } }, 180));
  send({ jsonrpc: '2.0', method: 'notifications/initialized' });
  await toolsP;
  let lastSeen = 0;
  // ready marker
  fs.writeFileSync('/tmp/gx-mcp-pc.ready', String(Date.now()));
  log('READY');
  const seenCmds = new Set();
  setInterval(() => {
    let files = [];
    try { files = fs.readdirSync(CMD_DIR).filter(f => f.endsWith('.json')).sort(); } catch (e) {}
    for (const f of files) {
      if (seenCmds.has(f)) continue;
      seenCmds.add(f);
      const raw = fs.readFileSync(CMD_DIR + '/' + f, 'utf8');
      let req; try { req = JSON.parse(raw); } catch (e) { log('BAD CMD ' + f); continue; }
      const callerId = req.id;
      const tool = req.tool || (req.schema ? req.tool : null);
      const outPath = CMD_DIR + '/' + callerId + '.res.json';
      if (req.tool === undefined) {
        fs.writeFileSync(outPath, JSON.stringify({ tools: tools.map(t => t.name) }));
        continue;
      }
      if (req.schema) {
        const t = tools.find(t => t.name === req.tool);
        fs.writeFileSync(outPath, JSON.stringify(t || { error: 'NOT FOUND' }));
        continue;
      }
      log('CALL ' + req.tool + ' ' + (JSON.stringify(req.args || {})).slice(0, 120));
      request('tools/call', { name: req.tool, arguments: req.args || {} }, parseInt(req.timeout || '600', 10))
        .then((res) => {
          const out = (res.content || []).map(c => c.type === 'text' ? c.text : JSON.stringify(c)).join('\n');
          fs.writeFileSync(outPath, JSON.stringify({ isError: !!res.isError, text: out }));
          log('OK ' + req.tool);
        })
        .catch((e) => {
          fs.writeFileSync(outPath, JSON.stringify({ isError: true, error: String(e.message || e) }));
          log('ERR ' + req.tool + ' ' + (e.message || e));
        });
    }
  }, 700);
}
main().catch((e) => { log('FATAL ' + (e.message || e)); process.exit(2); });
