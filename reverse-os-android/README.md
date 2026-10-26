# REVERSE OS v0.4 — escritorio natural, colores planos

**REVERSE OS** es una computadora virtual basada en XI y Ether dentro de Android.
El entorno adopta patrones convencionales de Windows y macOS: Inicio, búsqueda,
barra de tareas, aplicaciones y ventanas flotantes que se pueden mover, minimizar
y maximizar.

## Diseño

- Pantalla negra de arranque: `welcome.... REVERSE.`, sin resplandores.
- Escritorio horizontal en tonos de grafito, pizarra y azul suave; tipografía
  legible y aplicaciones nombradas naturalmente en español.
- Fondo procedural con **formas planas y órbitas lentas**; conserva movimiento
  real usando OpenGL ES 3 de Space Glitch V2 (portado), pero no muestra partículas
  espectaculares, efecto de plasma ni filtros de neón.
- Las ventanas mantienen acciones reales: XI Studio (editar y ejecutar),
  Terminal, Archivos, Navegador, Ether Core y Ajustes.
- Ajustes de calidad: ECO / AUTO / ALTA y Pausa / Movimiento.
- Pantalla inicial visible aun cuando falle el núcleo: diagnóstico explícito,
  nunca respuestas simuladas para aparentar ejecución.

## Tecnología que sí se utiliza

La lógica de XI se ejecuta con el `QuantumRuntime` propio del repositorio,
`InfiniteCore` y `Inverse Ether Memory`, sin crear una segunda autoridad.
Los estados guardados siguen en formato RVPC2, con commit tras éxito.

El fondo de pantalla usa un shader GLSL 300 ES para una escena bidimensional
de círculos y líneas. No se afirma aceleración cuántica física ni renderizado
en el aún incompleto backend GLES de Ether Render X. Los FPS mostrados
son medidos por el renderizador Android, con resolución adaptativa.

El navegador usa **Android WebView**, no ejecuta un binario de Chromium
dentro de XI. Android sigue siendo el sistema operativo anfitrión y gestiona
la GPU, el teclado y el kernel.

## Instalación y prueba

La compilación CI se llama `REVERSE OS v0.4 — minimal flat landscape desktop`.
Produce el artefacto `REVERSE-OS-v0.4.apk` firmado en modo desarrollo para
`arm64-v8a` (Samsung A16) y `x86_64` (emulador Android 15).

El pipeline valida firma, bibliotecas, arranque horizontal, cambio de
fotogramas en una región central del fondo, logs de FPS y funcionamiento del
código XI con Euclides `r0 = 21`. Conserva capturas y pruebas de RVPC2.

**Importante:** el debug APK de un runner GitHub puede tener firma distinta
de versiones anteriores. Si Android rechaza una actualización, exporta antes
tus datos RVPC2 y programas, desinstala el APK anterior e instala el nuevo;
desinstalar borra los archivos privados.
