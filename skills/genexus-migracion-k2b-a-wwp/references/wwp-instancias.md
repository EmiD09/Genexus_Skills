# WWP: Instancias, PatternInstance y WebForms (aprendido empiricamente)

Fuente: trabajo real en KBs GeneXus 18 (dos KBs GeneXus 18 reales ( WB/GAM y "Recursos")), 2026-10-14.
Complemento de `trampas-mcp.md`. La leccion central:

**El WebForm de un objeto WWP NO se edita a mano. El layout se edita en la
PatternInstance del pattern host (`WorkWithPlus<Objeto>`); el patron proyecta
al WebForm automaticamente. Un edit directo del WebForm SIEMPRE pierde: el
patron regenera ids y restaura los controles del snapshot de la instancia,
incluso con `forceWrite` o `SDPlus_Editor_Apply_On_Save=False`.**

## Anatomia del pattern host

- El host se llama `WorkWithPlus<NombreObjeto>` y es un objeto aparte
  (`genexus_inline read`/`genexus_read name=WorkWithPlus<X>` con el MCP).
- Su parte `PatternInstance` es **XML simple y chico** (~2-4 KB para un panel),
  legible y patchable:

```xml
<instance childrenOrderedList="7;57;" type="WebPanel">
  <WPRoot Template="Empty" formThemeClass="Form">
    <table name="Main" type="Responsive">
      <textBlock controlName="TBTitle" caption="..." themeClass="Title" />
      <variable name="CUIT" description="CUIT *" dataType="Basic" basicLength="13"
                themeClass="AttributeFL" cellThemeClass="DataContentCellFL" />
      <!-- los variables tipo dominio usan domain="<modulo>.<Dominio>" -->
      <errorViewer controlName="ErrorViewer1" />
      <actionGroup name="Actions" themeClass="TrnActionGroup">
        <userAction caption="Limpiar" name="Limpiar" />
        <standardAction ControlType="Button" name="Cancel" />
        <standardAction name="Enter" />
      </actionGroup>
    </table>
    <steps />
  </WPRoot>
</instance>
```

- Nodos validos de lo conocido: `table`, `textBlock`, `variable`
  (con `dataType="Basic"` + `basicLength`, o `domain="Modulo.Dominio"`),
  `errorViewer`, `actionGroup` + `userAction` + `standardAction`, `steps`.
- Los eventos del objeto quedan en el Source del objeto real; para acciones
  atadas a boton, `onClickEvent="'DoAlgo'"` coincide con `Event 'DoAlgo'`.

## Proyeccion

- La edicion del PatternInstance se **auto-proyecta** al WebForm del parent:
  `IPatternBuildProcess.UpdateParentObject`, `projectionStatus: "Projected"`
  (verificado con genexus-mcp v3.15).
- `SDPlus_Editor_Apply_On_Save` (propiedad del host): controla la re-proyeccion
  en cada save. **Dejar en `Default`.** `False` NO evita que el patron restaure
  el snapshot en un WebForm editado a mano, y ademas bloquea proyecciones sanas.

## Receta probada: crear una pantalla WWP desde el MCP

```
1) genexus_properties action=move/... o genexus_create (WebPanel en el modulo)
2) genexus_apply_pattern name=<X> pattern=WorkWithPlus          <- SIN settings
3) genexus_apply_pattern name=<X> pattern=WorkWithPlus reapply=true
   (la 2 crea la PatternInstance; la 3 genera el layout)
4) Editar variables por genexus_variable (los tipos globales van
   como GeneXusSecurityCommon.<Tipo>, no "Tipo, Modulo").
5) Editar el PatternInstance para ordenar/borrar/agregar controles
   (patch find/replace con el XML exacto).
6) Escribir el Source (genexus_edit part=source) — se valida contra los
   controles ya proyectados: un textblock/control referenciado en el source
   tiene que existir en la instancia primero.
7) Build One por el IDE (gx-oficial build_one).
```

Sin cantidad: `genexus_apply_pattern` con `mode=diagnose` devuelve findings
(`overrideConflict` → falta reapply) y la lista completa de templates validos
(en GX18/WWP 15.3.7 son ~120: Empty, PopoverEmpty, Transaction, Transaction
SplitScreen/Tabs, ViewExpanded, WizardArrowType, CardsMenu, etc.).

## Trampas vistas con mis ojos

1. Variable de tipo externo en el source: los EO usan `GeneXusSecurity.GAMUser`
   como tipo de variable; en la instancia, `domain="<ObjetoPadre>.GeneXusSecurity..."`.
   No acepta el formato `'Tipo, Modulo'` de los textos exportados.
2. `genexus_edit part=WebForm` con patch: guarda, pero el verify falla
   (`WriteNotPersisted`) porque el patron normaliza `id`/classes. Aun con
   patch aplicado, la **baja de un control no sobrevive** (el snapshot gana).
   Si se edita por WebForm por necesidad, esperar que el id del layout cambie
   con cada save.
3. `classList` del WebForm proyectado (p.ej. `d52f9833-...-617`) son GUIDs de
   theme del Design System: no hardcodearlos en patches de instancia; en la
   instancia se escriben nombres (`AttributeFL`, `DataContentCellFL`).
4. El Source valida contra controles EXISTENTES: `src0265 atributo inválido
   'TBXxx'` significa que el control no esta proyectado todavia. Primero la
   instancia, despues el source.
5. `IsEmpty()` no vale sobre propiedad de control (`TBX.Caption.IsEmpty()` da
   `src0294`) ni sobre Numeric en algunas sintaxis; usar comparaciones directas.
6. El `genexus_read part=PatternInstance` del host NO truncas como el Source:
   puede leerse entero (para panels chicos).

## Runtime web: patrones vistos 2026-10-27 (feature botón por-fila con 3er parm)

1. **`Return` en un evento de WebPanel (web) = volver al panel llamador**, no "cortar el
   evento". Es exactamente lo que hace el pattern en `AfterTrn`. Para cortar flujo dentro
   de un `If` de `Grid.Load`: **reestructurar con If/Else/EndIf**. `Exit` solo vale dentro
   de loops (`src0254`). Síntoma del error: la pantalla carga y vuelve sola al llamador.
2. **Las líneas auto-generadas (Call/Link de un userAction, parm rule) viven en el XML de la
   INSTANCIA**, no en el source: `genexus_edit mode=full` sobre Source改革发展 falla
   (`WriteNotPersisted`); el patrón re-proyecta el bloque `[Start]/[End]`. Para cambiar
   la firma de una llamada, **patchear `<parameters>` del `<userAction>` (y/o de la
   `<selection>` del panel destino) y dejar que el patrón regenere** el source
   (`Call(..., &TercerParm)`, `Link(&Id, &Id, &ChildsMode)`). Los parms que agregan al
   panel destino se resuelven con un leaf `<parameter>` en `<selection><parameters>`.
3. **Variables auxiliares por rama**: al reestructurar un If/Else, si una variable
   alimenta a AMBAS ramas (ej: `&GridPageSize = Grid.Rows` divisor de paginación),
   asignarla ANTES del If o en ambas ramas; quedar solo en una da Division by zero en runtime.
4. **Patches de Source: atómicos y balanceados.** Dos patches consecutivos sobre el mismo
   bloque (quitar Return y luego agregar EndIf) NO validan incrementalmente: cada save
   valida el árbol completo y rechaza el intermedio. Hacer UN patch con el bloque completo
   reestructurado.
5. Los finds de patch se escriben con el line-ending real que devuelve `genexus_read`
   (\n); el SDK normaliza igual, pero constructo de find de memoria con \r\n garantiza
   falso-negativo en los asserts locales.
6. UX de acción por fila: si el tool `genexus_wwp add_user_action` falla al crear una
   action en la grilla (InvalidCastException conocido del SDK), crearla a mano en el IDE
   (pattern editor) y los parms quedan en la instancia igual que cualquier UA.

## WebComponents con patrón (UsuariosPorRol, etc.) — ruta validada headless (2026-10-28, ticket 584b GamNucleo)

Editar un WebComponent WWP (grid + acciones) sin IDE. Lo que anda y lo que no, verificado:

1. **Resolver la instancia**: `genexus_read part=PatternInstance` con el nombre del PANEL
   (UsuariosPorRol) resuelve el host `WorkWithPlus<X>` y devuelve `resolvedEntityKey`.
   Ese entityKey es el que hay que pasar a `genexus_wwp` (con `gxobject` por nombre da
   `ObjectNotFound`, probado con panel y host).
2. **Acción de fila en grid**: `genexus_wwp add_user_action` solo agrega acciones de
   FORMULARIO (`TableActions`), nunca de fila. La vía que funciona es patch XML de la
   instancia agregando UN `<userAction>` bajo el `<grid>` (es kind permitido).
   - Atributos que el validador aceptó: solo `name` + `caption`. `image`, `confirm`,
     `confirmText`, `tooltip`, `fontIcon`, `ControlType`, `imageType` fueron RECHAZADOS
     (`PatternAttributeNotInSdkSpecification`) aunque la lista del error los mencione.
     Icono/formato fino: ajustar después en el WebForm proyectado o en el IDE.
   - El find del patch debe usar el texto EXACTO de la instancia re-leída: el SDK
     REORDENA atributos (`caption` antes de `name`) y normaliza indentación.
3. **Columna de grid (gridVariable)**: NO es patcheable por XML (no está entre los kinds
   permitidos: textBlock/attribute/variable/userAction/image/userControl/actionGroup/
   errorViewer/data/webComponent). Debe ir por `genexus_wwp add_grid_variable`, que pide
   `baseVersion` (el `currentVersion` viene en el payload del error, o de un dryRun).
   - LÍMITE CONOCIDO (v4.0.4 / GX 18.0.9): si el dueño del host es un **WebComponent**,
     `add_grid_variable` falla con `WwpSnapshotRequired` y `regenerate_derived` con
     `WwpParentNotResolved` ("Transaction/WebPanel that owns... could not be resolved").
     La resolución de padre del SDK solo contempla Trn/WebPanel. En ese caso la columna
     se agrega a mano en el IDE (editor WWP del grid) y el resto sigue headless.
4. **Leer el source de un objeto con eventos**: `genexus_read part=Source` puede devolver
   solo la rules (`parm(...)`). El contenido completo está en `genexus_read` sin part →
   `result.parts.events` / `result.parts.rules`.
5. **Stub de evento**: el patrón genera el stub del evento del userAction al APLICAR
   (IDE: abrir y guardar con SDPlus_Editor_Apply_On_Save en Default, o Build). No
   escribir el evento a mano antes de que exista el stub: queda duplicado (src0208).
6. **Variable de contexto de fila**: para que el evento del userAction sepa qué fila fue
   clickeada, la variable debe ser columna del grid. ATENCIÓN GAM: el EO `GAMUser` NO
   expone propiedad `Id` (src0216 'Id' invalid property); el id de usuario GAM es el GUID.
   Vía correcta: `&UserId` basada en dominio **GAMGUID** (GeneXusSecurityCommon), en el
   Load `&UserId = &GAMUser.GetId()` (método expuesto, devuelve GAMGUID) y en el evento
   `&GAMUser = GAMUser.GetByGUID(&UserId, &GAMError)` (convención GAMWWUsers) antes de
   `&GAMUser.DeleteRoleById(&RoleId, &GAMError)`. La lista de propiedades/métodos expuestos
   del EO se confirma en ModuleDefinition.xml dentro del .opc del módulo
   (Modules/GeneXusSecurity_*.opc), buscando el objeto y sus ExternalProperty/ExternalMethod.
   Las variables que el patrón proyecta como columnas DEBE declararlas el usuario por el
   editor WWP del IDE: una declaración por MCP `genexus_variable` el patrón la pisa
   (re-declara NUMERIC(4) default sobre una NUMERIC(12) hecha por MCP).
