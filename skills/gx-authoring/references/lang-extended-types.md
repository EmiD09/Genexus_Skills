<!-- GENERATED from catalog/language/lang-extended-types.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: lang-extended-types
description: Built-in extended types for system integration and advanced functionality (HTTP, email, file system, geography, XML, and more)
---

System-provided types for HTTP, email, XML, geography, file management, and other advanced operations

---

# HTTP TYPES

## HttpClient
See [lang-extended-type-httpclient](./lang-extended-type-httpclient.md)

## HttpRequest
See [lang-extended-type-httprequest](./lang-extended-type-httprequest.md)

## HttpResponse
See [lang-extended-type-httpresponse](./lang-extended-type-httpresponse.md)

---

# EMAIL TYPES

## SmtpSession
See [lang-extended-type-smtpsession](./lang-extended-type-smtpsession.md)

## Pop3Session
See [lang-extended-type-pop3session](./lang-extended-type-pop3session.md)

## MailMessage
See [lang-extended-type-mailmessage](./lang-extended-type-mailmessage.md)

## MailRecipient
See [lang-extended-type-mailrecipient](./lang-extended-type-mailrecipient.md)

---

# FILE SYSTEM TYPES

## File
See [lang-extended-type-file](./lang-extended-type-file.md)

## Directory
See [lang-extended-type-directory](./lang-extended-type-directory.md)

---

# GEOGRAPHY TYPES

## Geography
See [lang-extended-type-geography](./lang-extended-type-geography.md)

## GeoPoint
See [lang-extended-type-geopoint](./lang-extended-type-geopoint.md)

## GeoLine
See [lang-extended-type-geoline](./lang-extended-type-geoline.md)

## GeoPolygon
See [lang-extended-type-geopolygon](./lang-extended-type-geopolygon.md)

---

# XML TYPES

## XmlReader
See [lang-extended-type-xmlreader](./lang-extended-type-xmlreader.md)

## XmlWriter
See [lang-extended-type-xmlwriter](./lang-extended-type-xmlwriter.md)

---

# OTHER TYPES

## Expression
See [lang-extended-type-expression](./lang-extended-type-expression.md)

## RegExMatch
See [lang-extended-type-regexmatch](./lang-extended-type-regexmatch.md)

## Dictionary
See [lang-external-object-dictionary](./lang-external-object-dictionary.md)

## Log
See [lang-external-object-log](./lang-external-object-log.md)

---

# CONSTRAINTS
All extended types share these common characteristics:
- Initialization: Use `new()` function to create instances; e.g. `&MyType = new()`
- Constant strings: Use exclamation mark (`!`) prefix for non-translatable strings; e.g. `!"constant-value"`
- Error handling: Check `ErrCode` and `ErrDescription` properties after operations
	* `ErrCode = 0` indicates success
	* Any other code indicates failure
- Variable-only usage: Extended types can only be used for variables, not for attributes or SDT members
- Resource cleanup: Close resources when finished (files, connections, readers, writers)
- Cross-platform compatibility: Use `Separator` property from File instances when building paths

# RELATED MODULES
- [lang-extended-type-httpclient](./lang-extended-type-httpclient.md)
- [lang-extended-type-httprequest](./lang-extended-type-httprequest.md)
- [lang-extended-type-httpresponse](./lang-extended-type-httpresponse.md)
- [lang-extended-type-smtpsession](./lang-extended-type-smtpsession.md)
- [lang-extended-type-pop3session](./lang-extended-type-pop3session.md)
- [lang-extended-type-mailmessage](./lang-extended-type-mailmessage.md)
- [lang-extended-type-mailrecipient](./lang-extended-type-mailrecipient.md)
- [lang-extended-type-file](./lang-extended-type-file.md)
- [lang-extended-type-directory](./lang-extended-type-directory.md)
- [lang-extended-type-geography](./lang-extended-type-geography.md)
- [lang-extended-type-geopoint](./lang-extended-type-geopoint.md)
- [lang-extended-type-geoline](./lang-extended-type-geoline.md)
- [lang-extended-type-geopolygon](./lang-extended-type-geopolygon.md)
- [lang-extended-type-xmlreader](./lang-extended-type-xmlreader.md)
- [lang-extended-type-xmlwriter](./lang-extended-type-xmlwriter.md)
- [lang-extended-type-expression](./lang-extended-type-expression.md)
- [lang-extended-type-regexmatch](./lang-extended-type-regexmatch.md)
- [lang-external-object-dictionary](./lang-external-object-dictionary.md)
- [lang-external-object-log](./lang-external-object-log.md)
