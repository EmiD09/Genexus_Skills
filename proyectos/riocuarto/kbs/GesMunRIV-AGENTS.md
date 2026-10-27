# Reglas de trabajo — KB GesMunRIV (GeneXus 18, WWP + K2B)

## Contexto de negocio

- **Convenio de contexto estándar** (hallado en WClaPrgPry y otros WWP): `&OrgCod = 2` + `PEjeCodForEJE(&OrgCod, &EJECOD)` para obtener el ejercicio vigente. Los paneles WWP Sel/WW se invocan con estos valores de contexto.
- **&CUIT**: tipo `NUMERIC(13)`; validación con `PChkCUIT.Call(&x,&resp)` que devuelve 'S'/'N'.
- Dominio de email del municipio: `@riocuarto.gov.ar`.

## Operación del server MCP oficial (:1989)

- **NO export full de la KB** (`names=["[all]"]`): cuelga el server `GeneXus.PIA.McpServer.exe` y hay que reiniciarlo. Exportar por objeto o por tipo (`webpanel:*`), y el export puede seguir corriendo en background aunque la llamada MCP timeoutee.
- **NO grep masivo** sobre `src/` exportado (10k+ archivos, >60s por pasada). Para encontrar llamadores: `genexus_inspect include=callers` (rápido, ~1-2s por objeto) y luego `genexus_read part=source` acotado con offset/limit.
- `genexus_search_source` full-KB satura el worker (single-thread, un SDK op a la vez); para desatascar: matar `GxMcp.Worker` o esperar el op. Ajustar wait con `GXMCP_BUSY_WAIT_MS`.
- Si el server rota sesiones: reabrir con `genexus_kb action=open path=C:\KBs\GesMunRIV` + `set_default alias=gesmunriv`.
- ToolProfile `"all"` en el `config.json` DE LA KB (no `~/.genexus-mcp`) para exponer tools de patrón WWP.

## Trabajo en curso

- Ticket 626: patch de `ListWWPPrograms` (Root Module/WWPBaseObjects) para quitar ~68 warnings `spc0024`. Estado y plan en `odd/tasks/listwwpprograms-parms.md`; firmas de los paneles en `odd/tasks/listwwpprograms-signatures.txt`. Política decidida: copiar valores de llamadores existentes (no neutros, no quitar entries).
