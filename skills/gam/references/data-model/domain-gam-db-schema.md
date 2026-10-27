- description: GAM physical database — schema, connection discovery, and ready-to-run SQL (role hierarchy, users, permissions). Trigger: consultas SQL sobre la base de GAM, ROLEMEMROLE, jerarquía de roles, verificar roles/padres/hijos/usuarios por SQL, descubrir conexión del datastore GAM, esquema físico de tablas GAM.

# Modelo físico de la base de datos GAM (schema + SQL)

> Verificado en producción (Octubre 2026): GAM 18 U9 sobre IBM i (AS400), librería `<GAM_LIB>` (nombre real omitido del repo), generador Java.
> Las tablas se consolidan mejor consultando el catálogo que confiando en nombres de memoria: el nombre físico varía entre versiones de GAM y entre DBMS.

## 1) Cómo descubrir la CONEXIÓN del datastore GAM

La connection de la app a la base GAM vive en la config del build de la aplicación (no en la KB):

- **Java** (generator Java): `<KB>/<Modelo>/web/build/classes/java/main/<namespace>/client.cfg` — sección `[<namespace>|GAM]` con `CS_DBNAME`, `DB_URL`, `JDBC_DRIVER`, `DBMS`, `USER_ID`/`USER_PASSWORD` (cifrados). Ejemplo real: `<KB>\<ModeloWeb>\web\build\classes\java\main\<namespace>\client.cfg`.
- **.NET**: `web.config` de la carpeta `web` del target (connectionStrings del datastore GAM).

Claves del caso real verificado: `DBMS=as400`, `DB_URL=jdbc:as400://<AS400_HOST>`, `CS_DBNAME=<GAM_LIB>`          # nombre de la librería IBM i donde vive GAM entera → la base GAM entera es la **librería IBM i `<GAM_LIB>`** (en IBM i "librería" = schema).

## 2) Descubrir el esquema físico (IBM i / DB2 for i)

```sql
-- Todas las tablas del esquema GAM (con descripción)
SELECT TABLE_NAME, TABLE_TEXT
FROM   QSYS2.SYSTABLES
WHERE  TABLE_SCHEMA = '<librería>'          -- p.ej. '<GAM_LIB>'
ORDER  BY TABLE_NAME;
```

```sql
-- Solo lo relacionado a roles
SELECT TABLE_NAME, TABLE_TEXT
FROM   QSYS2.SYSTABLES
WHERE  TABLE_SCHEMA = '<librería>'
AND    UPPER(TABLE_NAME) LIKE '%ROLE%';
```

```sql
-- Columnas de una tabla (para armar queries exactas)
SELECT COLUMN_NAME, ORDINAL_POSITION
FROM   QSYS2.SYSCOLUMNS
WHERE  TABLE_SCHEMA = '<librería>'
AND    TABLE_NAME = '<tabla>'
ORDER  BY ORDINAL_POSITION;
```

En SQL Server (GAM sobre MSSQL) los equivalentes: `sys.tables LIKE '%Role%'` + `INFORMATION_SCHEMA.COLUMNS`.

## 3) Tablas confirmadas (GAM 18 U9 / IBM i, caso verificado)

Todas llevan `REPID` (repository id) como parte de la clave lógica y, en las de relación, audit columns (`...CREDATE`, `...CREUSER`, `...UPDDATE`, `...UPDUSER`).

| Tabla | Roll | Columnas clave |
|---|---|---|
| `ROLE` | Definición de rol | `REPID`, `ROLEID`, `ROLEEXTID`, `ROLESECPOLID`, `ROLEGUID`, `ROLENAME`, `ROLEDSC`, fechas/audit |
| `ROLELNG` | Traducciones del rol | `REPID`, `ROLEID`, `ROLELNGID`, `ROLENAMELNG`, `ROLEDSCSCLNG` |
| `ROLEPROP` | Propiedades OAV extendidas del rol | `REPID`, `ROLEID`, `ROLEPROPID`, `ROLEPROPTOKEN`, `ROLEPROPVALUE` |
| **`ROLEMEMROLE`** | **Jerarquía de roles (padre→hijo)** | `REPID`, **`ROLEMEMROLEPARENT`** (id rol padre), **`ROLEMEMROLECHILD`** (id rol hijo), audit |
| `USERMEMROLE` | Usuario ↔ rol | `USERGUID`, `REPID`, `USERMEMROLERROLEID`, audit |
| `USERREPOSITORY` | Usuario en repositorio | `USERGUID`, `REPID`, `USERREPMAINROLEID`, `USERREPSECPOLID`, `USERREPRECPWDANS`, ... |
| `APPPRMMEMPRM` | Agrupación de permisos (jerarquía permisos) | `REPID`, `APPID`, `APPPRMMEMPRMPARENT`, `APPPRMMEMPRMCHILD`, audit |
| `LIMITS`-style tabla `APPTYPEPERMISSION` | Permisos por tipo de app | `REPID`, `APPTYPEID`, `APPTYPEPRMID`, `APPTYPEPRMGUID`, `APPTYPEPRMISPARENT`, ... |
| `SECURITYPOLICYLNG` / `SECURITYPOLICYPROP` | policies (traducciones / OAV) | `REPID`, `SECPOLID`, `SECPOLLNGID` / `SECPOLPROPTOKEN`/`VALUE` |

También visibles en el diagrama (no necesariamente verificadas columna por columna): `REPOSITORY`, `SESSIONLOG*`, `GAMEVENT*`, `APP*` (OAuth auth requests `APPAUTHREQ`, roles de aplicación `APPROLE`), tablas `SYS*` del catálogo GeneXus.

## 4) Semántica que hay que saber antes de armar queries

1. **Jerarquía = tabla de membresías**, no columna `ParentId` en `ROLE`: un vínculo padre→hijo es una fila en `ROLEMEMROLE`. Un rol puede tener varios padres (fila por padre) y varios hijos.
2. **Dirección de la herencia (GAM docs)**: "if the role has children, the permissions of the child roles are also associated with the user" → el **padre hereda los permisos de sus hijos**. Un usuario del rol padre obtiene todo lo de sus roles hijos.
3. `GAMRole.GetChildren` ≡ filas de `ROLEMEMROLE` con `ROLEMEMROLEPARENT = id_del_rol`. **No existe `GetParent` en el EO GAMRole** (GAM 18 U9): para "padres de X" hay que recorrer los roles o cruzar `ROLEMEMROLE` (o el patrón usado en la KB donde se implementó: proc `GAMGetParentsOfRole` que inverse-scanea `GetRoles` + `GetChildren`).
4. Roles **sin `ROLENAME`** aparecen en la API/backoffice como **"Unknown"** (vío real: roles "copia"/test quedaron sin nombre). Los listados de herencia los van a traer si la relación existe.
5. `ROLEID` es numérico (GOB 12?). El `GAMRole.Id` de la API corresponde a `ROLEID`; los guides por GUID se hacen contra `ROLEGUID`.

## 5) Queries listas (IBM i; para SQL Server cambiar `<GAM_LIB>.<t>` por `dbo.<t>`)

### Padres de un rol (0 filas = rol raíz)

```sql
SELECT p.ROLENAME AS Padre
FROM   <lib>.ROLEMEMROLE h
JOIN   <lib>.ROLE p ON p.ROLEID = h.ROLEMEMROLEPARENT AND p.REPID = h.REPID
JOIN   <lib>.ROLE c ON c.ROLEID = h.ROLEMEMROLECHILD AND c.REPID = h.REPID
WHERE  c.ROLENAME = '<nombre del rol>'
ORDER  BY p.ROLENAME;
```

### Hijos de un rol

```sql
SELECT c.ROLENAME AS Hijo
FROM   <lib>.ROLEMEMROLE h
JOIN   <lib>.ROLE c ON c.ROLEID = h.ROLEMEMROLECHILD AND c.REPID = h.REPID
WHERE  h.ROLEMEMROLEPARENT = (SELECT ROLEID FROM <lib>.ROLE WHERE ROLENAME = '<nombre del rol>' AND REPID = h.REPID)
ORDER  BY c.ROLENAME;
```

### Mapa completo de la jerarquía (padre NULL = raíz)

```sql
SELECT c.ROLENAME AS Rol, p.ROLENAME AS Padre
FROM   <lib>.ROLE c
LEFT   JOIN <lib>.ROLEMEMROLE h ON h.ROLEMEMROLECHILD = c.ROLEID AND h.REPID = c.REPID
LEFT   JOIN <lib>.ROLE p ON p.ROLEID = h.ROLEMEMROLEPARENT AND p.REPID = c.REPID
ORDER  BY c.ROLENAME;
```
(Si la library sirve varios repositorios: `WHERE c.REPID = <valor>`; descubrir con `SELECT DISTINCT REPID FROM <lib>.ROLE`.)

### Roles de un usuario (el nombre de la tabla de usuarios se resuelve con el paso 2: `LIKE '%USER%'`; el GUID del user va por `USERMEMROLE.USERGUID`)

```sql
SELECT r.ROLENAME AS Rol
FROM   <lib>.USERMEMROLE ur
JOIN   <lib>.ROLE r ON r.ROLEID = ur.USERMEMROLERROLEID AND r.REPID = ur.REPID
WHERE  ur.USERGUID = '<guid del usuario>'
UNION
SELECT p.ROLENAME AS Rol   -- padres (permisos heredados)
FROM   <lib>.USERMEMROLE ur
JOIN   <lib>.ROLEMEMROLE h ON h.ROLEMEMROLECHILD = ur.USERMEMROLERROLEID AND h.REPID = ur.REPID
JOIN   <lib>.ROLE p ON p.ROLEID = h.ROLEMEMROLEPARENT AND p.REPID = ur.REPID
WHERE  ur.USERGUID = '<guid del usuarios>';
```

## 6) Verificación cruzada pantalla↔DB (flujos ya validados en la KB de GAM)

- Pantalla `GAMWWRoles` → hijos de un rol (`GAMWWRoleRoles` con `GetChildren`) ≡ query "Hijos".
- Botón "Padres" (proc `GAMGetParentsOfRole` + 3er parm `&ShowParents` en `GAMWWRoleRoles`) ≡ query "Padres".
- Verificado con resultados idénticos para: `Calles - Consulta` (4 padres), `Calles - Control Total` (3 padres).

## 7) Gotchas

- El nombre real de la tabla de relación cambió de nombre entre versiones de GAM en el pasado (en otra instancia podría no ser `ROLEMEMROLE`): SIEMPRE confirmar con el paso 2 antes de responder por escritura.
- En IBM i los nombres largos (p.ej. `ROLEMEMROLEPARENT`) son *SQL names*; vía system naming el límite es 10 chars — usar SQL naming (ACS "Run SQL Scripts", DBeaver con `jdbc:as400://host`).
- `USER_GUID`+`REPID` también van por clave en tablas de sesión/props: cruzar siempre por REPID si la instancia comparte DB entre repositorios.
- Permisos de usuario sobre tablas QSYS2/`<lib>`: pedir acceso de *read* al DBA; el user del app (`USER_ID` cifrado en client.cfg) puede no tener SQL directo desde ACS.
