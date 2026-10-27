<!-- GENERATED from catalog/properties/properties-environment-datastore.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: properties-environment-datastore
description: Configurable data store properties
---

Applies to: Backend DataStore block (#Backend DataStores) of an Environment deployment target file (*.env.gx)

# COMMON

## Access technology to set
Select the access technology for this Data Store
- Type: `enum{ADO.NET,JDBC,ODBC,Embedded SQL,iSeries Native,Ruby}`
- Options:
  - `ADO.NET`: Used by the .NET generator defined in the Environment
  - `JDBC`: Used by the Java generator defined in the Environment
  - `ODBC`: Used by the Visual FoxPro generator defined in the Environment
  - `Embedded SQL`: Embedded SQL access
  - `iSeries Native`: Used by RPG and Cobol generators defined in the Environment
  - `Ruby`: Used by the Ruby generator defined in the Environment (until GeneXus X Evolution 3)

## List of external stored procedures
Register external stored procedures
- Type: `string`

## Database Name
Set the database name (or library for iSeries)
- Type: `string`
- Scope: `.local` (goes to the local override file)

## Server Name
Set the database server host
- Type: `string`
- Scope: `.local` (goes to the local override file)

## Server TCP/IP port
Set the server port
- Type: `integer`

## Connect to server
Select connection mode to server
- Type: `enum{At first request,At application startup}`
- Options:
  - `At first request`: Connect after the first request to the server
  - `At application startup`: Connect during initialization before the main object is displayed

## Show connection dialog
Show the connection dialog
- Type: `enum{Never}`
- Options:
  - `Never`: Never show the dialog

## User Id
Set the database user
- Type: `string`
- Scope: `.local` (goes to the local override file)

## User Password
Set the database password
- Type: `string`
- Scope: `.local` (goes to the local override file)

## Additional connection string attributes
Add extra connection string attributes
- Type: `string`

## Use datasource for web-based applications
Use a datasource in web apps
- Type: `enum{True,False}`
- Options:
  - `True`: Use an application server JDBC Datasource
  - `False`: Use the standard JDBC connection

## Read Replica
Enable read replica usage
- Type: `boolean`

## Enable connection pooling
Enable connection pooling
- Type: `enum{True,False}`
- Options:
  - `True`: Enable GeneXus built-in connection pooling
  - `False`: Disable GeneXus built-in connection pooling

## Unlimited size
Allow unlimited pool size
- Type: `boolean`

## Recycle pool connections
Enable pool recycling
- Type: `boolean`

## Recycle type
Select recycling strategy
- Type: `enum{By creation time,By idle time}`
- Options:
  - `By creation time`: Recycle by creation time
  - `By idle time`: Recycle by idle time

## Recycle time (minutes)
Set recycle interval
- Type: `integer`

## Database schema
Set the default schema
- Type: `string`

## Primary key definition
Select primary key definition strategy
- Type: `enum{Primary Key,Index,Constraint}`
- Options:
  - `Primary Key`: Declare primary key using the PRIMARY KEY clause
  - `Index`: Declare primary key using a unique index
  - `Constraint`: Declare primary key using a CONSTRAINT clause

## Declare referential integrity
Generate referential integrity
- Type: `enum{Yes,No,Remove}`
- Options:
  - `Yes`: Declare all integrity references during creation/reorganization
  - `No`: Do not declare referential integrity
  - `Remove`: Remove integrity references for reorganized tables

## Default tables storage area
Set default table storage
- Type: `string`

## Default indices storage area
Set default index storage
- Type: `string`

## Default temporary storage area
Set default temp storage
- Type: `string`

## Generate COMMENT ON statements
Generate COMMENT ON statements
- Type: `boolean`

## Isolation level
Set the isolation level
- Type: `enum{Read Committed,Read Uncommitted,Repeatable Read,Serializable}`
- Options:
  - `Read Committed`: Use Read Committed
  - `Read Uncommitted`: Use Read Uncommitted
  - `Repeatable Read`: Use Repeatable Read
  - `Serializable`: Use Serializable

## Lock time-out (seconds)
Set lock timeout
- Type: `integer`

## Lock retry count
Set lock retry count
- Type: `integer`

# MYSQL SPECIFIC

## MySQL Version
Set the MySQL version for SQL generation
- Type: `enum{4.x to 5.0.2,5.0.3 to 5.7.6,5.7.7 to 5.7.23,8.x,9.x or higher}`
- Default: `9.x or higher`

# SQL SERVER SPECIFIC

## Connect using
Select the ODBC connection method
- Type: `string`

## Driver name
Set the ODBC driver name
- Type: `string`

## Server connection pooling
Configure connection pooling
- Type: `string`

## Size
Set max pool size
- Type: `integer`

## Create all pool connections at startup
Pre-create pool connections
- Type: `boolean`

## Show Connection Dialog in WinForms
Prompt for connection in WinForms
- Type: `boolean`

## Use trusted connection
Enable Windows authentication instead of using user/password. Only applicable for .NET environments with SQL Server data store
- Type: `boolean`
- Scope: `.local` (goes to the local override file)

## SQL server version
Set the SQL Server version for SQL generation
- Type: `enum{2012 or higher,2005 to 2008 R2}`

# POSTGRESQL SPECIFIC

## JDBC driver
Select the PostgreSQL JDBC driver
- Type: `enum{PostgreSQL JDBC Driver (Type 4),Custom Driver}`

## Use custom JDBC URL
Enable a custom JDBC URL
- Type: `boolean`
- Scope: `.local` (goes to the local override file)

## Custom JDBC URL
Custom JDBC URL
- Type: `string`
- Scope: `.local` (goes to the local override file)
Source listed this as a second 'Use custom JDBC URL'; renamed to the evident intent (the URL value paired with the boolean toggle)

## Show connection dialog in WinForms
Prompt for connection in WinForms
- Type: `boolean`

## PostgreSQL version
Set the PostgreSQL version for SQL generation
- Type: `enum{7.x,8.0,8.1 or 8.2,8.3 or higher}`

## PostgreSQL Extensions
Set enabled extensions
- Type: `string`

# ORACLE SPECIFIC

## Generate FOR UPDATE clause
Generate FOR UPDATE clause in SQL statements
- Type: `boolean`

## Declare Varchar as Varchar2
Use VARCHAR2 data type for VARCHAR
- Type: `enum{Yes,No}`
- Options:
  - `Yes`: Declare Varchar attributes as Varchar2
  - `No`: Declare Varchar attributes as Varchar

## Oracle version
Set the Oracle version for SQL generation
- Type: `enum{12c or higher,8.1.5 to 8.x.x,9 to 11g}`

# ISERIES SPECIFIC

## Initial catalog
Set the initial catalog
- Type: `string`

## Data library name
Set the data library name
- Type: `string`
- Scope: `.local` (goes to the local override file)

## Programs library name
Set the programs library name
- Type: `string`
- Scope: `.local` (goes to the local override file)

## Create save file
Configure save file creation
- Type: `string`

## Name of journal
Set the journal name
- Type: `string`

## Order attributes in file
Set attribute order in file
- Type: `string`

## Library list
Set the library list
- Type: `string`

## OS for iSeries version
Set the iSeries OS version for SQL generation
- Type: `string`

## Date data type definition
Set the date data type definition
- Type: `string`

# INFORMIX SPECIFIC

## Database type
Set the Informix database type
- Type: `string`

## Lock mode
Set the lock mode
- Type: `enum{Do not specify lock level,Use page level locking,Use row level locking}`
- Options:
  - `Do not specify lock level`: Do not generate a lock level clause
  - `Use page level locking`: Generate Lock Mode Page clause
  - `Use row level locking`: Generate Lock Mode Row clause

## Informix Version
Set the Informix version for SQL generation
- Type: `string`

# NOTES
Use this file to select editable properties, defaults, and valid options for a backend DataStore
from an Environment deployment target. Local-scoped values (scope ".local"), such as database
credentials and server names, must be written to the <name>.local.env.gx override file, never to
the main *.env.gx file.
The source type of "Show connection dialog" was wrapped in an "AUTO:" generation comment; the
marker was stripped, keeping the enum value (Never) verbatim.
The POSTGRESQL SPECIFIC category defines two properties with the same source heading
"Use custom JDBC URL": a boolean toggle ("Enable a custom JDBC URL") and a string holding the
custom JDBC URL itself; both are preserved verbatim from the source.
