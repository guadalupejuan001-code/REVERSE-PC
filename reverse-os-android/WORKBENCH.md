# REVERSE Workbench 2.0 para Android

Edición instalable `com.reversepc.workbench`, compatible con ARM64 y x86_64. Se instala junto a las ediciones anteriores y conserva un perfil propio. Usa el arranque REVERSE y el escritorio diseñado con el fondo Pliegue, papelera, ventanas, editor de fondo y centro de control.

## Qué se ejecuta realmente

- El escritorio se dibuja con WebView a partir de archivos incluidos en la APK. No descarga la interfaz ni necesita un servidor.
- La calculadora compila expresiones con `CalculatorCompiler` y las ejecuta mediante `NativeRuntime.execute` en XI. No usa el evaluador JavaScript para producir los resultados nativos.
- XI Studio ejecuta los programas escritos por el usuario en el runtime original. El ejemplo calcula 6×7 y aplica H/CNOT/T a q200–q327; cambia el estado y se ejecuta únicamente al pulsar Ejecutar.
- Sistema consulta `NativeRuntime.inspect` sobre el mismo checkpoint `session.rvp` (RVPC2): qubits activos, componentes, bytes de tableaux, reglas Ether, excepciones/enlaces y revisiones.
- Las lecturas de dispositivo, memoria y CPU acumulada del proceso proceden de Android. La CPU acumulada no es un porcentaje de carga total. Las cifras del núcleo son datos de una arquitectura de software, no mediciones de hardware cuántico físico.
- Programas .rxe abre las herramientas nativas existentes, incluido BBY Q E016. Su botón Mesa regresa al nuevo escritorio. No se modificó el entrenamiento de BBY Q.

`RuntimeExecutor` serializa las transacciones nativas de Workbench, DesktopActivity y MainActivity en una sola cola de proceso. Las interfaces cargan el estado confirmado, ejecutan y guardan antes de devolver un resultado. La dependencia Mundo X permanece fijada a `e2778d962af22f6f1a0794058dd4685fc2573966`.

## Datos y persistencia

El estado del núcleo usa `SessionStore`/RVPC2. Los documentos de la nueva mesa, preferencias y ventanas usan `workbench-profile.json`, escrito con `AtomicFile` y confirmado a la interfaz. La copia en `localStorage` es secundaria; al arrancar se prefiere la copia nativa. La restauración de un respaldo de la mesa sigue validando el JSON y pidiendo confirmación.

Las exportaciones usan el selector de documentos de Android y confirman el éxito después de escribir. Las importaciones usan el selector de archivos. El WebView con puente solo sirve los archivos propios bajo `https://reverse.local/`; bloquea navegación de terceros, subframes, conexiones y acceso `file://`. Los enlaces externos se abren en un navegador separado sin puente.

El fondo aprobado se empaqueta en WebP para reducir su tamaño; la imagen original se conserva en el proyecto de diseño. `build-info.json` registra el commit exacto del código usado por la compilación.

## Compilación y pruebas

Con las mismas dependencias fijadas y la firma de desarrollo del proyecto:

```sh
gradle -p reverse-os-android :app:assembleWorkbenchDebug :app:assembleWorkbenchDebugAndroidTest
```

El workflow `workbench-android.yml` compila y verifica firma/ABI. Luego instala la APK en Android 15 y ejecuta `WorkbenchTestRunner`: lecturas JNI/Android, aritmética entera/decimal, rechazo de división por cero, operaciones de 128 qubits, calculadora desde la interfaz, papelera, preferencias y conservación después de cerrar forzadamente el proceso. Conserva APK, registros y capturas. No sustituye una prueba en un Samsung A16 físico.

Esta edición continúa siendo un entorno REVERSE alojado sobre Android; no reemplaza el kernel ni los controladores del teléfono.
