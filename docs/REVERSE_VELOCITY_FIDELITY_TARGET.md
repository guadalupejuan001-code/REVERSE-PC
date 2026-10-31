# REVERSE VELOCITY — objetivo de fidelidad visual

## Referencia aceptada

La escena de referencia aportada y aprobada por el autor de Reverse Velocity
contiene un deportivo eléctrico blanco perlado, cámara de persecución,
paneles duros con juntas reales, trasera LED continua, difusor de múltiples
aletas, neumáticos y llantas definidos, y un entorno de circuito con asfalto
texturizado, árboles, vallas, sombras suaves y perspectivas de larga distancia.

**Es una visualización conceptual generada por IA; no es una captura
del motor.** Este documento describe la apariencia deseada, no un
resultado ya alcanzado ni un rendimiento garantizado.

## Límite comprobado de la implementación actual

- XI gobierna el estado de carrera, la cámara, las transformaciones,
  la autoría de materiales y el cálculo de iluminación.
- REgraphics CPU rasteriza triángulos y envía resultados XFS1 al presentador.
- Resolución interna: 320×180, 480×270, 640×360 como máximo.
- Paleta de 256 colores y materiales con rampas tonales.
- Presupuesto de 4096 triángulos y 4096 IDs de vértice por escena;
  el autor del juego restringe su búfer temporal a 1600.
- El detalle 0.5 añade treinta triángulos al automóvil del jugador:
  864→894, sin bajar la densidad de los otros objetos.
- Mantiene una escena de prueba existente para medir avances; el autor
  diseñará las pistas finales por separado.

## Plan técnico para alcanzar la referencia

1. **Carrocería medible**: mantener un modelo original sin logotipos,
   escala coherente y tres LOD; ampliar detalles de panel, cristales,
   neumáticos, frenos, llantas y difusor. Prueba automática de presupuesto
   y una imagen auténtica desde cámaras frontal, posterior y lateral.
2. **Materiales e iluminación**: evolución de REgraphics para colores
   de mayor precisión, UV y mapas de albedo/normal/roughness; sombreado
   apropiado para pintura, cristal, metal y goma. Comprobar luces,
   sombras de contacto y brillos a distintas horas del día.
3. **Resolución y estabilidad**: estudiar un backend GPU para el MISMO
   motor REgraphics, manteniendo XI como autoría/estado y el modo CPU
   de referencia. Empezar por un objetivo medible de 1280×720;
   no elevar los límites sin pruebas de memoria y tiempo por fotograma.
4. **Mundo visual**: incorporar texturas y elementos de pista solo cuando
   el autor defina su diseño. Evitar sustituir o rediseñar sus trazados.
5. **Medición de dispositivo**: repetir cámaras, colores, estados físicos y
   arranque en emulador y en un Galaxy A16 real; publicar FPS,
   resolución interna, tiempos de raster y memoria. No usar
   4K/8K/120 FPS como promesas sin datos reproducibles.

## Criterios de aceptación

Cada mejora que se declare **implementada** debe incluir código del juego,
asset compilado o generado, prueba del render real, prueba de física intacta,
y, si hay APK, un paquete firmado que se instale y abra en Android.

La mejora visual solo se valida con capturas **producidas por el motor**.
Una imagen generada para explorar el aspecto no es evidencia de
funcionalidad ni de calidad de la APK.
