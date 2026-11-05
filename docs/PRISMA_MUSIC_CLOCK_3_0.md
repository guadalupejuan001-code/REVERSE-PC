# PRISMA 3.0 — Flow conectado a la canción

La cola de cuatro notas de 2.9 frenaba los ataques posteriores. Además, su
movimiento restaba un delta de animación limitado por cuadro; con pocos FPS
ese delta avanzaba menos que el reloj de audio y acumulaba retraso.

## Llegada y ritmo

Durante la canción, la posición de cada cubo se calcula a partir de su marca
musical menos el tiempo del reloj de salida de audio. No depende de cuántos
cuadros se hayan dibujado ni del número de cubos anteriores sin cortar. Una
bajada de FPS reduce las muestras visuales, pero no ralentiza el tiempo del
recorrido.

Flow selecciona ataques detectados con una separación ligada al tempo local.
En la prueba regular de 120 BPM conserva un ataque por pulso; a tempos rápidos
puede seleccionar pulsos alternos. Se retira el filtro fijo de aproximadamente
un segundo y la apertura aún más lenta de 2.9. No se desplazan las marcas de los
ataques para ajustarlas a una cuadrícula inventada.

La anticipación inicial es 3,4 s, ajustable de 2,6 a 5,2 s. La actualización
cambia el antiguo valor inicial de 4,8 s una vez y conserva otros valores que
se hubieran elegido. El control modifica la lectura y la velocidad de llegada,
no el momento musical del golpe.

Los eventos de entrada pueden conservar hasta un segundo de retraso de entrega.
El corte se evalúa con la hora del gesto y su posición correspondiente, incluso
si la nota ya salió de la lista del cuadro actual. Las posiciones guardadas para
la recuperación final no se reutilizan al seleccionar notas durante la música.

## Margen de Flow y recuperación

- Un toque o corte por cubo, sin sostenidas.
- Entrada hasta 350 ms antes o 1.050 ms después del ataque.
- Tras llegar al plano de corte, un cubo pendiente se aparta hacia arriba y
  reduce su tamaño mientras sigue admitiendo el corte dentro de ese margen.
- Después pasa al contador PARA RECUPERAR AL FINAL. No se marca como acertado
  ni fallado ni bloquea los ataques nuevos.
- Al terminar la música vuelven los pendientes, con la recuperación tranquila
  de cuatro cubos y el botón Finalizar sesión. Pausar y continuar ahí no crea
  otra reproducción de audio.

El indicador de llegada sigue el próximo ataque musical. Un cubo antiguo no
roba el número 1 ni la entrada de otro que esté a ritmo. Los colores del mundo,
los modelos 3D y el backend GPU se conservan.

La clasificación de Flow continúa mostrando el porcentaje COMPLETADO, con los
aciertos a ritmo separados. Las marcas de Flow 2.9 y las anteriores se conservan
en sus categorías, sin compararlas con las reglas nuevas.

## Evidencia

Las pruebas deterministas cubren pulsos de 40 a 260 BPM, cambios de tempo,
selección a ritmo, margen temprano y tardío, desplazamiento de cubos atrasados,
recuperación y conservación de récords. Verifican que un cubo alcanza su marca
musical sin depender del índice de la cola ni de una frecuencia de 8, 15, 30,
60 o 120 FPS. Las regresiones previas continúan activas.

El juego completo en WebGL importa WAV generados con ataques conocidos: una
pista regular de 120 BPM y otra con secciones de 120 y 180 BPM. La primera
conserva 20 ataques; la segunda verifica que las marcas seleccionadas pertenecen
a ataques reales del archivo. Se observa el recorrido sin tocar los primeros
golpes, se hace un corte tardío mediante puntero, se comprueba un gesto por cubo
y se recuperan todos los pendientes al final. Otra partida usa eventos de
teclado a ritmo y termina sin entrar en recuperación. No hay fuentes de corte.

La instrumentación Android instala sobre el APK 2.9, conserva un récord de ese
modo y verifica un toque tardío. Después deja pasar golpes y comprueba que las
notas nuevas y sus posiciones siguen el reloj de audio. También prueba la
recuperación, los cinco mundos GLES, el paquete de 128 descriptores y una pista
de Pulso con frases y constelación, sin sostenidas.

Estas comprobaciones validan el cálculo del recorrido y las entradas. No miden
la latencia física entre altavoces y pantalla ni el rendimiento del Galaxy A16.
Android se ejecuta en emulador con SwiftShader; no se presentan sus tiempos de
envío CPU como mediciones de una GPU física.
