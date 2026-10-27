# Proyecto: Municipalidad de Río Cuarto (GeneXus)

> **Cuándo cargar esta carpeta:** SOLO si trabajás con las KBs de la Municipalidad de
> Río Cuarto. Si trabajás con GeneXus en otra organización, **ignorala por completo** —
> todo lo genérico está en `skills/`, `bin/`, `docs/` y `AGENTS.md` (raíz).

## Qué hay acá

| Archivo | Qué es |
|---|---|
| `kbs/GamNucleo-AGENTS.md` | Reglas de trabajo de la KB **GamNucleo** (GeneXus 18, GAM): tickets cerrados, convenciones, instrumentación, servidores MCP, estado. Es el copia del `AGENTS.md` vivo de la KB (fuente de verdad: la KB, no acá). |
| `kbs/GesMunRIV-AGENTS.md` | Reglas de la KB **GesMunRIV** (GeneXus 18, WWP + K2B): contexto de negocio (org/ejercicio/CUIT), operación del MCP, licencias. Copia del `AGENTS.md` vivo de la KB. |
| `entorno.md` | **Valores reales por máquina/servidor** de esta org: paths de KBs, servers, conexiones a datos, modelo de build, deploys. Los valores concretos que en las skills genéricas son `<placeholders>`. |

## Orden de lectura recomendado (agente trabajando con la muni)

1. `AGENTS.md` (raíz del repo) — reglas de trabajo globales y conexión MCP.
2. Este README → elegir la KB.
3. `kbs/<KB>-AGENTS.md` — REGLAS de esa KB (tocar solo lo pedido, no deploys sin OK, etc.).
4. `entorno.md` — valores concretos (paths, servidores, bases).
5. Skills genéricas según el tema (`gam`, `genexus-migracion-k2b-a-wwp`, `k2btools-ui`, …).

## Importante

- Estas KBs comparten la infraestructura de la org: **no copiar código generado entre KBs**
  (namespaces incompatibles) y **no tocar objetos fuera del scope del ticket**.
- Si el repo llega a usuarios FUERA de la municipalidad: esta carpeta debe **desgajarse a un
  repo privado** (contiene topología interna y reglas de negocio de la org). Lo genérico del
  kit está pensado para compartirse; lo de acá, no.
