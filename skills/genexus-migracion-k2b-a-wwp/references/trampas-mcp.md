# Trampas del MCP de GeneXus y como reaccionar

Todo esto esta **comprobado** en migraciones reales. Leer antes de la primera escritura.

## Lectura

| Situacion | Que hacer |
|---|---|
| `genexus_read` devuelve ~5 KB y termina en `// ... [CONTENT TRUNCATED...] ... //` | **El objeto esta bien; la lectura trunca.** Usar `genexus_transfer action=export` + leer el XML del `.xpz`. El paginado que sugiere el mensaje **no funciona**: `parts` es excluyente con `offset`/`limit`, y `part` singular no incluye `Events`. |
| `genexus_inspect` da `IndexNotReady` | Esperar el indice (`genexus_lifecycle action=status wait=30`). |
| `genexus_read` da `ObjectNotFound` pero el objeto deberia existir | Puede ser indice en reconstruccion. Confirmar con `genexus_read` tras esperar. |
| Hay que saber si un objeto **esta de verdad** en la KB | Sin MCP: `JavaDB2iSeries002/state/state12_2_<objeto>.ari` y `GXSPC002/**/<objeto>.sp0`. Si no estan, el objeto no entro, aunque el spec resuelva la llamada y `genexus_read` no de error. |
| Distinguir "no existe" de "existe vacio" | `genexus_inspect` lo distingue; `genexus_read` no (los dos dan 0 chars). |

## Escritura

| Codigo | Significado real |
|---|---|
| `WriteNotPersisted` | **Falso negativo frecuente**: la herramienta re-lee truncado y cree que no entro. **Verificar por `.xpz` antes de reintentar.** Reintentar a ciegas genera `já definida` y perdida de contenido. |
| `VariableRenamed` | **Dos casos**: el `modify` de tipo suele **si** aplicar (confirmar leyendo el `persistedType` de la respuesta). Pero tambien puede ser un fallo real: **verificar por `.xpz`**. |
| `WriteNoChange` con `existed: 1` | La variable ya estaba. **No le cambia el tipo**: si hay que retiparla, usar `modify`. |
| `TransactionFailed` + `''X'' é uma sub-rotina indefinida` | Falta el `Sub 'X'`. **Agregar los Subs antes que los `Do`.** |
| `TransactionFailed` + `atributo inválido 'X'` | `X` es un **control del layout** que no existe con ese nombre. |
| `TransactionFailed` + `não é uma matriz` | La variable se usa como `&var()`. Ver "Matrices" abajo. |
| `PostTimeoutReadRequired` | Un write anterior quedo en estado desconocido. Hacer un `genexus_read` **completo** del objeto; eso limpia la barrera. |
| `KB_LEASE_EXPIRED` | `genexus_kb action=select alias=<KB>` y reintentar. |
| `WorkerBusy` | El worker ejecuta una operacion SDK a la vez. Esperar. |
| `WorkerTimeout` | Puede seguir procesando: **verificar por `.xpz`**. |
| `DeleteFailed` | `genexus_delete_object` falla si **alguien llama al objeto**. Hay que borrar los llamadores primero (o actualizar en el lugar). |
| `LegacyWorkerError` | Operacion no soportada. Ver "Matrices". |
| `TransferImportVerificationUnavailable` | Dice *"no import was attempted"* **y sin embargo crea el objeto como stub vacio**. Siempre verificar. |
| `AtomicCreateValidationFailed` | No expone `fieldErrors`. Aislar por biseccion. |

### La respuesta del `modify` trae el tipo aplicado — usarla

`genexus_properties action=get` **puede devolver un tipo obsoleto** (reporto `VARCHAR` para una
variable que ya era `DATE`). En cambio la respuesta del `modify` trae el dato bueno:

```json
{"requestedType": "Date", "persistedType": "DATE", "details": "Variable '&Hoy' retyped to 'DATE'."}
```

Confirmar igual por `.xpz`. **Regla general: cualquier lectura puede estar desactualizada o
recortada; el `.xpz` no.**

## Creacion de objetos

- `genexus_create action=object_atomic` hace todo en una llamada: `parms`, `variables`,
  `source`, `rules`, `mode` (`create`/`update`/`auto`), `updateExisting`, `dryRun`,
  `validationMode`.
- Las `variables` van **como objetos** (`[{"varName":"X"}]`), no strings.
- **Es atomico**: si el `source` falla, no se guarda **nada**, ni las variables. Para objetos
  grandes: crear con variables + parms **sin** el source, despues los ajustes de matriz, y
  recien al final el source.
- Los tipos basados en **BC / SDT / ext fallan aca** → agregarlos aparte con
  `genexus_variable action=add` (`typeName: "SDT.Item"`).

## Matrices vs colecciones

- **Collection**: `AttCollection=True`, `AttNumDim=0` (lista, `&var.Add()`).
- **Matriz/Vector**: `AttCollection=**False**`, `AttNumDim=1`, `AttRows=N` (sintaxis `&var()`).

Se ajustan con `genexus_properties action=set name=<obj> control="&Var"`, **en este orden**:
`AttCollection=False` -> `AttNumDim=1` -> `AttRows=<N>`. Poner `collection:true` hace lo contrario.

**Como descubrir el valor correcto**: comparar las propiedades de la variable que falla contra
una equivalente de un objeto que **ya funciona** (el diff da exactamente que ajustar).

**No se puede deshacer mientras el fuente la use**: bajar `AttNumDim` a 0 da `LegacyWorkerError`
con un error de validacion del propio Source (`src023…`), porque el codigo todavia tiene `&var()`.
`Type` es read-only en `genexus_properties`.

**Secuencia para retipar una matriz** (probada):

1. Guardar el fuente.
2. Escribir un fuente minimo temporal (p. ej. `&Ok = 'S'`) para liberar la validacion.
3. `AttRows=0` -> `AttNumDim=0`.
4. `genexus_variable action=modify` con el tipo correcto.
5. Re-armar: `AttCollection=False` -> `AttNumDim=1` -> `AttRows=<N>`.
6. Restaurar el fuente y verificar por `.xpz`.

## Variables que aparecen solas (la trampa mas sutil)

Al escribir el `Source`, **el SDK auto-crea toda `&Variable` que aparezca y no este declarada,
con el tipo por defecto `VarChar(100)`**. No avisa. Despues el objeto compila mal con errores
que parecen de otra cosa:

```
spc0010: Type mismatch in assignment: &Hoy = serverdate() (Varchar=Date)
spc0009: Type mismatch in expression: year(&Hoy)
```

Pasa con variables que **GX17 tampoco declara** y GeneXus resuelve al especificar deduciendolas
del uso (`&Hoy = serverdate()` -> `Date`). **`genexus_inspect` de GX17 tampoco las lista.**

**Como detectarlas**: despues de escribir el fuente, sacar las variables que usa y ver cuales
no estaban en el XPZ de GX17. Declararlas **explicitamente** con el tipo correcto.

**Cuidado al hacer ese barrido**: `genexus_read` **trunca**, asi que la lista de variables usadas
tambien sale incompleta si se lee de ahi. Usar el fuente del `.xpz`.

- `genexus_edit` rechaza `\r\n`/`\n`/`\r` **literales** (`LiteralLineBreaksDetected`): el
  contenido necesita saltos de linea reales. Pasar el payload por `json.dumps` + `subprocess`
  evita problemas de comillas.
- `mode=full` sobre el **WebForm** es destructivo (sanitiza atributos): usar `mode=patch`.
- El archivo de respuesta del cliente se vacia antes del `curl`: si no, un fallo de red deja la
  respuesta **anterior** y el cliente muestra datos del objeto equivocado.

## Inspeccionar el layout del WebForm (no confundirse)

**Los controles que genera WWP se nombran con `attribute="&VarName"`, NO con `controlName`.**

Buscar solo `controlName="..."` hace que los campos de entrada **no aparezcan** y lleva a
concluir (mal) que faltan los controles. **Buscar siempre tambien `attribute="&Var"`.**

Ejemplo real: en `MPGBieCompP360` el WebForm tenia 19 nodos `<data attribute="&Var">`
—los 19 campos de entrada— y por mirar solo `controlName` se reporto un "hallazgo" de
controles faltantes que **no existia**.

Para comparar GX17 vs GX18:

```python
atrib = set(re.findall(r'attribute="([^"]*&[^"]*)"', webform))   # los campos de entrada
ctrl = set(re.findall(r'controlName="([^"]+)"', webform))        # botones, grilla, tablas
```

Las diferencias que aparecen son **andamiaje de grilla de K2B** (`IsVisibleSDTVar_*`,
`GridSettingsRowsPerPage_*`, `FreezeColumnTitles_*`, `&<Grid>_SDT`) que **no se porta** por
regla, mas el binding de la grilla que agrega WWP. Eso es lo esperado.

## Checkbox que viene de K2B con dominio numerico

Si un checkbox venia de K2B con un dominio numerico o caracter y el patron WWP se queja de
`'Empty' is not a valid value for property 'CheckedValue'` (o `UncheckedValue`), la solucion
limpia es **cambiar la variable a `Boolean` y adaptar el codigo**:

```genexus
&CamVto = 0        ->  &CamVto = False
If &CamVto = 1     ->  If &CamVto = True
```

Con Boolean el checkbox es nativo, esas propiedades dejan de hacer falta, el patron vuelve a
generar con `Success` y el build pasa. **El cambio de tipo y el del codigo van juntos, siempre.**

Ojo: el evento de tipo `Event &Chequeo.Click` (que en K2B habilitaba/deshabilitaba campos al
togglear) **no se porta solo por declarar la variable**: hay que crear el evento equivalente
sobre el control en GX18.

## Sintaxis de los payloads

- `genexus_edit` rechaza `\r\n`/`\n`/`\r` **literales** (`LiteralLineBreaksDetected`): el
  contenido necesita saltos de linea reales. Pasar el payload por `json.dumps` + `subprocess`
  evita problemas de comillas.
- `mode=full` sobre el **WebForm** es destructivo (sanitiza atributos): usar `mode=patch`.
- **En WWP editar la PatternInstance, no el WebForm**: el patron sobreescribe el WebForm.
- El archivo de respuesta del cliente se vacia antes del `curl`: si no, un fallo de red deja la
  respuesta **anterior** y el cliente muestra datos del objeto equivocado.

## Herramientas locales

| Ruta | Para que |
|---|---|
| `~/bin/gx-mcp-up.sh` | Levanta las dos KBs (GX18 :5000, GX17 :5101) + bridges. `--status` informa. |
| `~/bin/gx-cli.sh` | `gx-cli.sh gx <tool> '<args>'` (GX18) / `gx-cli.sh gx17 …` (GX17) / `--status` / `--schema <tool>`. Timeout 900s. |
| `~/bin/gx-migrate-object.py` | Ciclo completo de un objeto. `--dry-run`. Detecta solo las variables usadas como matriz. |
