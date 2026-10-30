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

## Primera APK verificada

La compilación del commit `8d43d2e1d7c33756f0df5e4f8e12529bdd5165d1`
pasó [el workflow de APK](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/41078636019).
El smoke completó 20 comprobaciones: primer fotograma, aceleración a 63 km/h,
pausa, cámara, pintura y reapertura mediante el lanzador conservando la carrera
(757 ticks observados tras volver). La actividad standalone usa un único task
para impedir que una nueva entrada del lanzador reinicialice la partida.

La APK mide 3.761.831 bytes. SHA-256:
`df6dedceae3b52315bca8b0a4a5d9c16cfd4488acbd5192ce47a638ff014ee37`.
Los resultados exactos están en `docs/evidence/velocity-apk-0.1.0-package.json`
y `docs/evidence/velocity-apk-0.1.0-smoke.json`. El dispositivo físico del usuario
no se ha probado desde este entorno.
