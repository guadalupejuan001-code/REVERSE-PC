# SUPER RENDER XI — Diseño y resultados

**Estado:** programa gráfico experimental que ejecuta reglas de escena en XI.
El componente no es todavía un renderizador 3D AAA ni una pantalla Android.

## Ingeniería aplicada

- Arquitectura: super-render.xi es la única autoridad de cálculo geométrico.
- Estados: 14 escalares XI por cada fila, sin almacenar un cuadro RGBA dentro
  de la máquina; el presentador únicamente expande las regiones.
- Escena: horizonte, curvatura de carretera, arcén, bordes, línea central,
  fase discontinua y variación de material por distancia.
- Resolución: trabajo procesado por bloques de filas; ningún número de
  resolución específica está codificado como límite de la escena.
- Ejecutable: SUPER-RENDER-XI.rxe compilado por el compilador propio de REVERSE
  y verificado contra el fuente XI real.

## Memoria Ether para configurar la cámara y la carga

| Dirección | Formato | Uso |
|---|---|---|
| 200–203 | uint32 LE | ancho lógico |
| 204–207 | uint32 LE | alto lógico |
| 208–211 | uint32 LE | primera fila |
| 212–215 | uint32 LE | filas en el bloque |
| 216 | uint8 | curvatura, 128 = sin giro |
| 217 | uint8 | fase visual |

Cada fila emite 14 valores en este orden: Y, material base, arcenes izquierda
y derecha, extremos de asfalto, franjas laterales, franja central, sombreado
por distancia y bandera de continuidad de la línea central. Los píxeles
fuera de la geometría pertenecen al fondo implícito.

## Restricciones reales

Mundo X EtherRenderSpatial tenía topes explícitos de 4.096 cuerpos y 8.192
píxeles por dimensión. El XI Machine v1 actual tiene 16 registros,
1.000.000 pasos por transacción y un transporte de salida de 16 MiB.
Estos números son decisiones de implementación, no límites físicos del
espacio matemático. SUPER RENDER XI procesa ventanas sucesivas de filas y
puede abarcar escenas lógicas mayores sin desactivar los límites de seguridad
de cada llamada.

La nueva representación de dimensiones es uint32. No implica capacidad
física ilimitada: las operaciones con enteros de 64 bits, RAM, temperatura,
CPU, ancho de banda y pantalla establecen límites reales según la máquina.

## Validación

La prueba super-verify.cjs ejecuta la máquina XI original, compara todas
las filas contra un cálculo independiente y confirma que cambiar el tamaño
de los bloques no cambia el resultado. Incluye 360p, 720p, 1080p, 4K, 8K,
16K e inputs inválidos. El modo HD genera una vista PPM desde descriptores.
La evidencia es producción lógica a esas resoluciones, NO pantalla 16K
ni FPS de Android.

El ejecutable compilado se ejecuta con la misma configuración de Ether y
debe publicar descriptores iguales a los del fuente XI.

## Para convertir el prototipo en un motor 3D completo

- Triángulos arbitrarios, mallas y perspectiva 3D con transformaciones XI.
- Profundidad y oclusión de muchos objetos, no solo franjas de carretera.
- Materiales físicos, texturas, iluminación, sombras y reflejos.
- Enlace eficiente desde las emisiones XI al búfer de pantalla REVERSE-PC.
- Pruebas reales de memoria, respuesta de entrada y FPS en Android/PC.

No se propone utilizar una implementación gráfica nueva en C++ o Java.
El sistema anfitrión siempre necesita una forma de presentar los datos
al hardware, pero las reglas de geometría permanecen en XI.
