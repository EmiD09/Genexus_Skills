---
name: genexus-migracion-k2b-a-wwp
description: "Trigger: cualquier trabajo sobre una KB GeneXus con WorkWithPlus (WWP): crear/editar paneles WWP, aplicar patrón, errores spc0023, builds sin .java, usar las herramiantras WWP del MCP de GeneXus; y migrar objetos de GeneXus 17 (K2B) a GeneXus 18 (WWP). Todo por el SDK del MCP con verificación por .xpz."
---

# WWP en cualquier KB + Migrar objetos de GeneXus 17 (K2B) a GeneXus 18 (WWP)

**Regla general (cualquier KB con WWP):** antes de tocares un objeto WWP por edición directa de parts (Source/WebForm), leer esta skill y usar las herramientas específicas (`genexus_apply_pattern`, `genexus_wwp`, `genexus_layout`, `genexus_refactor`, `genexus_properties`). Editar el WebForm a mano bajo un PatternInstance hace que el patrón re-proyecte y restaure controles: el patrón tiene prioridad sobre la edición manual.

# Migrar objetos de GeneXus 17 (K2B) a GeneXus 18 (WWP)

Migracion funcional exacta: se traslada **solo lo que existe en GX17**. Nada agregado, nada
inventado. Del andamiaje K2B no se porta nada. No modificar la KB de origen: solo se lee.

## Reglas que no se negocian

1. **Verificar SIEMPRE por `.xpz`**, nunca por el `success` ni por `genexus_read`.
   `genexus_read` **trunca a ~5 KB** y agrega `// ... [CONTENT TRUNCATED...] ... //`.
   Ese paginado no funciona. Un truncamiento puede hacerte creer que una escritura fallo.
2. **Nunca inferir el tipo de una variable por su nombre.** El unico tipo confiable es el que
   declara GX17 (`genexus_inspect projection=verbose`). Omitir el tipo para "heredar el
   atributo homonimo" **solo** vale si ese atributo existe de verdad; si no (p. ej. `BDeAnio_p`),
   el SDK pone un default y despues rompe al llamador con `spc0023`.
3. **Despues de migrar, comparar TODAS las variables y el Source contra GX17.** El error
   recien aparece al compilar; el barrido lo detecta al instante.
4. `WriteNotPersisted`, `VariableRenamed` y `WriteNoChange` son **codigos enganosos**
   (y `genexus_properties` puede devolver un tipo obsoleto). **Re-verificar por `.xpz` antes de
   reintentar.** Reintentar a ciegas duplica y pierde contenido.
5. **Al escribir el `Source`, el SDK auto-crea toda `&Variable` no declarada con el tipo por
   defecto `VarChar(100)`** — sin avisar. Despues el build falla con errores que parecen de
   otra cosa (`spc0010: &Hoy = serverdate() (Varchar=Date)`). Pasa con variables que GX17
   tampoco declara y resuelve al especificar. **Despues de escribir el fuente, comparar las
   variables usadas contra el XPZ de GX17 y declarar las que falten, con su tipo real.**
5. **Los tipos basados en objeto (BC/SDT/ext) no los acepta `object_atomic`**: van aparte con
   `genexus_variable action=add`. El prefijo de `idBasedOn`/`ATTCUSTOMTYPE` no se debe cortar.
6. **Sub antes que `Do`**: `Do 'X'` con `X` inexistente da sub-rotina indefinida.
7. **Para retipar una variable que es matriz**: el fuente la bloquea. Guardarlo, poner un fuente
   minimo temporal, bajar `AttRows` y `AttNumDim`, cambiar el tipo, re-armar la matriz y
   restaurar. Ver `references/trampas-mcp.md`.

## Convencion de eventos (K2B -> WWP)

K2B usa **dos niveles** por boton: `E_<Boton>` -> `Do 'U_<Boton>'` -> `Sub 'U_<Boton>'`.
**En GX18/WWP eso no hace falta**: el patron ya genera el evento del boton, asi que **el
codigo va directo en ese primer evento**, sin crear el segundo `Sub`.

Mapeo de nombres ya visto: `Event Start`<-`U_OpenPage`, `Event Refresh`<-`U_RefreshPage`,
`Event 'DoCargar'`<-`U_Cargar`, `Event 'DoEnvioP360'`<-`U_EnvioP360`.
El `&<Grid>_SDT` de K2B **se conserva** (el patron lo mantiene), con su variable declarada.

Controles del layout: el patron los renombra (`ActVto`->`BtnActVto`, `ChkTrjCrd`->`BtnChkTrjCrd`,
`Cargar`->`BtnCargar`). Adaptar la referencia al nombre nuevo.

## Flujo

1. Confirmar que el MCP esta arriba: `~/bin/gx-mcp-up.sh` y `~/bin/gx-cli.sh --status`.
   - **La parte GX17 (gateway :5001 / bridge :5101) SOLO se levanta si se pide explícitamente.**
     Para trabajo normal no es necesaria; si el script la arranca porque hay launcher,
     se puede ignorar sin problema.
2. Leer el objeto completo de GX17 por `.xpz` (`genexus_transfer action=export` + el XML).
3. Migrar con `~/bin/gx-migrate-object.py <Nombre>` (hace export, extrae, crea, aplica el fix
   de matrices y escribe el Source, y verifica). Tiene `--dry-run`.
4. Para la pantalla: migrar primero los procedimientos que faltan, despues las variables
   (solo las que usa el codigo a portar) y por ultimo los eventos.
5. Verificar **cada** objeto comparando Source, Rules y variables contra GX17.

Leer `references/trampas-mcp.md` antes de la primera escritura: ahi estan los codigos de error
del MCP y como reaccionar a cada uno.

## Referencias de esta skill (leer según el caso)

- `references/trampas-mcp.md` — códigos de error del MCP y cómo reaccionar.
- `references/wwp-instancias.md` — **regla central**: el layout se edita en la PatternInstance
  del host (`WorkWithPlus<X>`), nunca en el WebForm; estructura del XML de instancia, receta
  completa de pantalla nueva, y trampas de proyección (empírico KBs GX18).
- `references/wwp-oficial-for-agents.md` — estado de "WorkWithPlus for Agents" y cómo instalar
  la skill oficial de WWP cuando haya GeneXus for Agents.

## Herramientas de WWP — usar ESTAS primero

Antes de inspeccionar el WebForm a mano, usar las herramientas especificas. Existen y funcionan;
el error tipico es razonar sobre WWP por analogia con K2B e ignorarlas.

| Herramienta | Para que | Uso |
|---|---|---|
| `genexus_apply_pattern` | Diagnosticar / reaplicar el patron | `{name, pattern:"WorkWithPlus", mode:"diagnose"}` devuelve `findings` con `reason`/`severity`/`detail`/`remediation` (p. ej. `overrideConflict` → usar `reapply=true`). Sin `settings.template`, WWP auto-descubre uno (AddGridItems, CardImageMain, ...). |
| `genexus_wwp` | Ediciones tipadas de WWP (actions, tabs, grids, `set_table_type`) | Opera sobre la **PatternInstance** por el SDK nativo. |
| `genexus_layout` | `get_tree`, `find_controls`, `inspect_surface`, `scan_mutators` | `find_controls` devuelve `nodes:[{p:ruta, t:tipo}]` y un **`stats` con el conteo por tipo**. |
| `genexus_refactor` | Incluye "WWP condition set" | |
| `genexus_properties` | Propiedades de objeto, control o **variable** (`control:"&Var"`) | |

### Leer `genexus_layout` correctamente

`find_controls` devuelve **rutas**, no nombres: `{"p": "/GxMultiForm/Form[1]/...", "t": "table"}`.
**El dato util esta en `stats`**:

```json
{"GxMultiForm":1, "table":23, "textblock":5, "data":19, "action":5,
 "simplegrid":1, "item":12, "ucw":1, "gxWWP.GridEmpowerer":1}
```

`"data": 19` = los 19 campos de entrada. `"action": 5` = los 5 botones. Si se busca un
nombre concreto dentro de `nodes` **no aparece** (son rutas) — **leer `stats` primero**.

## Antes de afirmar que algo FALTA

**Regla dura**: nunca reportar "falta X" habiendo buscado con un solo criterio.

- En el WebForm, los campos de entrada de WWP usan **`attribute="&Var"`**, no `controlName`.
- Los botones usan `action` / `Btn*`; el grid usa `simplegrid`/`item` y `_Empowerer`.
- Verificar con al menos **dos criterios** y **decir cuales** se usaron.
- Preferir el `stats` de `genexus_layout` o el `findings` de `genexus_apply_pattern` antes que
  conclusiones por ausencia.

**Caso real que motivo esta regla**: se reporto que faltaban los 19 controles de entrada de
`MPGBieCompP360`. La herramienta ya habia dicho `"data": 19`. Estaban todos. El usuario tuvo
que corregirlo dos veces ("yo los veo a los controles").

## Crear una pantalla nueva con WWP (receta probada)

```
1) genexus_create action=object type=WebPanel name=<X>
2) genexus_apply_pattern name=<X> pattern=WorkWithPlus                    ← SIN settings
3) genexus_apply_pattern name=<X> pattern=WorkWithPlus reapply=true       ← genera el layout
```

- **El paso 2 va SIN `settings`.** Pasar `settings:{template:"..."}` explicito da `PatternNoOp`
  (*"PatternInstancePackageInterface overload resolution failed... does not expose one
  unambiguous five-parameter SettingsView.Web overload"* — incompatibilidad de reflexion del SDK
  con esta version de WWP). **Omitiendo `settings`, WWP auto-descubre el template y aplica limpio.**
- **El paso 2 solo crea la PatternInstance**; no genera layout. El paso 3 (`reapply=true`) es el
  que genera. Señal de que falta el paso 3: `mode=diagnose` devuelve `overrideConflict`
  (*"An existing PatternInstance was found... use reapply=true"*).
- Verificar con `genexus_layout action=find_controls` leyendo **`stats`** (paso de 5 a 27 nodos
  con `table`, `grid`, `textblock`, `data`).

### El nombre del host

Las herramientas de `genexus_wwp` **no** se llaman con el nombre del WebPanel sino con el del
**pattern host**: `name=WorkWithPlus<X>`. Con el nombre pelado devuelve `ObjectNotFound`.
El host lo devuelve `apply_pattern` en `patternHost`.

```bash
gx-cli.sh gx genexus_wwp '{"action":"list","name":"WorkWithPlusPruebasWWP"}'   # WwpActionsRead
```

### Invocar un WebPanel desde WWP

En WWP un WebPanel **no se embebe como UCW**: se invoca como **User Action** (un evento que
llama al objeto con sus parametros). Ejemplo real de la KB:

```genexus
Event 'DoMasFotos'
    VerFotosWP(0,01,01,001,001,000)
EndEvent
```

`genexus_wwp action=add_action` lo modela (`group`, `actionName`, `caption`, `procedure`), pero
**`procedure` exige un Procedure** — un WebPanel da `WwpActionFailed: Procedure 'X' was not found`.
Y con el template `AddGridItems` el apply da `PatternStructureChangeUnsupported` (*"Child
structure changed at .../freeStyleGrid/"*): el `freeStyleGrid` no acepta acciones agregadas.
→ Probar otro template, `settings_edit`, o hacerlo desde el IDE.

### Tipos de control utiles

| gxControlType | Que es |
|---|---|
| `-104584741` | panel de WWP (DVPanel) |
| `-822546690` | PaginationBar de WWP |
| `-667710712` | **WebComponent** (`ControlName="UserControl1"`) |

Referencia: la KB tiene ~2000 archivos `src/**/*.web.xml` con los layouts en XML.

## Fuera de alcance

No tocar el Design System. No portar andamiaje K2B (`GridState`, `IsVisibleSDTVar_*`,
`ActivityList`, paginado K2B, configuracion de grilla). No agregar funcionalidad.
