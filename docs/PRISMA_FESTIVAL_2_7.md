# PRISMA 2.7 — Festival de mundos

La galaxia se amplía con Puerto neón (arquitectura, lluvia y reflejos), Catedral
polar (auroras, montañas y cristales), Templo abisal (medusas, burbujas y ruinas)
y Sol de obsidiana (eclipse, fisuras de lava y ceniza). Son escenas procedurales
animadas, no imágenes fijas. Se eligen desde el inicio o en Ajustes.

En **Viaje**, la dirección musical propone un cambio cada seis compases y lo
sitúa en un ataque real cercano. Conserva al menos diez segundos entre cambios
y evita cortar un mundo justo al terminar. El fundido dura 1,5 segundos; no
cambia la posición de las notas ni sus tiempos. Las pistas sin acentos medidos
mantienen un único mundo.

## Fuegos y objetivo de precisión

Los cohetes ascienden 480 ms antes de un acento fuerte; la explosión ocurre
exactamente en su marca de audio. Hay peonías, anillos, palmeras y lluvia dorada,
con caída y pérdida de velocidad analíticas. No se añaden sonidos. Los mismos
tiempos producen la misma pose al pausar, reanudar o repetir.

Ocho aciertos consecutivos con error de hasta 110 ms completan una
**constelación**. Un fallo o un acierto fuera de ese margen reinicia la carga.
La celebración usa el ataque real que acaba de sonar (hasta 55 ms después) o
uno dentro de los siguientes 850 ms; sin un ataque cercano no inventa uno.
Incluye los ataques suaves que sí fueron jugados aunque no sean grandes
acentos ambientales. Las constelaciones no suman aciertos ni puntos
adicionales al motor XI. El resultado final muestra constelaciones, sostenidas
y frases.

Se admiten hasta cuatro fuegos simultáneos, con 12/26/40 chispas por fuego en
Ahorro/Automática/Detalle. El límite global incluye las recompensas. Efectos
suaves elimina la pirotecnia y congela la animación ambiental; también hay un
interruptor de fuegos independiente. Las capas de mundo y fuegos recortan sus
trazos fuera de la zona central de golpe. Las notas conservan su resolución y
prioridad en los 64 objetos nativos; los escenarios nuevos no consumen objetos
de ese paquete.

## Referencias de diseño

Se consultaron fuentes oficiales; no se ejecutaron los juegos comerciales ni
se copiaron sus recursos o mapas. La comparación es de decisiones de diseño,
no una medición de superioridad, FPS o latencia entre juegos.

| Referencia | Evidencia oficial | Aplicación en PRISMA |
| --- | --- | --- |
| Beat Saber | Separa velocidad de llegada, distancia de aparición, desfase y entorno en el editor. | Se preserva la llegada estable de 2.6; cambiar de mundo no modifica el contrato de entrada ni el reloj. |
| Synth Riders | Sus Experiences coordinan animaciones y música en una experiencia visual. | Cohetes, explosiones y cambios de mundo responden a marcas del análisis musical. |
| Tetris Effect: Connected | Journey recorre etapas con temas, gráficos y música coordinados con el juego. | Viaje recorre cinco identidades visuales, y las constelaciones muestran una meta de precisión. |

- https://www.beatsaber.com/documentation/preparing-the-song/index.html
- https://synthridersvr.com/
- https://tetriseffect.game/connected/

## Verificación

Once suites Node verifican movimiento, música, reloj, controles, sostenidas,
frases, fuegos, capítulos, límites y recompensas. Una partida automática de un
WAV conocido entra por eventos de teclado, sin modificar la puntuación ni
marcar notas como acertadas: completa tres sostenidas, dos frases y una
constelación con una única fuente musical. El análisis de píxeles de los cinco
mundos verifica que esas capas dejan transparente el centro protegido.

La prueba Android instala la versión anterior, escribe un récord, actualiza y
comprueba que sigue presente. Juega con el renderizador Ether Render X y la
puntuación XI, recorre los cinco mundos, completa las mecánicas y verifica los
fuegos y su desactivación con Efectos suaves. El rendimiento en teléfono físico
queda por medir; los tiempos de un navegador o emulador no lo sustituyen.
