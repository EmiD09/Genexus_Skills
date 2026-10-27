<!-- GENERATED from catalog/properties/properties-object-structured-data-type.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: properties-object-structured-data-type
description: Configurable structured data type properties
---

Applies to: Structured Data Type objects and their items ([object-structured-data-type](./object-structured-data-type.md))

# GENERAL
Includes [properties-common](./properties-common.md).

## Exposed name
Name exposed to external interfaces
- Type: `string`

## Exposed namespace
Namespace exposed to external interfaces
- Type: `string`

## Json Input Format
Input JSON wrapping strategy for services
- Type: `enum{Wrapped,Unwrapped}`
- Options:
  - `Wrapped`: Includes wrapper/root element in serialized output
  - `Unwrapped`: Omits wrapper/root element in serialized output
- Default: `Wrapped`

## IsSapParameter
Mark object as SAP parameter
- Type: `boolean`
- Default: `false`

## Dynamic structure
Allows dynamic member structure at runtime
- Type: `boolean`
- Default: `false`

# SDT ITEM GENERAL

## Title
Label shown in generated UI and tooling
- Type: `string`

## Column title
Column header shown in tabular UI
- Type: `string`

## ContextualTitle
Context-aware label shown in UI
- Type: `string`

## Formula
Expression used to calculate the value
- Type: `string`

## AllowNull
Allow null value
- Type: `boolean`
- Default: `false`

## EmptyAsNull
Define empty to null behavior
- Type: `enum{No Nulls,Empty as Null,Blank as Null,Compatible}`
- Options:
  - `No Nulls`: Keeps empty values as non-null values
  - `Empty as Null`: Converts empty input values to null
  - `Blank as Null`: Converts blank-only input values to null
  - `Compatible`: Uses legacy-compatible null handling behavior

## Class
Theme class applied to rendering
- Type: `string`

# SDT ITEM TYPE

## Supertype
Type selector that controls generation behavior
- Type: `string`

## Based on
Base attribute or domain used for definition
- Type: `string`

## Data Type
Logical type used for storage and validation
- Type: `string`

## Length
Maximum length for character or numeric values
- Type: `integer`
- Default: `4`

## Decimals
Decimal precision for numeric values
- Type: `integer`
- Default: `0`

## Signed
Allows negative numeric values
- Type: `boolean`
- Default: `false`

## Autonumber
Enables automatic sequential value generation
- Type: `boolean`

## Autonumber start
Initial value used by autonumber sequence
- Type: `integer`

## Autonumber step
Increment used by autonumber sequence
- Type: `integer`

## Autonumber for replication
Replicates autonumber values across environments
- Type: `boolean`
- Default: `true`

## Rows
Number of rows used by matrix or multiline controls
- Type: `integer`
- Default: `3`

## Initial value
Value assigned when no explicit value is provided
- Type: `string`

# SDT ITEM VALIDATION

## Value range
Allowed value interval for validation
- Type: `string`

## Validation Failed Message
Message shown when validation fails
- Type: `string`

# SDT ITEM PICTURE

## Left fill
Padding strategy applied to numeric formatting
- Type: `enum{Blank,Zero,Blank when Zero}`
- Options:
  - `Blank`: Pads unused leading positions with blanks
  - `Zero`: Pads unused leading positions with zeros
  - `Blank when Zero`: Uses blanks when the numeric value is zero
- Default: `Blank`

## Thousand separator
Displays group separator in numeric formatting
- Type: `boolean`
- Default: `false`

## Prefix
Static prefix added in formatted output
- Type: `string`

## Picture
Format mask used for display and parsing
- Type: `string`

# SDT ITEM CONTROL

## ControlType
UI control used to edit or display the value
- Type: `enum{Combo Box,Radio Button,Edit,Check Box,Dynamic Combo Box,List Box,Dynamic List Box,Image}`
- Options:
  - `Combo Box`: Renders a drop-down selector with fixed values
  - `Radio Button`: Renders mutually exclusive options as radio buttons
  - `Edit`: Renders a standard editable input field
  - `Check Box`: Renders a boolean value as a checkbox
  - `Dynamic Combo Box`: Renders a drop-down selector loaded dynamically
  - `List Box`: Renders a visible list selector with fixed values
  - `Dynamic List Box`: Renders a visible list selector loaded dynamically
  - `Image`: Renders the value as an image
- Default: `Edit`

## NotifyContextChange
Raises context-change notification for control updates
- Type: `boolean`

# SDT ITEM BEHAVIOR

## InputHistory
Enables device input history suggestions
- Type: `boolean`
- Default: `false`

## IsPassword
Masks text input as password
- Type: `boolean`

# SDT ITEM APPEARANCE

## AutoResize
Adjusts control size automatically to content
- Type: `boolean`

## Width
Width assigned to rendered control
- Type: `string`

## Height
Height assigned to rendered control
- Type: `string`

## Fill
Expands control to fill available layout space
- Type: `boolean`
- Default: `true`

## BackColor
Background color applied to the control
- Type: `string`

## ForeColor
Foreground/text color applied to the control
- Type: `string`

## Font
Font family and style used for rendering
- Type: `string`

## HorizontalAlignment
Horizontal alignment used for displayed text
- Type: `enum{Left,Center,Right}`
- Options:
  - `Left`: Aligns content to the left
  - `Center`: Centers content horizontally
  - `Right`: Aligns content to the right
- Default: `Left`

## Format
Text rendering format mode in UI
- Type: `enum{Text,HTML,Raw HTML,Text with meaningful spaces}`
- Options:
  - `Text`: Renders content as plain text
  - `HTML`: Renders content as HTML with formatting support
  - `Raw HTML`: Outputs HTML without escaping or additional processing
  - `Text with meaningful spaces`: Preserves spaces and line breaks in rendered text

## TooltipText
Help text shown on hover or focus
- Type: `string`

## InviteMessage
Prompt text shown before user input
- Type: `string`

# SDT ITEM INTERFACE

## External Name
External parameter name used when the SDT item is exposed in services
- Type: `string`

## Required
Marks the service parameter as mandatory
- Type: `boolean`
- Default: `false`

# NOTES
Categories prefixed "SDT ITEM" apply to individual items (members/fields) inside the SDT structure, not to the SDT object itself.
