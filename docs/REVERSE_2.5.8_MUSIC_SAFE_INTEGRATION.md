# REVERSE-PC 2.5.8 — consolidación segura de Music, BBY Q y PRISMA

## Problema corregido

YouTube se reproduce en una WebView nativa separada de la interfaz del escritorio.
Mover la WebView directamente mediante coordenadas CSS no garantizaba que toda
su superficie quedara recortada al área de vídeo. Una navegación o fullscreen
podía impedir tocar el buscador o pegar enlaces. El modo teclado ocultaba además
las pestañas y el botón para copiar.

**2.5.8** introduce un contenedor Android `FrameLayout` para la vista remota.
El contenedor limita el dibujo y los eventos táctiles a `music-stage`; la
vista remota llena únicamente ese contenedor, no todo el escritorio. El
contenedor se oculta por completo durante la edición, al cambiar de aplicación
o al pausar la sesión. El intento HTML5 de pantalla completa no toma la ventana
REVERSE. La memoria, localAudioService y el motor XI se mantienen como estaban.

El teclado conserva la barra de búsqueda, pestañas y botón copiar. La
lectura del portapapeles solo se realiza cuando el operador pulsa Pegar;
las rutas externas no obtienen acceso al puente XI/Ether.

## Funciones incluidas en la misma APK

- PR #33: PRISMA/X Render e iconos vectoriales
- PR #31: Music, reproducción local, favoritos, repetición y YouTube
- PR #34, #35: Qd/Cody como módulo interno de BBY Q, aprendizaje XI validado
- PR #27: Laplace X experimental, predictor de un paso XI con datos manuales
- PR #36: combinación de servicios y laboratorio
- PR #37: escritorio horizontal compacto, Chat, Work/W4u y Cody integrados,
  movimiento 3D optativo por sensor en PRISMA
- PR de esta revisión: contención nativa de YouTube + UI de teclado y regresiones

El módulo Qd comparte identidad y memoria privada RVPC2 con BBY Q. W4u
solo ejecuta acciones explícitas disponibles; no se anuncian funciones
autónomas todavía inexistentes.

## Ramas no incorporadas automáticamente

- PR #32: nueva ejecución ARM64/Linux con cambios de CPU/JNI y snapshots.
  Permanece independiente, su integración alteraría el núcleo validado y
  requiere campañas de compatibilidad y persistencia propias.
- PR #30: inspector estático de compatibilidad Wild Rift; no ejecuta Android.
  Se conserva como análisis separado y no se anuncia como emulador completo.
- PR #21: BBY Q E010, anterior al E025 incluido; no se degrada la versión.
- PR #5 y ramas de rendimiento: pruebas de investigación para el núcleo,
  independientes de la interfaz APK. Se preservan intactas.

El hecho de que una rama permanezca independiente no implica borrar código
ni perder avances. Las ramas integradas y no integradas están documentadas.

## Pruebas de entrega

Exigir CI de código XI, UI en diversos tamaños, Music copy/paste/teclado,
contenedor nativo recortado, Android 15 con migración, gráficos PRISMA,
Cody, Music, restauración y firma del APK. No afirmar éxito hasta obtener
el resultado real del workflow. Las firmas CI son efímeras: no instalar
por encima de una app firmada con otro certificado sin respaldar datos.
