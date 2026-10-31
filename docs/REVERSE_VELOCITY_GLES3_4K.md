# REgraphics 0.7 — ruta 4K por GPU

## Lo implementado

- `render4k.xi` comparte la geometría, los estados, las texturas
  y las ecuaciones con `render.xi`. No crea una nueva pista.
- `MachineMeshRaster` capta el mismo flujo de triángulos de XI a
  resolución de proyección 3840×2160 en el formato XFG4.
- El paquete XFG4 contiene coordenadas de pantalla y profundidad,
  iluminación de XI (Q8), UV, identificadores de material y tiles XI.
- `VelocityGpuFrame` comprueba todos los límites antes de enviar
  datos a la GPU. Evita geometría no confiable o dimensiones espurias.
- `VelocityGpuPresenter` crea un contexto OpenGL ES 3.0 y un
  framebuffer de color RGBA8 con profundidad. El fragment shader
  interpola UV e intensidad en perspectiva y lee las texturas originales.
- La imagen se blitea a la pantalla. El framebuffer **interno** objetivo
  es 3840×2160 (8.294.400 píxeles), no un escalado del render CPU.
- El botón 4K de la APK es opcional: los teléfonos incompatibles
  pueden utilizar 1920×1080, 1280×720 o la vía CPU.

## Recursos y limitaciones reales

Un framebuffer RGBA8 de 3840×2160 requiere aproximadamente 31,6 MiB;
un búfer de profundidad 16-bit requiere otros 15,8 MiB, sin contar
memoria del driver, Java, geometría y texturas.

Es una mejora de resolución y precisión geométrica. Todavía no se
alcanzan los materiales PBR, normal maps, iluminación global,
texturas de alta resolución o las pistas y efectos de la referencia
conceptual. El motor no promete 60/120 FPS ni soporte 4K en Galaxy A16.

## Criterios de verificación

La CI prueba el transporte XFG4, la escena real de XI, y una carrera
completa manteniendo la física. La APK instala y ejercita la opción 4K
en un emulador Android con GPU SwiftShader, comprobando la resolución
interna realmente asignada y el retorno al render CPU. El benchmark
del dispositivo físico todavía es un trabajo independiente.
