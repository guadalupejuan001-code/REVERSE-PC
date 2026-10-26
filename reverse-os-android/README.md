# REVERSE Desktop 1.1

## Instalar programas

Aplicaciones ofrece **Instalar APK**, **Importar XI**, búsqueda y un menú por
programa. Un `.xi` se importa a Programas sin ejecutarlo ni cambiar RVPC2;
al abrirlo, el mismo intérprete XI lo ejecuta en una ventana de resultados.
Reabrir el proceso recupera esa ventana sin repetir la ejecución. Se puede
editar, anclar y quitar un programa importado, conservando la memoria compartida.

Las APK se copian por bloques a una carpeta privada (hasta 512 MiB) y se revisan
por nombre/versión antes de entregarlas al instalador Android. Android pide
permitir REVERSE como fuente y confirmar la instalación. Cancelar la vista
previa elimina la copia temporal. Las apps con acceso de inicio aparecen en el
gestor; se pueden abrir, anclar al escritorio y a Inicio y encontrar con Buscar.
Se ejecutan en Android y permiten volver con Atrás/Recientes. Información y
Desinstalar abren los controles del sistema. Las apps del sistema conservan
su protección frente a la desinstalación desde este gestor.

El proveedor solo concede lectura temporal de un APK concreto; no expone
programas, documentos, RVPC2 ni carpetas completas. Los `.xi` aceptan UTF-8,
hasta 256 KiB, y no sobrescriben nombres existentes. Se mantienen el mismo motor,
la dependencia fijada y la versión de BBY Q.

`REVERSE-Desktop-v1.1.apk` usa `com.reversepc.desktop.apps`, con nombre visible
REVERSE Desktop 1.1, para instalarse **junto a 1.0**. La clave de desarrollo de
1.0 no quedó retenida y no se puede prometer una actualización con esa firma.
RVPC2 se transfiere exportando/importando desde Ajustes. El respaldo ZIP conserva
los documentos para extracción; esta versión no restaura un perfil ZIP completo.
Las próximas compilaciones de esta edición usan una ruta de clave explícita y
una caché comprobable en CI. Es firma de desarrollo: la caché puede caducar y
no sustituye un almacén de firma de producción.

CI conserva los 13 recorridos anteriores y añade importación/ejecución XI,
cancelación de APK, permiso de origen, instalación mediante Android, acceso y
búsqueda, reinicio y desinstalación. El APK de prueba se instala mediante los
botones de REVERSE/Android; adb solo instala REVERSE. Se comprueban los bytes
RVPC2 antes y después. `PackageStagingTest` prueba límites, copia incompleta,
archivos vacíos, nombres y enlaces usando archivos reales.

Compilar esta edición después de preparar las dependencias fijadas:

```bash
export REVERSE_SIGNING_KEYSTORE="$PWD/build-signing/reverse-desktop.jks"
mkdir -p build-signing
# Crear solo una vez; conservar este archivo privado entre compilaciones.
keytool -genkeypair -keystore "$REVERSE_SIGNING_KEYSTORE" -storetype JKS \
  -storepass android -keypass android -alias reverse-desktop -keyalg RSA \
  -keysize 2048 -validity 10000 -dname 'CN=REVERSE Desktop Development'
gradle -p reverse-os-android :app:assembleProgramsDebug :fixture:assembleDebug
```

## Base conservada de Desktop 1.0

Escritorio de trabajo dentro de Android, desarrollado sobre REVERSE OS v0.5
(`7420e067db6b42d207dd43eab00bdb9942eacafc`). Mantiene el diseño plano en grafito
con fondo orbital y el arranque `welcome.... REVERSE.`.

## Trabajo cotidiano

- Varias ventanas dentro de la misma actividad: mover, redimensionar, minimizar,
  maximizar, ajustar izquierda/derecha y recuperar cada tarea en la barra.
- Inicio, búsqueda de aplicaciones/documentos, escritorio y panel de ventanas.
- Hasta doce ventanas, con posiciones y sesión recordadas entre reinicios.
- Archivos: carpetas, texto, copiar archivos, mover archivos/carpetas, renombrar,
  papelera, restauración sin sobrescribir destinos existentes y eliminación
  definitiva con confirmación.
- Editor de texto UTF-8 y XI Studio con borradores conservados al cerrar o
  reiniciar. Los borradores no sustituyen el archivo hasta pulsar Guardar.
- Calculadora: precedencia, paréntesis, signo y seis decimales. La interfaz
  compila expresiones a XI; las operaciones se ejecutan en el intérprete propio.
  Usa registros de 64 bits y rechaza desbordamientos/división por cero.
- Visor de imágenes con decodificación acotada; navegador Android WebView;
  acceso explícito a las aplicaciones instaladas en Android.
- Preferencias de movimiento/calidad conservadas. El fondo se pausa cuando una
  ventana está maximizada, dos ventanas cubren ambos lados o Android suspende
  la actividad.
- Importar/exportar archivos mediante el selector Android, exportar respaldo
  ZIP de documentos/programas/memoria/borradores y restaurar RVPC2 validado.
  El ZIP se puede extraer con un gestor de archivos; no se importa como un
  perfil completo desde la interfaz de esta versión.
- Uso opcional como pantalla de inicio: Ajustes → Usar como escritorio de inicio.
  Android pide al usuario elegir la aplicación de inicio. Volver a Inicio
  recupera la misma actividad y no crea otra autoridad XI.

Atajos con teclado: Alt+Tab, Alt+F4, Ctrl+S, Ctrl+Alt+T, Meta+D y Meta+flechas.
Con el dedo/ratón, mantener pulsado un archivo o usar ⋮ abre sus operaciones;
el menú de cada ventana permite ajustar y restaurar su tamaño.

## Archivos y conservación

Los programas `.xi` continúan en la carpeta original `files/programs`; la
memoria computacional sigue siendo el mismo `files/session.rvp`. Las carpetas
Documentos, Descargas, Imágenes, Escritorio y Papelera viven en almacenamiento
privado. Android solo expone un archivo externo cuando el usuario lo elige.
No se solicita acceso general al almacenamiento ni se borran archivos al cerrar
ventanas. Los límites son 8 MiB por archivo, 256 KiB por texto/programa y 64 MiB
de documentos por respaldo ZIP. Las carpetas se mueven; copiar carpetas completas
no está incluido. Los archivos en papelera se pueden restaurar a su origen.

El gestor usa vistas no modales; desaparece la limitación anterior de un único
`Dialog` minimizado. Teclado y cambios de área disponible acotan las ventanas
sin perder su tamaño normal. Las barras se ocultan mientras se escribe para
liberar espacio en el teclado horizontal. La actividad es `singleTask` y el trabajador XI es
único en el proceso, también durante recreaciones de la pantalla.

Se mantiene la aplicación BBY Q ya incluida en v0.5, con sus fuentes E009
fijadas en `7dfa6c31247cf609128db78908313a6ce41c0b80`. Esta iteración no actualiza
su entrenamiento ni integra los checkpoints E014: ese trabajo permanece
separado, como se había acordado. La rama pendiente de v0.6 no se incorpora
silenciosamente.

## Instalar

`REVERSE-Desktop-v1.0.apk` usa `com.reversepc.desktop`, por lo que se instala al
lado de versiones antiguas de REVERSE OS y conserva su instalación. Es un
espacio nuevo; no puede leer el almacenamiento privado de otra aplicación.
Puede importar su RVPC2 desde Ajustes si se exportó previamente.

`REVERSE-OS-v1.0-compatible.apk` conserva `com.reversepc.os`. Solo puede actualizar
una instalación con la misma firma. No desinstalar una versión anterior para
resolver una firma distinta sin exportar antes sus datos. La compilación anterior intentaba conservar la clave en una ruta que no existía; su firma no puede darse por conservada. Estas APK son compilaciones de desarrollo, no una distribución de producción.

Compilar ambas ediciones:

```bash
bash reverse-os-android/scripts/prepare-bbyq.sh deps/bbyq
python3 scripts/prepare-ether-compat.py deps/mundo-x build/ether-compat
gradle -p reverse-os-android :app:assembleDesktopDebug :app:assembleClassicDebug
```

El runtime y Mundo X se conservan fijados. Android aporta kernel, controladores,
GPU, almacenamiento y WebView; XI/Ether ejecutan programas y conservan RVPC2.
Este proyecto aún no reemplaza el kernel Android ni ejecuta aplicaciones de
Windows. Las cifras de FPS/PSS provienen del proceso/renderizador reales;
no se presentan como aceleración cuántica ni como pruebas del Samsung A16.

## Verificación

`DesktopCoreTest.java` realiza operaciones reales con archivos, conflictos,
papelera, Unicode, límites, enlaces y geometría. `check-calculator.py` ejecuta
19 programas generados en el runtime XI y comprueba respuestas independientes,
rechazo y conservación del núcleo/memoria. Estas pruebas se ejecutan en host.

La CI además compila y firma las dos ABI (`arm64-v8a`, `x86_64`), instala la APK
Desktop en Android 15 y opera la interfaz mediante `adb`: arranque, movimiento
real del fondo, varias ventanas, arrastre, tamaño, ajuste, archivos, borradores,
calculadora XI, Euclides y recuperación tras matar/reabrir el proceso. La
batería ampliada además opera WebView, aplicaciones Android, el acceso Inicio,
importación de imágenes, exportación de borradores y respaldo ZIP a través del
selector real de Android. Guarda
capturas reales, registros y resultados. La prueba en el teléfono físico queda
fuera de lo que puede comprobar el emulador.
