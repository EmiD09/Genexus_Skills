# AGENTS.md — Manual operativo para la IA que tome este repo

> Este archivo es la **primera lectura** de cualquier agente (Pi, Claude, Cursor…) que use este repo.
> El repo es el **kit completo de conocimiento y herramientas GeneXus** acumulado trabajando con
> tickets reales. El flujo correcto es: leer esto → instalar → trabajar con las skills →
> devolver al repo lo aprendido (así el conocimiento crece).

## Qué contiene

| Ruta | Qué es y cuándo usarlo |
|---|---|
| `skills/` | **11 skills listas para instalar** en `~/.pi/agent/skills/` (o el dir de skills de tu agente). La tabla completa está más abajo. Lo más valioso del repo. |
| `bin/` | Herramientas cliente del MCP de GeneXus + migrador/diagnóstico. Ver "Dos formas de conectarse a la KB". |
| `conf/` | `gx-ai.conf.ejemplo` (config de la cadena legacy) y `AGENTS-reglas-globales.md` (reglas de trabajo globales acordadas con el usuario). |
| `docs/` | `02-flujo-migracion.md` (migrar K2B→WWP paso a paso) y `03-errores.md` (catálogo errores con causa/solución). |
| `odd/tasks/` | Especificaciones y bitácora de cómo se construyó este kit (lifecycle del repo mismo). |

## Instalación

```bash
./install.sh                       # skills → ~/.pi/agent/skills/, bin → ~/bin/
```

Verificador de variables: `PI_SKILLS_DIR` y `BIN_DIR` para instalar en otra ubicación.
Requisitos: **Windows con GeneXus 18** instalado + **WSL2/WSL con Node.js** en la misma máquina
(las 2 herramientas MCP se lanzan via `cmd.exe`). El resto (`npx genexus-mcp`) se descarga solo.

## Dos formas de conectarse a las KBs GeneXus

### A (recomendada, la que usamos hoy): cliente MCP stdio persistente

1. Levantar el cliente en background (queda escuchando):
   ```bash
   node ~/bin/gx-mcp-server-client.js &        # log: /tmp/gx-mcp-pc.log
   ```
   Abre el server oficial (npm `genexus-mcp`, manejado por el SDK de GeneXus 18) vía `cmd.exe`.

2. Llamar tools escribiendo archivos:
   ```bash
   gx-call.sh genexus_kb '{"action":"open","path":"C:\\KBs\\TuKB"}'   # abrir KB (win path)
   gx-call.sh genexus_kb '{"action":"set_default","alias":"<TuKB>"}'  # coherentemente con alias 'npx'
   gx-call.sh genexus_read '{"name":"MiWebPanel","part":"Source","limit":50000,"refresh":true}'
   ```

   Protocolo real, para cualquier lenguaje:
   - Se pide con `/tmp/gx-mcp-cmds/<ID>.json` → `{"id":"<ID unicos>","tool":"<tool>","timeout":600,"args":{...}}`
   - Se responde `.../<ID>.res.json` (metadata + `text` con el estado JSON).
   - **IDs únicos absolutos por llamada** (el cliente rastrea los ficheros que ya vio).

3. Cambiar de KB:
   ```bash
   gx-call.sh genexus_kb '{"action":"open","path":"C:\\KBs\\OtraKB"}'
   gx-call.sh genexus_kb '{"action":"set_default","alias":"otrakb"}'
   ```

### B (legacy): cadena completa GeneXus + gateway (bin/gx-mcp-up.sh + gx-cli.sh)

Útil cuando se necesitan las dos KBs con núcleos GeneXus corriendo (canales oficiales de
IDE, migración 17↔18 con GeneXus abierto). Documento completo: `docs/02-flujo-migracion.md`.
La config está en `~/.config/gx-ai.conf` (template `conf/gx-ai.conf.ejemplo`).

## Reglas duras de trabajo (resumen — la fuente completa la mantengo también en conf/AGENTS-reglas-globales.md)

1. **Tocar SOLO lo requerido por el ticket.** Si hay que tocar más, avisar ANTES. En los
   builds finales el usuario decide ("hago el build yo"); deploy solo con permiso explícito.
2. **Nunca inventar valores de negocio** (parámetros, llamadas, configs): copiar la convención
   del código existente o preguntar.
3. **Verificar cada write por re-read / XPZ**: nunca confiar en el `success` de la tool.
   `genexus_read` trunca: leer la KB entera.
4. **Freno 2-3 fallas**: al 2º fallo del MISMO error, no reintentar variantes cosméticas,
   investigar la causa raíz; al 3º, consultar al usuario con opciones y costos.
5. **Con PatternInstance WWP activa: el layout se edita vía PatternInstance XML** (patrón gana
   y re-proyecta). Detalle: `skills/genexus-migracion-k2b-a-wwp/references/wwp-instancias.md`.

## Regla de separación genérico ↔ organización

- Este repo es **100% genérico GeneXus**: aplica a cualquier organización. Los datos por
  máquina/u organización quedan como `<placeholders>`; este repo NUNCA lleva datos reales
  de una org (paths de prod, IPs, KBs concretas).
- Lo específico de cada organización vive en **un repo aparte y privado** (convención:
  `genexus-<org>`): un README con cuándo cargarlo, un `entorno.md` con los valores reales
  que resuelven los placeholders de las skills, y las reglas de cada KB (`kbs/<KB>-AGENTS.md`,
  copia de las reglas vivas de cada KB). Al trabajar sobre esa org se cargan ambos repos;
  para todos los demás, este básico alcanza. El kit genérico se puede distribuir sin tocar.

## Skills instaladas incluidas (routing rápido)

| Skill | Cuándo se usa |
|---|---|
| `gam` | Autenticación/autorización GAM, backoffice, seguridad de las apps, modelo FÍSICO de la DB GAM (queries listas: `references/data-model/domain-gam-db-schema.md`).|
| `gx-authoring` | Crear/editar objetos GeneXus (*.gx): sintaxis, modelado, eventos. |
| `gx-kb` | Operar KBs vía `gxnext` CLI o MCP: abrir/configurar/build/reorg. |
| `genexus-migracion-k2b-a-wwp` | Migrar de GeneXus 17 (K2B) a 18 (WWP), edición de PatternInstance via MCP. |
| `genexus-entorno-local` | PLANTILLA por máquina: activar servidores MCP, control del build Gradle, fixes conocidos. Completá tus paths; los valores reales de cada org viven en el repo privado de esa org (`entorno.md`). |
| `k2btools-ui` | Web UI GeneXus cuando la KB tiene K2BTools (PRIORIDAD sobre `nexa` en web UI). |
| `nexa` | Experto GeneXus genérico: modelado de objetos y administración de KBs. |
| `ui-creator` | UI desde imagen / OpenAPI a Angular (requisitos de migrar a este framework). |
| `chameleon-controls-library` | UI con componentes `ch-*` (Chameleon). |
| `design-system-builder` / `mercury-design-system` | Design systems CSS sobre Chameleon. |

## Cómo devolver al repo lo aprendido

- Reglas/acuerdos de trabajo → `conf/AGENTS-reglas-globales.md`.
- Errores nuevos con causa y solución → `docs/03-errores.md`.
- Convenciones de migración → `skills/genexus-migracion-k2b-a-wwp/references/`.
- Data/modelo físico de la DB GAM → `skills/gam/references/data-model/`.
- **Nunca commitear** datos de especie de la organización (paths de prod, IPs, usuarios,
  nombres de bases de datos ajenas): dejarlos en las skills privadas por máquina (ver
  `genexus-entorno-local` como plantilla, para copiar).
- Lifecycle del repo: `odd/tasks/`.
