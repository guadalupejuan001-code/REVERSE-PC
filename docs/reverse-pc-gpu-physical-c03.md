# REVERSE-PC C03 — GPU Virtual a render WebGL y QSSD

**Objetivo:** conectar la salida real de la autoridad de trabajo de GPU-VIRTUAL PR #8 con el renderizador físico del escritorio de REVERSE, conservando el runtime XI/RVPC2, los ejecutables RXE y la interfaz de REVERSE. El anfitrión de la APK es Android; el huésped x86/x64 sigue siendo el original de Mundo X C03.

## Ruta ejecutable

1. La CPU virtual de Mundo X ejecuta las instrucciones originales del huésped y escribe la memoria VGA clásica 80 × 25.
2. **GPU-VIRTUAL** observa esas celdas y construye su `PhysicalWorkPlan` real, con `camera_indices`, descartes y revisiones.
3. REVERSE recorre **exclusivamente** los índices seleccionados por la autoridad GPU-VIRTUAL. Para cada índice se adjuntan el byte VGA original y sus atributos, nunca valores sintetizados por la interfaz. El plan queda en el `GraphicsWorkMemory` original de QSSD, con una revisión de dependencia y `completed_revision=0` mientras no haya confirmación.
4. El escritorio original de REVERSE presenta esas celdas en un `canvas` WebGL de 640 × 400. Un atlas de glifos ASCII 33–126 se genera localmente; las posiciones, coordenadas UV y colores VGA se cargan en un VBO e IBO. La llamada GPU observable es **una `drawElements`** para todos los glifos seleccionados, o ninguna si no hay glifos.
5. La interfaz llama `gl.finish()`, `gl.getError()` y `gl.readPixels()`. Si la lista es no vacía, exige píxeles visibles; si falla, conserva la salida de texto de respaldo y **no confirma QSSD**. El Android WebView puede implementar WebGL mediante el hardware o mediante SwiftShader del emulador.
6. El puente validado `nativeRequest('fabric',...)` informa al servicio de REVERSE del serial QSSD, cantidad de celdas seleccionadas, número de draw calls y píxeles leídos. El servicio rechaza seriales obsoletos o conteos incorrectos. Solo entonces publica una nueva versión inmutable `completed_revision` de QSSD y devuelve `submitted_webgl:true`.
7. Los workers XI C02 siguen operando sobre copias privadas RVPC2 y no dibujan ni cambian el motor gráfico. La autoridad XI/RVPC2 persiste exclusivamente en `SessionStore`.

## Qué se comprueba

- El framebuffer se alimenta de **los mismos `camera_indices`** originales que entrega GPU-VIRTUAL. Se comprueba el contrato de cantidad, seis índices por glifo y rango ordenado de 0..1999.
- El número físico de envíos WebGL para una pantalla con glifos es 1, en lugar de N envíos individuales; el número de vértices y bytes subidos a buffers se contabilizan aparte.
- La revisión QSSD se confirma únicamente después del envío y lectura de píxeles; una confirmación desfasada o con conteos incorrectos falla.
- El test Android utiliza el escritorio REAL, con render WebGL, guarda una captura de pantalla, valida el recuento de píxeles y el código nativo original. Conservar la pantalla de texto como fallback es una función, no un resultado falso.
- Los tests nativos de Linux/Windows verifican el contrato de seriales y el plan, **no** simulan la GPU física. Solo la instrumentación Android ejerce `drawElements/finish/readPixels`.

## Restricciones explícitas

Este ciclo conecta la ruta de **VGA texto**. No reemplaza el renderer GLES3 de REgraphics para gráficos RXE ni afirma que el modo VBE32 ya utilice el mismo camino. El `PhysicalWorkAuthority` describe un plan compacto y el IBO/VBO consumen bytes físicos separados; no equipararlos ni anunciar una reducción de transferencias si la medición no la demuestra. El número de glifos puede depender del contenido. Una sola llamada GPU puede reducir el costo de *draw calls*, pero no prueba mejora de FPS o menor carga total.

La señal `submitted_webgl` es una confirmación desde el cliente WebView empaquetado de que la API terminó y permitió leer el framebuffer; **no es una certificación criptográfica del hardware** ni implica aceleración si Android ejecuta WebGL por software. Los perfiles de 3.6 GB de RAM siguen sujetos al presupuesto físico del anfitrión. No hay GPU física cuántica ni qubits físicos añadidos.

## Entrega

Esta PR se apila sobre **REVERSE-PC #238**, que incluye #237 y REgraphics #236. Las dependencias tienen SHA exacto en `docs/fabric-component-lock.json`; ninguna PR es fusionada automáticamente. La evidencia de rendimiento y salida está en el workflow `workbench-android.yml` del commit validado, con `reverse-pc-gpu-webgl.png` y `reverse-fabric-android.json`.
