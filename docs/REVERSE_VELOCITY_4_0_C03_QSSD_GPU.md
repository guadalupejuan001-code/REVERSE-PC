# REVERSE VELOCITY 4.0 C03 — REgraphics -> qSSD -> OpenGL ES -> GPU física

Base: C02R (PR #223, revisión `ae10293ee835440017c3fb3472f17a431c983686`).
No mezclar con la PR C04 experimental del repositorio Virtual-qSSD-.

## Qué se corrigió

Antes, `VelocityGpuSurface` administraba por su cuenta `residentGeometry`,
`residentPalette` y `residentAtlas`. Aunque XI ya publicaba XFG4 a través de
`qssd::SharedProjection<std::string>`, la decisión de reutilización y
transferencia de texturas seguía fuera de qSSD.

Ahora el flujo es:

```
CPU XI / mundo y física
   -> XI REgraphics produce XFG4 immutable
   -> qssd::SharedProjection (identidad y revisión originales C03/C06)
   -> XiSharedGeometryPacket (ByteBuffer directo, solo lectura)
   -> VelocityQssdGraphicsBridge.publish(...)
   -> VelocityQssdGraphicsBridge.plan(...)
   -> CompactTriangleStream (deltas exactos de páginas de vértices)
   -> OpenGL ES glBufferSubData / glTexSubImage2D
   -> VelocityQssdGraphicsBridge.confirm(plan)
   -> GPU física rasteriza píxeles finales
```

La entrega a GLES de geometría, paletas y atlas **pasa por un único lease
inmutable**. QSSD controla revisiones y plan de cambios: si no ha cambiado
la geometría, no genera de nuevo los vértices; si se cambian pocos materiales
actualiza solo tramos contiguos de 4 bytes/texel; para el atlas compara 16
filas de 128 bytes. El formato XFG4 conserva íntegros los valores, orden
y semántica de pases. No se cuantiza, no se convierte en un nuevo motor.

La comparación se realiza contra la última copia **aceptada por GLES**,
no contra el último estado publicado. Si la transferencia falla no se
confirma la versión; un nuevo intento vuelve a detectar sus deltas.
Tras pérdida de contexto GLES, se invalidan las copias físicas pero no
la autoridad lógica de qSSD, y se vuelven a subir los recursos necesarios.

GPU-VIRTUAL C12 conserva la ejecución nativa por fotograma introducida
en C02R para cinco uniformes de materiales. C12 ejecuta en CPU anfitriona;
OpenGL ES y la GPU física rasterizan. No se afirma que el ejecutor C12
ejecute todos los vértices/píxeles ni Bell simulado en cada fotograma.
Las puertas Bell C05 y el resto del bus QSSD C06 siguen separados.

## Verificación

- JVM: `VelocityQssdGraphicsBridgeTest` usa una observación XFG4 válida
  respaldada por ByteBuffer directo, fuerza paleta parcial de tres texeles,
  una fila del atlas, versión inválida, transferencia interrumpida y reset GL.
- Android: `velocity-graphics-ui-smoke.cjs` exige
  `QSSD_GPU_BRIDGE_ACTIVE ... route=REgraphics_QSSD_GLES` y el log del
  despachador C12, además de comprobar los cinco perfiles gráficos.
- Empaquetado: la APK debe incluir `VelocityQssdGraphicsBridge`, el JNI
  de GPU C12 y el compilador de XI, con pruebas de firma, ELF y alineación.
- Medir en hardware real: FPS y latencia de subida de VBO/materiales
  frente al baseline. No afirmar aumentos de FPS sin esta comparación.

La aplicación de laboratorio sigue usando `com.reversepc.velocity.c02`,
ahora versión Android `45 / 4.0.0-c03-qssd` con la misma clave de laboratorio
de la rama C02. Es independiente de la aplicación original `com.reversepc.velocity`.
