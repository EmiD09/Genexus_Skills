---
name: genexus-mcp-tools
description: "Trigger: cualquier tarea sobre una KB GeneXus via MCP (genexus-mcp comunitario): saber QUE herramienta usar para cada cosa, capacidades y limites del server, routing por intencion (leer, escribir, analizar, compilar, datos, UI, migrar). Inventario completo de las 72 tools con marcas de uso."
---

# MCP comunitario de GeneXus — routing por intencion

Server: `npx genexus-mcp` (stdio nativo Windows), repo `github.com/lennix1337/Genexus18MCP`.
Version relevada: **v4.4.1** (72 tools). Inventario completo con marcas de uso:
**`references/mcp-tools-inventario.md`** — leerlo cuando la duda sea "¿existe una tool para X?".

Empezar siempre con `genexus_whoami` (contexto KB + salud). Las llamadas stateful
(build, specify) exigen `kb:"<alias>"` explicito.

## Routing rapido: "quiero..."

| Intencion | Tool |
|---|---|
| Leer un objeto/parte | `genexus_read` (paginacion offset/limit ok; `refresh:true` para lectura fresca) |
| Buscar objetos por nombre/tipo/uso | `genexus_query` (prefijos `name:` `type:` `usedby:`) o `genexus_list_objects` |
| Buscar TEXTO dentro de fuentes | `genexus_search_source` (regex; **NO escanea PatternInstance**) |
| Escribir una parte | `genexus_edit` (siempre `dryRun` primero; receipt trae `persistedState`/`persistedVerified`) |
| Editar y recompilar llamadores de una | `genexus_edit_and_build` |
| Crear un objeto | `genexus_create` (`object_atomic` para todo en uno) |
| Borrar un objeto | `genexus_delete_object` (falla si tiene llamadores) |
| Ver/retipar variables | `genexus_variable` |
| Estructura de Transaccion/SDT (attrs, niveles, propiedades tipadas) | `genexus_structure` |
| Propiedades de objeto/control | `genexus_properties` (`refresh:true` para fresco) |
| Editar layout WWP (acciones, tabs, grids, tablas) | `genexus_wwp` (no editar WebForm bajo instancia) |
| Aplicar/reaplicar patron | `genexus_apply_pattern` (`mode=diagnose` primero) |
| WWP estandar (tabs/actions/conditions) | `genexus_workwith` |
| K2B WebPanel Designer activo en IDE | `genexus_k2b_designer` |
| Compilar / validar | `genexus_lifecycle` (`action=build` por `targetGuid`; `validate`; `specify_only`) |
| Correr/probar la app | `genexus_browser` (headless: screenshots, fill, click, auth) + `genexus_run_object` (URL de runtime) |
| Ver/escribir DATOS reales | `genexus_db` (queries, drift_check, execution plan) |
| Analizar impacto/dependencias | `genexus_analyze` / `genexus_impact` / `genexus_object_context` / `genexus_wire` / `genexus_dfd` (ER) |
| Comparar objetos o KBs | `genexus_compare` (objetos) / `genexus_kb_diff` (KBs en disco) |
| Exportar/importar XPZ | `genexus_transfer` (dryRun → confirm; fidelity verificada) |
| Copiar objeto entre KBs / clonar KB | `genexus_kb_import` / `genexus_sandbox` |
| Renombrar con referencias | `genexus_refactor` |
| Historial/diff/rollback por objeto | `genexus_versioning` |
| Grabar un flujo repetido | `genexus_recipe` (playbooks + macros) |
| Deploy / modulos / GAM / seguridad | `genexus_deploy` / `genexus_module` / `genexus_gam` / `genexus_security` — [OPS]: solo con decision explicita del usuario |
| Documentacion embebida del server | `genexus_read_*_playbook` y demas `genexus_read_*` (9 playbooks gratis; ver inventario) |

## Reglas duras (aprendidas con costo)

1. **`genexus_search_source` no llega a la PatternInstance.** Para saber si una
   clase/valor vive en una instancia WWP: `genexus_read` de la instancia, o
   `genexus_edit ... dryRun:true` con `replaceAll` — el `matchCount` del dryRun
   responde sin escribir.
2. **Todo write va con `dryRun` primero** y el `versionToken` del dryRun sirve de
   `expectedVersion` del write inmediato. El receipt es honesto desde v4.4.0
   (`persistedState: confirmed/unknown`) pero lo critico se re-verifica por `.xpz`.
3. **Build**: nombres ambiguos (Bien = transaccion + tabla + data view) →
   `BuildTargetAmbiguous`; resolver con `genexus_query` y compilar por `targetGuid`.
   Un objeto `unreachable` (spc0217, sin llamadores) no genera codigo: esperado.
   Los `>W`/«errors» del summary pueden ser warnings del spec: `Status` manda.
4. **Nada de escribir WebForm a mano donde haya PatternInstance**: el patron gana y
   pisa. Ver skill `genexus-migracion-k2b-a-wwp` (reglas WWP) y sus referencias.
5. **No insistir ante fallas del engine del patron** (p. ej. `add_table` sobre
   Selection: dryRun planifica, live falla con rollback exacto). 2 fallos = documentar
   y frenar.
6. **Datos/estructura destructivos** (`genexus_db` writes, deletes en cascada,
   reorg): siempre con decision explicita del usuario.

## Cuando una tool responde mal

Consultar primero `genexus_doctor` y `genexus_read_gateway_health_report`; si el
worker esta mal, `genexus_worker_reload` / `genexus_connection_recover`. Si el error
parece del SDK (no del MCP), buscar el mensaje en el repo del mantenedor (issues) —
casi siempre esta documentado; si no, reportar con el repro.
