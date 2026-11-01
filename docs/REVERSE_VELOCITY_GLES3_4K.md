# REVERSE VELOCITY: 4K legado y transición a REgraphics nativo

> Documento histórico. La ruta OpenGL ES 3 del prototipo 0.9 fue eliminada de la aplicación jugable en 1.0. Consulta `REVERSE_VELOCITY_XI_NATIVE.md` para el estado vigente.

## Qué tenía el prototipo

- XI generaba geometría y texturas originales a coordenadas de proyección 3840 × 2160 (`render4k.xi`, XFG4).
- En la APK 0.9, OpenGL ES 3 rasterizaba esos triángulos y materializaba los píxeles.
- Por tanto, el flujo era híbrido y **no una renderización enteramente propia de REgraphics**.

## Qué conserva Reverse Velocity 1.0

- La carrera física, los rivales y la geometría siguen íntegramente en XI.
- `render.xi` y `MachineMeshRaster` siguen realizando proyección, z-buffer, interpolación de luz y texelado, sin motor externo.
- Android usa `SurfaceView` y `Canvas` solamente para mostrar la matriz final de píxeles de XFS1.
- Se conserva `render4k.xi` **como captura geométrica de investigación**, no como promesa de 4K jugable.
- Se retiraron `VelocityGpuPresenter`, `VelocityGpuFrame` y `VelocityMaterialShader` de la ruta de compilación, así como el botón que usaba OpenGL.

## Limitación no resuelta

La rasterización XI actual se limita a 640 × 360, 8.000.000 pruebas de píxel y 16 MiB de salida por fotograma. 4K físico equivale a 8.294.400 píxeles: la rasterización plena exige optimización por regiones, salida compacta, un z-buffer más eficiente y una nueva campaña de benchmarks Android.

No se declarará que REgraphics produce 4K nativo jugable hasta que lo haga y una prueba real lo confirme.
