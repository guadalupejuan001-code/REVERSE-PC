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
| 02. Beatmap inteligente | Densidad/direcciones dependientes de acento e instrumento; estimación BPM mejorada; pruebas con músicas de ritmos variables | Pendiente |
| 03. Maquinaria de concierto | Seis focos móviles, ráfagas de haces y reacción por beat y energía | Prototipo integrado; falta geometría/articulaciones avanzadas y luces volumétricas nativas |
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

**No es todavía una prueba de juego en pantalla real o Android.** El análisis existente en audio.js aún tiene BPM fijo durante toda la pista y una detección basada en energía, no separa instrumentos; el Ciclo 02 resolverá esas limitaciones. La fase 03 solo tiene un prototipo de focos, no iluminación volumétrica físicamente basada. Debe construirse un ejecutable RXE3 y validar la APK de extremo a extremo antes de considerarla lista para entrega.

## Construcción en la base RXE3

Usar los comandos existentes de docs/PRISMA_RXE_GRAPHICS.md. El empaquetador de scripts/build-prisma.mjs incluye todos los ficheros de apps/prisma/web. La puntuación sigue en apps/prisma/game.xi; no se modificó en estos ciclos.
