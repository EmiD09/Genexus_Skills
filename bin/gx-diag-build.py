#!/usr/bin/env python3
"""Analiza un Build.log de GeneXus y encuentra los OBJETOS QUE FALTAN.

Por que existe
--------------
Los errores de compilacion de GeneXus vienen EN CASCADA y el que ves no es el
problema. El patron tipico:

    WContri no existe en la KB
        -> iparlimp_impl.java no compila (cannot find symbol: wcontri)
        -> el build descarta iparlimp_impl.java
        -> iparlimp.java falla ("cannot find symbol: class iparlimp_impl")
        -> ESTE es el error que ves

O sea: el error visible apunta a un `*_impl` que "desaparecio", y el verdadero
culpable es un objeto que NUNCA EXISTIO. Este script recorre el log y separa
los sintomas de las causas.

Uso
---
    gx-diag-build.py [ruta/al/Build.log] [--kb /mnt/c/ruta/de/la/KB]

Sin argumentos, busca el Build.log del KB del directorio actual.
"""
import os
import re
import sys
import glob


def leer_log(path):
    """El log de GeneXus suele estar en latin1."""
    for enc in ('utf-8', 'latin-1'):
        try:
            with open(path, encoding=enc, errors='strict') as f:
                return f.read()
        except UnicodeDecodeError:
            continue
    with open(path, encoding='latin-1', errors='replace') as f:
        return f.read()


def extraer_errores(texto):
    """Devuelve [(archivo_java, linea, simbolo)] de cada 'cannot find symbol'."""
    out = []
    # ...com/gesrec/iparlimp_impl.java:2352: error: cannot find symbol
    #    new com.gesrec.wcontri(...)...
    #    symbol:   class wcontri
    patron = re.compile(
        r'([\w./\\-]+\.java):(\d+):\s*error:\s*cannot find symbol'
        r'(.*?)symbol:\s*(?:class|variable|method)?\s*([\w.$]+)',
        re.S)
    for m in patron.finditer(texto):
        out.append((os.path.basename(m.group(1)), int(m.group(2)), m.group(4).strip()))
    return out


def clase_a_texto(nombre):
    """La clase de un objeto GeneXus es su nombre en minusculas, sin puntos."""
    return nombre.split('.')[-1]


def buscar_rastros(kb, objeto):
    """Busca el rastro de un objeto en la KB: state .ari y .sp0."""
    low = objeto.lower()
    rastros = {}
    st = glob.glob(os.path.join(kb, 'Java*', 'state', f'state12_2_{low}.ari'))
    rastros['state'] = st[0] if st else None
    sp = glob.glob(os.path.join(kb, 'GXSPC*', '**', f'{objeto}.sp0'), recursive=True)
    if not sp:
        # el .sp0 puede estar con otra capitalizacion
        sp = [p for p in glob.glob(os.path.join(kb, 'GXSPC*', '**', '*.sp0'), recursive=True)
              if os.path.basename(p).lower() == f'{low}.sp0']
    rastros['sp0'] = sp[0] if sp else None
    return rastros


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    kb = None
    if '--kb' in sys.argv:
        kb = sys.argv[sys.argv.index('--kb') + 1]
    if kb is None:
        kb = os.getcwd()

    log = args[0] if args else os.path.join(kb, 'OutputLogs', 'Build.log')
    if not os.path.isfile(log):
        print(f'No encuentro el log: {log}')
        print('Pasá la ruta:  gx-diag-build.py /ruta/Build.log --kb /ruta/de/la/KB')
        return 2

    texto = leer_log(log)
    errores = extraer_errores(texto)
    if not errores:
        print('No hay errores "cannot find symbol" en el log.')
        return 0

    # separar sintomas (faltan .java generados por GeneXus) de causas (objetos reales)
    sintomas, causas = [], []
    for arch, linea, simbolo in errores:
        s = clase_a_texto(simbolo)
        # Las rutas del log son de Windows: normalizar antes de comparar
        arch_norm = arch.replace('\\', '/')
        base = arch_norm.split('/')[-1].lower()
        # Un sintoma es "me falta el _impl de ESTE MISMO archivo", que GeneXus ya genero
        if s.endswith('_impl') and base.startswith(s[:-5].lower()):
            sintomas.append((arch, linea, s))
        else:
            causas.append((arch, linea, s))

    print(f'Log analizado: {log}')
    print(f'Errores "cannot find symbol": {len(errores)}')
    print()

    if causas:
        print('=' * 68)
        print('OBJETOS QUE FALTAN  (estas son las causas reales)')
        print('=' * 68)
        vistos = set()
        for arch, linea, s in causas:
            if s in vistos:
                continue
            vistos.add(s)
            r = buscar_rastros(kb, s)
            tiene = [k for k in ('state', 'sp0') if r[k]]
            if tiene:
                estado = 'DUDOSO - tiene ' + ' y '.join(tiene) + ', revisar a mano'
            else:
                estado = 'CONFIRMADO: no existe (sin state ni .sp0)'
            print(f'  {s}')
            print(f'      lo pide  : {arch}:{linea}')
            print(f'      en la KB : {estado}')
            if r['state']:
                print(f'      state    : {r["state"]}')
            if r['sp0']:
                print(f'      sp0      : {r["sp0"]}')
            print()
        print('  -> Solucion: traer/exportar esos objetos a la KB (export .xpz + import).')
    else:
        print('No encontre causas: puede que el log este cortado, o que sea otra clase de error.')

    if sintomas:
        print('=' * 68)
        print('SINTOMAS  (consecuencia, NO el problema)')
        print('=' * 68)
        for arch, linea, s in sintomas[:10]:
            print(f'  {arch}:{linea}  no encuentra {s}')
        if len(sintomas) > 10:
            print(f'  ... y {len(sintomas) - 10} mas')
        print()
        print('  Estos se arreglan solos cuando la causa real compila.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
