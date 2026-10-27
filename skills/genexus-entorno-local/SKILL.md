---
name: genexus-entorno-local
description: Plantilla editable del entorno GeneXus local por máquina. Ejemplo real des-idendificado de referencia (KBs <KB_ACTUAL>/<KB_SECUNDARIA>, <ORGANIZACION>): servidores MCP disponibles y como activarlos, modelo de build Gradle y fixes conocidos de compilacion. Usar cuando se trabaje con KBs GeneXus locales, errores de compilacion de entornos, o configuracion de MCP GeneXus.
---

# Entorno GeneXus local PLANTILLA: completar per-máquina (no commitear datos reales)

PLANTILLA por máquina: copiar a skills privadas (o rellenar y NO commitear). Los valores <> se completan con los de tu instalación. Basado en un caso real des-identificado.

## KBs y paths

| KB | Path | Namespace Java | Notas |
|---|---|---|---|
| <KB_ACTUAL> | `C:\KBs\<KB_ACTUAL>` (WSL: `/mnt/c/KBs/<KB_ACTUAL>`) | `com.<namespace1>` | KB actual de trabajo. GeneXus 18. SQL Server (`GX_KB_<KB>.mdf`). Env: `Prototipo\web` (Gradle). Deploy: Tomcat 10.1 (`...\webapps\<KBNombre>Prototipo`). |
| <KB_SECUNDARIA> | `C:\KBs\<KB_SECUNDARIA>` | `com.<namespace2>` | Otra KB del <ORGANIZACION> (otro sector). Comparte datastore con <KB_ACTUAL> pero son KBs DISTINTAS: no copiar codigo generado entre ellas (namespace incompatible). Env: `JavaDB2iSeries002`. |

- Instalaciones GeneXus: `C:\Program Files (x86)\GeneXus\GeneXus17U11`, `GeneXus18`, `GeneXusSelector`.
- No hay JDK en WSL; compilar desde Windows: `cmd.exe /c "cd /d C:\KBs\<KB_ACTUAL>\<CENTRO_PROTOTIPO>\web && gradlew.bat compileJava -Dorg.gradle.jvmargs=-Xmx12288m"`.
- Logs de build del IDE: `<KB>\OutputLogs\Build.log` (texto ASCII con byte 0x96; usar `grep -a`).

## Servidores MCP (config: `~/.pi/agent/mcp-adapter.json`)

1. **gx-oficial** → `http://localhost:1989/mcp`. Es el MCP del IDE GeneXus 18: SOLO escucha mientras GeneXus.exe esta abierto Y el MCP server esta habilitado en el IDE (Tools > Options). Tools cacheadas (2025-11-19): `open_knowledge_base`, `close_knowledge_base`, `create_knowledge_base`, `build_all`, `build_one`, `reorganize`, `run`, `run`/`create_or_impact_database`, `import_text_to_kb`, `export_kb_to_text`, `delete_kb_objects`, `validate_kb_text_files`. Si no responde: pedir al usuario que habilite el MCP en el IDE con puerto 1989.
2. **gx-mcp** → RECONFIGURADO (2026-10-13) a stdio: `cmd.exe /c "npx -y genexus-mcp@latest"` (genexus-mcp v3.14.0, github.com/lennix1337/Genexus18MCP; maneja la KB via el SDK nativo de GeneXus 18). VALIDADO end-to-end desde WSL: responde initialize y expone 20 tools (`genexus_read`, `genexus_edit`, `genexus_create`, `genexus_kb`, `genexus_query`, `genexus_list_objects`, `genexus_search_source`, `genexus_structure`, `genexus_impact`, `genexus_lifecycle`, ...). Config propia del server: `C:\Users\<USUARIO>\.genexus-mcp\config.json` (GatewayMode stdio-isolated, GX18 en `C:\Program Files (x86)\GeneXus\GeneXus18`, ResolutionPolicy strict sin KBs declaradas -> la KB se resuelve por llamada, p.ej. tool `genexus_kb`; si pide KB explicita, agregarla a `Environment.KBs` de ese config). OJO: desde WSL `npx.cmd` directo NO anda (bash lo parsea como script): siempre via `cmd.exe /c`. VS Code usa el mismo server como `genexus18mcp`. La entrada vieja (http://localhost:5000/mcp) quedo descartada; backup en `~/.pi/agent/mcp-adapter.json.bak-gxmcp`.
3. En la KB secundaria hubo trabajo previo con un MCP `mcp__genexus` (edicion de events por canal directo, ver `<KB_SECUNDARIA>\ESTADO_PROYECTO.md`).

## Modelo de build Gradle (env web GeneXus 18)

- `build.gradle`: `compileClasspath.extendsFrom(genexusConfiguration)`; `genexusConfiguration` = `fileTree("lib")` + `fileTree("drivers")` + `fileTree("modules")` (relativos a `Prototipo\web`). `WEB-INF\lib` es SOLO runtime: NO entra al classpath de compilacion.
- **Regla**: jars de External Objects / File objects tienen que estar en `web\lib` (o `modules`) para que `compileJava` los vea. GeneXus los copia solo a `WEB-INF\lib` y al Tomcat segun la propiedad de copia del File object.
- `drivers\` = JDBC (`jt400` etc.), `modules\` = modulos GeneXus (`GeneXus.jar`, `GeneXusSecurity`, ...), `lib\` = libs del usuario.

## Fixes conocidos (ejemplos reales, nombres de objetos genericos) (primera compilacion 2026-10-13)

1. **EO jars faltantes en compile classpath** — errores `package <ORG>.facturas / com.<CODIFICADOR>.Principal does not exist`. FIX APLICADO: copiados `CodeBarGRB.jar` y `arca-factura-reader.jar` de `WEB-INF\lib` a `web\lib`. Si una limpieza los borra, repetir la copia.
2. **`loadauditplacuerec` no generado** — **RESUELTO Y VERIFICADO (2026-10-13)**: `gradlew compileJava` = BUILD SUCCESSFUL, 0 errores. Causa raiz REAL: la instancia WorkWithPlus de PlaCueRec tenia referencia colgada (`MissingKBObject:Objects_LoadAuditPlaCueRec`); el procedure `LoadAuditPlaCueRec` faltaba como OBJETO en la KB. Los `LoadAudit<Trn>` son objetos reales creados por el patron WWP (parent = instancia `WorkWithPlus<Trn>`), no artefactos internos. FIX: save_as LoadAuditPlaCue→LoadAuditPlaCueRec (clone fallo en Source, objecto parcial) + import_part de Source transformado (renames a PlaCueRec y borrado de 12 atributos/2 niveles inexistentes) + import_part de Variables (29). Despues: Build One del objeto Y **Build One de la transaccion llamadora PlaCueRec** (clave: el `_impl` viejo, generado con el objeto faltante, emitia llamados con buffers `GXv_char7` String[] que no tipan; al regenerar la transaccion salen tipados `execute("Y", GXv_SdtAuditingObject2, A37ORGCOD, ...)`). Archivos del fix: `C:\KBs\<KB_ACTUAL>\_tmp_gxmcp\` (borrables).
   - OJO MCP: para ESCRIBIR objetos el MCP anda bien; `genexus_lifecycle action=specify` funciona pero NO reescribe los .java generados; `action=build` crashea (el server espera SDK 18.0.10, instalado 18.0.9, drift en 17 DLLs). Para GENERAR: IDE (Build One).
   - La KB apunta a **DB2** (datastores Db2Universal, env Prototipo).
3. **Warning duplicado**: File objects `<LIB_CODIFICADOR>` y `CodeBarMuni.<LIB_CODIFICADOR>` copian ambos a `WEB-INF\lib\CodeBarGRB.jar` (mismo output dir). No bloquea; limpiar en KB (borrar el File duplicado o cambiar output).
4. **GAM warning**: "Trying to register permissions while Reorganize Server Tables property is set to NO" — si falla la creacion de permisos GAM, revisar esa propiedad / schema GAM.
5. Copias puntuales aparecieron a 16:36-17:14 sin log de build: archivos `placuerec*.java` regenerados fuera del Build All de las 14:49. Ojo con estado incremental inconsistente tras copiar archivos entre entornos.

## Licencias GeneXus (teoria y herramientas locales)

- Herramienta unica: **GeneXus License Manager** — en esta maquina: Start Menu > "GeneXus 18 License Manager" o `C:\Program Files (x86)\GeneXus\GeneXus18U09\GxLMgr.exe` (tambien Help > License Manager dentro del IDE).
- La licencia esta **activada por maquina** (registro + huella de hardware), no es un archivo copiable. Cada activacion consume una "copia" del cupo de la empresa.
- **Transferir** (mover la copia, sin tocar el cupo): Directa (misma red + GeneXus Protection Server en destino) o Remota (baile del archivo .trf: Register Transfer en destino > Transfer Out en origen > Transfer In en destino).
- **Autorizar** (pedir activacion nueva): Authorize Online (cuenta GeneXus) o Generate Authorization File + .gxa (sin internet, via distribuidor).
- **Desinstalar/liberar** (devolver la copia al cupo): License Manager > Uninstall (web con cuenta GeneXus, o .gxa por email al distribuidor).
- Esquema centralizado/concurrente: GeneXus Protection Server administra las copias para varias maquinas.

## Skills GeneXus instaladas en pi (`~/.pi/agent/skills/`)

Origen: `C:\KBs\<KB_SECUNDARIA>\genexus-skills-main` (repo oficial genexus-skills). Copiadas fuera de la KB para uso permanente:

- `nexa` — experto GeneXus: modelado de objetos y administracion de KB (con `references/` y delegacion de expertos).
- `ui-creator` — UI desde imagenes/OpenAPI a Angular/React.
- `chameleon-controls-library` — UI con componentes Chameleon (`ch-*`).
- `mercury-design-system` — estilos Mercury sobre Chameleon.
- `design-system-builder` — crea/evoluciona design systems CSS sobre Chameleon.
