#!/bin/bash
# =============================================================================
# gx-cli.sh — Cliente MCP para las KBs de GeneXus
# -----------------------------------------------------------------------------
# Habla con los bridges de WSL (que a su vez hablan con los gateways de Windows).
# Los clientes anteriores vivían en /tmp y se perdían al reiniciar WSL.
#
# Uso:
#   gx-cli.sh gx   <herramienta> '<args json>'     # KB GX18 (puerto 5000)
#   gx-cli.sh gx17 <herramienta> '<args json>'     # KB GX17 (puerto 5101)
#
#   gx-cli.sh gx --schema genexus_edit             # ver el schema de una tool
#   gx-cli.sh gx --reset                           # rearmar la sesión MCP
#   gx-cli.sh --status                             # estado de la cadena
# =============================================================================

set -uo pipefail

# --- configuracion -----------------------------------------------------------
# Todo sale de ~/.config/gx-ai.conf (copiar de conf/gx-ai.conf.ejemplo).
# Los valores de abajo son solo el default si el archivo no existe.
GX_CONF="${GX_AI_CONF:-$HOME/.config/gx-ai.conf}"
[ -f "$GX_CONF" ] && . "$GX_CONF"
PORT_GX18="${PORT_GX18:-5000}"
PORT_GX17_BRIDGE="${PORT_GX17_BRIDGE:-5101}"
KB_GX18="${KB_GX18:-GX18_GesRec_Prd2026}"
KB_GX17="${KB_GX17:-GX17_Recursos}"

# --- seleccion de KB ---------------------------------------------------------
case "${1:-}" in
  gx|gx18) PORT="$PORT_GX18";        KB="$KB_GX18"; SIDF="$HOME/.cache/gx-sid-18.txt" ;;
  gx17)    PORT="$PORT_GX17_BRIDGE"; KB="$KB_GX17"; SIDF="$HOME/.cache/gx-sid-17.txt" ;;
  --status|'')
    echo "Estado de la cadena MCP de GeneXus:"
    for p in "$PORT_GX18" "$PORT_GX17_BRIDGE"; do
      printf '  bridge :%s  ->  ' "$p"
      curl -s -m 4 -o /dev/null "http://localhost:$p/mcp" 2>/dev/null && echo "activo" || echo "caído"
    done
    echo "  (si algo está caído: ~/bin/gx-mcp-up.sh)"
    exit 0 ;;
  *) echo "Uso: $0 {gx|gx17} <herramienta> '<args json>'  |  $0 --status" >&2; exit 2 ;;
esac

shift
U="http://localhost:$PORT/mcp"
H=(-H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream')
mkdir -p "$(dirname "$SIDF")"

call_raw() {
  # borrar el destino primero: si curl falla, NO queremos leer la respuesta vieja
  # (bug real: un fallo silencioso mostraba el resultado de la llamada anterior)
  : > "$2"
  curl -s -m 900 -o "$2" -X POST "$U" "${H[@]}" -H "Mcp-Session-Id: $(cat "$SIDF" 2>/dev/null)" -d @"$1"
}

bootstrap() {
  curl -s -m 40 -D /tmp/gx-h.txt -o /dev/null -X POST "$U" "${H[@]}" \
    -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"pi","version":"1.0"}}}'
  grep -i '^mcp-session-id:' /tmp/gx-h.txt | awk '{print $2}' | tr -d '\r\n' > "$SIDF"
  curl -s -m 20 -o /dev/null -X POST "$U" "${H[@]}" -H "Mcp-Session-Id: $(cat "$SIDF")" \
    -d '{"jsonrpc":"2.0","method":"notifications/initialized"}'
  printf '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"genexus_kb","arguments":{"action":"open","alias":"%s"}}}' "$KB" > /tmp/gx-p.json
  call_raw /tmp/gx-p.json /tmp/gx-r.json
  printf '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"genexus_kb","arguments":{"action":"select","alias":"%s"}}}' "$KB" > /tmp/gx-pb.json
  call_raw /tmp/gx-pb.json /tmp/gx-rb.json
}

if [ "${1:-}" = "--reset" ]; then rm -f "$SIDF"; echo "sesión reseteada"; exit 0; fi
[ -s "$SIDF" ] || bootstrap

if [ "${1:-}" = "--schema" ]; then
  echo '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' > /tmp/gx-p1.json
  call_raw /tmp/gx-p1.json /tmp/gx-sch.json
  python3 -c "
import json
d=json.load(open('/tmp/gx-sch.json'))
for t in d['result']['tools']:
    if t['name']=='$2': print(json.dumps(t,indent=1)); break
"
  exit 0
fi

python3 -c "
import json,sys
a=json.loads(sys.argv[2]); a.setdefault('kb','$KB')
print(json.dumps({'jsonrpc':'2.0','id':9,'method':'tools/call','params':{'name':sys.argv[1],'arguments':a}}))
" "$1" "${2:-{\}}" > /tmp/gx-payload.json
call_raw /tmp/gx-payload.json /tmp/gx-resp.json

if grep -q "Unknown or expired MCP session" /tmp/gx-resp.json 2>/dev/null; then
  rm -f "$SIDF"; bootstrap; call_raw /tmp/gx-payload.json /tmp/gx-resp.json
fi

python3 -c "
import json,sys
p='/tmp/gx-resp.json'
try:
    raw=open(p).read()
except Exception:
    print('ERROR: el bridge no respondio (sin respuesta)'); raise SystemExit(1)
if not raw.strip():
    print('ERROR: el bridge no respondio (respuesta vacia) — ~/bin/gx-mcp-up.sh --status'); raise SystemExit(1)
d=json.loads(raw)
if 'error' in d:
    print('ERROR:', json.dumps(d['error'],ensure_ascii=False)[:600]); raise SystemExit(1)
r=d.get('result',{})
for c in r.get('content',[]):
    if c.get('type')=='text': print(c['text'])
"
