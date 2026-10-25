# BOARDWALK → ESPACIO (Android, v1)

Una demo técnica georreferenciada: POV desde el Boardwalk de Atlantic City
hasta una observación virtual a 400 km sobre el mismo punto geográfico.

No hay vuelo humano. La cámara es un observador matemático sin cuerpo;
el ascenso es una transición de escala visual y no una trayectoria dinámica.

## Capacidades

- Una única Tierra esférica (radio NASA 6.371 km), sin cambiar de escenario.
- Textura terrestre satelital NASA Blue Marble, guardada offline en el APK.
- Atmosfera con dispersión Rayleigh y Mie aproximada mediante ocho muestras
  en el shader, que se debilita naturalmente fuera de la atmósfera.
- Escena local aproximada: paseo de madera, playa, agua, Steel Pier,
  noria y siluetas de edificios. No es fotogrametría ni mapa LIDAR.
- Cámara georreferenciada cerca de Steel Pier, con ángulo/rumbo ajustables.
- POV automático de ~57 segundos con la misma latitud/longitud,
  cámara libre para girar y deslizador de altitud de 6 m a 400 km.
- HUD: altitud real del modelo, horizonte geométrico, gravedad decreciente,
  rendimiento del bucle GPU y porcentaje de resolución interna.
- AUTO/ECO/ULTRA, resolución dinámica, captura PNG local.
- APK offline Android 10+ (sin Internet ni permisos extra).

## Cómo obtener la APK

En GitHub Actions se construye la APK con la textura NASA descargada de
fuente oficial antes de empaquetarla:

    cd boardwalk-space-android
    bash scripts/fetch-earth.sh
    gradle --no-daemon :app:assembleDebug

APK: app/build/outputs/apk/debug/app-debug.apk

## Demostración reproducible

    javac -d build/math app/src/main/java/com/reversepc/boardwalk/ObserverMath.java tests/ObserverMathTest.java
    java -cp build/math ObserverMathTest

Un workflow adicional instala la APK en un emulador Android 15, abre la
cámara y comprueba capturas de suelo y espacio.

## Crear el video

1. Activa la función de grabación de pantalla de Android/Samsung.
2. Abre la app y selecciona AUTO para empezar.
3. Pulsa INICIAR POV.
4. Pulsa OCULTAR para reducir las superposiciones.
5. Termina la grabación con las funciones normales del dispositivo.

Consulta SOURCES.md antes de publicar el video: el escenario local es
procedimental y la Tierra es un mosaico histórico NASA. La demostración
no acredita que el núcleo cuántico calcule los gráficos.
