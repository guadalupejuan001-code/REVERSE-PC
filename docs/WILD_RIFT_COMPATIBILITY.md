# Wild Rift original en REVERSE: investigación de compatibilidad

## Objetivo y estado

El objetivo del usuario es ejecutar el **Wild Rift original de Riot** desde
REVERSE en el mismo teléfono Android, usando su conexión normal y, eventualmente,
el renderizador propio. La inspección inicial todavía no ejecuta ese cliente ni
cambia su motor gráfico.

No se ha recibido el APK ni el conjunto de splits de Wild Rift. No se conoce por
observación directa su ABI, versión, bibliotecas, API gráfica activa ni coste de
CPU/GPU en el teléfono. No se atribuyen a Wild Rift los resultados de REVERSE ni
los de las fixtures sintéticas.

`tools/android_compat.py` es la primera herramienta de la investigación. Lee
archivos locales, reconstruye metadatos del manifiesto Android y consulta las
dependencias y símbolos dinámicos ELF con GNU `readelf`. No carga las bibliotecas
como código ni ejecuta instrucciones del APK.

La APK actual de REVERSE utiliza Android como anfitrión. XI/RXE no implementan
el entorno de ejecución Android. `QuantumRenderer` consume OpenGL ES para escenas
propias; Ether Render X todavía no proporciona una implementación de EGL/GLES o
Vulkan a la que se pueda entregar el cliente de Wild Rift. El inventario no
convierte un juego Android a RXE ni incorpora un controlador gráfico.

## Qué entrega la primera inspección

| Evidencia | Alcance |
| --- | --- |
| SHA-256 del APK y de cada biblioteca inspeccionada | Identificación de bytes, sin verificar su firma/procedencia |
| Manifest binario UTF-8/UTF-16 o XML de texto | Paquete, versión, splits, SDK y requisitos GLES declarados |
| Entradas `lib/<abi>/*.so` | ABI declarada y comprobación contra la cabecera ELF |
| `DT_NEEDED` y símbolos dinámicos indefinidos | Enlaces a EGL/GLES/Vulkan y funciones importadas |
| Nombres de bibliotecas gráficas presentes como bytes | Indicios débiles de carga dinámica, separados de los enlaces |
| Lista de DEX y tamaños | Inventario, sin decompilar métodos ni observar ejecución |

Una referencia a Vulkan no demuestra que se use Vulkan en una partida. La falta
de imports GLES tampoco demuestra que no exista renderizado: podría pasar por
Java, WebView, una biblioteca cargada dinámicamente u otros archivos. No se
afirma que un conjunto de splits esté completo solo por coincidir sus versiones.

## Inspección local

Requisitos: Python 3.10 o posterior y GNU Binutils (`readelf`). El analizador no
requiere paquetes de Python externos ni una instalación del SDK de Android.

```sh
python3 tools/android_compat.py inspect android-compat-input/ \
  --expect-package com.riotgames.league.wildrift \
  --output android-compat-results/wild-rift.json
```

El ID anterior debe contrastarse con el paquete realmente instalado, especialmente
si se usa una distribución regional. `--expect-package` rechaza otro paquete;
no lo identifica automáticamente como Wild Rift por el nombre del archivo.

Se puede pasar un APK, varios APKs, una carpeta que contenga los splits, o un
contenedor APKS/XAPK/ZIP con APKs. Los APKs internos se copian a temporales con
nombres propios, sin extraer rutas del contenedor. Los recursos adicionales/OBB
del juego no se analizan ni se reconstruyen.

Los límites predeterminados son 2 GiB por entrada APK/contenedor, 512 MiB por
biblioteca nativa, 4 GiB de descompresión acumulada, 128 APKs y 100.000 entradas
por ZIP. `--max-apk-mib`, `--max-native-mib` y `--max-total-mib` permiten cambiar
los presupuestos explícitamente. Se rechazan nombres ZIP duplicados o inseguros,
metadatos truncados y versiones/paquetes mezclados.

Código de salida `0` significa que terminó el inventario estático dentro de su
alcance. Código `2` indica error o análisis incompleto. Los campos
`runtime_graphics_backend`, `renderer_replacement`, `wild_rift_execution` y
`performance` conservan sus estados no observados/no implementados: el inventario
no confirma compatibilidad ni rendimiento.

## Copiar los APKs de un teléfono conectado

Esta opción requiere Android SDK Platform Tools y un dispositivo que el usuario
haya autorizado para ADB. Es opcional: también se pueden entregar los archivos
sin conectar el teléfono al entorno de desarrollo.

```sh
python3 tools/android_compat.py collect android-compat-input/wild-rift \
  --package com.riotgames.league.wildrift \
  --serial SERIAL_DEL_DISPOSITIVO
```

`collect` consulta `pm path` y copia **todos** los APKs que devuelve, incluidos los
splits. Guarda sus hashes en `collection.json` y vuelve a consultar las rutas
para detectar una actualización durante la copia. Se exige un directorio nuevo.
Un fallo conserva un registro `incomplete`; no se presenta como una colección
terminada. Comparar rutas detecta cambios de instalación habituales, pero no
constituye una captura atómica del dispositivo.

Las únicas operaciones sobre el dispositivo son `shell pm path` y `pull`.
No se instala, inicia, modifica ni desinstala el juego. No se consultan cuentas,
sesiones ni almacenamiento privado del juego. La extracción ADB todavía no se
ha probado con el teléfono físico del usuario.

No subir los APKs o recursos del juego al repositorio. Las carpetas locales
`android-compat-input/` y `android-compat-results/` quedan excluidas de Git.

## Validación realizada

```sh
python3 -m unittest discover -s tests -p test_android_compat.py -v
```

Las pruebas usan manifiestos binarios sintéticos, una biblioteca ELF real
compilada para la prueba con un import GLES conocido y un transporte ADB
simulado. Comprueban la preservación de entradas, identidad de splits, rechazo
de archivos truncados/rutas ZIP inseguras y fallos de recolección. Estas pruebas
no ejecutan Wild Rift ni miden un teléfono.

Además se inspeccionó la APK real **REVERSE-v2.5.1.apk**, como control:

- SHA-256 `62c35d9020b2ad497983544775546c399bdcff46affe89a1c615e62add692aa2`.
- Paquete `com.reversepc.control.workbench`, código `251`, nombre `2.5.1-control`.
- SDK mínimo 29 y objetivo 35.
- Bibliotecas `libreverse_os.so` ARM64 y x86_64, ambas de 64 bits.
- Sin imports gráficos directos observados en esas dos bibliotecas; no es una
  conclusión sobre la interfaz Java/WebView ni sobre Wild Rift.

El [informe del control](evidence/android-compat-reverse-2.5.1.json) es reproducible
con el analizador. No contiene el APK ni datos de una partida.

## Próximas etapas dependientes del cliente

1. Recibir el conjunto real de APKs e identificar versión, ABI y bibliotecas.
2. Documentar los límites entre la capa Android, el motor del cliente y las APIs
   gráficas; distinguir imports estáticos de llamadas observadas en ejecución.
3. Obtener una medición autorizada y representativa en el teléfono: tiempos de
   frame, CPU/GPU y límites térmicos. Evaluar qué observación admite el cliente
   de distribución antes de elegir herramientas de trazado.
4. Definir una prueba de compatibilidad pequeña a partir de las llamadas
   observadas. Verificar corrección antes de cambiar su implementación.
5. Comparar rendimiento con la misma escena, dispositivo y condiciones. No
   deducir mejoras del juego a partir de benchmarks de otra aplicación.

La conexión/IP del teléfono no proporciona capacidad de cómputo adicional.
Esta etapa no modifica la ruta de red: el objetivo sigue siendo el cliente
original en el mismo dispositivo.

## Referencias primarias

- [APK Analyzer](https://developer.android.com/tools/apkanalyzer).
- [Android Debug Bridge: `pm path` y `pull`](https://developer.android.com/tools/adb).
- [Estructuras binarias de recursos Android](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/main/libs/androidfw/include/androidfw/ResourceTypes.h).
- [GNU readelf](https://sourceware.org/binutils/docs/binutils/readelf.html).
- [EGL y OpenGL ES en Android](https://source.android.com/docs/core/graphics/arch-egl-opengl).
- [Inventario del motor propio](https://github.com/guadalupejuan001-code/mundo-X/blob/main/docs/render-engine-inventory.md).
