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
