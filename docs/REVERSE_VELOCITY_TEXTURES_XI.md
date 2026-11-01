# Texturas indexadas XI / REgraphics — RV-01 0.6

## Implementación real

El archivo `scripts/velocity-textures.cjs` genera ocho patrones originales
de **16×16 texeles**, con índices de 4 bits (0..15). Se emiten como
`meshtexrow` dentro del programa `render.xi`. No hay PNGs de referencia
que se estén presentando como texturas funcionales.

La malla de cada vehículo conserva sus vértices a escala centimétrica;
cada posición canónica tiene coordenadas UV derivadas de su modelo,
no de la pantalla. `meshtexuv` asigna las coordenadas, y
`meshtexcopy` las transporta a la geometría transformada. Las ruedas
pueden girar sin que la textura permanezca pegada al monitor.

`meshfacegradienttex` combina:

- la luz interpolada por XI (intensidad Q8 de 0 a 65280);
- la coordenada UV interpolada con perspectiva y clipping cercano;
- un texel de la tabla 16×16, repetido por módulo 16;
- la fuerza del patrón, acotada de 1 a 16;
- una rampa de materiales dentro de la paleta XFS1 de 256 colores.

El motor sólo conserva los ocho tiles y las coordenadas temporales durante
el render. Las imágenes siguen pasando por XFS1 y el presentador Android
sin disponer de un segundo motor gráfico.

## Materiales activos

| Tile | Material | Asignación |
|---:|---|---|
| 0 | Pintura blanco perla y otros colores | RV-01 y rivales |
| 1 | Compuesto aerodinámico oscuro | carrocería inferior |
| 2 | Cristal panorámico ahumado | lunas y espejos |
| 3 | Caucho con estrías | neumáticos |
| 4 | Metal de llantas | radios y aros |
| 5 | Asfalto granular | banda central de la pista de prueba |
| 6 | Pintura vial envejecida | reservado para otro ciclo |
| 7 | Rejilla negra | reservado para otro ciclo |

La textura de asfalto usa el mismo centro de pista y límites laterales
del generador original de XI, con UV derivados del número de segmento y
del ancho en centímetros. No se cambia el circuito.

## Seguridad, límites y mediciones

- Tiles de tamaño fijo, ocho como máximo; filas completas y nibbles
  hexadecimales verificados antes de dibujar.
- Índices UV acotados y reiniciados al renovar el vértice o el fotograma.
- Interpolación por perspectiva, z-buffer y clipping cercano.
- Presupuesto: máximo 4096 triángulos, 1600 índices de autoría usados
  por el juego, 640×360 y 256 colores XFS1; sin incrementar esos límites.
- Las pruebas nativas verifican Q8, repetición, clipping, UV incompletas
  y compatibilidad con el render sin texturas.
- La APK se verifica en CI con instalación y conducción Android; aún se
  debe medir rendimiento en Galaxy A16.

**No es PBR ni texturizado fotográfico de alta resolución.** Las texturas
generan detalle real anclado a la malla, pero alcanzar la referencia aprobada
requerirá futuros materiales, mapas de normales, colores de mayor precisión,
resolución superior y posiblemente un backend acelerado de REgraphics.
