// GX MCP Gateway bridge (HTTP): exposes the Windows genexus-mcp gateway to WSL loopback.
// Injects GXMCP_HTTP_TOKEN as Bearer auth on every request.
// Usage: node ~/bin/gx-mcp-gateway-bridge.js <token> [wslListenPort] [host|port]
const http = require("http");

const TOKEN = process.argv[2];
const LISTEN_PORT = parseInt(process.argv[3] || "5000", 10);
// Host de Windows: se puede pasar por env, si no se detecta solo (WSL)
function detectarHost() {
  try {
    return require('child_process').execSync("ip route | awk '/^default/{print $3}'")
      .toString().trim();
  } catch (e) { return ''; }
}
const HOST_IP = process.env.GX_HOST_IP || detectarHost();
const HOST_PORT = parseInt(process.env.GX_HOST_PORT || "5000", 10);   // destino en Windows (configurable)

const server = http.createServer((clientReq, clientRes) => {
  const options = {
    hostname: HOST_IP,
    port: HOST_PORT,
    path: clientReq.url,
    method: clientReq.method,
    headers: {
      ...clientReq.headers,
      host: `${HOST_IP}:${HOST_PORT}`,
      authorization: `Bearer ${TOKEN}`,
    },
  };

  const proxyReq = http.request(options, (proxyRes) => {
    // Forward status and headers (trim hop-by-hop)
    const safeHeaders = { ...proxyRes.headers };
    delete safeHeaders["content-length"];
    delete safeHeaders["connection"];
    clientRes.writeHead(proxyRes.statusCode || 502, safeHeaders);
    proxyRes.pipe(clientRes);
  });

  proxyReq.on("error", (err) => {
    console.error(`[gx-mcp-gateway-bridge] upstream error: ${err.message}`);
    if (!clientRes.headersSent) {
      clientRes.writeHead(502, { "content-type": "text/plain" });
      clientRes.end("bridge upstream error");
    } else {
      clientRes.end();
    }
  });

  clientReq.pipe(proxyReq);
});

server.listen(LISTEN_PORT, "127.0.0.1", () => {
  console.log(
    `[gx-mcp-gateway-bridge] listening on http://127.0.0.1:${LISTEN_PORT}/mcp -> ${HOST_IP}:${HOST_PORT} (token injected)`
  );
});