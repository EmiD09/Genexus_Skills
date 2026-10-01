# Kit IA para GeneXus + WorkWithPlus

Herramientas y conocimiento para que una IA (Pi, Claude, Cursor…) trabaje sobre GeneXus 17/18
y WorkWithPlus **sin tropezar con las mismas piedras** que tropezamos nosotros.

Nació de migrar pantallas de **K2B (GeneXus 17) a WWP (GeneXus 18)**. Todo lo que está acá
salió de errores reales, no de documentación.

---

## Qué trae

| Carpeta | Qué es |
|---|---|
| `skills/` | **El conocimiento.** Una skill de Pi con las convenciones y las trampas. Es lo más valioso del kit. |
| `bin/` | Las herramientas: cliente MCP, arranque de la cadena, y un migrador de objetos. |
| `conf/` | **El único archivo que hay que editar.** Rutas, puertos y nombres de KB. |
| `docs/` | Guías paso a paso: instalar la cadena, migrar un objeto, y el catálogo de errores. |

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

## Instalación (5 pasos)

### 1. Copiar el kit

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
mkdir -p <TU_PROYECTO>/.agents/skills
cp -r ~/kit-genexus-ai/skills/* <TU_PROYECTO>/.agents/skills/
```

Pi escanea `.agents/skills/` **al arrancar**. Después de copiarla, reiniciá Pi.
Si no aparece sola, forzala con `/skill:genexus-migracion-k2b-a-wwp`.

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
