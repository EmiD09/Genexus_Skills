# Entorno real — Municipalidad de Río Cuarto (valores por máquina/servidor)

> Estos son los valores **concretos** que en las skills genéricas aparecen como placeholders.
>Actualizado al validar el modelo físico GAM (2026-10). NO commitear credenciales acá
> (los users/keys cifrados viven en los `client.cfg` / `*.config` de cada instalación).

## KBs (Windows `C:\KBs\`, WSL `/mnt/c/Kbs/`)

| KB | GeneXus | Datastore DB | Generador / Env web | Deploy |
|---|---|---|---|---|
| **GamNucleo** | 18.0.9.182098 | IBM i (AS400) `jdbc:as400://172.17.0.6` — librería **GXDGAMRIV** (todo GAM: `ROLE`, `ROLEMEMROLE`, `USERMEMROLE`...) | Java (`Nucleo\web`, montado en `/mnt/c/Kbs/GamNucleo/Nucleo/web`) | gamdev: servidores del municipio |
| **GesMunRIV** | 18 | SQL Server localdb KB (`GX_KB_GesMunRIV.mdf`) + datastores DB2 iSeries (Db2Universal, env Prototipo) | Java Gradle en `Prototipo\web` | Tomcat 10.1: `webapps\GesMunRIVPrototipo` |
| **GX18_GesRec_Prd2026** | 18 | Comparte datastore con GesMun pero es una KB DISTINTA (namespaces incompatibles: no copiar código generado) | `JavaDB2iSeries002` | sector distinto |

## Servidores MCP activos

| Server | Cómo levanta | Uso |
|---|---|---|
| **genexus-mcp (npm) — el de uso diario** | WSL: `node ~/bin/gx-mcp-server-client.js &` (spawn `cmd.exe /c npx -y genexus-mcp@latest`) | Clientespersistentes vía `/tmp/gx-mcp-cmds/<id>.json` → `<id>.res.json` (`gx-call.sh`). Config server: `C:\Users\<USUARIO_WINDOWS>\.genexus-mcp\config.json` (RequirementPolicy via llamada: `genexus_kb open` + `set_default`) |
| **MCP oficial IDE GeneXus (`:1989`)** | Solo con GeneXus.exe abierto + MCP habilitado (Tools > Options) | Builds (`build_one`/`build_all`), import/export text, reorganize, run |
| GeneXus4Agents (`:19891`, tmux `gxagentbridge`) | `~/bin/gx-mcp-up.sh` | caso GamNucleo, a pedido |

## Conexión base GAM ( GamNucleo) — dato confirmado vía SQL

- Servidor DB2 for i: `172.17.0.6`; librería GAM: **`GXDGAMRIV`**.
- Consulta/verificación con ACS "Run SQL Scripts" (Query over `QSYS2.SYSTABLES`).
- Creador del esquema físico/queries: `skills/gam/references/data-model/domain-gam-db-schema.md`
  (usar ese doc con los valores de acá: donde dice `<GAM_LIB>` → `GXDGAMRIV`, `<AS400_HOST>` → `172.17.0.6`).

## Trámites operativos (org)

- Dominio de email: `@riocuarto.gov.ar`.
- Licencias GeneXus: GeneXus License Manager (`GxLMgr.exe`), activación por máquina,
  cupo de la empresa (Protection Server centralizado: ver `GesMunRIV-AGENTS.md`).
- Builds finales y deploys: los hace el user (regla global); nunca deploy a gamdev sin OK.
