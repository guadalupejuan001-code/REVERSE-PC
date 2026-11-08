# REVERSE VELOCITY 4.0 — C02: conducción, pastizales y núcleos C12/C06

Base: C01 de conducción (PR #222), sin fusionar ni eliminar sus checkpoints.

## Diagnóstico del acelerador

`VelocityGearbox.prepare()` aplicaba el freno de servicio y anulaba el acelerador **durante toda la espera de un cambio D/R**, hasta que XI observaba velocidad <= 25 cm/s. El usuario percibía el coche bloqueado mientras seguía moviéndose. C02 cambia la política de entrada: al pulsar expresamente el acelerador **sin el freno**, se cancela el cambio D/R pendiente y se conserva la marcha actual. No se engrana reversa mientras se circula. Si el conductor mantiene el freno, la solicitud de cambio sigue frenando hasta detenerse. El modelo XI de seis marchas, la rampa de par, el frenado y los checkpoints permanecen intactos.

El test `VelocityGearboxTest` cubre la cancelación, la prioridad de freno y el bloqueo seguro de reversa.

## Pastizales espaciales

El antiguo actor de hierba (`nature_grass_model`) se regeneraba cerca de la cámara y podía parecer que seguía al vehículo. C02 lo retira de la selección de actores en ambos recursos XI y en el generador canónico. Los actores de esa clase ahora utilizan el modelo de roca ya existente. Los pastizales son regiones de **material de suelo**, ancladas a coordenadas UV de la geometría XI y mezcladas mediante ruido espacial, no arbustos que se desplazan con el coche. Los perfiles bajo/ahorro omiten el detalle fino; alto/ultra añaden microvariación. No hay movimiento del césped vinculado a la posición del coche.

## Tres componentes y limitaciones

- **CPU**: XI de REVERSE-PC sigue ejecutando física, mundo y escena.
- **GPU**: dependencia oficial `GPU-VIRTUAL C12` fijada en el workflow. El juego conserva su transporte compacto XFG4 de 24 bytes por vértice y la presentación física GLES. La ejecución de kernels C12 de cálculo y sus operaciones float32 ya están probadas en QSSD C06, pero **no se afirma que ejecuten cada fotograma del juego**.
- **QSSD**: dependencia fijada al commit C06, conservando el mismo código de proyección C03 que usa la ruta de juego. El bus de estados y los checkpoints continúan funcionando. El traslado Bell simulado C05 se conserva en QSSD; no sustituye la comunicación con la GPU física.

## Validación

La PR activa la construcción de APK Android en GitHub Actions, compara los archivos XI regenerados, verifica los SHA de componentes originales, ejecuta pruebas de conducción, comprueba firma y actualización sobre la APK 3.9 y realiza pruebas de arranque y persistencia en emulador. No se atribuyen FPS reales de teléfono sin medición del dispositivo.

Siguiente ciclo: ampliar C12 desde los materiales a geometría compacta solo tras medir latencia y FPS A/B en Android. La PR C04 de crecimiento QSSD sigue independiente.

## Firma de compatibilidad Android

La aplicación mantiene el identificador `com.reversepc.velocity`. Las compilaciones
se aceptan para actualización sobre la instalación anterior únicamente si el
certificado SHA-256 coincide con `061c28614fffecdc9a53a5661c4acf8c4d1173b631095aaaee8a98070abdf0d7`.
No se debe distribuir como actualización un binario firmado con una clave
nueva generada en la rama de experimentos; conservar los datos del usuario
tiene prioridad. La validación requiere el certificado de la rama de liberación.

## C02R: el ejecutor faltante

El error de PR #223 fue un checkout parcial: la APK descargaba solamente
`GPU-VIRTUAL/android-graphics/shared`, es decir, **XFG4**. El núcleo
`include/ejecucion_gpu.hpp` no estaba disponible al compilar Android.
Por eso las dependencias C12/C06 estaban fijadas pero no se ejecutaba C12.

Ahora la variante Velocity exige el SHA C12 original y compila un módulo
nativo C++20 (sin reescribir el núcleo). En **cada nuevo fotograma GLES**
se ejecuta un despacho XGPU-C12 real de cinco lanes, con operaciones
`LoadGlobal`, `FloatFromUnsigned` y `FloatMultiply`.
Sus resultados controlan parámetros visibles del shader: humedad, agua,
tiempo, luz de día y faros. El estado llega de la observación coherente
XI/QSSD e incluye la publicación de origen. No se modifica el protocolo
XFG4 ni los checkpoints o la autoridad de física.

Es una primera conexión **real y acotada**, no un reemplazo de toda
la rasterización: CPU XI sigue calculando geometría y dinámica; GLES
sigue dibujando en la GPU física. C12 ejecuta su propio intérprete en
la CPU anfitriona. QSSD C06 permanece fijado y el juego conserva su
proyección C03; las puertas Bell de C05 no se ejecutan por frame.
El registro `GPU_C12_EXECUTED` acredita llamadas, pasos y publicación.
El host prueba 240 estados contra float32; las mejoras de FPS siguen
pendientes de medir en hardware físico.
