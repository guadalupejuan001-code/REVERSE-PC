# PRISMA 2.0 — plan de implementación y estado

Base recuperada: REVERSE-PC PR #33, rama codex/prisma-rhythm-20261028.
Trabajo incremental: codex/prisma-2-musical-stage-20261101.

## Principios obligatorios

1. La canción decodificada es el reloj de verdad. No usar timers independientes para lanzar efectos musicales.
2. Una explosión grande necesita un hito de combo Y un acento musical detectado en un intervalo breve.
3. Mantener el flujo RXE3/XI de puntuación, importación local y aislamiento.
4. Los cubos 3D (notas y focos) usan Ether Render X donde el host nativo ofrece el protocolo ether-render-x-cuboids-v1. Las estelas y haces de luz son una superposición Canvas, NO un supuesto nuevo material volumétrico de Ether Render X.
5. El navegador puede conservar la ruta WebGL/COSMIC existente y Canvas de reserva; no afirmar que esas rutas son Ether Render X.
6. No exigir destellos intensos para jugar: respetar «Efectos suaves».
7. Toda afirmación de FPS/latencia necesita mediciones en el Android real.

## Ciclos

| Ciclo | Alcance | Estado |
| --- | --- | --- |
| 01. Dirección musical | Clasificar acentos fuertes con datos de audio, energía por ventanas, reloj de canción, reinicio/pausa/seek | Implementación inicial terminada |
| 02. Beatmap inteligente | Densidad y direcciones por bandas grave/medio/agudo, tempo local, validación con pistas sintéticas | Implementado; CI Android aprobó el 2026-11-01 |
| 03. Maquinaria de concierto | Seis focos articulados, bases/cabezales nativos, juntas y vigas de metal, programa escénico por compases, guardarraíl de 64 cuboides, luces adaptativas | Validado en emulador Android 15 (workflow 41288455075) |
| 04. Combos musicales | Cinco niveles de explosiones prismáticas, carga y liberación por acento, sincronía del concierto, control de intensidad y coste | Validado en emulador Android 15 (workflow 41290171414) |
| 05. Materiales y escenarios | ABI material v2 (vidrio facetado, aleación, lentes), sombreado dentro de Ether Render X, suelo especular, oráculos de exactitud y fallback v1 | Validado en emulador Android 15 (workflow 41320011018) |
| 06. Android/QA/optimización | Selección precisa de notas, cola final, audio de prueba limitado, control de partículas, bench CPU nativo, emulador Android, diagnóstico y calibración | Implementado; falta cerrar validación de este commit y prueba en móvil físico |

## Ciclos iniciales — director musical y escenario

apps/prisma/web/music-stage.js convierte onsets, duración, BPM y una envolvente energética en acentos y energía normalizada. Descarta tiempos inválidos, elimina picos muy próximos conservando el más intenso y diferencia acentos mayores. Todo el cálculo es local.

MusicStageDirector mantiene un cursor sobre los acentos y solo anuncia un gran evento cuando se llega a 10, 20, 30, 50, 100, 150, etc. de combo y existe un acento mayor muy próximo, en una ventana acotada por el tempo. Si no existe, el evento grande no ocurre. Un fallo cancela la celebración pendiente. Si un cuadro llega con retraso mayor de 180 ms, se omite en vez de lanzar una explosión fuera del compás. Los mapas sintéticos para audio ambiental no habilitan celebraciones grandes.

Scene integra seis descriptores 3D de focos móviles (dos columnas, tres profundidades) con la ruta de cubos de Ether Render X. Los haces, anillos y fragmentos de la celebración se dibujan en la capa 2D del propio juego. Su brillo se relaciona con la señal de energía y los acentos. Los giros suaves no usan animación aleatoria.

Las explosiones no se generan por intervalos de reloj ni por alcanzar el combo aisladamente. Los efectos siguen vinculados a la posición temporal de la canción al pausar y continuar.

## Comprobaciones de desarrollo

- Lógica del director: 17 aserciones de tempo, filtrado, energía, calendario de explosiones, repetición, cancelación, retroceso y fallback ambiental.
- Prueba sintética adicional: parámetros y cantidad de focos nativos, dibujo de haces y modo reducido.
- Prueba repetible en Node: node tests/prisma-stage.mjs.

**La compilación y emulación Android del Ciclo 02 terminaron satisfactoriamente** (workflow #41286237762); eso NO equivale a una medición en teléfono físico. El Ciclo 02 detecta transitorios en tres bandas y deriva tempo por ventanas, pero NO separa instrumentos ni transcribe notas o melodías. El tempo local puede sufrir ambigüedad de medio/doble tiempo. El Ciclo 03 incorpora cabezas y apoyos nativos articulados mediante piezas cúbicas y juntas con líneas 2D; NO es iluminación volumétrica físicamente basada, cinemática de esqueletos 3D arbitrarios ni materiales metálicos PBR. Esta nueva revisión todavía necesita la prueba Android de su propio commit.

## Construcción en la base RXE3

Usar los comandos existentes de docs/PRISMA_RXE_GRAPHICS.md. El empaquetador de scripts/build-prisma.mjs incluye todos los ficheros de apps/prisma/web. La puntuación sigue en apps/prisma/game.xi; no se modificó en estos ciclos.


## Ciclo 02 — lectura espectral y beatmaps (implementación)

- music-analysis.js: procesa audio local decodificado (primeros dos canales) a ventanas de unos 20 ms; usa filtros paso bajo para aproximar regiones grave, media y aguda sin FFT masiva ni peticiones de red. Calcula energía RMS, ataques de amplitud por banda, descarta ruido bajo un umbral relativo y etiqueta heurísticamente cada evento: bass, percussion, melody o mixed.
- Estima autocorrelación de eventos por ventanas temporales y agrega segmentos locales de BPM; las ventanas superpuestas y una mediana atenúan errores aislados. La precisión depende de que existan ataques regulares en el audio. En música ambiental sin transitorios se conserva un mapa sintético, explícitamente etiquetado como tal.
- music-stage.js: makeIntelligentChart usa las etiquetas, fuerza del ataque, energía local y BPM del segmento para separar Flow, Pulso y Vértigo. Graves producen gestos verticales bajos, agudos cortes laterales alternos y medios trayectorias conectadas. Los tiempos de impacto vienen de ataques acústicos existentes; no se inventan golpes para densificar patrones salvo el fallback explícito.
- app.js: conserva audio, entrada, UX, puntuación y estado XI, pero alimenta el mapa y director del escenario con los datos espectrales y presenta la indicación aproximada de tempo variable cuando corresponde.
- La frecuencia local también ajusta la ventana de programación de explosiones y el movimiento de los focos. No se cambia el contrato de cuboides de Ether Render X.
- tests/prisma-music-analysis.mjs: pruebas sintéticas graves/agudos/medios, tempo 100→140 BPM, dificultades, orden temporal, estabilidad del caso 120 BPM, silencio y estéreo en contrafase. Ejecutar: node tests/prisma-music-analysis.mjs.

Siguiente: Ciclo 03 (mejorar brazos mecánicos, cinemática y visualización con materiales nativos que soporte realmente la ABI).


## Ciclo 03 — escena mecánica musical (2026-11-01)

- apps/prisma/web/concert-rig.js: programa offline por compases. Mide la energía de la canción y reconoce estados visuales quiet, groove, build, impact, peak, release, calculados por variaciones energéticas; no infiere letras, géneros ni un detector de drops perfecto. Integra BPM variable preservando continuidad del tiempo musical para los movimientos.
- Seis focos, tres a la izquierda y tres a la derecha, con base fija, codo calculado y cabezal móvil. Brazos de articulación y vigas se dibujan como líneas metálicas proyectadas 2D; cuerpos cúbicos de las bases y cabezales se resuelven mediante el observador espacial Ether Render X nativo en Android. En el navegador se usa el adaptador de referencia WebGL o Canvas disponible.
- **Sin flechas falsas:** la dirección -1 en el protocolo de cuboides PRISMA indica una pieza escénica sin flecha. Sigue habiendo flechas 0..3 en las notas. Esta opción aprovecha la extensión de EtherRenderSpatial::Body, que ya admite -1. El paquete se valida en PrismaXRender::Frame. WebGL respeta la misma semántica.
- **Prioridad jugable:** las notas se añaden primero al paquete de cubos. Los cabezales, bases y codos solo utilizan el presupuesto restante, con límite de 64 cuboides en la ruta nativa; al agotarse se sacrifica decoración, nunca una nota. Alta: hasta 18 cuerpos escénicos. Automática: hasta 12. Ahorro: 2 (uno por lado). La calidad automática puede reducir las cabezas cuando caen los FPS.
- **Luces y seguridad:** seis haces de luz en una superposición Canvas 2D con barridos controlados, brillo acotado, articulaciones y pulsos de piso. No utiliza ráfagas estroboscópicas de pantalla completa. «Efectos suaves» mantiene las cabezas inmóviles y los haces tenues.
- **Determinismo y reproducción:** cualquier posición de las luces es función del tiempo de audio y del mapa energético/tempo; al pausar, continuar o buscar tiempo no se ejecuta una simulación física divergente.
- tests/prisma-concert-rig.mjs: prueba reproducible con sección calma/ascenso/pico/descanso, continuidad en BPM variable, seis articulaciones, congelación reducida, modo batería, validez ABI y prioridad de las notas en el límite de 64.
- tests/prisma_xrender.cpp: cobertura nueva para los cuerpos escénicos con dirección -1 y rechazo de campos fuera de rango. Instrumentación Android valida la presencia de cuerpos nativos en la escena sin presuponer el mismo número para todos los ajustes.

Los focos proyectan también conos translúcidos y pequeñas huellas de luz en el escenario. Son polígonos 2D con degradados derivados del movimiento musical, no un shader volumétrico oculto; su intensidad está acotada para no tapar las notas.

**Pendientes de otros ciclos:** geometría 3D no cúbica, superficies metálicas PBR, niebla volumétrica real y benchmark de Android físico. El navegador WebGL no es Ether Render X. La apariencia de varillas y vigas del ciclo 03 se compone en el overlay, pero sus cuboides no se falsifican: provienen del renderizador nativo.


## Publicación segura y actualización de instalaciones

La compilación del juego se etiqueta ahora como PRISMA 2.0.0 (RXE3). Antes, el paquete seguía identificándose como 1.2.0 incluso después de los ciclos 01–03: una instalación antigua podía conservar el ejecutable anterior debido a la preferencia de inicialización 1.2.

El host REVERSE introduce el estado prisma-2.0-seeded, independiente del estado 1.2. El instalador identifica el binario incluido y solo reemplaza imágenes de PRISMA que coincidan exactamente con una lista de hashes SHA-256 publicados en artefactos previos de GitHub Actions. Un ejecutable personalizado/desconocido nunca se sustituye por solo coincidir en nombre, app_id o versión. Una app eliminada no se restaura. La lista incluye las imágenes oficiales RXE 1.1, RXE3 2.5.3, 2.5.4, ciclo 01 y ciclo 02.

Para conservar los registros y ajustes de la WebView, el nuevo PRISMA oficial reutiliza el origen HTTPS local del ejecutable oficial instalado previamente. El host compara la identidad SHA-256 del ejecutable abierto con la imagen oficial incluida antes de permitir esa reutilización; los RXE personalizados siguen aislados por hash propio. No se reintroduce navegación, red, acceso a archivos arbitrarios ni se relaja CSP.

El estado RVPC2 de XI permanece individual por identidad del ejecutable; los récords locales de la UI se guardan en la WebView y usan el origen conservado. La validación Android debe incluir la conservación de ese origen y las rutas de actualización oficial, personalizada y eliminada. No confundir los registros UI preservados con una migración completa del estado RVPC2 entre ejecutables.

Se verifican las firmas SHA de artefactos oficiales descargados del proyecto. El mecanismo preserva datos para versiones reconocidas; las compilaciones oficiales no incluidas en la lista solo podrán instalarse mediante importación explícita, evitando reemplazos inseguros.


## Ciclo 04 — espectáculo musical de combos (2026-11-01)

Implementación: music-stage.js, combo-spectacle.js, concert-rig.js y engine.js. Se mantiene la puntuación XI de game.xi sin modificaciones.

- El jugador alcanza uno de los hitos 10/20/30/50/100/150... El director busca un acento mayor *medido* dentro de un horizonte corto y ajustado al BPM local. Se favorece un drop real cuando la canción lo permite; de lo contrario se utiliza un acento fuerte próximo. Un combo sin acento disponible NO puede crear una explosión mayor. No hay timers propios ni Math.random para elegir la liberación.
- Mientras espera ese acento, aparece una carga visual discreta calculada a partir del tiempo de audio. Un fallo elimina el evento pendiente. Una pausa congela el tiempo de audio. Una búsqueda hacia atrás reinicia la cola; un cuadro que llega más de 180 ms tarde descarta el efecto antes de soltarlo a destiempo.
- El efecto se convierte en un plan determinista, inmutable y temporalmente acotado: spark (x10), surge (x20), prism (x30), cascade (x50), finale (x100+). Produce hasta 3 ondas y 40 fragmentos geométricos 2D en el modo más alto. Los fragmentos dependen únicamente del combo y el tiempo musical, nunca de la velocidad de los frames.
- Drops acústicos confirmados pueden abrir dos alas prismáticas; el solo hito del combo no declara un drop. La envolvente decae y la intensidad máxima de los focos permanece limitada para no deslumbrar, incluso durante el final.
- La cinemática del concierto reacciona a la envolvente del evento. Modo batería: máximo 8 fragmentos, una onda y la geometría 3D de cabezales ya reducida. «Efectos suaves»: cero fragmentos, una onda tenue, cabezas inmóviles y brillo limitado. Máximo tres eventos visuales activos.
- Los flashes son locales y progresivos; no hay estrobo de pantalla completa ni modificación de muestras musicales. Ether Render X sigue resolviendo las notas y cuerpos nativos, mientras que las ondas y fragmentos se presentan como efectos compuestos.
- La prueba tests/prisma-combo-spectacle.mjs verifica tiempo de carga/liberación, no repetición, cancelación, descarte de cuadros tardíos, niveles, número de fragmentos, renderización con el observador nativo simulado y reglas de reducción. Se integra a la CI del proyecto junto con suites anteriores.

**Versionado e instalación:** el nuevo empaquetado anuncia PRISMA 2.1.0 (Ciclo 04). REVERSE reconoce el hash SHA-256 del ejecutable oficial de PRISMA 2.0.0 del Ciclo 03 como predecesor verificado; crea el flag específico prisma-2.1-seeded y preserva el origen de récords/ajustes de WebView sin sobrescribir ejecutables personalizados. La memoria XI RVPC2 continúa aislada por identidad de ejecutable; los récords de la UI sí conservan su origen cuando la actualización es oficial reconocida.

**Estado de validación al registrar este documento:** el código ha superado pruebas funcionales sintéticas del director, pero las pruebas de integración completas de este commit y sus artefactos Android quedan condicionadas a la ejecución de GitHub Actions.


## Ciclo 05 — materiales y profundidad (2026-11-01)

**Objetivo:** mejorar superficies REALES del observador nativo, sin crear la ilusión de que una capa CSS es un material 3D. Esta versión se etiqueta PRISMA 2.2.0.

### Extensión verificable de Ether Render X

- El paquete de escena conserva cabecera de 16 floats y 12 floats por cuerpo, máximo 64 cuerpos y la misma cámara/intersección exacta. La versión 1 mantiene estrictamente el campo reservado a cero. La versión 2 reutiliza SOLO ese campo como ID entero de material: 0 = legado, 1 = prisma facetado, 2 = aleación cepillada, 3 = lente luminosa. No hay cabecera/cuerpos de tamaño ampliado.
- El host Android añade ReverseGraphics.xRenderMaterials() que anuncia la compatibilidad prisma-materials-v2 mientras xRender() sigue devolviendo el contrato v1. La nueva app pregunta por capacidad; en hosts antiguos envía de forma segura escenas v1, sin pedir materiales inexistentes. Ejecutables previos emiten v1 y continúan funcionando.
- scripts/xrender_extension.py incorpora el material directamente al mundo_x::EtherRenderSpatial::Body original, conservando el mismo planificador por regiones y rayo/caja exactos. No se sustituye Ether Render X por WebGL. La selección del material solo actúa en shade_cube, después de resolver el cuerpo más próximo. El material 0 conserva la lógica anterior sin cambio. El vidrio muestra facetas y resaltado angular, la aleación tiene reflejo especular direccional y la lente una contribución radial. Son materiales **estilizados**, no trazado físico completo de refracción, mapas de entorno ni PBR calibrado.
- El rasterizador WebGL de navegador, que NO es Ether Render X, incorpora aproximaciones GLSL a estos tres acabados para conservar la intención visual fuera de Android. Se añade un brillo de suelo procedimental tenue tanto al shader de fondo de GLES del presentador nativo como a la ruta WebGL de navegador; NO se afirma que refleje exactamente objetos de la escena.
- Scene.cube entrega material facetado a las notas (salvo ahorro) y Scene.stageRig envía aleación para los soportes y lentes para las cabezas. En calidad «Ahorro» se utiliza material 0 para limitar trabajo adicional.
- Las reglas de puntuación apps/prisma/game.xi, los acentos musicales, combos, aislamiento RXE3, id/profundidad y el orden de nota-antes-decoración NO se modifican.

### Gates de exactitud y compatibilidad

- tests/prisma_xrender.cpp compara pixels del protocolo 2 material 0 con el protocolo 1 original, comprueba que materiales 1/2/3 generan superficies diferentes conservando cobertura y alfa, valida los tres contadores de material y rechaza materiales no enteros/fuera de rango y datos v1 no reservados.
- tests/prisma-materials.mjs prueba negociación de capacidad y fallback en Android antiguo, las posiciones del campo material, la distribución de materiales por notas/focos y la reducción de efectos en batería. El CI mantiene oráculos geométricos de millones de puntos, pruebas anteriores de XI/RXE y emulador Android.
- Instrumentación Android: pide la capacidad v2 y comprueba que existen cuerpos facetados nativos en una pantalla de PRISMA antes de ejecutar la interacción.
- La versión oficial 2.2.0 recibe un flag propio de publicación y actualiza únicamente los SHA-256 oficiales conocidos, incluido el RXE final 2.1.0 del ciclo 04. Se conserva el origen local WebView de récords/ajustes reconocidos; el estado XI RVPC2 no se intercambia con otros ejecutables.

**Límites todavía existentes:** cubos y articulaciones cúbicas, sin mallas generales; sin refracción física, reflejo geométrico perfecto, geometría de partículas nativa ni niebla volumétrica. Las afirmaciones sobre FPS deberán compararse en teléfono físico durante el ciclo 06, no extrapolarse a partir de la emulación.


## Ciclo 06 — jugabilidad, calibración, eficiencia y QA integral (PRISMA 2.3.0)

### Cambios auditados

- rhythm-qa.js: selección del cubo con mejor coincidencia temporal y espacial cuando varios eventos comparten la ventana de corte. Las notas ya completadas o perdidas no vuelven a elegirse. En modo «Corte preciso» se filtra correctamente por sentido del gesto. Se mantienen Flow táctil, teclado, multilocalidad y la tolerancia por dificultad.
- El final de la canción espera a que concluya la ventana de impacto de las últimas notas, incluida la calibración de latencia positiva, antes de cerrar resultados. Se evita perder notas válidas que llegan al límite del audio.
- El feedback de cortes no perfectos indica «ANTICIPADO» o «TARDE» según la diferencia real entre el reloj WebAudio y la marca de la nota. No hay cambios en la autoridad XI de puntos, combo o fallos. Una pulsación perfecta conserva su puntuación y feedback previos.
- El selector de pistas acepta audios decodificables de 3 segundos a 30 minutos y hasta 100 MiB de archivo. Estos límites protegen la memoria y evitan analizar archivos desmesurados accidentalmente; no representan una limitación arquitectónica inamovible.
- music-analysis.js: ahora procesa ventanas de tempo ordenadas mediante índices deslizantes; evita recorrer todos los transitorios de la canción en cada segmento local. La estimación de BPM, las etiquetas acústicas y las ventanas de 12 s se conservan.
- engine.js: conserva la adaptación automática de la resolución y el orden de prioridad de las notas nativas. Reduce partículas no esenciales en Ahorro (6 y máximo 90 activas), auto con calidad degradada (9 y máximo 180), Efectos suaves (4) y hasta 27 en «Máximo detalle»; no modifica la cantidad de cubos necesarios para jugar.
- Ajustes: se muestra el motor realmente seleccionado (Ether Render X nativo, Graphics/COSMIC WebGL de navegador o Canvas de reserva), y se incluye un botón «Restablecer 0 ms» para la calibración de latencia. La interfaz conserva las preferencias previas.

### Verificación reproducible

- tests/prisma-gameplay-qa.mjs: gestos simultáneos, dirección de corte, tap en Flow, teclado, corrección positiva/negativa, error temprano/tardío, cola de canción, continuidad reloj audio en pausa/reanudación, escalado de partículas y análisis sintético de tres minutos.
- tests/prisma_performance.cpp: prueba aislada en máquina CI del observador Ether Render X con 18 cuerpos mixtos en 960×540; documenta mediana y percentil 95 de duración CPU por fotograma de render, fracción de superficies y candidatos y presupuesto de píxeles en calidad auto/alta/ahorro. Sus resultados NO son FPS del teléfono ni del compositor Android.
- Instrumentación Android 15: valida que Ajustes muestre el motor nativo, que el botón de calibración restablezca y persista 0 ms, y registra el total de trabajos de render nativos observados durante una ventana real de reproducción, la duración de esa ventana y el último tiempo CPU del motor. Se guarda en evidence/prisma-ui/prisma-emulator-performance.json; el número de trabajos por segundo en el emulador NO equivale a la frecuencia de pantalla real.
- El CI sigue exigiendo el test de id/profundidad/color nativo, el RXE3 con XI, controles táctiles, migración del juego y aislamiento de otras aplicaciones. Nunca se asegura que la GPU renderiza miles de cuadros ni se atribuye coste cero a las capas WebView/GLES.

### Versionado, límites y siguiente tarea externa

- La versión candidata PRISMA 2.3.0 conserva las actualizaciones de 1.1, 1.2, 2.0, 2.1 y 2.2 oficiales por huellas exactas SHA-256 y mantiene la protección de ejecutables personalizados y el origen de los récords de WebView. Las memorias XI se mantienen separadas por identidad.
- El resultado de la CI de ciclo 06 y los archivos APK/RXE deben proceder del mismo commit SHA y aprobar la comprobación de hash; todavía no constituyen una medida del funcionamiento de la APK en el dispositivo físico del propietario.
- **Prueba física necesaria después de instalar:** contraste en pantalla táctil, latencia real con auriculares Bluetooth, ausencia de pérdida de notas y consumo/temperatura en sesiones prolongadas. Los costes reales de CPU/GPU y fotogramas por segundo se obtienen con perfilado sobre el Samsung real, no extrapolados del emulador.


## Ciclo 06 — pulido y verificación final

- Política de adaptación visual aislada de la lógica XI: degradación por 20 frames lentos, recuperación tras 120 frames rápidos y 8 segundos de histéresis para evitar oscilaciones. Se preserva la resolución adaptativa anterior.
- Presupuesto explícito de partículas por calidad; el ahorro y los efectos suaves limitan material y partículas. La puntuación, temporización de las notas, beatmaps y combos no se alteran.
- Test repetible: node tests/prisma-quality.mjs. Se ejecuta junto con suites anteriores y el pipeline Android 15.
- Versión 2.3.0 para distinguir el último ciclo. Las mediciones de FPS en un teléfono físico siguen pendientes: una emulación no es un benchmark de hardware real.
