# Reglas de trabajo — KB GamNucleo (GeneXus 18, GAM)

## Trabajo hecho y pautas

- **Ticket 631 (completo)**: `GAMAltaUsuarioSoporte` (Root Module/Sistema) — alta de usuarios GAM con rol "Soporte al Usuario" (147), accesible sin login. Vars tipo GAM (`GeneXusSecurityCommon.*`/`GeneXusSecurity.*`), Source con validaciones (obligatorios, PChkCUIT, dominio `@riocuarto.gov.ar`, passwords coinciden), alta `GAMUser.Save()+Commit` + `AddRoleById(147)`. MasterPage=MasterPageGamNucleo, IntegratedSecurityLevel=None.
- Checks Activo/PwdNuncaExpira resueltos **hardcodeados True** en Enter; `&Usuario = str(&CUIT, 11)` internamente post-PChkCUIT, sin validación visual de Usuario.
- Sin email de credenciales en el alta (fuera de alcance del ticket).
- **LoginRioIV NO tocar**: revertido y limpio (hash original `d8e7b3bca91b...`); el enlace en el login lo hace el usuario.
- Patrón WWP: instancia `WorkWithPlusGAMAltaUsuarioSoporte` refleja el estado final (CUIT/Apellido/Nombre/EMail/Password/PasswordConf/TBPwdRequirements; sin checks ni &Usuario).

## Instrumentación

- Git inicializado (snapshot `5048b9f` en main, identity local `EmiD09 <emid09@users.noreply.github.com>`). Backups/commits antes de editar objetos de la KB.
- ToolProfile `"all"` en el `config.json` DE LA KB para exponer tools de patrón WWP.
- Server oficial MCP `:1989` (`GeneXus.PIA.McpServer`); reabrir KB con `genexus_kb action=open path=C:\KBs\GamNucleo` + `set_default alias=gamnucleo` si rota sesión.
- GeneXus4Agents: server `:19891` + bridge tmux `gxagentbridge` (`~/bin/gx-agents-bridge.js`), integrado a `~/bin/gx-mcp-up.sh`. GX17 (gateway :5001/bridge :5101) solo a pedido, fuera de la cadena base.
