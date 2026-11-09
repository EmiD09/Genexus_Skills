# Inventario de herramientas del MCP comunitario (genexus-mcp)

Version relevada: **v4.4.1** (72 tools, profile `all`). Fecha: 2026-11-09.
Fuente: `mcp({ server: "genexus" })` sobre el server stdio `npx genexus-mcp`.

Marcas: **[USA]** = la usamos habitualmente · **[PARCIAL]** = usada alguna vez ·
**[NUEVA]** = no usada aún, con potencial identificado · **[OPS]** = infraestructura/ops,
uso raro · **[DOCS]** = documentación embebida que el server sirve.

## Núcleo de lectura / análisis

| Tool | Para qué | Marca |
|---|---|---|
| `genexus_whoami` | Contexto de KB, versión, salud del worker/índice. Empezar siempre por acá. | [USA] |
| `genexus_doctor` | Health check completo (instalación GX, KB, worker, cache). | [USA] |
| `genexus_read` | Leer partes de objetos (Source, Events, PatternInstance, WebForm, Variables...). Paginación offset/limit ok en v4.4.x. **No escanea PatternInstance con search: leer directo.** | [USA] |
| `genexus_inspect` | Snapshot compacto de un objeto: metadata, partes, dependencias. | [PARCIAL] |
| `genexus_query` | Búsqueda por prefijos `name:`/`type:`/`usedby:`/`description:`, federada multi-KB. | [USA] |
| `genexus_list_objects` | Listado paginado con GUID/EntityKey. | [USA] |
| `genexus_search_source` | Regex sobre fuentes (NO escanea PatternInstance). Cursor v3 retomable; slice cap 250ms. | [USA] |
| `genexus_analyze` | Análisis semántico: impact, callers, navigation, linter, theme_classes, kb_stats... | [PARCIAL] |
| `genexus_wire` | Grafo de llamadas/indexación rápida (Rust). Requiere export de text-tree. | [PARCIAL] |
| `genexus_impact` | Conjunto afectado por un objeto (dirección, profundidad, filtro por tipo). | [NUEVA] |
| `genexus_object_context` | Contexto 360 de un objeto: identidad + dependencias en una llamada. | [NUEVA] |
| `genexus_dfd` | **Diagrama entidad-relación** de la KB (read-only, maxDepth). | [NUEVA] |
| `genexus_navigation` | Reporte de navegación (como el View Navigation del IDE). | [NUEVA] |
| `genexus_compare` | **Comparar dos objetos por SDK** (content = con diffs). Útil para verificar migración 17↔18 y post-import. | [NUEVA] |
| `genexus_doc` | Genera docs estructuradas (wiki, dependencias) de la KB. | [NUEVA] |
| `genexus_format` | Formatea código GeneXus con las reglas del worker. | [NUEVA] |

## Núcleo de escritura

| Tool | Para qué | Marca |
|---|---|---|
| `genexus_edit` | Editar partes: full/patch/ops, dryRun, expectedVersion, rollback, autoDeclareVariables, changeSet multi-objeto. La caballeriza de todos los writes. | [USA] |
| `genexus_create` | Crear objetos (object, object_atomic, save_as, popup, template, curl_procedure...). | [USA] |
| `genexus_delete_object` | Baja de objetos con inspección de referencias (confirm). | [USA] |
| `genexus_edit_and_build` | **Editar + rebuild de llamadores en una sola llamada.** Ideal para el flujo sin IDE. | [NUEVA] |
| `genexus_properties` | Propiedades por objeto/control; `refresh:true` para lectura fresca; escribe EnumValues de Dominios (v4.4.0). | [USA] |
| `genexus_variable` | CRUD de variables con tipos (add/modify retyped, colecciones, dimensiones). | [PARCIAL] |
| `genexus_structure` | Leer/escribir estructura de Transacciones/SDT (`get_item_property`/`set_item_property` nuevos en v4.4.0, con dryRun/rollback). | [PARCIAL] |
| `genexus_authoring` | Autoring de miembros de tipos que el DSL de structure no cubre. | [NUEVA] |
| `genexus_edit_form` | Ediciones semánticas de WebForm: add_textblock, add_table..., con legenda/eventos/visibilidad. | [NUEVA] |
| `genexus_data_view` | Transacción + Data View atómico y tipado (mapeos de atributos, datastore, updatable). | [NUEVA] |
| `genexus_merge` | **Merge de dos objetos (o three-way con base)** con detección de conflictos. Útil para traer cambios entre KBs. | [NUEVA] |
| `genexus_refactor` | Refactors: rename de objetos/subrutinas con actualización de referencias. | [NUEVA] |

## WWP / K2B / UI

| Tool | Para qué | Marca |
|---|---|---|
| `genexus_wwp` | Ediciones tipadas WWP: actions, tabs, grids, add_table, settings, regenerate_derived... | [USA] |
| `genexus_apply_pattern` | Aplicar/reaplicar patrón; `mode=diagnose` da findings accionables. | [PARCIAL] |
| `genexus_layout` | Layout/WebForm: get_tree (mirar `stats`!), set_property, add controles. | [PARCIAL] |
| `genexus_workwith` | Autoring/remoción de WorkWith estándar (tabs, actions, conditions). | [NUEVA] |
| `genexus_k2b_designer` | Editar un K2B WebPanel Designer activo en el IDE (requiere bridge del IDE). | [NUEVA] |
| `genexus_browser` | **Verificación headless en browser**: navegar la app, capturar screenshots, fill/click, auth, network. Para el control visual que hoy hace el usuario a mano. | [NUEVA] |

## Build / despliegue / runtime

| Tool | Para qué | Marca |
|---|---|---|
| `genexus_lifecycle` | Build (por target/targetGuid), validate, index, specify_only (v4.4.0), Build All, status/result de jobs. Requiere `kb` explícito. | [USA] |
| `genexus_run_object` | Resuelve la URL de runtime de un objeto (webRoot + parms) para probarlo. | [NUEVA] |
| `genexus_test` | Ejecuta tests nativos GXtest. | [NUEVA] |
| `genexus_deploy` | Deploy de aplicación vía SDK (Ev3 y targets). | [OPS] |
| `genexus_module` | Module Manager: export/import de módulos (.opc). | [OPS] |
| `genexus_generator_reference` | Referencias del generador .NET (tipadas). | [OPS] |

## Base de datos / seguridad

| Tool | Para qué | Marca |
|---|---|---|
| `genexus_db` | Umbrella de DB: `drift_check`, queries con where/values, execution plan, index advisor. Acceso a DATOS sin salir del MCP. | [NUEVA] |
| `genexus_data_view` | (ver escritura) Transacción + Data View atómico. | [NUEVA] |
| `genexus_gam` | Provisioning GAM (rebuild de tablas de seguridad). | [OPS] |
| `genexus_security` | Auditoría de seguridad de la KB (`audit_gam`). | [NUEVA] |

## Transferencia / versionado / team dev

| Tool | Para qué | Marca |
|---|---|---|
| `genexus_transfer` | XPZ export/import con dryRun, confirm y fidelity verification (#927 ok en v4.4.x). | [USA] |
| `genexus_kb_version` | Version tree de la KB (freeze/branch/changed_objects). | [PARCIAL] |
| `genexus_gxserver` | Team Development: status/pending/commit/update/locks/merge strategy. | [NUEVA] |
| `genexus_versioning` | Historial de versiones por objeto: history, snapshots, diffs, rollback puntual. | [NUEVA] |
| `genexus_io` | Umbrella IO: assets, export/import KB↔texto, import_part, export_kb_to_text (insumo de genexus_wire). | [PARCIAL] |

## Multi-KB (solo gateway, a nivel filesystem)

| Tool | Para qué | Marca |
|---|---|---|
| `genexus_kb_diff` | **Comparar dos KBs en disco** (modo maxObjects). Para saber qué cambió entre Prototipo/Producción. | [NUEVA] |
| `genexus_kb_import` | **Copiar un objeto entre KBs a nivel filesystem** (sin XPZ). | [NUEVA] |
| `genexus_sandbox` | **Clonar la KB a un sandbox** (carpeta aparte) para probar sin riesgo. | [NUEVA] |

## Productividad / self-service

| Tool | Para qué | Marca |
|---|---|---|
| `genexus_recipe` | **Playbooks nombrados + macros auto-extensibles**: graba flujos repetidos y los re-ejecuta. | [NUEVA] |
| `genexus_memory` | Almacén de hechos per-KB (save/list/delete) — notas pegadas a la KB. | [NUEVA] |
| `genexus_telemetry` | Observabilidad: ejecuciones, eventos, diagnósticos con correlación. | [NUEVA] |
| `genexus_sdk_probe` | Volcar la superficie del SDK instalado (qué soporta exactamente esta versión). | [NUEVA] |
| `genexus_kb` | Gestión de KBs abiertas/aliases/sesión. | [PARCIAL] |
| `genexus_connection_recover` | Recuperar workers enfermos. | [OPS] |
| `genexus_worker_pool` / `genexus_worker_reload` | Warm-spares y reload de worker. | [OPS] |
| `genexus_read_gateway_health_report` / `genexus_read_kb_index_status` | Salud del gateway / estado de indexación. | [OPS] |
| `genexus_api` | Inspección de Procedures HTTP y rutas API nativas (OpenAPI-ish). | [NUEVA] |

## Playbooks embebidos ([DOCS] — pedirlos y leerlos, son gratis)

- `genexus_read_genexus_agent_playbook` — workflow recomendado por el mantenedor.
- `genexus_read_llm_cli_mcp_playbook` — cuándo CLI vs MCP.
- `genexus_read_genexus_sdk_capabilities` — capacidades reales de esta instalación.
- `genexus_read_genexus_objects_index` / `genexus_read_genexus_attributes` — índices navegables.
- `genexus_read_web_panel_events_start_refresh_load_order` — orden de eventos verificado.
- `genexus_read_genexus_navigation_methods_call_calloption_4e96597d` — navegación entre paneles.
- `genexus_read_gam_genexus_access_manager_integrated_security` — GAM integrado.
- `genexus_read_smart_device_sd_panel_basics_main_property_a4729bdf` — SD panels.
- `genexus_read_nexa_official_genexus_modeling_and_kb_reference` — referencia nexa oficial.

## Las 8 que más nos servirían (orden de impacto)

1. **`genexus_edit_and_build`** — edita y recompila llamadores en una llamada: el flujo sin IDE completo.
2. **`genexus_browser`** — control visual headless con screenshots: reemplaza el "yo lo pruebo en el prototipo".
3. **`genexus_db`** — ver/escribir datos reales (drift_check incluido) sin tools externas.
4. **`genexus_compare`** — verificación objetivo de migraciones y post-imports.
5. **`genexus_kb_diff` + `genexus_sandbox`** — experimentar en clon y comparar KBs.
6. **`genexus_refactor`** — renames con referencias actualizadas.
7. **`genexus_recipe`** — grabar los flujos repetidos (baterías, migraciones) como macros.
8. **`genexus_versioning`** — diff/rollback puntual por objeto antes de tocar.
