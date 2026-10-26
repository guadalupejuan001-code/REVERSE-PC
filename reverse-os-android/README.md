# REVERSE OS v0.3 — Escritorio horizontal con movimiento real

**REVERSE OS** funciona como un entorno de computadora dentro de Android.
La interfaz adopta convenciones conocidas de Windows y macOS: escritorio,
iconos, menú Inicio, búsqueda, barra de tareas y ventanas flotantes.

No reemplaza el kernel de Android; no ejecuta Windows, macOS ni Chromium como
procesos huéspedes XI.

## Arranque

1. Pantalla negra: `welcome.... REVERSE.`.
2. Transición al escritorio panorámico.
3. Fondo orbital violeta animado con **OpenGL ES 3**, usando el renderizador
   adaptativo procedente de **REVERSE Space Glitch V2** y un shader propio
   para REVERSE OS. La CPU no dibuja cada píxel.
4. Accesos directos: **XI Studio, Terminal, Files, Chromium, Ether Core,
   Settings**, y barra inferior con Inicio, búsqueda y aplicaciones.
5. Ventanas con cerrar, minimizar, maximizar y arrastrar; menú lateral
   con Home, Files, Settings, Terminal y About.

## Aplicaciones funcionales

- **XI Studio:** ventana editable de código XI con Guardar y Ejecutar;
  invoca el mismo `QuantumRuntime.execute()` C++ que la CLI y conserva
  el archivo RVPC2 solo cuando la ejecución termina correctamente.
- **Terminal:** `help`, `ls`, `run fichero.xi`, `edit fichero.xi`,
  `core` y `clear`; salida real del intérprete.
- **Files:** programas XI privados.
- **Ether Core:** consultas reales al estado, reglas, qubits y revisiones.
- **Chromium:** navegador sobre el **WebView de Android**, no un Chromium
  binario compilado para la arquitectura XI.
- **Settings:** reinicio, calidad visual **ECO / AUTO / ALTA** y
  **PAUSA / MOVIMIENTO** del fondo.

## Qué motor gráfico participa

Se revisó `mundo-X/docs/render-engine-inventory.md` y
`mundo-X/docs/ether-render-x.md`. **Ether Render X** es el núcleo estructural
objetivo de Mundo X, pero en la revisión indicada aún no disponía de un
backend Android GLES que sustituyera el renderer de producción.

REVERSE OS utiliza en esta versión la infraestructura verificada de
**Space Glitch V2** (`SpaceRenderer` adaptado como
`ReverseOrbitalRenderer`), sin introducir un segundo estado
cuántico. El shader `space.frag` genera una esfera, anillos y partículas
mediante reglas compactas evaluadas directamente por la GPU.

El visualizador **no ejecuta los circuitos cuánticos en la GPU**.
No afirma aceleración cuántica, una tasa FPS fija ni hardware cuántico.
La calidad automática ajusta la resolución interna según FPS medidos.

## Cómo reproducir

El CI `.github/workflows/reverse-os-android.yml` compila para
`arm64-v8a` (Galaxy A16) y `x86_64` (emulador). Necesita Java 17,
SDK Android 35, NDK, Gradle, el checkout de Mundo X en
`e2778d962af22f6f1a0794058dd4685fc2573966` y el overlay
comprobado por hashes.

El artefacto de Actions contiene `REVERSE-OS-v0.3.apk`,
`boot.png`, `desktop.png`, `motion.png`, `result.png`,
logs y la medición FPS del renderer.

Los criterios obligatorios son:
- APK firmada con JNI real de XI y bibliotecas para ARM64/x86_64.
- Inicio visible en horizontal y accesos a las seis aplicaciones.
- Dos capturas separadas muestran cambio real en el centro del fondo;
  el log aporta FPS medidos.
- Abrir XI Studio desde el escritorio, ejecutar Euclides y comprobar
  `r0 = 21`, RVPC2 guardado y regreso al escritorio.
- Regresiones de REVERSE-PC sin alteraciones.

## Limitaciones e instalación

Es un *shell* Android, no un SO arrancable. Las ventanas son ventanas de
aplicación del entorno; la planificación de procesos, GPU, teclado y WebView
dependen del sistema anfitrión. El ejecutor de programas XI sigue siendo
propio del proyecto REVERSE-PC.

Los APK de debug de distintos runners GitHub pueden tener firmas distintas.
Si Android rechaza la actualización sobre una versión anterior, **exporta
primero tus programas y estado**, desinstala y reinstala. Desinstalar borra
el almacenamiento privado.
