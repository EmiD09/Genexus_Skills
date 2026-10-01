// GX MCP bridge: forwards TCP from localhost:1989 (WSL) to Windows host MCP server.
// GitHub path: ~/bin/gx-mcp-bridge.js
// Usage: node ~/bin/gx-mcp-bridge.js
const net = require("net");

const UPSTREAM_HOST = process.env.GX_MCP_HOST || ""   // vacio: se detecta con ip route;
const UPSTREAM_PORT = parseInt(process.env.GX_MCP_PORT || "1989", 10);
const LISTEN_PORT = parseInt(process.env.GX_MCP_LISTEN || "1989", 10);
const LISTEN_HOST = "127.0.0.1";

const server = net.createServer((clientSocket) => {
  const upstream = net.connect(UPSTREAM_PORT, UPSTREAM_HOST, () => {
    clientSocket.pipe(upstream);
    upstream.pipe(clientSocket);
  });
  upstream.on("error", (err) => {
    console.error(`[gx-mcp-bridge] upstream error: ${err.message}`);
    clientSocket.destroy();
  });
  clientSocket.on("error", (err) => {
    console.error(`[gx-mcp-bridge] client error: ${err.message}`);
    upstream.destroy();
  });
});

server.listen(LISTEN_PORT, LISTEN_HOST, () => {
  console.log(
    `[gx-mcp-bridge] listening on http://${LISTEN_HOST}:${LISTEN_PORT}/mcp -> ${UPSTREAM_HOST}:${UPSTREAM_PORT}`
  );
});