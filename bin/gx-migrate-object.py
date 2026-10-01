#!/usr/bin/env python3
"""Migra un objeto de la KB GX17 a la KB GX18, por el SDK del MCP.

Ciclo completo, todo verificado:
  1. exporta el objeto de GX17 a .xpz y extrae Source / Rules / Variables
  2. crea el objeto en GX18 con las variables y el Parm (SIN el source:
     object_atomic es atomico y un fallo del source perderia todo)
  3. detecta las variables usadas como matriz (&var()) y les aplica
     AttCollection=False / AttNumDim=1 / AttRows=N
  4. escribe el Source
  5. re-exporta de GX18 y compara Source y Rules contra GX17

Uso:  gx-migrate-object.py <NombreDelObjeto> [--dry-run] [--rows N] [--tipo Procedure]

Por defecto NO escribe nada si --dry-run esta presente.
"""
import json, re, subprocess, sys, zipfile, os, tempfile

GX = os.path.expanduser('~/bin/gx-cli.sh')

# --- configuracion: sale de ~/.config/gx-ai.conf ------------------------------
def _conf():
    """Lee el archivo de configuracion del kit (formato KEY='valor')."""
    out = {}
    for p in (os.environ.get('GX_AI_CONF'), os.path.expanduser('~/.config/gx-ai.conf')):
        if p and os.path.exists(p):
            for l in open(p, encoding='utf-8', errors='replace'):
                l = l.strip()
                if l.startswith('#') or '=' not in l:
                    continue
                k, _, v = l.partition('=')
                out[k.strip()] = v.strip().strip("'\"")
            break
    return out


_C = _conf()
_EXPORT_WIN = _C.get('GX_EXPORT_DIR_WIN')
if not _EXPORT_WIN:
    _u = _C.get('GX_WIN_USER', '') or os.environ.get('USER', '')
    _EXPORT_WIN = rf'C:\Users\{_u}\gx-export'
EXPORT_DIR_WIN = _EXPORT_WIN
# misma ruta pero vista desde WSL
EXPORT_DIR = '/mnt/c/' + EXPORT_DIR_WIN.replace('\\', '/').replace(':', '', 1).lstrip('/')


def gx(kb, tool, payload, timeout=600):
    r = subprocess.run([GX, kb, tool, json.dumps(payload)],
                       capture_output=True, text=True, timeout=timeout).stdout
    try:
        return json.loads(r)
    except Exception:
        return {'_raw': r[:300]}


def norm(t):
    return re.sub(r'[ \t]+', ' ', (t or '').replace('\r\n', '\n')).strip()


def tipos_reales(nombre):
    """Tipos reales de las variables del objeto en GX17 (type/length/decimals).

    Necesario porque el XPZ no siempre trae el tipo: sin esto, una variable cuyo
    nombre no coincide con un atributo (p.ej. los parametros con sufijo `_p`, o
    nombres con otra capitalizacion) queda con el tipo por DEFECTO y despues
    falla la compilacion del llamador con spc0023 (parametro con tipo erroneo).
    """
    d = gx('gx17', 'genexus_inspect', {'name': nombre, 'projection': 'verbose'})
    r = d.get('result') or d
    out = {}
    for v in (r.get('variables') or []):
        n = (v.get('name') or '').strip('&')
        if n:
            out[n] = (v.get('type'), v.get('length'), v.get('decimals'))
    return out


MAPEO_TIPO = {'NUMERIC': 'Numeric', 'CHARACTER': 'Character', 'VARCHAR': 'VarChar',
              'LONGVARCHAR': 'LongVarChar', 'DATE': 'Date', 'DATETIME': 'DateTime',
              'BOOLEAN': 'Boolean'}


def extraer(nombre, xpz):
    """Lee Source, Rules y Variables del .xpz exportado de GX17."""
    z = zipfile.ZipFile(xpz)
    xml = z.read(z.namelist()[0]).decode('utf-8', 'replace')
    src = rul = ''
    for m in re.finditer(r'<Source>(.*?)</Source>', xml, re.S):
        t = m.group(1).replace('<![CDATA[', '').replace(']]>', '')
        if t[:160].lower().strip().startswith('parm'): rul = t
        elif len(t) > len(src): src = t
    pv = re.search(r'<Part type="e4c4ade7-53f0-4a56-bdfd-843735b66f47">(.*?)</Part>', xml, re.S)
    reales = tipos_reales(nombre)          # GX17: la unica fuente confiable del tipo
    attrs, otros, objvars = [], [], []
    if pv:
        for v in re.finditer(r'<Variable Name="([^"]+)">(.*?)</Variable>', pv.group(1), re.S):
            pr = dict(re.findall(r'<Name>([^<]+)</Name><Value>([^<]*)</Value>', v.group(2)))
            n = v.group(1)
            # NO cortar el prefijo: define la clase de tipo (Attribute/Domain/bas/sdt/bc/ext)
            raw = pr.get('idBasedOn') or pr.get('ATTCUSTOMTYPE') or ''
            pref, _, val = raw.partition(':')
            val = val.split(',')[0].strip()
            # ⚠️ El truco "omitir typeName para heredar el atributo homonimo" SOLO es
            # seguro si EXISTE un atributo con ese nombre. Si no (p.ej. `BDeAnio_p`),
            # el SDK le pone un tipo por defecto y despues rompe al llamador con
            # spc0023 (parametro con tipo erroneo). En ese caso, tipo real de GX17.
            if pref == 'Attribute' and _tiene_atributo_homonimo(n):
                attrs.append({'varName': n})            # hereda el atributo homonimo
            elif pref in ('bc', 'sdt', 'ext'):
                objvars.append({'varName': n, 'typeName': val})
            elif pref in ('bas', 'Domain'):
                prims_append(otros, n, val, pr)
            else:
                # sin prefijo (o atributo sin homonimo): el tipo REAL de GX17, sin adivinar
                t = reales.get(n)
                if t and t[0] and str(t[0]).upper() in MAPEO_TIPO:
                    e = {'varName': n, 'typeName': MAPEO_TIPO[str(t[0]).upper()]}
                    if t[1] is not None:
                        e['length'] = int(t[1])
                    if t[2] is not None:
                        e['decimals'] = int(t[2])
                    otros.append(e)
                else:
                    prims_append(otros, n, val or pr.get('Type') or 'Character', pr)
    return src, rul, attrs, otros, objvars


_ATTR_CACHE = {}


def _tiene_atributo_homonimo(nombre):
    """¿Existe un atributo con el mismo nombre en GX18? (consultado una vez por nombre)"""
    if nombre in _ATTR_CACHE:
        return _ATTR_CACHE[nombre]
    d = gx('gx', 'genexus_read', {'name': nombre})
    r = d.get('result') or d
    t = (r.get('type') or '').lower() if isinstance(r, dict) else ''
    _ATTR_CACHE[nombre] = (t == 'attribute')
    return _ATTR_CACHE[nombre]


def prims_append(dst, n, tipo, pr):
    e = {'varName': n, 'typeName': tipo}
    if pr.get('Length'):
        e['length'] = int(pr['Length'])
    if pr.get('Decimals'):
        e['decimals'] = int(pr['Decimals'])
    dst.append(e)


_CLASE_CACHE = {}


def clasificar(n, val, pr):
    """Sin prefijo en el XPZ: pregunta a GX18 que es. 'attr' | 'obj' | nombre-de-tipo."""
    clave = val or pr.get('Type') or 'Character'
    if clave in _CLASE_CACHE:
        return _CLASE_CACHE[clave]
    d = gx('gx', 'genexus_read', {'name': clave})
    r = d.get('result') or d
    t = (r.get('type') or '').lower() if isinstance(r, dict) else ''
    if t in ('sdt', 'businesscomponent', 'externalobject', 'domain',
             'procedure', 'data provider', 'dataprovider'):
        clase = {'domain': clave, 'sdt': 'obj', 'businesscomponent': 'obj',
                 'externalobject': 'obj'}.get(t, 'obj')
    elif t:
        clase = 'obj'
    else:
        clase = clave
    _CLASE_CACHE[clave] = clase
    return clase


def parms_de(rule):
    """'Parm(In:&A,Out:&B);' -> ['in:&A','out:&B']"""
    m = re.search(r'parm\s*\((.*?)\)\s*;', rule, re.S | re.I)
    if not m:
        return []
    out = []
    for p in m.group(1).split(','):
        p = p.strip()
        mm = re.match(r'(?i)(in|out)?\s*:?\s*(&\w+)', p)
        if mm:
            out.append((mm.group(1).lower() + ':' if mm.group(1) else '') + mm.group(2))
    return out


def matrices_en(src):
    """Variables usadas como &var()  -> necesitan ser matrices."""
    return sorted(set(re.findall(r'&(\w+)\s*\(\s*\)', src)))


def migrar(nombre, tipo='Procedure', rows=1000, dry=False):
    print(f'══ {nombre} ══')
    xpz17 = os.path.join(EXPORT_DIR, f'{nombre}.xpz')
    d = gx('gx17', 'genexus_transfer', {"action": "export", "targets": [nombre],
           "outputFile": rf'{EXPORT_DIR_WIN}\{nombre}.xpz', "includeDependencies": False})
    if (d.get('result') or {}).get('exportedCount') != 1:
        print('  ❌ no se pudo exportar de GX17:', d.get('code'), d.get('message'))
        return False
    src, rul, attrs, otros, objvars = extraer(nombre, xpz17)
    parms = parms_de(rul)
    print(f'  GX17: source {len(src)} chars | rules {norm(rul)[:70]!r}')
    print(f'        variables: {len(attrs)} atributos + {len(otros)} primitivos/dominios'
          f' + {len(objvars)} de objeto | parms: {len(parms)}')
    print(f'        objetos: {[o["varName"] for o in objvars]}')
    mats = matrices_en(src)
    print(f'        matrices detectadas: {mats}')

    payload = {"action": "object_atomic", "type": tipo, "name": nombre, "mode": "auto",
               "updateExisting": True, "parms": parms,
               "variables": attrs + otros, "dryRun": True}
    d = gx('gx', 'genexus_create', payload)
    if d.get('code') != 'DryRun':
        print(f'  ❌ dryRun {d.get("code")}: {(d.get("message") or "")[:110]}')
        return False
    if dry:
        print('  (dryRun: no se escribe nada)')
        return True

    payload['dryRun'] = False
    d = gx('gx', 'genexus_create', payload)
    res = d.get('result') or d
    print(f'  crear+variables -> {d.get("code")}')
    if d.get('code') not in ('ObjectCreatedAtomic', 'ObjectUpdatedAtomic'):
        print('  ❌', json.dumps(res, ensure_ascii=False)[:300])
        return False
    st = res.get('steps', {}).get('variables', {})
    print(f'     variables: {st.get("counts")}')
    if objvars:
        d2 = gx('gx', 'genexus_variable', {"action": "add", "name": nombre, "variables": objvars})
        r2 = d2.get('result') or d2
        print(f'     variables de objeto -> {d2.get("code")} {r2.get("counts")}')
        for o in (r2.get('outcomes') or []):
            if o.get('status') != 'Added':
                print(f'        ❌ {o.get("name")}: {o.get("status")}')

    for v in mats:
        for prop, val in (('AttCollection', 'False'), ('AttNumDim', '1'), ('AttRows', str(rows))):
            gx('gx', 'genexus_properties', {"action": "set", "name": nombre,
               "control": '&' + v, "propertyName": prop, "value": val})
    if mats:
        print(f'     matrices aplicadas: {mats}')

    d = gx('gx', 'genexus_edit', {"name": nombre,
         "parts": [{"part": "Source", "content": src.rstrip('\r\n'), "mode": "full"}],
         "dryRun": False, "validationMode": "specify"})
    res = d.get('result') or d
    txt = json.dumps(res, ensure_ascii=False)
    if '"status": "error"' in txt:
        err = (res.get('results') or [{}])[0].get('error', {})
        print(f'  ❌ source: {(err.get("message") or "")[:400]}')
        return False
    print('  ✅ source escrito')

    # verificacion por xpz
    gx('gx', 'genexus_transfer', {"action": "export", "targets": [nombre],
       "outputFile": rf'{EXPORT_DIR_WIN}\{nombre}_18.xpz', "includeDependencies": False})
    s2, r2, _, _, _ = extraer(nombre, os.path.join(EXPORT_DIR, f'{nombre}_18.xpz'))
    ok_s = bool(src) and norm(src) == norm(s2)
    ok_r = norm(rul).lower().replace(' ', '') == norm(r2).lower().replace(' ', '')
    print(f'  VERIFICACION  source {len(src)} vs {len(s2)} -> {"✅ IDENTICO" if ok_s else "❌ DIFIERE"}'
          f'  |  rules {"✅" if ok_r else "⚠️"}')
    return ok_s


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(__doc__); sys.exit(2)
    nom = sys.argv[1]
    dry = '--dry-run' in sys.argv
    tip = 'Procedure'
    if '--tipo' in sys.argv:
        tip = sys.argv[sys.argv.index('--tipo') + 1]
    ok = migrar(nom, tipo=tip, dry=dry)
    sys.exit(0 if ok else 1)
