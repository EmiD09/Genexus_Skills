# Reglas globales de trabajo (todos los proyectos)

> Fuente viva de reglas acordadas con el usuario. Agregar nuevas reglas aquí a medida que se pacten.

## Alcance y permisos

- **Proyectos iniciados** (especialmente KBs GeneXus): tocar SOLO lo requerido por el pedido/ticket. Si hay que modificar algo más, avisar ANTES o dejar que lo haga el usuario manualmente. En proyectos propios de cero, libertad razonable.
- **Builds finales**: los hace el usuario si lo prefiere ("sino hago el build yo"). No forzar builds completos sin pedirlo.
- Nunca commitear destruir o revertir trabajo del usuario sin confirmación explícita.
- Nunca inventar valores de negocio: en llamadas, parámetros y configuraciones, copiar la convención del código existente (llamadores reales) o preguntar.

## Manejo de sesiones y tokens

- **Freno y replanteo**: cuando un mismo enfoque acumula 2-3 fallas/timeout seguidos, o el contexto crece rápido sin resolver el core, DETENERSE: diagnosticar en pocas líneas, proponer 2-3 alternativas con costo estimado (incluida postergar), y pedir decisión al usuario. No seguir remando en fricción.
- **No repetir lo mismo** (pactado 2026-10-26, ticket 584): al 2º fallo del MISMO error, no reintentar variantes cosméticas del mismo mecanismo — evitar alternar por otra vía o investigar la causa raíz en docs/código del proyecto; al 3º fallo del mismo patrón, consultar al usuario con opciones y costo antes de seguir.
- Al pausar una tarea: dejar feature doc actualizado (estado, decisiones, plan de reanudación), guardar memoria, y no dejar nada a medio escribir en la KB/repo.
- Background jobs: registrarlos y detenerlos limpiamente al cerrar sesión (job_stop).

## Tecnología GeneXus

- Consultar la skill correspondiente antes de trabajar: `genexus-migracion-k2b-a-wwp` en cualquier KB con WWP, `nexa`/`gx-kb`/`gx-authoring`/`k2btools-ui`/`gam` según el tema.
- Los patrones WWP se editan vía **PatternInstance** (XML del host `WorkWithPlus<X>` con `genexus_edit part=PatternInstance`); el patrón gana y restaura — no tocar el WebForm a mano donde exista instancia.
- WEB UI GeneXus con K2BTools instalado: seguir skill `k2btools-ui` (prioridad sobre genérica).

## Protocolo de sesión

- Al reiniciar: buscar memoria con `mem_search` (match_mode=any si falla el default), leer feature docs en `odd/tasks/` y reconciliar antes de continuar.
- Reglas específicas de cada KB/repo viven en el `AGENTS.md` de cada proyecto, no acá.
