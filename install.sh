#!/usr/bin/env bash
# Instalador del kit Genexus_Skills para agentes IA (Pi, Claude, Cursor, ...)
#   skills/ → $PI_SKILLS_DIR (default ~/.pi/agent/skills)
#   bin/*   → $BIN_DIR       (default ~/bin)
#   conf/gx-ai.conf.ejemplo → ~/.config/gx-ai.conf (solo si no existe)
# Idempotente: puede correrse varias veces (resincroniza skills y bins).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PI_SKILLS_DIR="${PI_SKILLS_DIR:-$HOME/.pi/agent/skills}"
BIN_DIR="${BIN_DIR:-$HOME/bin}"
HAS_RSYNC=$(command -v rsync || true)

echo "==> Instalando skills en $PI_SKILLS_DIR"
mkdir -p "$PI_SKILLS_DIR"
for src in "$ROOT"/skills/*/; do
  name="$(basename "$src")"
  dst="$PI_SKILLS_DIR/$name"
  if [ -n "$HAS_RSYNC" ]; then
    rsync -a --delete "$src" "$dst/"
  else
    rm -rf "$dst"; cp -r "${src%/}" "$dst"
  fi
  echo "    skill  $name"
done

echo "==> Instalando herramientas en $BIN_DIR"
mkdir -p "$BIN_DIR"
for f in "$ROOT"/bin/*; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  if [ -e "$BIN_DIR/$base" ] && ! cmp -s "$f" "$BIN_DIR/$base"; then
    cp "$BIN_DIR/$base" "$BIN_DIR/$base.bak-$(date +%s)"
    echo "    backup  $base.bak"
  fi
  install -m 0755 "$f" "$BIN_DIR/$base"
  echo "    bin     $base"
done

if [ ! -f "$HOME/.config/gx-ai.conf" ] && [ -f "$ROOT/conf/gx-ai.conf.ejemplo" ]; then
  mkdir -p "$HOME/.config"
  cp "$ROOT/conf/gx-ai.conf.ejemplo" "$HOME/.config/gx-ai.conf"
  echo "==> Config copiada a ~/.config/gx-ai.conf (COMPLETALA antes de usar la cadena legacy)"
else
  echo "==> ~/.config/gx-ai.conf ya existía: sin cambios"
fi

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;  # ya está en PATH
  *) echo ""
     echo "NOTA: agregá $BIN_DIR a tu PATH si aún no lo tenés:"
     echo "       echo 'export PATH=\"$BIN_DIR:\$PATH\"' >> ~/.bashrc"
  ;;
esac

cat <<'MSG'

==> Listo. Próximos pasos:
  1. Leer AGENTS.md (la primera lectura del repo).
  2. Ajustar ajustes BASE de tu máquina en skills/genexus-entorno-local/
     (es una PLANTILLA: completá tus paths reales y evitá commitearlos).
  3. Probar el cliente MCP persistente:
       node ~/bin/gx-mcp-server-client.js &
       gx-call.sh genexus_kb '{"action":"open","path":"C:\\KBs\\TuKB"}'
     Debe responder `{ ... "opened": ... }`.
  Cadena legacy completa (GeneXus abierto + gateway): README.md + docs/02-flujo-migracion.md.
MSG