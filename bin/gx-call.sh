#!/bin/bash
# call a genexus-mcp tool via the persistent client:  gx-call.sh <tool> '<json args>' [timeout]
# result: stdout = json {isError:bool, text|error}
set -euo pipefail
CMD_DIR=/tmp/gx-mcp-cmds
CID=$(date +%s%N)
if [ $# -ge 2 ]; then ARGS="$2"; else ARGS='{}'; fi
if [ $# -ge 3 ]; then TMO="$3"; else TMO=600; fi
if [ $# -ge 4 ]; then WAIT="$4"; else WAIT=240; fi
printf '{"id":"%s","tool":"%s","timeout":%s,"args":%s}' "$CID" "$1" "$TMO" "$ARGS" > "$CMD_DIR/$CID.json"
FILE="$CMD_DIR/$CID.res.json"
for i in $(seq 1 "$WAIT"); do [ -f "$FILE" ] && break; sleep 2; done
[ -f "$FILE" ] || { echo "TIMEOUT waiting response $CID"; exit 124; }
cat "$FILE"
