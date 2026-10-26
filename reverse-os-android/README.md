# REVERSE OS v0.5 — escritorio natural con BBY Q en XI

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

## BBY Q: una aplicación instalada en el escritorio

REVERSE OS v0.5 añade **BBY Q** como programa del escritorio,
barra de tareas, Inicio y búsqueda. El botón abre una ventana real
con diálogo y dos controles de aprendizaje:

- **Preguntar:** introduce una microoración en letras ASCII minúsculas,
  por ejemplo `cuarto contiene llave?`. `readline.xi` la tokeniza,
  `ask.xi` busca hechos o una demostración de dos pasos,
  `reflect.xi` decide qué aprender si desconoce la respuesta,
  y `speak.xi` produce los bytes de respuesta.
- **+ PALABRA:** enseña una palabra como observación con tres sensores
  categóricos (0..3). La relación sensorial y el léxico nacen en XI.
- **+ RELACIÓN:** enseña una relación observada o refutada con
  sujeto, predicado y objeto; `relate.xi` actualiza evidencias y
  `calibrate.xi` comprueba si corresponde inferencia transitiva.

### Instalación y persistencia, sin borrar tu REVERSE-PC

El primer acceso a BBY Q activa el **runtime XI del mismo
`session.rvp` del escritorio**. No se instala un segundo
núcleo, ni un modelo conectado a Internet.

1. Se abre la sesión existente sin reiniciarla.
2. Si el organismo BBY Q todavía no está presente, los programas XI
   aprenden y certifican cuatro bancos (XOR, XNOR, AND, OR). Si ya
   existen cuatro bancos válidos, se reutilizan.
3. `birth.xi`, `ground.xi`, `relate.xi` y `calibrate.xi`
   crean sus primeros símbolos, sinónimos y relaciones mediante
   experiencias del `curriculum-v1.txt` incluido. Este archivo
   contiene observaciones y palabras, **no respuestas prefabricadas**.
4. Se comprueban `e008/audit-organism.xi`,
   `language/audit.xi` y una inferencia real nueva.
5. **Una única transacción `SessionStore.writeState`** publica todo
   en el RVPC2. Ante error, el archivo anterior no se sustituye.

Los programas originales `BBYQ_*.xi` quedan registrados en
**Archivos** y disponibles desde XI Studio; se conserva el resto de
programas y del estado de la computadora, incluida su memoria Ether.
Las preguntas y las lecciones subsiguientes también se ejecutan
en XI con commit tras verificación y rollback ante error.

### Origen y alcance

Los 24 programas empaquetados son **copias sin modificar del código
original del repositorio BBY-Q**, fijadas en commit
`7dfa6c31247cf609128db78908313a6ce41c0b80`.
El script `reverse-os-android/scripts/prepare-bbyq.sh` las prepara
para el APK y comprueba su SHA. El código Java es solo interfaz
Android y transporte de bytes/estado hacia el **mismo XI nativo**;
**no implementa un nuevo algoritmo de inteligencia ni sustituye
el aprendizaje por respuestas Java**.

**Límites:** BBY Q entiende por ahora microoraciones
`sujeto predicado objeto?`, con palabras ASCII de 1..8 caracteres,
y sus sensores son artificiales, no cámaras ni micrófonos. No hay
conversación natural abierta, síntesis de voz, acceso a un LLM de
terceros ni ventaja cuántica demostrada. El intérprete original XI
aún emplea bootstrap C++; MX es la dirección del lenguaje fuente
canónico, sin cadena autocompilada comprobada.

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

La compilación CI se llama `REVERSE OS v0.5 — native BBY Q XI desktop`.
Produce el artefacto `REVERSE-OS-v0.5-BBYQ.apk` firmado en modo desarrollo para
`arm64-v8a` (Samsung A16) y `x86_64` (emulador Android 15).

El pipeline valida firma, bibliotecas, arranque horizontal, cambio de
fotogramas en una región central del fondo, logs de FPS y funcionamiento del
código XI con Euclides `r0 = 21`. También verifica que BBY Q se abra,
aprenda y responda mediante XI, **sin perder el resultado anterior de
Euclides ni otros datos del mismo RVPC2**. Conserva capturas y pruebas.

**Importante:** el debug APK de un runner GitHub puede tener firma distinta
de versiones anteriores. Si Android rechaza una actualización, exporta antes
tus datos RVPC2 y programas, desinstala el APK anterior e instala el nuevo;
desinstalar borra los archivos privados.
