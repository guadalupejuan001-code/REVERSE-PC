#!/usr/bin/env python3
"""Install an APK through real Android dialogs, and execute an imported XI file."""
import json
from pathlib import Path
import runpy
import subprocess
import sys
import time
import xml.etree.ElementTree as ET

driver=runpy.run_path(str(Path(__file__).with_name('desktop-smoke.py')),init_globals={'REVERSE_DRIVER_ONLY':True})
for key in ['adb','tree','find','box','tap','click','enter','launch','close','screenshot','wait_log','log_check','file','OUT','PACKAGE','COMPONENT','events']:
    globals()[key]=driver[key]

def downloads():
    root=tree()
    if any(n.get('text','').casefold()=='downloads' for n in root.iter('node')):
        click(text='Downloads');return
    for n in root.iter('node'):
        if any(t in n.get('content-desc','').lower() for t in ['roots','navigation drawer']):
            tap(n);click(text='Downloads');return
    raise AssertionError('cannot choose Downloads in the Android document picker')

def package_installed():
    return 'package:com.reversepc.fixture' in adb('shell','pm','list','packages','com.reversepc.fixture').splitlines()

def wait_package(expected):
    until=time.monotonic()+30
    while time.monotonic()<until:
        if package_installed()==expected:return
        time.sleep(.5)
    raise AssertionError(('fixture package state',expected))

def filter_programs(value):
    enter(find(desc='FILTRAR PROGRAMAS'),value)

def select_fixture():
    click(text='Instalar APK');downloads();click(text='Programa-prueba.apk')
    find(text='Instalar Programa de prueba',timeout=25)

def exists_in_tree(desc):
    return any(n.get('content-desc')==desc for n in tree().iter('node'))

# Existing desktop journeys ran first; only REVERSE itself used adb install.
assert not package_installed(),'fixture must be installed by the REVERSE UI, not adb'
fixture=Path(sys.argv[2]);adb('push',fixture,'/sdcard/Download/Programa-prueba.apk')
program=OUT/'hola_reverse.xi'
program.write_text('#!reverse-pc-machine-v1\nset r0 6\nmul r0 7\nstore8 4096 r0\nprint r0\nhalt\n')
adb('push',program,'/sdcard/Download/hola_reverse.xi')
for name in ['Programa-prueba.apk','hola_reverse.xi']:
    adb('shell','am','broadcast','-a','android.intent.action.MEDIA_SCANNER_SCAN_FILE','-d','file:///sdcard/Download/'+name)

launch('Aplicaciones');baseline=file('session.rvp')
click(text='Importar XI');downloads();click(text='hola_reverse.xi')
find(text='Importar programa XI');click(text='Aceptar')
wait_log('PROGRAM_XI_INSTALLED hola_reverse.xi')
assert file('programs/hola_reverse.xi')==program.read_bytes()
assert file('session.rvp')==baseline,'import executed the program without a launch'
filter_programs('hola_reverse')
click(desc='ABRIR PROGRAMA xi:hola_reverse.xi')
wait_log('PROGRAM_XI_RUN_OK hola_reverse.xi')
assert '42' in find(desc='SALIDA PROGRAMA hola_reverse.xi').get('text','')
state=file('session.rvp');assert b'O 4096 42' in state and b'O 42 21' in state
screenshot('native-program.png');close('hola_reverse')
log_check('XI_IMPORT_DOES_NOT_EXECUTE_AND_LAUNCH_USES_ORIGINAL_CORE_PASS')

select_fixture();click(text='Cancelar')
assert not package_installed() and file('session.rvp')==state
assert not adb('shell','run-as',PACKAGE,'ls','cache/install-packages').strip(),'cancelled APK retained'
log_check('APK_REVIEW_CANCEL_PRESERVES_CORE_AND_REMOVES_STAGED_FILE_PASS')

select_fixture();click(text='Continuar')
# Grant this specific source through the actual Android Settings switch.
until=time.monotonic()+30
while time.monotonic()<until:
    root=tree()
    allow=next((n for n in root.iter('node') if n.get('text','').casefold()=='allow from this source'),None)
    install=next((n for n in root.iter('node') if n.get('text','').casefold()=='install' and n.get('clickable')=='true'),None)
    if install:break
    if allow is not None:
        switches=[n for n in root.iter('node') if n.get('checkable')=='true' and n.get('clickable')=='true']
        if switches:
            if switches[-1].get('checked')!='true':tap(switches[-1])
        else:tap(allow)
        adb('shell','input','keyevent','4');break
    time.sleep(.5)
click(text='Install');wait_log('APK_INSTALL_OK com.reversepc.fixture',timeout=45);wait_package(True)
assert file('session.rvp')==state,'Android installation changed the XI authority'
filter_programs('Programa de prueba');find(text='Programa de prueba')
log_check('REAL_ANDROID_PERMISSION_AND_APK_INSTALL_THROUGH_REVERSE_PASS')

click(desc='OPCIONES PROGRAMA Programa de prueba');click(text='Anclar al escritorio')
close('Aplicaciones');click(desc='MOSTRAR ESCRITORIO')
click(desc='ACCESO PROGRAMA Programa de prueba')
find(text='Programa instalado desde REVERSE',timeout=25);click(text='Volver al escritorio')
log_check('PINNED_ANDROID_PROGRAM_LAUNCHES_REAL_EXTERNAL_ACTIVITY_PASS')

click(desc='BUSCAR');enter(find(desc='BUSQUEDA GLOBAL'),'Programa de prueba')
click(text='Programa de prueba · Android')
find(text='Programa instalado desde REVERSE',timeout=25);click(text='Volver al escritorio')
before=file('session.rvp');time.sleep(1)
adb('shell','am','force-stop',PACKAGE);adb('shell','am','start','-W','-n',COMPONENT)
find(desc='ACCESO PROGRAMA Programa de prueba',timeout=30)
assert package_installed() and file('session.rvp')==before
screenshot('installed-program-desktop.png')
log_check('SEARCH_AND_RESTART_PRESERVE_INSTALLED_APP_SHORTCUT_AND_XI_MEMORY_PASS')

launch('Aplicaciones');filter_programs('Programa de prueba')
click(desc='OPCIONES PROGRAMA Programa de prueba');click(text='Desinstalar')
root=tree();positive=next((n for n in root.iter('node') if n.get('text','').casefold() in ('uninstall','ok') and n.get('clickable')=='true'),None)
if positive is None:positive=find(text='OK')
tap(positive);wait_package(False);time.sleep(1)
assert file('session.rvp')==before
log_check('REAL_ANDROID_UNINSTALL_PRESERVES_DESKTOP_DOCUMENTS_AND_CORE_PASS')

filter_programs('hola_reverse');click(desc='OPCIONES PROGRAMA hola_reverse');click(text='Quitar programa');click(text='Quitar')
wait_log('PROGRAM_XI_REMOVED hola_reverse.xi')
adb('shell','run-as',PACKAGE,'sh','-c','test ! -e files/programs/hola_reverse.xi')
assert file('session.rvp')==before
log_check('XI_UNINSTALL_REMOVES_PROGRAM_WITHOUT_RESETTING_SHARED_STATE_PASS')
close('Aplicaciones')
(OUT/'logcat.txt').write_text(adb('logcat','-d'))
(OUT/'results.json').write_text(json.dumps({'package':PACKAGE,'passed':events,'apk_installed_via_ui':True,'native_xi_program_executed':True},indent=2)+'\n')
print('REVERSE_PROGRAMS_UI_PASS',len(events),flush=True)
