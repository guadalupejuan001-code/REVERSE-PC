# REgraphics XI — Ciclo 2: rasterización paralela determinista

## Diagnóstico medido

Instrumentación local sobre la escena real de Reverse Velocity 1.4, raster
4K de 3840×2160. Las tres cámaras mostraron aproximadamente:

| Fase | Tiempo local |
|---|---|
| Análisis del programa XI al iniciarse el proceso | 7–13 ms |
| Ejecución XI de la escena excluyendo rasterizado | 37–42 ms |
| Rasterización de las 68 franjas en un único trabajador | 204–268 ms |
| Creación de las listas de triángulos por franja | menos de 0,2 ms |

Mediciones de CPU Linux en un proceso por ejecución, no cifras Android ni
medidas del Galaxy A16.

## Implementación

Se conserva un único MachineMeshRaster y el formato de salida XFB5. El núcleo
reparte las 68 franjas de 32 filas entre hasta cuatro trabajadores nativos de
CPU cuando la escena es suficientemente grande. Cada trabajador dispone de
su propio buffer temporal de profundidad 1/z y materiales, y utiliza la misma
geometría, iluminación, perspectiva y texturas XI ya preparadas.

La selección de franjas emplea un contador atómico, para repartir las zonas
más costosas sin imponer una distribución fija. Los trabajadores escriben en
regiones **disjuntas** de un único XFB5 de tamaño ya reservado. No se crean
cuatro imágenes 4K ni se modifican los datos de Ether.

La regla global de trabajo XI se mantiene: se contabiliza el trabajo agregado
de todos los trabajadores una vez por franja. Una escena que supere el
presupuesto falla antes de publicar una salida parcial.

Si Android rechaza la creación de un trabajador por limitaciones de recursos,
se unen los trabajadores existentes y se reproduce la imagen completa de
forma secuencial, con el mismo XFB5 final.

La ruta secuencial con el mismo código se compila mediante
REGRAPHICS_FORCE_SERIAL_STRIPS y sirve de referencia verificable.

## Umbrales y restricciones

- CPU worker count: mínimo entre 4 y el número de núcleos que declara el host.
- Escenas inferiores a 1280×720 o con menos de 128 caras permanecen secuenciales.
- No se altera la física XI de 50 Hz ni se declara un cambio de FPS antes de
  medir una carrera en Android.
- Memoria temporal: cada trabajador activo reserva como máximo la profundidad
  y los materiales de 3840×32 píxeles, aproximadamente 1,1 MB por trabajador,
  más objetos y overhead del sistema. La salida indexada XFB5 sigue usando
  8.294.416 bytes.
- CPU 100% propio, sin sustituir REgraphics por GLES/Vulkan u otro renderizador.

## Resultados preliminares locales

Bajo el mismo programa XI y snapshot Ether, el tiempo de rasterización bajó
de 204–268 ms a aproximadamente 90–114 ms en las tres cámaras al utilizar
cuatro trabajadores.

Comparaciones de ejecución completa, en el mismo entorno local y con fuentes
originales, mostraron:

| Cámara | Secuencial | Paralelo |
|---|---:|---:|
| Trasera | 287 ms | 162 ms |
| Cercana | 315 ms | 151 ms |
| Capó | 344 ms | 176 ms |

Estas medidas son de escritorio; dependen del hardware, contención del CPU,
temperatura y compilación. No representan FPS de Android ni garantizan una
ganancia idéntica en el teléfono.

En cinco rondas alternadas, dos, tres y cuatro trabajadores produjeron imágenes
idénticas. En las tres cámaras el menor tiempo mediano de raster agregado
lo consiguió cuatro trabajadores (aprox. 319 ms acumulados frente a
369 ms con tres y 521 ms con dos). El trabajo y el uso energético por
fotograma no necesariamente disminuyen; se reduce la latencia empleando
más núcleos en paralelo.

## Puertas de calidad

- Suites originales XI: pruebas de profundidad, textura, perspectiva,
  clipping, rev2 y XFG4 intactas.
- Test serial-versus-parallel en 320p, 720p, 1080p y 4K, con superficies
  coloreadas, inversión de orientación y atributos de textura, comparando
  **todos los bytes** y el mismo presupuesto de píxeles.
- Test de denegación global del presupuesto incluso bajo concurrencia.
- A/B en estados estacionario y en movimiento real de XI, tres cámaras y dos
  pinturas, comparando XFB5 con el mismo snapshot Ether.
- Android smoke: real 4K, controles, pausa, conducción, firma y telemetría
  de cada etapa.

## Siguiente cuello de botella

La escena XI y la ejecución siguen siendo secuenciales, y los fotogramas
se rasterizan completos cuando se mueve la cámara. La siguiente evolución
requiere compilar/cachar preparación de escena con un contrato invalidable,
estudiar bloques de visibilidad y optimizar las divisiones de profundidad y
textura, sin aproximar silenciosamente la imagen.
