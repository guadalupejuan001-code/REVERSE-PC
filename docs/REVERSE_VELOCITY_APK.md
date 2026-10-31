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
El artefacto actual del workflow se llama `REVERSE-VELOCITY-0.8.0-Realismo-XI.apk`.

## REgraphics 0.8 — materiales GLES3 más realistas
La versión `0.8.0-realismo-xi` mantiene el motor XI, el formato
XFG4 de la geometría 4K y la vía CPU sin alterar el circuito ni la física.
El shader REgraphics GLES3 usa normales derivadas de la geometría, una
aproximación de Fresnel para el cristal, reflejo del cielo sobre la pintura,
materiales diferenciados para metal, aero y goma, asfalto de dos escalas,
un gradiente atmosférico y muestreo bilineal de los texeles XI.
El color final de la GPU admite RGB completo además de la paleta XI.
Esto **no es** PBR completo ni iluminación global fotorrealista.
La prueba Android registra 4K, FPS y captura la pintura blanca real
seleccionada por el usuario en la interfaz de juego.
[Detalles técnicos de materiales](REVERSE_VELOCITY_MATERIALS_08.md).

## REgraphics 0.7 — GPU nativa 4K (experimental)
La edición Android `0.7.0-4k-gles3` incrementa `versionCode` a 7 y
conserva el paquete `com.reversepc.velocity` y la firma de desarrollo.

La interfaz añade el control **4K**, independiente de Auto/Alta. El mismo
generador de XI crea `render4k.xi` con resolución de proyección
**3840 × 2160** y revisión de geometría XFG4. XI conserva la cámara,
las texturas, la iluminación y todas las reglas de física. REgraphics
usa GLES3 para materializar los triángulos en un framebuffer real;
la CPU original queda como vía de recuperación.

La resolución interna efectiva, el número de triángulos y los FPS se
registran en la telemetría. Un equipo incompatible con 4K puede usar
1080p/720p o regresar a CPU. No se supone rendimiento 4K sostenido en
Galaxy A16 sin medirlo.

[Arquitectura y limitaciones](REVERSE_VELOCITY_GLES3_4K.md).

## RV-01 0.6 — texturas reales creadas con XI

VersionCode **6**, versión `0.6.0-xi-textures`. Mantiene el paquete y firma
de desarrollo de la 0.5 para instalación como actualización Android.
El rasterizador REgraphics conserva la iluminación generada por XI y
ahora interpola coordenadas UV por perspectiva, con tiles indexados 16×16
y modulación tonal Q8. La pintura blanca, cristal tintado, carbono, goma
y metal de las llantas poseen materiales texturizados; la superficie
asfáltica existente recibe un mosaico anclado a su geometría 3D.
No se modifican el trazado, las reglas físicas, ni los controles.
Los datos se producen por `scripts/velocity-textures.cjs`, no por un render
generado artificialmente. Los resultados y velocidad del teléfono físico
no se infieren de las pruebas del emulador.
[Documentación del pipeline XI](REVERSE_VELOCITY_TEXTURES_XI.md).

## RV-01 0.5 — detalles 3D de carrocería (verificar evidencia en CI)

La versión `0.5.0-rv01-detail` (versionCode 5) mantiene el paquete
`com.reversepc.velocity` y el certificado de desarrollo de 0.4.
Su automóvil principal suma paneles reales en la malla: juntas de puertas,
marcos del techo, líneas de carrocería, aletas de difusor con profundidad,
un receso trasero y remates metálicos.
Su LOD alto usa 894 triángulos; los LOD de rivales se mantienen en
306 y 108. La escena completa tiene un máximo acotado de
4082/4096 triángulos. XI transforma 1543 entradas de vértice
(`max 1600`). No se cambian las pistas ni las reglas de conducción.

La referencia visual de alta fidelidad compartida por el autor del proyecto
es un **objetivo**, no una captura producida por REgraphics. La etapa 0.5
no incluye todavía mapas PBR, texturas de asfalto o cielo, reflejos
de escena ni resolución 1080p. [Criterios de calidad y plan del
renderizador](REVERSE_VELOCITY_FIDELITY_TARGET.md).

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
