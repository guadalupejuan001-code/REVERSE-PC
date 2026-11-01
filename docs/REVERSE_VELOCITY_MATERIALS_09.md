# RV-01 0.9 — materiales realistas en REgraphics/ XI

## Alcance
Modificación real de `VelocityMaterialShader.FRAGMENT` en
`reverse-os-android/app/src/main/java/com/reversepc/os/`.
El motor conserva XI, la geometría original, las físicas y los diseños
actuales de pista. Las texturas originales de ocho tiles 16x16 se
siguen leyendo de la salida de XI y se combinan con microdetalle
procedural ligado a coordenadas UV del vehículo y carretera.

## Materiales implementados
- **Pintura automotriz:** dos lóbulos de brillo y Fresnel de Schlick
  sobre la pintura original y el reflejo aproximado de una atmósfera.
- **Vidrio:** tinte oscuro bajo el reflejo, coeficiente de Fresnel
  independiente y brillo más concentrado.
- **Metal:** brillo metálico, reflejo y acabado mecanizado sobre llantas.
- **Carbono/aerodinámica:** patrón tejido de XI y reflexión difusa.
- **Caucho:** estrías y rugosidad del neumático muestreadas según UV.
- **Asfalto:** grano de dos frecuencias y atenuación atmosférica al alejarse.
- **LED:** luminancia diferenciada para faros y luces traseras.

La corrección tonal final utiliza un operador acotado, no una conversión
de la paleta XI a un render fotográfico externo. El ruido se calcula en
coordenadas de modelo: no permanece pegado a la pantalla.

## Pruebas de aceptación
1. Sintaxis de la fuente Java y requisitos del shader GLES3.
2. Ejecución de la escena XI real y del rasterizador CPU, sin alteraciones
   en la carrera y en el estado InverseMemory.
3. Instalación y ejecución de la nueva APK en Android, activación del
   framebuffer 3840x2160, cambio de cámara y regreso a CPU.
4. Captura real de Android con el RV-01 y telemetría de resolución/FPS.
5. Reutilización de firma, package y controles para actualizar 0.8 a 0.9.

**Limitaciones:** 4K requiere GPU; las texturas fuente siguen teniendo
16x16 texeles y la carrocería LOD alto tiene menos de 900 triángulos.
No se puede declarar fidelidad AAA ni FPS concretos en Galaxy A16 sin
medirlos físicamente.
