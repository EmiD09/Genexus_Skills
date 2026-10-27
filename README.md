# Kit IA para GeneXus + WorkWithPlus

Herramientas y conocimiento para que una IA (Pi, Claude, Cursor…) trabaje sobre GeneXus 17/18
y WorkWithPlus **sin tropezar con las mismas piedras** que tropezamos nosotros.

> **Separación genérico ↔ proyecto:** el kit es genérico; los datos reales de cada
> organización van en `proyectos/<org>/` (ver `AGENTS.md`, sección "Regla de separación").
> Si tu caso es la Municipalidad de Río Cuarto: `proyectos/riocuarto/README.md`.

Nació de migrar pantallas de **K2B (GeneXus 17) a WWP (GeneXus 18)**. Todo lo que está acá
salió de errores reales, no de documentación.

---

## Qué trae

| Carpeta | Qué es |
|---|---|
| `skills/` | **El conocimiento: 11 skills completas** (GAM, modelado GeneXus, KBs, migración K2B→WWP, K2BTools UI, entorno por-máquina, Chameleon/Mercury/ui-creator). Es lo más valioso del kit. Routing completo en `AGENTS.md`. |
| `bin/` | Herramientas: **cliente MCP persistente** (`gx-mcp-server-client.js` + `gx-call.sh`), la cadena legacy (bridge/gateway), migrador de objetos y diagnóstico de builds. |
| `conf/` | Config de la cadena legacy (`gx-ai.conf.ejemplo`) y las **reglas globales de trabajo** (`AGENTS-reglas-globales.md`). El único archivo **por editar** es tu `~/.config/gx-ai.conf`. |
| `docs/` | Guías paso a paso: flujo de migración y catálogo de errores. |
| `proyectos/` | **Por organización.** Cada carpeta trae el entorno real y las reglas de las KBs de esa org (ej: `proyectos/riocuarto/`). Si no trabajás con esa org, ignorala — lo tuyo es todo lo demás. |

> **AGI ARRANQUES: si sos una IA, lo primero que tenés que leer es `AGENTS.md`** — ahí está el manual operativo
> (cómo llamar a las KBs, reglas duras de trabajo y el routing de las skills). Este README es la vista humana.

---

## Requisitos

- **WSL2** (o Linux) en la misma máquina que GeneXus. Todas las herramientas asumen WSL.
- **GeneXus** instalado en Windows, con la KB accesible.
- **`genexus-mcp`** (el gateway). Viene con el ecosistema de herramientas MCP de GeneXus;
  si no lo tenés, buscá `GxMcp.Gateway.exe` en tu máquina o instalalo aparte.
- **Node.js** en WSL (para los bridges).
- **`curl`**, **`python3`**, **`tmux`**.

> El kit **no** incluye GeneXus ni el gateway. Los orquesta.

---

## Instalación rápida (una línea)

```bash
./install.sh                # skills → ~/.pi/agent/skills/, bin → ~/bin/, config template
```
Idempotente. Después: **leer `AGENTS.md`**, completar tu entorno en `skills/genexus-entorno-local/`
(plantilla), y probar el cliente:

```bash
node ~/bin/gx-mcp-server-client.js &                # en background (log: /tmp/gx-mcp-pc.log)
gx-call.sh genexus_kb '{"action":"open","path":"C:\\KBs\\TuKB"}'
gx-call.sh genexus_kb '{"action":"set_default","alias":"tukb"}'
gx-call.sh genexus_read '{"name":"AlgunWebPanel","part":"Source","limit":20000,"refresh":true}'
```

Esa es la cadena **MCP stdio persistente** (la que usamos a diario): se abre el server oficial
`genexus-mcp` (npm) vía `cmd.exe`, y cada tool se pide con un `<ID>.json` y respondida con
`<ID>.res.json`. Grabado igual en `AGENTS.md`.

## Instalación detallada de la cadena legacy (5 pasos)

### 1. Copiar el kit (o correr ./install.sh y saltar al paso 4)

```bash
cp -r kit-genexus-ai ~/kit-genexus-ai
mkdir -p ~/bin ~/.config
cp ~/kit-genexus-ai/bin/* ~/bin/
chmod +x ~/bin/gx-cli.sh ~/bin/gx-mcp-up.sh ~/bin/gx-migrate-object.py
```

### 2. Completar la configuración

```bash
cp ~/kit-genexus-ai/conf/gx-ai.conf.ejemplo ~/.config/gx-ai.conf
nano ~/.config/gx-ai.conf
```

Los valores que hay que averiguar están explicados dentro del archivo. Los dos más
importantes:

```bash
# La IP de tu Windows, vista desde WSL:
ip route | awk '/^default/{print $3}'          # -> GX_HOST_IP

# Dónde quedó el gateway:
find /mnt/c -name "GxMcp.Gateway.exe" 2>/dev/null | head -1
```

### 3. Instalar la skill

```bash
mkdir -p ~/.pi/agent/skills
cp -r <ubi>~/kit-genexus-ai/skills/* ~/.pi/agent/skills/
```

Pi escanea `~/.pi/agent/skills/` **al arrancar** (y los proyectos también pueden traer sus
propias skills en `.agents/skills/`). Después de copiarlas, reiniciá Pi.
Si no aparece sola, forzala con `/skill:<nombre-de-la-skill>`.

### 4. Levantar la cadena

```bash
~/bin/gx-mcp-up.sh              # levanta GeneXus + los bridges
~/bin/gx-mcp-up.sh --status     # verifica
```

### 5. Probar

```bash
gx-cli.sh gx genexus_whoami '{}'
```

Si devuelve `"connected": true` con el nombre de tu KB, está andando.

---

## Uso diario

```bash
gx-cli.sh --status                          # ¿está arriba la cadena?
gx-cli.sh gx  <herramienta> '<args json>'   # KB principal (GX18)
gx-cli.sh gx17 <herramienta> '<args json>'  # segunda KB (GX17), si la configuraste
gx-cli.sh gx --schema genexus_edit          # ver los parámetros de una herramienta
```

Migrar un objeto completo (exporta de GX17, extrae, crea en GX18, escribe la fuente y verifica):

```bash
~/bin/gx-migrate-object.py NombreDelObjeto --dry-run   # primero en seco
~/bin/gx-migrate-object.py NombreDelObjeto             # en serio
```

---

## Las 5 reglas que te van a ahorrar días

Están desarrolladas en `skills/genexus-migracion-k2b-a-wwp/SKILL.md`, pero en resumen:

1. **Verificá siempre por `.xpz`**, nunca por el `success` de la herramienta.
   `genexus_read` **trunca a ~5 KB** y puede hacerte creer que una escritura falló.
2. **Nunca infieras el tipo de una variable por su nombre.** El único tipo confiable es el
   que declara la KB de origen. Un tipo mal puesto rompe al compilar con un `spc0023` que
   aparece recién al final.
3. **Al escribir el `Source`, el SDK auto-crea toda variable no declarada con `VarChar(100)`**,
   sin avisar. Después el build falla con errores que parecen de otra cosa.
4. **Antes de decir "falta X", buscá con dos criterios distintos.** En WWP los campos se
   llaman `attribute="&Var"`, no `controlName`.
5. **Usá las herramientas de WWP primero**: `genexus_apply_pattern mode=diagnose` te dice
   exactamente qué le falta al patrón.

---

## Para trabajar con WWP

```bash
# Ver qué opina el patrón de un objeto (SIEMPRE empezar por acá)
gx-cli.sh gx genexus_apply_pattern '{"name":"MiPantalla","pattern":"WorkWithPlus","mode":"diagnose"}'

# Crear una pantalla nueva con WWP aplicado
gx-cli.sh gx genexus_create '{"action":"object","type":"WebPanel","name":"MiPantalla"}'
gx-cli.sh gx genexus_apply_pattern '{"name":"MiPantalla","pattern":"WorkWithPlus"}'
gx-cli.sh gx genexus_apply_pattern '{"name":"MiPantalla","pattern":"WorkWithPlus","reapply":true}'
```

> El nombre del **host** del patrón es `WorkWithPlus<Objeto>`. Las herramientas de
> `genexus_wwp` se llaman con ese nombre, no con el del WebPanel.

---

## Si algo no anda

1. `~/bin/gx-mcp-up.sh --status`
2. `docs/03-errores.md` — catálogo de los errores que ya vimos, con su causa y su solución.
3. Si el error es nuevo, **verificá por `.xpz` antes de reintentar**. Reintentar a ciegas
   duplica contenido y lo pierde.

---

## Créditos

Generado trabajando codo a codo con un humano que corrigió a la IA varias veces — y esas
correcciones son justamente las que están escritas acá.
