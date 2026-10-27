<!-- GENERATED from catalog/language/lang-data-picture.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: lang-data-picture
description: Formatting mini-language for configuring the Picture property
---

Defines how values are displayed using format tokens

---

# TOKENS
- `9`: Mandatory digit (0-9)
- `Z`: Suppresses leading zeros
- `#`: Suppresses insignificant zeros
- `?`: Suppresses insignificant zeros but keeps alignment with spaces
- `.`: Decimal separator character
- `,`: Thousands separator character
- `X`: Represents any character
- `!`: Single uppercase character
- `+`: Always show sign (+ or -)
- `@!`: Whole field forced to uppercase
- `()`: Show negatives in parentheses

---

# GRAMMAR
~~~
Picture ::= NumericMask | StringMask | DateTimeMask | DateOnlyMask | TimeOnlyMask

NumericMask  ::= [ AnyLiteral ' ' ] SignNumPart
StringMask   ::= [ '@!' ] StringChar
DateTimeMask ::= DateMask TimeMask
DateOnlyMask ::= YearFirst | YearFinal
TimeOnlyMask ::= TwoDigits [ ':' TwoDigits ] [ ':' TwoDigits ]

SignNumPart  ::= [ '+' ] NumericPart | '(' NumericPart ')'
NumericPart  ::= IntegerPart [ '.' DecimalPart ]
IntegerPart  ::= MaskAlternatives DigitMask | IntegerPart [ ',' ThreeDigits ]
DecimalPart  ::= DigitMask MaskAlternatives

StringChar   ::= ε | StringChar StringPart
StringPart   ::= 'X' | '!' | AnyLiteral

YearFirst    ::= YearPart '/' TwoDigits '/' TwoDigits | YearPart '-' TwoDigits '-' TwoDigits
YearFinal    ::= TwoDigits '/' TwoDigits '/' YearPart | TwoDigits '-' TwoDigits '-' YearPart
YearPart     ::= TwoDigits | FourDigits

TwoDigits    ::= DigitMask DigitMask
ThreeDigits  ::= DigitMask DigitMask DigitMask
FourDigits   ::= DigitMask DigitMask DigitMask DigitMask

MaskAlternatives ::= BlankMask | StripMask | FixedMask

DigitMask    ::= '9'
BlankMask    ::= BlankMask 'Z' | 'Z'
StripMask    ::= StripMask '#' | '#'
FixedMask    ::= FixedMask '9' | '9'

AnyLiteral   ::= any literal character (rendered verbatim in output)
~~~

---

# EXAMPLES
Numeric:
- `ZZZZ99.9`: Value `5` displays as `05.0`
- `(ZZ99.9)`: Value `-12` displays as `(12)`
- `+ZZZZ9.9`: Value `12` displays as `+12.0`
- `$ ZZ99.9`: Value `12` displays as `$ 12.0`

Date/Time:
- `Z9:99:99`: Value `#00:23:59#` displays as `0:23:59`
- `99/99/99`: Value `#2025-09-19#` displays as `19/09/25` (Spanish) or `09/19/25` (English)

String:
- `!XXX Z99`: Value `"abc1"` displays as `Abc 01`
- `999.999-9`: Value `"1234567"` displays as `123.456-7`
