# REVERSE VELOCITY 3.9 — qSSD como autoridad de estados completos

La versión parte del APK 3.8. Conserva los mismos 20 recursos, física, shaders,
cinco perfiles gráficos y representación exacta de vértices. qSSD C03 pasa a
ser la autoridad del estado de ejecución completo; la caché de geometría queda
como una proyección auxiliar de esa autoridad.

## Qué almacena

| Estado | Contenido conservado |
| --- | --- |
| CPU | QuantumRuntime original completo: núcleo, InverseMemory, RNG, salida, generación y último programa ejecutado. RVPC2 conserva su formato original. |
| Recursos | Los 20 programas, shaders, atlas y paletas originales. CPU y cargador de shaders consultan estos recursos en el mismo bus. |
| GPU lógico | Último trabajo preparado: geometría XFG4, entradas, calidad, programa y las versiones exactas de CPU, recursos y componentes de las que depende. |
| Componentes | Coche, pintura, cámara, suavizado, marcha y solicitud pendiente, controles, asistencia, perfil gráfico y modo ambiental. Los tiempos de cámara se expresan como duraciones. |
| Versiones | Anillo de 32 raíces completas y hasta 16 marcadores. Las vistas en uso mantienen sus datos inmutables. Las bifurcaciones tienen una autoridad independiente. |

La CPU publica sus transacciones dentro de `StateBus<XiSessionGraph>`. La GPU
retiene una raíz y publica su trabajo con sus dependencias. Una CPU posterior
puede coexistir con un trabajo preparado anteriormente: se conserva la CPU que
realmente lo produjo. El bus publica raíces completas, valida antes de confirmar
y permite retroceder bajo una revisión nueva.

Los datos grandes inmutables se comparten entre versiones. No se serializa RVPC2
por cada fotograma ni se escribe a disco durante la conducción. Las entradas
arbitrarias continúan ocupando memoria y las vistas externas pueden prolongar
su vida; un límite de versiones no equivale a un límite total de RAM.

## Guardar y recuperar

El menú añade **Guardar recorrido** y **Recuperar recorrido**. Estas operaciones
detienen los productores en un límite de trabajo completo, conservan el estado
de vista y generan un archivo `QSB3` con CPU, programas, recursos, componentes y
trabajo gráfico. El archivo guarda una raíz completa y sus dependencias; el
anillo entero de historial permanece en RAM y no se exporta en este formato.

El archivo admite hasta 64 MiB y deduplica secciones por igualdad exacta.
Android utiliza un archivo atómico con sincronización explícita del contenido.
La recuperación abre una autoridad candidata, verifica el archivo, inventario
completo de recursos y protocolos de CPU/vista antes de reemplazar la sesión.
Un archivo inválido conserva la ejecución anterior.

Se reconstruyen los objetos del controlador a partir del estado lógico. Los
identificadores GL, colas internas del controlador, framebuffer físico, eventos
táctiles del sistema y reproducción del dispositivo de audio no se capturan.
JNI y las cargas a GPU continúan realizando proyecciones físicas explícitas.
No se presenta este almacenamiento como teletransporte ni como nueva capacidad
de hardware.

## Comprobación

- Las trazas anteriores siguen comparando todos los bytes de geometría, salida
  de shaders, vértices y RVPC2 con la base original.
- El test nativo conserva 1000 cúbits correlacionados con una fase no Clifford,
  memoria enlazada y RNG; un archivo completo recupera exactamente el estado y
  sus resultados futuros. Las bifurcaciones y retrocesos dejan las vistas previas
  intactas.
- El JNI de producción guarda los 20 recursos, recupera la misma geometría y
  continúa la conducción de forma idéntica. Comprueba también corrupción y
  validez de las vistas después de cerrar la autoridad.
- Android debe ejecutar los controles reales de guardar, matar el proceso,
  reiniciar, recuperar y conducir, además del humo gráfico y A/B contra 3.8.

Las mediciones del emulador describen ese equipo de pruebas. El reporte del
usuario de aproximadamente 90 FPS detenido y 40 FPS conduciendo en Ultra con
3.8 es una observación de su dispositivo, distinta de esas mediciones. 3.9 debe
medirse por separado; añadir estados completos no establece una mejora de FPS.
