# Reverse Velocity 0.8 — materiales del motor REgraphics

## Alcance
El coche RV-01 conserva su geometría y las ecuaciones físicas existentes.
XI sigue enviando posición de cámara, UV, material, valores de luz Q8 y
los ocho tiles de textura. El renderizador OpenGL ES 3 genera, para la
superficie 4K, reflejos aproximados de cielo y luces de estudio.

El shader añade efecto de Fresnel al cristal y a la pintura, reflejo de
capa transparente sobre carrocería, brillo metálico en las llantas,
compuesto aerodinámico mate y caucho menos reflectante. La carretera
usa un único muestreo filtrado de grano procedente del tile XI; el cielo recibe
una transición de color según la posición del fotograma. El color
final sale en RGB y puede variar entre los índices originales XI.

El tile XI 16×16 se interpola bilinealmente, no se sustituye por una
imagen de referencia. El atlas original se almacena en GPU una vez y
se vuelve a cargar únicamente cuando cambie realmente.
La física, el renderizador CPU y las pistas permanecen intactos.

## Validación y limitaciones
- La compilación Java verifica los contratos de materiales.
- El emulador Android compila los shaders GLES3, presenta el 4K real,
  captura el RV-01 con pintura blanca perla y comprueba el regreso a CPU.
- No son mapas PBR fotográficos, reflejos de objetos reales, ni ray tracing.
- Los polígonos de carrocería siguen siendo limitados; no se promete
  nivel de detalle equivalente a la imagen conceptual.
- No se anuncian 30/60/120 FPS 4K ni resultados en Galaxy A16 sin prueba física.
