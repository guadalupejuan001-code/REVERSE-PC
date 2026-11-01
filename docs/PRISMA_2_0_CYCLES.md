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
| 03. Maquinaria de concierto | Seis focos articulados, bases/cabezales nativos, juntas y vigas de metal, programa escénico por compases, guardarraíl de 64 cuboides, luces adaptativas | Implementado; CI Android del ciclo 03 pendiente |
| 04. Combos musicales | Hitos 10/20/30/50 y múltiplos de 50 desde 100, evento diferido hasta siguiente acento, cancelación por fallo | Prototipo integrado |
| 05. Materiales y escenarios | Mejoras del renderizador, refracción/materiales XI y geometría escénica con oráculos de exactitud | Pendiente |
| 06. Android/QA/optimización | Compilar RXE3/APK, verificar WebView y XI, rendimiento, protección contra mareo, pruebas en móvil físico | Pendiente |

## Ciclo 01/03/04 — cómo funciona el prototipo

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

**Pendientes de otros ciclos:** geometría 3D no cúbica, superficies metálicas PBR, niebla volumétrica real y benchmark de Android físico. El navegador WebGL no es Ether Render X. La apariencia de varillas y vigas del ciclo 03 se compone en el overlay, pero sus cuboides no se falsifican: provienen del renderizador nativo.


## Publicación segura y actualización de instalaciones

La compilación del juego se etiqueta ahora como PRISMA 2.0.0 (RXE3). Antes, el paquete seguía identificándose como 1.2.0 incluso después de los ciclos 01–03: una instalación antigua podía conservar el ejecutable anterior debido a la preferencia de inicialización 1.2.

El host REVERSE introduce el estado prisma-2.0-seeded, independiente del estado 1.2. El instalador identifica el binario incluido y solo reemplaza imágenes de PRISMA que coincidan exactamente con una lista de hashes SHA-256 publicados en artefactos previos de GitHub Actions. Un ejecutable personalizado/desconocido nunca se sustituye por solo coincidir en nombre, app_id o versión. Una app eliminada no se restaura. La lista incluye las imágenes oficiales RXE 1.1, RXE3 2.5.3, 2.5.4, ciclo 01 y ciclo 02.

Para conservar los registros y ajustes de la WebView, el nuevo PRISMA oficial reutiliza el origen HTTPS local del ejecutable oficial instalado previamente. El host compara la identidad SHA-256 del ejecutable abierto con la imagen oficial incluida antes de permitir esa reutilización; los RXE personalizados siguen aislados por hash propio. No se reintroduce navegación, red, acceso a archivos arbitrarios ni se relaja CSP.

El estado RVPC2 de XI permanece individual por identidad del ejecutable; los récords locales de la UI se guardan en la WebView y usan el origen conservado. La validación Android debe incluir la conservación de ese origen y las rutas de actualización oficial, personalizada y eliminada. No confundir los registros UI preservados con una migración completa del estado RVPC2 entre ejecutables.

Se verifican las firmas SHA de artefactos oficiales descargados del proyecto. El mecanismo preserva datos para versiones reconocidas; las compilaciones oficiales no incluidas en la lista solo podrán instalarse mediante importación explícita, evitando reemplazos inseguros.
