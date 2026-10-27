# WWP oficial para agentes (para qué mirar cuando se instale GeneXus for Agents)

Fuente: docs.workwithplus.com (consultas 2026-10-14).

## Estado en esta máquina (2026-10-14)

- GeneXus 18 IDE con WWP **15.3.7** (la KB de GAM) — escucha el MCP oficial del
  IDE en :1989, pero NO tiene instalado el setup "WorkWithPlus for Agents".
- Las herramientas WWP que expone genexus-mcp v3.15 (`genexus_wwp`,
  `genexus_apply_pattern`, `genexus_layout`, `genexus_refactor`, y el perfil
  `ToolProfile: "all"` sobre el `config.json` de la KB) cubren: crear/aplicar
  instancias, ediciones tipadas (acciones/tabs/grids), lectura de layout con
  `stats`, diagnóstico del patrón.
- La **skill oficial de WWP** no viene instalada: viene con el setup
  "WorkWithPlus for Agents" del developer center
  (https://developer.workwithplus.com/, requiere licencia WWP al dia).
  El tool oficial `wwp_is_available` la reporta y devuelve el path local
  para copiarla al directory de skills del agente.

## Referencias oficiales

| Pagina | Donde |
|---|---|
| Marco "GeneXus for Agents" | https://docs.genexus.com/en/wiki?61619,GeneXus+for+Agents, |
| WWP for Agents (TOC) | https://docs.workwithplus.com/wiki?5686,Toc:WorkWithPlus+for+Agents, |
| WWP Agents Install | https://docs.workwithplus.com/wiki?5728,WorkWithPlus+Agents+Install, |
| WWP Agents Getting Started | https://docs.workwithplus.com/wiki?5731,WorkWithPlus+Agents+Getting+Started, |
| WorkWithPlus AI Module (features AI dentro del producto) | https://docs.workwithplus.com/wiki?4972,Toc:WorkWithPlus+AI+Module, |
| Trouble de la sensacion | https://docs.workwithplus.com/wiki?5732,WorkWithPlus+Agents+Troubleshooting, |

## Cuando GeneXus for Agents este instalado

1. Con la KB abierta, preguntar al agente:
   "Is the WorkWithPlus skill available to work on this KB?"
   (usa el tool `wwp_is_available`).
2. Si no esta: pedir "Please install the WorkWithPlus skill" — el agente copia
   la skill del path que devuelve el tool, aprobar el copiado y **reiniciar
   el agente**.
3. A partir de ahi, prompts naturales: "_Create the WorkWithPlus instance of
   transaction X from the 'Cards' template_", "_Apply the 'View with tabs'
   template to the View of X_", "_Initialize the Design System 'Arno'_".

## Relacion con esta skill

Esta skill complementa (no reemplaza) la oficial: la oficial trae el
conocimiento canonico de templates/propiedades valido para GeneXus for
Agents; esta skill trae el conocimiento empirico de extrema-de-verdad
(trampas del MCP, orden de proyeccion, tools con perfil all) que vale
tambien sin GeneXus for Agents instalado.
