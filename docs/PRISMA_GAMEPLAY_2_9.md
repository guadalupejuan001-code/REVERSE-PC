# PRISMA 2.9 — Flow para aprender y recuperar

Flow deja de retirar notas por superar una ventana de 240 ms. Un cubo pendiente
permanece disponible hasta que lo cortes o decidas finalizar la sesión. La
música continúa con su reloj original: un corte tardío se registra como
recuperado y obtiene menos puntos que un corte a ritmo.

## Reglas de juego

| Elemento | Flow 2.9 | Pulso y Vértigo |
| --- | --- | --- |
| Ataques | Separación de al menos 0,85 s; apertura de al menos 1,15 s | Densidad del nivel |
| Altura | Una sola fila; desplazamientos a carriles vecinos | Dos filas |
| Vista | Hasta cuatro pendientes; los siguientes esperan su turno | Lectura temporal del nivel |
| Corte | Un toque o gesto por cubo; admite una configuración precisa guardada | Ventanas y dirección del nivel |
| Nota atrasada | Permanece y puede recuperarse | Conserva el juicio temporal |
| Sostenidas | Ninguna | Ninguna |
| Orden | Una sola numeración de llegada | Numeración de llegada y enlaces de frase opcionales |
| Clasificación | Proporción de cubos completados, indicada como COMPLETADO | Precisión temporal |

Los ataques se seleccionan de los inicios musicales analizados, sin inventar
ni desplazar sus marcas. La separación de Flow usa una subdivisión entera del
compás estimado. Los seis primeros ataques tienen más espacio. La anticipación
inicial sube a 4,8 s y puede ajustarse entre 3,2 y 6,4 s. La actualización migra
el valor inicial de la versión anterior una vez; las elecciones posteriores
quedan guardadas.

El frente de la cola conserva su posición en el plano de corte. Sus seguidores
guardan una separación en profundidad y avanzan a velocidad acotada cuando
queda espacio. Un gesto de puntero no atraviesa y puntúa varios cubos de Flow.
No se cambian las marcas usadas para el bono de precisión ni para las ocho
notas precisas de una constelación.

Al acabar el audio, los pendientes de Flow siguen disponibles. Se pueden
completar o pulsar Finalizar sesión. Pausar y continuar en esta fase no crea
otra fuente de audio. Las marcas del Flow anterior se conservan en una categoría
distinta y se muestran como Flow anterior; no se comparan con las reglas nuevas.

## Señales visuales

El marco y la insignia del siguiente cubo toman los dos colores del mundo
actual. La guía PRÓXIMOS usa la misma combinación. Se retiran la placa blanca
y las fracciones de frase que competían con el número de llegada. Los modelos
3D, los cinco mundos, el render GPU y los cortes sin audio añadido se conservan.

## Verificación

Las pruebas deterministas cubren densidad entre 40 y 260 BPM, persistencia hasta
10.000 s, selección de una nota atrasada, geometría de la cola, avance sin
saltos, pausa y separación de récords. Las regresiones anteriores siguen activas.

La prueba en navegador usa el juego WebGL completo y entradas de puntero y
teclado. Deja el primer cubo más de dos segundos tarde antes de tocarlo, verifica
un gesto por cubo, completa pendientes al acabar la canción, prueba la salida
manual y conserva un récord anterior. Después juega Pulso con frases y una
constelación, sin sostenidas ni fuentes de sonido de corte.

La instrumentación Android usa el APK anterior para sembrar un récord, instala
2.9 como actualización y prueba GLES, los cinco mundos y un paquete de 128
descriptores. En Flow toca un cubo atrasado mediante un evento de puntero Android,
espera al final del audio y prueba la recuperación, la pausa y la finalización.
Después ejecuta la pista de Pulso mediante eventos de teclado y el reloj real
de salida de audio. Las notas de prueba se derivan antes de iniciar la pista;
el automatismo no modifica la puntuación ni el estado de las notas.

Android se ejecuta en un emulador con SwiftShader. Esta validación acredita el
comportamiento y el camino GLES, no los FPS del Galaxy A16 ni la latencia de su
GPU física.
