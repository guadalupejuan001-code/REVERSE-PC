# REVERSE Music · 2.5.2

REVERSE Music es el reproductor de YouTube integrado en el escritorio. Aparece en Aplicaciones, búsqueda, Centro de control y barra de tareas. Conserva una sola sesión entre Principal y Enfoque.

## Uso

1. Abre REVERSE Music y escribe un artista o canción, pega un enlace de YouTube o pulsa **Abrir YouTube**.
2. Selecciona un resultado en la página. Los controles del reproductor y de YouTube permiten reproducir, pausar y cambiar de canción cuando existe una pista/lista compatible.
3. **Guardar favorito** conserva el video o lista actual. Favoritos y la última búsqueda se guardan en el mismo perfil atómico del escritorio y se incluyen en su respaldo. No se guardan archivos de audio.
4. El botón **Bloqueador** activa o desactiva el filtrado. La preferencia se conserva en Android; el contador muestra solicitudes bloqueadas en la sesión actual.

Abrir o restaurar una ventana carga solamente la interfaz local. La conexión a YouTube empieza tras Buscar, Abrir YouTube o elegir un favorito. Restaurar un perfil nunca inicia música.

Minimizar, cambiar de espacio o abrir otra herramienta conserva la vista y su sesión; su superficie se oculta para respetar las ventanas del escritorio. Salir de REVERSE o apagar la pantalla pausa la reproducción. Volver no reproduce automáticamente. Cerrar Music destruye la vista, el temporizador y la sesión multimedia. La pérdida de foco de audio y la desconexión de auriculares pausan el reproductor.

## Filtrado y límites

`MusicPolicy` bloquea dominios publicitarios conocidos y rutas de anuncios de YouTube mediante `shouldInterceptRequest`. No bloquea googlevideo, el endpoint del reproductor ni las miniaturas. `assets/music/youtube.js` oculta espacios publicitarios y solo silencia/avanza el video cuando el reproductor declara explícitamente `ad-showing` o `ad-interrupting`; restaura el silencio anterior al terminar o desactivar el filtro.

El bloqueo es experimental: los selectores, rutas y anuncios insertados dentro de una transmisión pueden cambiar. No se promete eliminar todos los anuncios, evitar una pantalla anti bloqueador ni reproducir contenido restringido o de pago. Si YouTube no carga con el filtro, desactívalo y pulsa Recargar. No se extraen URLs privadas de streaming ni se descargan pistas. Esta primera versión usa la página móvil de YouTube; un enlace compartido desde YouTube Music abre el mismo video/lista en YouTube.

## Aislamiento

El WebView del escritorio conserva `https://reverse.local/`, su CSP sin conexiones ni iframes y su puente `ReverseNative`. `MusicPlayer` crea un segundo WebView sin `addJavascriptInterface`, sin acceso file/content, sin contenido mixto y sin permisos de cámara, micrófono o geolocalización. La navegación principal se limita a HTTPS de YouTube y su consentimiento; no hay un flujo de credenciales incrustado. Los enlaces arbitrarios, intents y descargas se rechazan.

Los comandos y límites de la superficie se originan en la interfaz empaquetada. Android lee título/tiempo/estado mediante `evaluateJavascript` y devuelve datos JSON al escritorio; los títulos se muestran como texto. La superficie nativa se oculta al abrir menús, cuadros de diálogo, Favoritos u otra ventana. El reproductor no ejecuta XI ni modifica checkpoints RVPC2, ejecutables o memoria de BBY Q/W4u.

Referencias: [WebViewClient](https://developer.android.com/reference/android/webkit/WebViewClient#shouldInterceptRequest(android.webkit.WebView,%20android.webkit.WebResourceRequest)) y [WebSettings](https://developer.android.com/reference/android/webkit/WebSettings#setMediaPlaybackRequiresUserGesture(boolean)). El filtro de solicitudes no intercepta todas las clases de URL ni todas las redirecciones; el aislamiento no depende del éxito del bloqueo publicitario.

## Validación

```sh
mkdir -p build/music-policy
javac -d build/music-policy reverse-os-android/app/src/main/java/com/reversepc/os/MusicPolicy.java reverse-os-android/tests/MusicPolicyTest.java
java -cp build/music-policy com.reversepc.os.MusicPolicyTest
NODE_PATH=/ruta/a/node_modules node reverse-os-android/tests/music-ui.cjs evidence/music
```

`MusicPolicyTest` verifica enlaces, búsquedas UTF-8, navegación, dominios engañosos y conservación de solicitudes de contenido. `music-ui.cjs` usa los archivos empaquetados en Chromium, con transporte nativo controlado, en 640×360, 740×360, 844×390, 915×412, 1024×600 y 1440×900; comprueba persistencia, favoritos, límites, ventanas y medios/anuncios de prueba.

El workflow de APK añade `mode=music` a `WorkbenchTestRunner`. `MusicPlayerChecks` verifica un WebView Android real con HTML local bajo un origen de prueba YouTube, sin solicitudes a YouTube: ausencia de puente, permisos de archivos, filtros, límites y ciclo de vida. Además decodifica y reproduce un WAV PCM local real en el motor multimedia de Android: avance del reloj, pausa, interrupción de audio, reanudación manual y cierre. Las pruebas locales y de DOM no acreditan reproducción o bloqueo contra el servicio real. Sigue pendiente probar audio y anuncios reales en el teléfono.

Las ediciones Workbench y REVERSE mantienen sus identificadores de paquete y elevan `versionCode` a 252. La actualización instalable exige la misma firma de distribución; la APK de CI usa una firma temporal y no debe presentarse como actualización firmada de 2.5.1.

## Refinamiento de reproducción y ventanas

Cada ventana identifica sus comandos y respuestas. Cerrar libera la sesión inmediatamente; una respuesta atrasada o el cierre de una ventana anterior no puede modificar una nueva. Importar un perfil con ventanas Music duplicadas conserva una sola sesión. La búsqueda escrita se conserva al cambiar de pestaña. La barra de posición sigue avanzando después de tocarla y solo se detiene visualmente mientras se arrastra.

El reproductor publica un estado completo al cargar, fallar o recuperarse: se borran el título, tiempo, controles y favorito de la pista anterior. Los errores HTTP y un WebView sin respuesta ofrecen recarga. Solo hay una consulta de estado pendiente; se descartan respuestas de documentos o sesiones anteriores. Los controles de lista se habilitan cuando el reproductor dispone de ellos, y la sesión multimedia de Android conserva el control Reproducir cuando está en pausa en primer plano.

Una interrupción de audio o desconexión de auriculares mantiene pausados todos los elementos multimedia hasta una interacción real o un comando explícito de reproducción. Volver a la aplicación conserva esa pausa. El filtro solo adelanta anuncios declarados por un contenedor que contiene el video actual; anuncios de otras partes de la página no alteran la canción. Las acciones de salto tienen un intervalo mínimo para evitar bucles de clics.
