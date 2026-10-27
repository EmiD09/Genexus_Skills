#!/bin/bash
# xsimple MCP HTTP client for gx-oficial (:1989)
set -uo pipefail
U="http://localhost:1989/mcp"
H=(-H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream')
SIDF=/tmp/gx-official-sid.txt
call() { curl -s -m "${3:-60}" -X POST "$U" "${H[@]}" -H "Mcp-Session-Id: $(cat $SIDF 2>/dev/null)" -d "$1"; echo; }
case "${1:-}" in
  init)
    curl -s -m 30 -D /tmp/gx-h.txt -o /dev/null -X POST "$U" "${H[@]}" -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"pi-gx","version":"1.0"}}}'
    grep -i '^mcp-session-id:' /tmp/gx-h.txt | awk '{print $2}' | tr -d '\r\n' > $SIDF
    call '{"jsonrpc":"2.0","method":"notifications/initialized"}' > /dev/null
    echo "initialized sid=$(cat $SIDF)";;
  list) call '{"jsonrpc":"2.0","id":10,"method":"tools/list","params":{}}' 120 ;;
  call) shift; T="$1"; A="${2:-\{\}}"; call "$(python3 -c "import json,sys; print(json.dumps({'jsonrpc':'2.0','id':11,'method':'tools/call','params':{'name':sys.argv[1],'arguments':json.loads(sys.argv[2] or '{}')}}))" "$T" "$A")" 600 ;;
  *) echo "usage: $0 init|list|call <tool> '<json>'" >&2; exit 2;;
esac
