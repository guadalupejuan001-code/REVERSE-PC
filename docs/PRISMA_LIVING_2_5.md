# PRISMA 2.5 — Galaxia viva

Las luces dejan de depender únicamente de alcanzar un combo: los ataques reales
de la canción mueven dos bocinas junto al jugador, sus conos, anillos RGB y un
abanico de rayos. Los acentos fuertes producen supernovas laterales. Los combos
conservan sus celebraciones mayores y su autoridad XI original.

- Dos cajas acústicas con dos drivers, aros RGB giratorios, pequeños medidores
  y ondas de presión visuales; graves, medios y agudos tienen respuestas distintas.
- Hasta 28 rayos en máximo detalle, 18 en automático y 6 en ahorro. Las
  supernovas simultáneas están limitadas a tres y caducan por tiempo de audio.
- Polvo estelar con profundidad, neblina y núcleos de explosión. Los rayos y
  estallidos dejan despejada la zona central de lectura.
- El sonido añadido al cortar se elimina del grafo de audio. Solo suena la música.
- Los trazos usan curvas suaves y un lienzo de resolución independiente del
  regulador de detalle del escenario; cada corte añade un anillo breve.
- FFT Hann, potencia estéreo y flujo espectral positivo en ventanas de 10 ms;
  no se descartan muestras para decimar ni se cancelan canales en contrafase.
  El análisis cede periódicamente al hilo de interfaz. El estimador de tempo
  interpola retardos y la demo usa ataques medidos, incluidos sus silencios.
- El mapa de energía pasa de 250 a 50 ms y conserva las proporciones espectrales
  para dirigir el escenario. No se afirma separación de instrumentos ni lectura
  exacta de notas musicales.

La edición Android independiente `org.reverse.prisma` abre directamente PRISMA
con XI/Ether Render X. Se instala junto a REVERSE; usa su propio espacio de
récords. Las actualizaciones de esta edición conservan su origen WebView. La
integración de escritorio solo migra imágenes anteriores con hash autorizado.

Pruebas: `node tests/prisma-*.mjs` mediante el bucle del workflow
`prisma-living.yml`, validación de puntuación RXE y prueba en Android 15 con
toque real de inicio, cortes, una única fuente musical, dos bocinas, render
nativo, pausa y continuación. Los resultados del emulador no certifican FPS en
el Galaxy físico del propietario.
