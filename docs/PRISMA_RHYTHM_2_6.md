# PRISMA 2.6 — Ritmo y mecánicas

## Problema y comportamiento

En 2.5, un cubo atrasado podía pasar desde z=0 hasta z=-3,39 durante la ventana
de Flow. Su proyección llegaba a multiplicar su tamaño por más de tres después
del golpe. Ahora los cubos llegan a un plano marcado, mantienen un tamaño de
0,64 unidades y se desvanecen al pasarlo. Su crecimiento aparente es gradual;
las flechas dejan de rotar durante la llegada. Las notas y la selección táctil
usan la misma función de proyección en Canvas, WebGL y Ether Render X.

Flow registra el toque al apoyar el dedo, en lugar de esperar a soltarlo. Las
ventanas de juego son ±240/190/160 ms para Flow/Pulso/Vértigo y un perfecto exige
±55 ms. La precisión visible pondera el momento del golpe; acertar muchas notas
con anticipación ya no produce automáticamente un 100 % de precisión.

## Reloj

La sincronía automática usa la posición de salida del dispositivo informada por
`AudioContext.getOutputTimestamp()` y su correspondencia con `performance.now()`.
Si el dato no es válido, usa las latencias informadas; si tampoco existen,
conserva el reloj de render. El ajuste manual sigue disponible y también desplaza
las luces y celebraciones. Las marcas de los eventos de entrada compensan colas
de hasta 100 ms. No se promete sincronía física perfecta ni se obtiene una
medición de latencia de la diferencia entre dos relojes.

Referencia del contrato de Web Audio:
https://webaudio.github.io/web-audio-api/#dom-audiocontext-getoutputtimestamp

## Mecánicas

- Sostenidas: el análisis encuentra duración en la envolvente de graves/medios.
  Se pulsa la cabeza y se mantiene dentro de su zona hasta completar el aro.
  Soltar antes falla una vez; completar registra un solo acierto XI.
- Secuencias: grupos de 3–4 ataques reales tienen numeración, enlaces y gestos
  ordenados. La frase se completa una sola vez, y fallar una nota la interrumpe.
- La demo en Flow tiene 9 sostenidas y 24 frases, con 119 notas en total. Las
  canciones importadas dependen de sus propias características musicales.
- Flow despeja las otras notas mientras se sostiene. En modos más rápidos las
  notas que coinciden se desplazan fuera de la posición del dedo sostenido.
- Pausar conserva el estado; al continuar una sostenida se ofrece preparación
  para volver a sujetarla. Se puede desactivar la nueva mecánica en Ajustes.
- Las celebraciones de frase no simulan aciertos ni añaden eventos falsos al
  contador de XI. La puntuación continúa usando la ABI de eventos original.

## Continuidad y pruebas

Se conservan `org.reverse.prisma`, su firma de distribución y el origen WebView.
La prueba Android instala 2.5, escribe un récord, actualiza a 2.6 y comprueba su
conservación. Un WAV local con tonos sostenidos y frases conocidas se analiza y
se juega dentro del WebView con puntuación XI y renderizado Ether.

Las pruebas de `prisma-note-flow.mjs` cubren tamaño después del golpe, llegadas
a varios tempos, reloj de salida, inicio/final/repetición de sostenidas, salida
temprana, pausa/reenganche y frases interrumpidas. Las suites históricas siguen
ejecutándose. El rendimiento del teléfono físico queda por medir.
