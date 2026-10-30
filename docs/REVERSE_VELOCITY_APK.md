# APK de prueba de Reverse Velocity

El flavor `velocity` abre directamente `VelocityActivity` como REVERSE VELOCITY,
con identificador `com.reversepc.velocity`. Reutiliza las mismas clases Java,
las reglas XI y los cuatro assets del juego; no copia otra implementación.
La edición de prueba no solicita acceso a Internet ni se ofrece como launcher
HOME del teléfono.

La dependencia nativa Android permanece fijada en Mundo X
`1f925786522aba91f72707ad1638a8edcdd31a8f`; NDK 27.2.12479018,
Gradle 8.9, AGP 8.7.3 y Android SDK 35. La APK contiene ARM64 y x86_64,
con Android mínimo 10 (API 29).

El workflow `velocity-apk.yml` prepara una identidad de firma de desarrollo,
compila `assembleVelocityDebug`, verifica firma, alineación, launcher y hashes de
los assets. La clave se conserva en la caché de CI y no se incluye en el APK ni
en sus artefactos. La aplicación es una versión de prueba firmada.

La prueba de arranque usa un emulador Android 35 x86_64: instala la APK real,
espera un fotograma publicado, mantiene el acelerador, comprueba velocidad,
pausa/continúa, cambia cámara/pintura y vuelve al juego desde HOME. Los
resultados y capturas quedan como evidencia de CI; esto no acredita todavía
rendimiento sostenido en un Galaxy A16 físico.

Comando de compilación una vez preparado el entorno:

```sh
gradle -p reverse-os-android --no-daemon :app:assembleVelocityDebug
```

Salida: `reverse-os-android/app/build/outputs/apk/velocity/debug/app-velocity-debug.apk`.
El artefacto del workflow se llama `REVERSE-VELOCITY-0.1.0-Prueba.apk`.
