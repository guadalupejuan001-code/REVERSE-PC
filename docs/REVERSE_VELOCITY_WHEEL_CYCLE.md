# Reverse Velocity — ciclo del automóvil: animación de ruedas

## Alcance

Trabajo exclusivo del automóvil. La geometría y el diseño de las pistas,
las colisiones y los estados físicos de XI no cambian.

## Implementación de render en XI/REgraphics

- El giro de las cuatro ruedas de un coche cercano procede del avance real
  de su estado XI, no de una animación con un temporizador independiente.
- El jugador usa el progreso de carrera en dirección 278. Los rivales usan
  6016+32*i. Se aproxima la circunferencia de una rueda de radio 34 cm
  por 214 cm para calcular su rotación.
- Las ruedas delanteras giran además alrededor del eje vertical según
  la dirección real del jugador (dirección 256, centro 1000), hasta unos
  28 grados en cada sentido. Las traseras no reciben dirección.
- El LOD lejano conserva ruedas fijas. El bucle evita transformar dos
  veces un vértice que solo tiene varias normales/materiales.
- Los intervalos de índices de rueda se deducen del modelo original,
  sin números de vértice escritos manualmente.

El presupuesto no cambia: 886 triángulos para el coche principal, 300
para cada rival cercano, 110 por LOD lejano y 4056/4096 en el conjunto.

## Validación y límites

La CI comprueba que el programa y la paleta derivados de los scripts de
autoría coinciden con los assets incluidos; ejecuta el renderer XI real
en cuatro variaciones de rodadura/dirección, decodifica XFS1 y comprueba
que los fotogramas sean deterministas y el estado original permanezca
intacto. Estas comprobaciones no constituyen una medida de FPS Android.

La rotación visual sigue el progreso longitudinal de la pista: no simula
el patinaje de neumáticos durante derrapes ni recalcula las normales de
iluminación tras la deformación. El resultado sigue siendo un automóvil
de estética simplificada, no PBR fotográfico; requerirá mediciones en un
Galaxy A16 físico para validar la fluidez.
