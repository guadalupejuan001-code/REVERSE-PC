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
El artefacto actual del workflow se llama `REVERSE-VELOCITY-0.3.0-Autos.apk`.

## Coches 0.3

La versión `0.3.0-cars` tiene versionCode 3 y conserva el mismo paquete y
certificado de desarrollo. Sustituye las carrocerías de cajas por mallas curvas
con pasos de rueda, cristales inclinados, llantas y sombreado interpolado.
`Nitidez` permite fijar `Alta` a 640×360 o regresar a `Auto`, adaptativo.
La física y el circuito conservan las fuentes de la versión 0.2.

El smoke exige un fotograma nuevo a 640×360 con `fixedDetail=true`, pausa sin
avance del cronómetro y retorno a la resolución adaptativa con
`fixedDetail=false`. Después comprueba conducción y graba vídeo en `Auto`.
La comprobación del selector acredita la resolución usada, sin presuponer una
tasa de imágenes en el dispositivo físico.

[Modelo, materiales, pruebas y límites de los coches](REVERSE_VELOCITY_CARS_V03.md).

## Carrera 3D 0.2

La versión `0.2.0-race3d` tiene versionCode 2 y conserva el paquete y certificado
SHA-256 `061c28614fffecdc9a53a5661c4acf8c4d1173b631095aaaee8a98070abdf0d7`
de la APK 0.1 verificada. El empaquetado rechaza una identidad diferente.
El nuevo smoke comprueba aceleración tras la cuenta atrás, giro físico,
pausa, cámaras, pintura, recuperación y grabación real de diez segundos.
Los resultados de esta compilación deben consultarse en su workflow: la
prueba histórica de abajo corresponde exclusivamente a la versión 0.1.

[Arquitectura y límites de la carrera 3D](REVERSE_VELOCITY_RACE3D.md).

## Histórico: primera APK 0.1 verificada

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

## APK 0.2 verificada

La fuente `8ec9dd2e92d5f0438996b347f7e5ffa3b546bdf9` pasó el
[workflow Android completo](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/41091100443)
y la [validación de XI/JNI/Java](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/41091111031).
El smoke completó 28 comprobaciones, incluida una grabación de 9,986 segundos,
giro real, pausa, cámaras/pintura y reapertura conservando la carrera.
La observación final mostró posición (-392,36071) cm, yaw 3591 y 115 km/h.

APK: 3.800.703 bytes; SHA-256
`79f91f702b7d64e9f37b34895700d9ffdd1aa7da1674f5232821707ed2f2853f`.

Vídeo original de la APK: 1.214.320 bytes; SHA-256
`e1a68aa154681aa7fe86caf8026548bfa58f326de4bd2503eb0c9bf778746938`.

Durante siete muestras de carrera y grabación en el emulador Android 35 x86_64,
la escena de 320×180 tuvo 26–30 FPS publicados y aproximadamente 50 pasos
físicos por segundo. El arranque frío a 480×270 fue más lento y activó la
reducción automática de calidad. Estas cifras no son una medida del Galaxy A16.

La segunda prueba encontró una fila válida con 48 regiones de primer plano
que rebasaba el límite provisional de 47. La versión final transmite hasta
una región por píxel, y la misma instantánea ya renderiza completa. También
pasó una carrera completa con 14 observaciones periódicas y estado final idéntico
al recorrido sin render. Evidencia local persistida en
`docs/evidence/velocity-race3d-coupled.json`.

El resultado exacto del paquete y del smoke está en los archivos
`docs/evidence/velocity-apk-0.2.0-package.json` y
`docs/evidence/velocity-apk-0.2.0-smoke.json`.


## APK 0.3 verificada

La fuente `236513fc0870e5e07a5ff0eb2f1d2609e29328ce` pasó el
[workflow de APK](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/41101228105)
y la [validación XI/JNI/Java](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/41101234581).
El smoke de Android 35 x86_64 completó 35 comprobaciones: instalación,
fotogramas reales, aceleración, dirección, pausa, cámaras, pintura, ambos
perfiles de nitidez, regreso desde HOME y grabación de vídeo.
La velocidad observada pasó por 57 km/h y terminó a 120 km/h, con posición
(-357,36638) cm y yaw 3592 tras operar los controles.

APK: 3.862.959 bytes; SHA-256
`beee163435aea85db6d5c55c1a9e16a0071ef1e14e5ca784c389c00e095e4bff`.
Conserva el certificado SHA-256
`061c28614fffecdc9a53a5661c4acf8c4d1173b631095aaaee8a98070abdf0d7`;
las dos bibliotecas ABI y el ZIP pasaron la alineación de 16 KiB.

Vídeo original de la APK: 1.401.352 bytes y 10,1681 segundos; SHA-256
`63bbf2ba030aca046c8ffccf8cfa446e814774abc8c5fdbe73dc9a8228ab3e70`.
Es una grabación real mediante `adb screenrecord`, no un render promocional.

Tras volver de Alta a Auto, ocho muestras durante conducción y grabación
publicaron 28–30 FPS a 480×270, con física a 50 Hz. En esa ventana hubo
241 fotogramas en 8,152751745 segundos (29,56 FPS ponderados). El arranque
frío fue más lento y redujo temporalmente a 320×180; las muestras de pausa
rondan 10 FPS por el ritmo de reposo y se excluyen de la ventana de conducción.
Alta se comprobó con un fotograma nuevo a 640×360 y `fixedDetail=true`,
sin avance del cronómetro. No se midió su conducción sostenida ni el
rendimiento del Galaxy A16 físico.

Resultados exactos: `docs/evidence/velocity-apk-0.3.0-package.json` y
`docs/evidence/velocity-apk-0.3.0-smoke.json`.
