# REVERSE-PC 2.5.7 — estado de consolidación y ramas

## Entrega unificada de esta compilación

El árbol de la rama `ux/reverse-compact-bbyq-gyro-20261028` desciende de la integración PR #36 y preserva sus capacidades. La APK conjunta incorpora:

- **PR #33:** iconos vectoriales, PRISMA 1.2 y X Render (motor nativo XI/Ether)
- **PR #31:** REVERSE Music, archivos locales, favoritos, repetición, YouTube y filtro experimental
- **PR #34 y #35:** Qd/Cody como módulo de programación del mismo BBY Q, evaluación XI 32 casos y memoria privada compartida
- **PR #27:** laboratorio Laplace X, pruebas de predicción cronológica y ejecución XI aislada bajo demanda
- **PR #37:** escritorio horizontal compacto, ventanas no superpuestas, botones pequeños, BBY Q Chat / Work-W4u / Cody, paralaje optativo desde sensor para PRISMA
- **2.5.7:** controles Music que no quedan cubiertos por WebView remoto, pegado/copias explícitos y comprobaciones nativas de límites de ventana

E025 y W4u se mantienen fijados en la cadena del compilador. No se sobrescribe el estado de usuario ni se modifican los repositorios de origen.

## Pendientes: NO se mezclan a ciegas

| PR | Contenido | Estado para APK 2.5.7 |
|---|---|---|
| #32 | Emulador ARM64/guest Linux, núcleo/JNI, SoftFloat y snapshots | **Pendiente**, no incluido. Modifica código nativo, ABI y autoridad de estado; necesita integración y pruebas propias antes de alterar una APK ya estable |
| #30 | Auditoría estática de APK Wild Rift | **Separado**. No ejecuta Android ni juegos y no introduce una aplicación jugable |
| #21 | Laboratorio BBY Q bilingüe E010 | **Superado por E025**; no degradar memoria ni reemplazar modelos |
| #5 | Pruebas de rigor Clifford/estado | **Pruebas independientes**; sin aplicación visual, reservar para CI al revisar núcleo |
| Ramas históricas / perf / experimentos | Variantes XI/Ether y estudios parciales | **Separadas** hasta demostrar equivalencia en la misma versión del motor; no crear conflictos cambiando dependencias fijadas |

## Seguridad, compatibilidad y evidencias

La vista de YouTube es una segunda WebView sin puente JNI. Solo puede ocupar la región de vídeo delimitada por la barra de búsqueda, pestañas y controles. El host valida los límites antes de mostrarla y la oculta cuando el usuario edita o pega. Lectura de portapapeles **solo tras pulsar Pegar**, sin sondeo ni guardar copias adicionales. El botón Copiar valida la URL como YouTube. El filtro de solicitudes no es un bloqueo infalible.

La fuente de sonido de YouTube depende de condiciones de la plataforma/servicio. La descarga de música no extrae audio de YouTube; importa archivos locales o URLs HTTPS directas permitidas. En pantalla pequeña se mantiene una sola ventana activa visible, preservando otras sesiones.

Los resultados XI y estadísticas se representan con procedencia; no se anuncian como aceleración cuántica física, generalidad de Cody o poder de predicción futura garantizada.

**Prueba obligatoria:** comparar UI en pantallas 640/740/844/915/1024/1440, edición de música, bounding seguro del WebView, importación y reproducción de audio, migración de BBY Q/W4u, examen de Cody, PRISMA, Laplace, persistencia y prueba Android 15. La firma CI es efímera e incompatible con firmas previas; exportar respaldo antes de reemplazar APK.
