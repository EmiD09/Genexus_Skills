# Feature: kit completo de skills + tools + manual IA en Genexus_Skills

## Specs
S1 (pedido verbatim): "con un repositorio de git guardar todo lo que sea genexus, mcp conexiones, skills y todo lo aprendio para que puedan descargar el repositorio e instalar todo"
S2 (custom del user): "antes de subir todo, fijemosnos que todo quede bien para que lo puedan utilizar facilmente, tal vez crear un manual para que la IA que tome el repo sepa que hacer"
S3: Incluir TODAS las skills (11): gam, gx-authoring, gx-kb, k2btools-ui, nexa, genexus-migracion-k2b-a-wwp, genexus-entorno-local, chameleon-controls-library, design-system-builder, mercury-design-system, ui-creator.
S4: genexus-entorno-local se sube ANONIMIZADA (KBs, IPs, hostnames, usuarios reales → placeholders; valores reales quedan fuera del repo).
S5: El push a GitHub se hace solo tras revisión del user (esta pasada: commit local).
S6 (L3+L4): separar lo genérico-GeneXus de lo específico-de-organización. CIERRE FINAL (L4): lo específico sale del kit y vive en un REPO PRIVADO aparte (`~/genexus-riocuarto`): `AGENTS.md`/README del kit quedan 100% genéricos con placeholders; el repo org lleva README (cuándo cargarlo), kbs/*-AGENTS.md con las reglas reales por KB y entorno.md con los valores concretos.

## Tasks
- T8 (S6): proyectos/riocuarto/ (README routing + advertencia de desgajar fuera de la org; kbs/GamNucleo-AGENTS.md y kbs/GesMunRIV-AGENTS.md copias reales; entorno.md con valores concretos: servidor BX i, librería GAM, servers MCP, build/deploy) + regla de separación genérico↔org en AGENTS.md y README. Commit: pendiente
- T1 (S3): sincronizar las 11 skills completas desde ~/.pi/agent/skills → repo skills/ (incluye cambios sin commitear de migracion-k2b-a-wwp). Commit: pendiente
- T2 (S4): anonimizar skills/genexus-entorno-local con placeholders + ejemplo de conf por máquina fuera del repo. Commit: pendiente
- T3 (S1): traer /home/emi/bin/{gx-mcp-server-client.js,gx-call.sh,gx-http-call.sh,gx-mcp-call.js} → repo bin/ (genericos, sin datos de KB). Commit: pendiente
- T4 (S1): conf/ → reglas globales de trabajo como ejemplo (no datos privados) + documentar dónde instala cada pieza. Commit: pendiente
- T5 (S2): AGENTS.md en raíz del repo: manual operativo para la IA que tome el repo (estructura, routing de skills, uso del cliente MCP persistente, reglas de KBs). Commit: pendiente
- T6 (S2): README.md humano + install.sh (clonar → skills a ~/.pi/agent/skills, bin a ~/bin, AGENTS.md opcional, verificacion) . Commit: pendiente
- T7 (S5): revisión integral de estructura + commit final; push tras OK del user. Commit: pendiente

## Log
- L1 (2026-10-27, user): "te iba a pedir de... vamos a trabajar con gesmun ... vamos a salir de las kb, creo que teniamos un repositorio con todo las skills y todo lo de genexus sino me equivoco, lo que estoy pensando hacer es con un repositorio de git guardar todo lo que sea genexus, mcp conexiones, skills y todo lo aprendio para que puedan descargar el repositorio e instalar todo" → feature autorizado, en curso.
- L2 (2026-10-27, user): respuestas del cuestionario — skills: todas (11); entorno-local: anonimizar; entrega: "antes de subir todo, fijemosnos que todo quede bien para que lo puedan utilizar facilmente, tal vez crear un manual para que la IA que tome el repo sepa que hacer" → push diferido tras revisión; manual para IA como entregable clave.

- L3 (2026-10-27, user): "hay cosas que son especificas para este proyecto y otras para trabajar con genexus, habria que separar eso... porque hay muchos proyectos en esta empresa y capaz que alguien mas me pide el repositorio" → creada la capa proyectos/riocuarto/ (S6/T8); skills quedan genéricas con placeholders.

- L4 (2026-10-27, user): lo riocuarto mejor en otro repositorio — si alguien lo necesita se lo pasa, sino trabaja con el básico. → específico extraído a repo privado ~/genexus-riocuarto (commit 21b74ff, sin remote); kit principal 100% genérico.
