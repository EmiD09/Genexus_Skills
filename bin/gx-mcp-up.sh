#!/usr/bin/env bash
# =============================================================================
# gx-mcp-up.sh — Levanta la cadena MCP de GeneXus
# -----------------------------------------------------------------------------
# Deja operativos, en este orden:
#
#   1. Gateway comunitario en Windows   (puerto 5000)  ->  MCP "gx-mcp"
#   2. Servidor oficial en Windows      (puerto 1989)  ->  MCP "gx-oficial"
#   3. Bridges TCP/HTTP en WSL (tmux)   hacia ambos
#
# Es IDEMPOTENTE: si algo ya está levantado, lo saltea. Se puede correr las
# veces que haga falta, incluso en paralelo (hay un lock).
#
# Uso:
#   gx-mcp-up.sh              levanta todo y muestra el estado
#   gx-mcp-up.sh --quiet      sin salida (para arranque automático)
#   gx-mcp-up.sh --status     solo informa el estado, no levanta nada
# =============================================================================

set -uo pipefail

# --- configuracion -----------------------------------------------------------
# TODAS las rutas, puertos y nombres de KB salen de ~/.config/gx-ai.conf
# (copiar de conf/gx-ai.conf.ejemplo). Lo de abajo es solo el default.
GX_CONF="${GX_AI_CONF:-$HOME/.config/gx-ai.conf}"
[ -f "$GX_CONF" ] && . "$GX_CONF"

GX_WIN_USER="${GX_WIN_USER:-}"
MOUNT_WIN="${MOUNT_WIN:-/mnt/c}"

# Convierte una ruta de Windows (C:\Users\...) a su equivalente en WSL (/mnt/c/Users/...)
win_a_wsl() { printf '%s/%s' "$MOUNT_WIN" "$(printf '%s' "$1" | tr '\\' '/' | sed -e 's|^[A-Za-z]:||' -e 's|^/||')"; }

# Ruta del gateway en formato WSL y en formato Windows
GX_GATEWAY_DIR_WIN="${GX_GATEWAY_DIR_WIN:-C:\\Users\\$GX_WIN_USER\\AppData\\Local\\npm-cache\\_npx\\<hash>\\node_modules\\genexus-mcp\\publish}"
GX_OFFICIAL_DIR_WIN="${GX_OFFICIAL_DIR_WIN:-C:\\Users\\$GX_WIN_USER\\AppData\\Local\\Programs\\GeneXus\\GeneXus Next\\bl}"
GX_GATEWAY_DIR="$(win_a_wsl "$GX_GATEWAY_DIR_WIN")"
GX_OFFICIAL_DIR="$(win_a_wsl "$GX_OFFICIAL_DIR_WIN")"

PORT_COMMUNITY="${PORT_GX18:-5000}"      # gateway comunitario (requiere token)

PORT_OFFICIAL="${PORT_OFFICIAL:-1989}"    # servidor oficial de GeneXus

# --- segunda KB: GeneXus 17 (GX17_Recursos) ---------------------------------
# El gateway de GeneXus tiene UN SOLO InstallationPath, asi que GX17 necesita su
# propia instancia del gateway con su propio config (config-gx17.json, puerto
# 5001). Su bridge en WSL escucha en 5101.
GX17_LAUNCHER_WIN="${GX17_LAUNCHER_WIN:-}"
GX17_LAUNCHER_DIR="$(win_a_wsl "$GX17_LAUNCHER_WIN")"
PORT_GX17=5001          # gateway de GX17 en Windows
PORT_GX17_BRIDGE=5101   # bridge de GX17 en WSL

BRIDGE_HTTP="$HOME/bin/gx-mcp-gateway-bridge.js"
BRIDGE_TCP="$HOME/bin/gx-mcp-bridge.js"
TMUX_HTTP='gxproxy2'
TMUX_TCP='gxproxy'
TMUX_AGENTS='gxagentbridge'
TMUX_HTTP17='gxproxy17'

LOCK="$HOME/.cache/gx-mcp-up.lock"

# --- modos -------------------------------------------------------------------
QUIET=0; STATUS_ONLY=0
for a in "$@"; do
  case "$a" in
    --quiet)  QUIET=1 ;;
    --status) STATUS_ONLY=1 ;;
  esac
done
say() { [ "$QUIET" = 1 ] || echo "$@"; }

# --- lock (evita corridas simultáneas) ---------------------------------------
mkdir -p "$(dirname "$LOCK")"
if ! mkdir "$LOCK" 2>/dev/null; then
  # hay otra corrida en curso; si el lock es viejo (>10 min), lo reciclo
  if [ -n "$(find "$LOCK" -maxdepth 0 -mmin +10 2>/dev/null)" ]; then rm -rf "$LOCK"; mkdir "$LOCK" 2>/dev/null || exit 0; else exit 0; fi
fi
trap 'rm -rf "$LOCK"' EXIT

# --- helpers -----------------------------------------------------------------
# curl devuelve 0 si el servidor respondió (cualquier código HTTP)
up() { curl -s -m 4 -o /dev/null "$1" 2>/dev/null; }

start_bridge() { # $1=sesión tmux  $2=comando  $3=descripción
  if tmux has-session -t "$1" 2>/dev/null; then
    say "  $3: ya estaba"
  else
    tmux new-session -d -s "$1" "$2" 2>/dev/null \
      && say "  $3: arrancado" \
      || say "  $3: ERROR al arrancar"
  fi
}

# --- datos del entorno -------------------------------------------------------
TOKEN=$(MSYS_NO_PATHCONV=1 reg.exe query 'HKCU\Environment' /v GXMCP_HTTP_TOKEN 2>/dev/null \
        | grep GXMCP | awk '{print $3}' | tr -d '\r\n')
HOSTIP=$(ip route 2>/dev/null | awk '/^default/{print $3}')

if [ -z "${HOSTIP:-}" ]; then
  say "  ERROR: no pude determinar la IP del host Windows (¿WSL sin red?)"
  exit 1
fi

# =============================================================================
#  ESTADO
# =============================================================================
if [ "$STATUS_ONLY" = 1 ]; then
  say "Host Windows : $HOSTIP"
  printf '  %-14s :%s  ->  ' "comunitario" "$PORT_COMMUNITY"
  up "http://$HOSTIP:$PORT_COMMUNITY/" && say "escuchando" || say "CAÍDO"
  printf '  %-14s :%s  ->  ' "oficial" "$PORT_OFFICIAL"
  up "http://$HOSTIP:$PORT_OFFICIAL/version" && say "escuchando" || say "CAÍDO"
  printf '  %-14s :%s  ->  ' "GX17 windows" "$PORT_GX17"
  up "http://$HOSTIP:$PORT_GX17/" && say "escuchando" || say "CAÍDO"
  printf '  %-14s          ->  ' "bridge HTTP"
  up "http://127.0.0.1:$PORT_COMMUNITY/" && say "activo" || say "caído"
  printf '  %-14s          ->  ' "bridge TCP"
  up "http://127.0.0.1:$PORT_OFFICIAL/version" && say "activo" || say "caído"
  printf '  %-14s :%s  ->  ' "bridge GX17" "$PORT_GX17_BRIDGE"
  up "http://127.0.0.1:$PORT_GX17_BRIDGE/mcp" && say "activo" || say "caído"
  printf '  %-14s :%s  ->  ' "4Agents" "19891"
  up "http://127.0.0.1:19891/" && say "activo" || say "caído"
  exit 0
fi

say "Levantando la cadena MCP de GeneXus (host Windows: $HOSTIP)"

# =============================================================================
#  1. GATEWAY COMUNITARIO  (:5000)
# =============================================================================
if up "http://$HOSTIP:$PORT_COMMUNITY/" ; then
  say "  gateway comunitario :$PORT_COMMUNITY: ya estaba"
else
  if [ -z "${TOKEN:-}" ]; then
    say "  gateway comunitario: ERROR — no pude leer GXMCP_HTTP_TOKEN del registro de Windows"
    say "                       (verificá con: reg query \"HKCU\\Environment\" /v GXMCP_HTTP_TOKEN)"
  elif [ ! -d "$GX_GATEWAY_DIR" ]; then
    say "  gateway comunitario: ERROR — no existe $GX_GATEWAY_DIR"
  else
    say "  gateway comunitario :$PORT_COMMUNITY: arrancando..."
    powershell.exe -NoProfile -Command \
      "\$env:GXMCP_HTTP_TOKEN='$TOKEN'; Start-Process -FilePath '$GX_GATEWAY_DIR_WIN\\GxMcp.Gateway.exe' -WorkingDirectory '$GX_GATEWAY_DIR_WIN' -WindowStyle Minimized" \
      >/dev/null 2>&1
    for _ in $(seq 1 25); do sleep 2; up "http://$HOSTIP:$PORT_COMMUNITY/" && break; done
    up "http://$HOSTIP:$PORT_COMMUNITY/" && say "  gateway comunitario: listo" || say "  gateway comunitario: NO respondió tras 50s"
  fi
fi

# =============================================================================
#  1b. GATEWAY DE GX17  (:5001)
# =============================================================================
if up "http://$HOSTIP:$PORT_GX17/" ; then
  say "  gateway GX17 :$PORT_GX17: ya estaba"
elif [ ! -f "$GX17_LAUNCHER_DIR" ]; then
  say "  gateway GX17: no existe el launcher $GX17_LAUNCHER_DIR — se saltea"
else
  say "  gateway GX17 :$PORT_GX17: arrancando... (requiere el IDE de GX17 o la KB accesible)"
  powershell.exe -NoProfile -Command \
    "Start-Process -FilePath 'powershell.exe' -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','$GX17_LAUNCHER_WIN' -WindowStyle Minimized" \
    >/dev/null 2>&1
  for _ in $(seq 1 25); do sleep 2; up "http://$HOSTIP:$PORT_GX17/" && break; done
  up "http://$HOSTIP:$PORT_GX17/" && say "  gateway GX17: listo" || say "  gateway GX17: NO respondió tras 50s"
fi

# =============================================================================
#  2. SERVIDOR OFICIAL  (:1989)
# =============================================================================
if up "http://$HOSTIP:$PORT_OFFICIAL/version" ; then
  say "  servidor oficial :$PORT_OFFICIAL: ya estaba"
elif [ ! -d "$GX_OFFICIAL_DIR" ]; then
  say "  servidor oficial: no instalado en $GX_OFFICIAL_DIR — se saltea"
else
  say "  servidor oficial :$PORT_OFFICIAL: arrancando... (la BL tarda ~30s)"
  powershell.exe -NoProfile -Command \
    "Start-Process -FilePath '$GX_OFFICIAL_DIR_WIN\\GeneXus.PIA.McpServer.exe' -WorkingDirectory '$GX_OFFICIAL_DIR_WIN' -WindowStyle Minimized" \
    >/dev/null 2>&1
  for _ in $(seq 1 30); do sleep 3; up "http://$HOSTIP:$PORT_OFFICIAL/version" && break; done
  up "http://$HOSTIP:$PORT_OFFICIAL/version" && say "  servidor oficial: listo" || say "  servidor oficial: NO respondió tras 90s"
fi

# =============================================================================
#  3. BRIDGES EN WSL
# =============================================================================
# El bridge HTTP inyecta el token como Bearer, porque Pi no puede mandar headers.
if [ -n "${TOKEN:-}" ]; then
  start_bridge "$TMUX_HTTP" "GX_HOST_IP='$HOSTIP' node '$BRIDGE_HTTP' '$TOKEN' '$PORT_COMMUNITY' 2>&1 | tee /tmp/gx-mcp-gateway-bridge.log" \
               "bridge HTTP  :$PORT_COMMUNITY"
else
  say "  bridge HTTP: se saltea (sin token)"
fi
start_bridge "$TMUX_TCP" "GX_MCP_HOST='$HOSTIP' node '$BRIDGE_TCP' 2>&1 | tee /tmp/gx-mcp-bridge.log" \
             "bridge TCP   :$PORT_OFFICIAL"

# --- GeneXus4Agents (oficial agentic; puerto propio para no chocar con GeneXus Next) ---
PORT_AGENTS=19891
SERVER_AGENTS_DIR="$MOUNT_WIN/Users/$GX_WIN_USER/AppData/Local/Programs/GeneXus/GeneXus4Agents/server/current"
if [ "${SKIP_GX4AGENTS:-0}" = "1" ]; then
  say "  GeneXus4Agents: se saltea (SKIP_GX4AGENTS=1)"
elif up "http://$HOSTIP:$PORT_AGENTS/" ; then
  say "  server GeneXus4Agents :$PORT_AGENTS: ya estaba"
elif [ -f "$SERVER_AGENTS_DIR/GeneXus.PIA.McpServer.exe" ]; then
  say "  server GeneXus4Agents :$PORT_AGENTS: arrancando..."
  powershell.exe -NoProfile -Command \
    "Start-Process -FilePath '$SERVER_AGENTS_DIR\GeneXus.PIA.McpServer.exe' -WorkingDirectory '$SERVER_AGENTS_DIR' -WindowStyle Minimized" \
    >/dev/null 2>&1
  for _ in $(seq 1 25); do sleep 2; up "http://$HOSTIP:$PORT_AGENTS/" && break; done
  up "http://$HOSTIP:$PORT_AGENTS/" && say "  server GeneXus4Agents: listo" || say "  server GeneXus4Agents: NO respondió"
else
  say "  GeneXus4Agents: no está instalado en $SERVER_AGENTS_DIR — se saltea"
fi
start_bridge "$TMUX_AGENTS" "node '$HOME/bin/gx-agents-bridge.js' 2>&1 | tee /tmp/gx-agents-bridge.log" \
             "bridge 4Agents :$PORT_AGENTS"
# El bridge de GX17 apunta al gateway de GX17 (5001), no al comunitario (5000).
if [ -n "${TOKEN:-}" ]; then
  start_bridge "$TMUX_HTTP17" "GX_HOST_PORT='$PORT_GX17' node '$BRIDGE_HTTP' '$TOKEN' '$PORT_GX17_BRIDGE' 2>&1 | tee /tmp/gx-mcp-bridge-17.log" \
               "bridge GX17  :$PORT_GX17_BRIDGE"
else
  say "  bridge GX17 : se saltea (sin token)"
fi

sleep 3

# =============================================================================
#  VERIFICACIÓN
# =============================================================================
say ""
say "Estado final:"
printf '  %-22s ' "gx-oficial  :1989"
curl -s -m 8 -o /dev/null -w 'HTTP %{http_code}\n' "http://localhost:$PORT_OFFICIAL/version" \
  2>/dev/null || say "sin respuesta"
printf '  %-22s ' "gx-mcp      :5000"
curl -s -m 25 -o /dev/null -w 'HTTP %{http_code}\n' \
  -X POST "http://localhost:$PORT_COMMUNITY/mcp" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"gx-mcp-up","version":"1"}}}' \
  2>/dev/null || say "sin respuesta"
printf '  %-22s ' "gx-mcp-17   :5101"
curl -s -m 25 -o /dev/null -w 'HTTP %{http_code}\n' \
  -X POST "http://localhost:$PORT_GX17_BRIDGE/mcp" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"gx-mcp-up","version":"1"}}}' \
  2>/dev/null || say "sin respuesta"
say ""
say "Clientes: ~/bin/gx-cli.sh gx <tool> '<args>'   (GX18)"
say "          ~/bin/gx-cli.sh gx17 <tool> '<args>' (GX17)"
say ""
say "Recordá: el adapter de Pi lee la config al ARRANCAR. Si acabás de levantar"
say "la cadena, reiniciá Pi para que la vea."
