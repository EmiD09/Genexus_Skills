# Kit IA para GeneXus + WorkWithPlus

Herramientas y conocimiento para que una IA (Pi, Claude, Cursor…) trabaje sobre GeneXus 17/18
y WorkWithPlus **sin tropezar con las mismas piedras** que tropezamos nosotros.
> **Genérico ⇄ organización:** este kit no lleva datos de ninguna organización — los
> valores reales por org/repositorio van en un repo privado aparte (convención en
> `AGENTS.md`, sección "Regla de separación genérico ↔ organización").

Nació de migrar pantallas de **K2B (GeneXus 17) a WWP (GeneXus 18)**. Todo lo que está acá
salió de errores reales, no de documentación.

---

## Qué trae

| Carpeta | Qué es |
|---|---|
| `skills/` | **El conocimiento: 10 skills completas** (GAM, modelado GeneXus, KBs, migración K2B→WWP, K2BTools UI, entorno por-máquina, Chameleon/Mercury/ui-creator). Es lo más valioso del kit. Routing completo en `AGENTS.md`. |
| `bin/` | Herramientas: **cliente MCP persistente** (`gx-mcp-server-client.js` + `gx-call.sh`), migrador de objetos y diagnóstico de builds. |
| `conf/` | Config de la cadena legacy (`gx-ai.conf.ejemplo`) y las **reglas globales de trabajo** (`AGENTS-reglas-globales.md`). El único archivo **por editar** es tu `~/.config/gx-ai.conf`. |
| `docs/` | Guías paso a paso: flujo de migración y catálogo de errores. |

> **AGI ARRANQUES: si sos una IA, lo primero que tenés que leer es `AGENTS.md`** — ahí está el manual operativo
> (cómo llamar a las KBs, reglas duras de trabajo y el routing de las skills). Este README es la vista humana.

---

## Requisitos

- **GeneXus 18** instalado en Windows, con la KB accesible.
- **Node.js** en Windows: el único MCP que se usa es el **comunitario** (`genexus-mcp`,
  github.com/lennix1337/Genexus18MCP), que corre con `npx genexus-mcp` en modo stdio.
  No se necesita IDE abierto, ni bridges, ni tmux, ni ningún server oficial.
- **`python3`** solo para `gx-diag-build.py` / `gx-migrate-object.py`.

> El kit **no** incluye GeneXus. Con el MCP comunitario alcanza para todo:
> leer, escribir, validar y hasta compilar (`genexus_lifecycle action=build`).

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

Esa es la cadena **MCP stdio persistente** (la que usamos a diario): se abre el MCP comunitario
`genexus-mcp` (npm) vía `npx`, y cada tool se pide con un `<ID>.json` y respondida con
`<ID>.res.json`. Grabado igual en `AGENTS.md`.

## Instalación detallada

### 1. Copiar el kit (o correr ./install.sh)

```bash
cp -r kit-genexus-ai ~/kit-genexus-ai
mkdir -p ~/bin
cp ~/kit-genexus-ai/bin/* ~/bin/
chmod +x ~/bin/gx-call.sh ~/bin/gx-migrate-object.py
```

### 2. Instalar la skill

```bash
mkdir -p ~/.pi/agent/skills
cp -r <ubi>~/kit-genexus-ai/skills/* ~/.pi/agent/skills/
```

Pi escanea `~/.pi/agent/skills/` **al arrancar** (y los proyectos también pueden traer sus
propias skills en `.agents/skills/`). Después de copiarlas, reiniciá Pi.
Si no aparece sola, forzala con `/skill:<nombre-de-la-skill>`.

### 3. Probar

Con el MCP configurado en tu cliente (Pi/VS Code: `npx genexus-mcp` en modo stdio), pedile
al agente un `genexus_whoami`. Si devuelve `"connected": true` con el nombre de tu KB, está andando.
Sin cliente MCP, la cadena de scripts (`gx-mcp-server-client.js` + `gx-call.sh`) sigue disponible.

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
3. **Las variables no declaradas**: desde v4.4.x el MCP ya no las declara en silencio
   (y con `autoDeclareVariables:true` las lista en el receipt con su tipo). Declará las
   que falten con su tipo real igual: un `VarChar(100)` mal tipado rompe el build con
   errores que parecen de otra cosa.
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

1. `genexus_doctor` / `genexus_whoami` vía MCP (¿está viva la KB y el worker?)
2. `docs/03-errores.md` — catálogo de los errores que ya vimos, con su causa y su solución.
3. Si el error es nuevo, **verificá por `.xpz` antes de reintentar**. Reintentar a ciegas
   duplica contenido y lo pierde.

---

## Créditos

Generado trabajando codo a codo con un humano que corrigió a la IA varias veces — y esas
correcciones son justamente las que están escritas acá.
