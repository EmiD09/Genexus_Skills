# Flujo de trabajo: migrar un objeto de GeneXus 17 (K2B) a GeneXus 18 (WWP)

## Regla de oro

**Migración funcional exacta**: se traslada **solo lo que existe en el origen**. Nada agregado,
nada inventado. Del andamiaje del patrón viejo (K2B) no se porta nada. La KB de origen **solo se
lee**; nunca se modifica.

---

## Antes de empezar

```bash
~/bin/gx-mcp-up.sh --status          # las dos KBs tienen que responder
```

Anotá el nombre exacto del objeto en **ambas** KBs. Si difiere, peor.

---

## Paso 1 — Inventario de la brecha

No empieces escribiendo. Primero medí qué falta.

```bash
# ¿Existe en el destino?
gx-cli.sh gx genexus_read '{"name":"MiObjeto","parts":["Source"]}'

# ¿De qué depende? (procedimientos, SDTs, tablas)
gx-cli.sh gx17 genexus_analyze '{"mode":"context","name":"MiObjeto","maxBytes":4000}'
```

Para cada dependencia que falte, **repetí el análisis recursivamente** hasta que la cascada
termine. En la práctica termina en 2 niveles.

Escribí el inventario en un documento de tareas **antes de tocar nada**.

---

## Paso 2 — Migrar los procedimientos, hoja primero

```bash
~/bin/gx-migrate-object.py NombreDelProcedimiento --dry-run
~/bin/gx-migrate-object.py NombreDelProcedimiento
```

El migrador hace el ciclo completo y verifica por `.xpz`. Si algo falla, mirá
`03-errores.md`.

**Un procedimiento por vez.** Verificá antes de pasar al siguiente.

---

## Paso 3 — Las variables de la pantalla

De todas las variables, **la mayoría del delta en una migración K2B→WWP es andamiaje** que no
se porta:

- **NO se portan**: `ActivityList`, `GridState`, `IsVisibleSDTVar_*`, `TrnContext`,
  `RowsPerPage_*`, `FreezeColumnTitles_*`, `GridConfiguration`, `&<Grid>_SDT`…
- **SÍ se portan**: las que el código de usuario realmente usa.

Calculá el subconjunto así: extraé las `&variables` del código de los subs a portar y cruzá
contra las que ya están en el destino.

---

## Paso 4 — Los eventos

En **K2B** cada botón usa **dos niveles**:

```genexus
Event 'E_Cargar'        // lo genera el patrón
    Do 'U_Cargar'
EndEvent
Sub 'U_Cargar'          // acá va el código de usuario
    ...
EndSub
```

En **GX18 con WWP eso no hace falta**: el patrón ya genera el evento del botón, así que
**el código va directo en ese primer evento**, sin crear el segundo sub.

Mapeo de nombres observado:

| K2B | WWP |
|---|---|
| `Event Start` | `Event Start` |
| `Sub 'U_OpenPage'` | el código va en `Event Start` |
| `Sub 'U_Cargar'` | `Event 'DoCargar'` |
| `Sub 'U_EnvioP360'` | `Event 'DoEnvioP360'` |
| `ActVto.Enabled` | `BtnActVto.Enabled` |

**El `&<Grid>_SDT` de K2B se conserva** (declaralo como `sdt:<laSDT>`) — así lo hace el
patrón del lado WWP.

---

## Paso 5 — Verificar (no negociable)

**Nunca** por el `success` de la herramienta. Siempre por `.xpz`:

```bash
gx-cli.sh gx17 genexus_transfer '{"action":"export","targets":["X"],
            "outputFile":"C:\\ruta\\X_17.xpz","includeDependencies":false}'
gx-cli.sh gx   genexus_transfer '{"action":"export","targets":["X"],
            "outputFile":"C:\\ruta\\X_18.xpz","includeDependencies":false}'
```

Y comparar el `<Source>` de ambos. Un `.xpz` es un ZIP con un XML adentro.

**Al comparar variables, cuidado con el falso positivo**: `Attribute:CalCod` (origen) contra
`bas:Numeric(4)` (destino) **no es un error** — es el atributo expresado por su tipo base.
Solo son diferencias reales las de **tipo base** y las variables que faltan o sobran.

---

## Checklist de cierre

- [ ] Todos los `Source` idénticos al origen (verificado por `.xpz`)
- [ ] Las reglas iguales (ignorando comentarios)
- [ ] Ninguna variable con tipo base distinto
- [ ] Ninguna variable usada que falte
- [ ] Los eventos mapeados y con el código presente
- [ ] **Compila** (`BUILD SUCCESSFUL` en `OutputLogs/Build.log`)
- [ ] Ninguna diferencia funcional conocida sin documentar
