# X Render XI — experimento controlado A/B

## Hipótesis falsable

> Escribir la geometría en **XI Machine v1**, conservando Ether/InverseMemory,
> mejora la velocidad del renderizador nativo X Render.

**No se presupone un resultado positivo.** La prueba mide el ejecutor real de
XI, no un intérprete JavaScript ficticio. No cambia el motor de REVERSE, sus
librerías ni el juego publicado.

## Implementación

- \`triangle-frame.xi\`: el único algoritmo de generación de píxeles nuevo.
  Dos triángulos con oclusión, aritmética entera, protocolo de píxel y hash.
- \`native-reference.cpp\`: adaptador **solo de prueba**, sin intersector,
  sombreador, planificador ni rasterizador nuevo. Invoca literalmente
  \`mundo_x::EtherRenderEngine::triangle\`, \`prepare\` y \`observe\`.
- \`verify-and-benchmark.cjs\`: oráculo geométrico independiente y controlador
  de medición, sin participación en los píxeles generados por XI.

Escena: dos triángulos sobre planos 3D z=0 y z=2 observados con FOV 90°,
la primera ocluida por la segunda. Ambos modelos producen una lista ordenada
de clases de píxel: fondo 0, triángulo trasero 2, triángulo frontal 3. La
comparación exige igualdad **por cada píxel** entre tres cálculos: XI original,
X Render nativo y el oráculo geométrico independiente.

Resoluciones de prueba: 48×24, 96×48 y prueba de límite a 192×96. Son escenas
de laboratorio, no la carretera real ni un videojuego HD.

Métricas: tres ejecuciones por versión, tiempo de reloj de proceso (mediana)
incluyendo arranque, entrada/salida y los píxeles JSON para ambos. XI incluye
además la transacción de RVPC2; por ello el tiempo **no** mide únicamente el
núcleo gráfico y favorece estructuralmente al proceso nativo. La comparación
sirve para detectar órdenes de magnitud y cuellos de botella, no como
benchmark GPU o prueba de rendimiento por hardware idéntico.

\`XI Machine v1\` dispone de 16 registros y límite de 1.000.000 de pasos
por transacción, de modo que una pantalla HD necesitaría un protocolo
nuevo por bloques, un ejecutor vectorizado, o ambos. No atribuir a la
compresión de estados reducciones automáticas del trabajo por píxel.

## Seguridad e integración

La prueba vive únicamente en esta rama experimental; no fusionar un
renderizador XI de baja resolución con el X Render de producción sin aprobar
las pruebas de imagen completa, de rendimiento y Android. El adaptador C++
del test **no forma parte del motor del juego**, y no se agregan nuevas
rutinas de geometría C++.

Para reproducirla, ejecutar el workflow
\`.github/workflows/xi-render-ab.yml\`, revisar \`results.json\` y los
dos \`xi-*.ppm\` exportados directamente de las observaciones XI.

**Criterio para aceptar la hipótesis:** XI debe igualar píxeles y superar al
nativo en la misma máquina, con métricas repetibles. Para aceptar HD móvil,
además se requieren una ABI de salida por bloques y pruebas con hardware real.

## Segunda hipótesis: descriptor XI por filas, no píxeles XI

\`span-frame.xi\` ejecuta una variante geométrica más compacta: por fila
calcula 2 intervalos con los triángulos superpuestos y publica cuatro
enteros desde XI; la regla de oclusión (delante/sobre el fondo) es explícita.
El decodificador en el test JavaScript expande esos tramos a píxeles. **El
decodificador es un adaptador de presentación**; por tanto, no puede
afirmarse que los 921.600 píxeles de una imagen HD estén calculados en XI.

\`span-verify-and-benchmark.cjs\` ejecuta XI real y los confronta bit por bit
contra la salida binaria del X Render nativo y contra el oráculo geométrico,
sin aproximaciones. Mide 96×48, 1280×720 y 1920×1080.

En esta variante se mide el **tiempo de proceso XI más decodificación
en el anfitrión**, frente al proceso nativo y su generación completa de
píxeles. Son algoritmos y costos internos diferentes (spans frente a
intersecciones de rayos). Es válido como comparación de arquitecturas de
presentación, no para afirmar que el lenguaje XI ejecuta más rápido una
misma instrucción ni que Android podrá dibujar a 60 FPS.

No ampliar estas conclusiones a mallas generales, texturas, sombras,
geometría arbitraria o escenas sin continuidad por filas. La aceptación
de X Render XI completo necesita memoria/buffers nativos, tratamiento
de materiales y mediciones dentro del teléfono.


## SUPER RENDER XI — especificación de evolución (sin límites arbitrarios)

La representación canónica es una escena compacta, no un bitmap persistente.
El ejecutor XI será la autoridad de geometría, materiales, transformaciones,
visibilidad, niveles de detalle y comandos de regiones. El anfitrión solo
materializa un framebuffer o lo entrega a la pantalla, sin recrear las
reglas del motor. La siguiente ABI de salida debe soportar:

- \`frame_begin width height format revision\`
- \`span y x0 x1 material depth\`
- \`tile x y width height descriptor\`
- \`frame_end revision checksum\`

Estos son **contratos propuestos**, no instrucciones que ya entienda XI v1.
Se implementarán en una versión nueva y optativa del ejecutor, con pruebas
de compatibilidad de programas antiguos. Los presupuestos serán configurables
por trabajo y recurso, con cancelación, límites de memoria y rollback.
"No hay límite fijo de mundo" significa espacio lógico generado bajo demanda;
no significa RAM, CPU o almacenamiento físicamente infinitos.

Orden de implementación:
1. ABI de framebuffer por bloques, validación de rangos y cancelación.
2. Compilación XI de descriptores geométricos en vez de una instrucción por píxel.
3. Materiales XI con profundidad, sombreado y oclusión de múltiples objetos.
4. Streaming de regiones, LOD y caché temporal acotada.
5. Prueba de estrés HD/Full HD con escenas crecientes y medición en Android.

Regla de aceptación: igualdad visual, ausencia de corrupción de estado,
rendimiento medido y compatibilidad con REVERSE-PC. No eliminar la ruta
funcional actual hasta completar esas verificaciones.
