# Errores que ya vimos, con su causa y su solución

> El catálogo completo y detallado está en
> `skills/genexus-migracion-k2b-a-wwp/references/trampas-mcp.md`.
> Acá van los que más van a aparecer.

---

## Errores de compilación de GeneXus

### `spc0023: Parameter &X ... has wrong type (expecting ...)`

**Causa**: una variable quedó con el tipo equivocado. Casi siempre porque **el nombre no coincide
con un atributo** (típico en los parámetros con sufijo `_p`: `BDeAnio_p`) y se le puso un tipo
por defecto.

**Solución**: comparar **todas** las variables contra la KB de origen y corregir el tipo real.

```bash
gx-cli.sh gx genexus_variable '{"action":"modify","name":"MiProc","varName":"BDeAnio_p",
   "typeName":"Numeric","length":4,"decimals":0}'
```

⚠️ `genexus_properties action=get` **puede devolver un tipo obsoleto**. La respuesta del
`modify` trae el dato bueno (`persistedType`), y el `.xpz` es la verdad.

---

### `spc0010: Type mismatch in assignment: &Hoy = serverdate() (Varchar=Date)`

**Causa**: la variable **no estaba declarada** en el origen (GeneXus la resolvía al especificar).
Al escribir el `Source` por SDK, **el SDK la creó con el tipo por defecto `VarChar(100)`**.

**Solución**: declararla explícitamente con el tipo correcto. Y después del próximo `Source`,
comparar las variables usadas contra el origen — van a aparecer otras.

---

### `spc0234: '&X' não é uma matriz`

**Causa**: la variable se usa como `&X()` y no es matriz.

**Solución** (son 3 propiedades, **en este orden**):

```bash
gx-cli.sh gx genexus_properties '{"action":"set","name":"MiProc","control":"&PagEsta",
   "propertyName":"AttCollection","value":"False"}'
gx-cli.sh gx genexus_properties '{"action":"set","name":"MiProc","control":"&PagEsta",
   "propertyName":"AttNumDim","value":"1"}'
gx-cli.sh gx genexus_properties '{"action":"set","name":"MiProc","control":"&PagEsta",
   "propertyName":"AttRows","value":"1000"}'
```

⚠️ Poner `collection:true` en `genexus_variable` hace **lo contrario** de lo que se necesita.

**Cómo descubrir los valores correctos**: comparar las propiedades de la variable que falla
contra una equivalente de un objeto que **ya funciona**.

---

### `build: cannot find symbol — class xyz`

**Causa**: el objeto que se llama **no existe en la KB destino**. La importación lo salteó en
silencio. El error recién aparece en `javac` porque el *spec* resuelve la llamada igual.

**Cómo confirmarlo** (sin depender del MCP):

```bash
ls JavaDB2iSeries002/state/state12_2_<objeto>.ari      # estado de generación
find GXSPC002 -name "<Objeto>.sp0"                     # resultado de la especificación
```

Si ninguno de los dos existe, el objeto **no entró**.

---

## Errores del MCP

### `WriteNotPersisted`

**Casi siempre es un FALSO NEGATIVO**: la herramienta relee truncado y cree que no entró.

**Solución**: **verificar por `.xpz` antes de reintentar**. Reintentar a ciegas genera
`já definida` y **pierde contenido**.

---

### `VariableRenamed`

**Dos casos**: normalmente el `modify` de tipo **sí aplicó** (mirá el `persistedType` en la
respuesta); otras veces es un fallo real. **Verificar por `.xpz`.**

---

### `TransactionFailed` + `''X'' é uma sub-rotina indefinida`

**Causa**: se agregó `Do 'X'` antes que exista `Sub 'X'`.

**Solución**: **primero los `Sub`, después los `Do`**.

---

### `KB_LEASE_EXPIRED`

```bash
gx-cli.sh gx genexus_kb '{"action":"select","alias":"TuKB"}'
```

---

### `WorkerBusy`

El worker ejecuta una operación SDK a la vez. **Esperar y reintentar.**

---

### `TransferImportVerificationUnavailable`

Dice *"no import was attempted"* **y sin embargo crea el objeto como stub vacío**. **El mensaje
miente.** Siempre verificar después.

---

## Errores de WWP

### `'Empty' is not a valid value for property 'CheckedValue' in '&X'`

**Causa**: un checkbox que viene de K2B con un **dominio numérico** necesita
`CheckedValue`/`UncheckedValue`, y el patrón no las tiene.

**Solución**: cambiar la variable a **`Boolean`** y **adaptar el código**:

```genexus
&CamVto = 0        →  &CamVto = False
If &CamVto = 1     →  If &CamVto = True
```

Con Boolean el checkbox es nativo y esas propiedades dejan de hacer falta. **El cambio de tipo
y el del código van juntos.**

---

### `PatternNoOp` al aplicar WWP

```
PatternInstancePackageInterface overload resolution failed...
does not expose one unambiguous five-parameter SettingsView.Web overload
```

**Causa**: se pasó `settings:{template:"..."}` explícito — incompatibilidad de reflexión del SDK.

**Solución**: **llamar `apply_pattern` SIN `settings`**. WWP auto-descubre el template.

---

### Al aplicar WWP no se genera el layout

**Causa**: el primer apply **solo crea la PatternInstance**; no genera el layout.

**Solución**: segundo llamado con **`reapply=true`**.

**Señal de que falta ese paso**: `mode=diagnose` devuelve `overrideConflict`
(*"An existing PatternInstance was found... use reapply=true"*).

---

### No encuentro los controles de entrada en el WebForm

**Causa**: en WWP los campos usan **`attribute="&Var"`**, no `controlName`.

**Solución**: buscar las dos cosas, y mirar el **`stats`** de `genexus_layout`:

```bash
gx-cli.sh gx genexus_layout '{"action":"find_controls","name":"MiPantalla","pattern":"*"}'
# -> stats: {"data": 19, "action": 5, "simplegrid": 1, ...}
```

`"data"` cuenta los campos de entrada; `"action"`, los botones.

---

### `ObjectNotFound` en las herramientas de `genexus_wwp`

**Causa**: se pasó el nombre del WebPanel.

**Solución**: el host del patrón se llama **`WorkWithPlus<Objeto>`**.

```bash
gx-cli.sh gx genexus_wwp '{"action":"list","name":"WorkWithPlusMiPantalla"}'
```

---

## Regla general

Ante **cualquier** código de error raro del MCP:

1. **No reintentar a ciegas.**
2. Verificar el estado real por **`.xpz`**.
3. Recién entonces decidir.
