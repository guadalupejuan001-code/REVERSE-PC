# Reverse Velocity 2.3 — dinámica, materiales y bosque

Parte de la versión 2.2 (`d28f6a4`). El motor de conducción y el render
siguen ejecutándose en XI sobre Ether / REgraphics. Android presenta la imagen.

## Ciclo 1 — movimiento secundario

- Las ruedas del jugador integran velocidad física a 50 Hz, incluyendo reversa,
  con fase y resto enteros persistentes. No dependen del progreso de la pista.
- Se conserva el giro de dirección de las ruedas delanteras.
- Cuatro resortes amortiguados Q8 conservan posición y velocidad: cabeceo por
  aceleración medida, balanceo por dirección/velocidad/deslizamiento, movimiento
  vertical con impulso de aterrizaje y desplazamiento lateral por derrape.
- El cuerpo rota alrededor de los ejes y los cubos conservan el apoyo en tierra.
  En vuelo las ruedas extienden visualmente su recorrido 4 cm.
- Estado nuevo: Ether 496..519. El protocolo público conserva 26 registros.
  Renderizar, pausar o cambiar de cámara no integra física adicional.

## Ciclo 2 — materiales

Tablas distintas para pintura con brillo y reflexión aproximada de borde,
cristales con reflexión del cielo, goma mate sin el brillo de pintura,
rines con especular más amplio y piezas aerodinámicas de brillo bajo.
Las tablas se calculan por actor y se consultan por vértice; no hay
iluminación cara por píxel. Se mantiene la señal real de las luces de freno.

## Ciclos 3 y 4 — bosque y luz

Las arboledas existentes varían escala, altura, profundidad, inclinación y
separación mediante semillas deterministas. El borde tiene textura procedural,
las rocas tienen material propio y el bosque pierde contraste con la distancia.
El cielo, las montañas, el suelo y las sombras usan una paleta coordinada.
La inclinación del chasis también modifica la base de iluminación.

## Validación

- Carrera XI de 3 vueltas y 12 sectores sin salidas o contactos con muros.
- Pruebas de giro por velocidad, balanceo contrario en curvas, cabeceo de
  aceleración/frenada, compresión/rebote/asentamiento y reproducción RVPC2.
- Comparaciones de píxeles con y sin resortes en los tres vehículos del garaje.
- Cámaras, cinco pinturas, efectos, captura 4K y regeneración reproducible XI.
- Presupuesto máximo conservado: 4.090 / 4.096 triángulos; 894 en el coche
  principal. Cada programa XI queda por debajo de 512 KiB.

## Límites prácticos

Es render de software estilizado con paleta de 256 colores. La reflexión y
la atmósfera son aproximaciones de sombreado, no PBR, trazado de rayos ni
niebla volumétrica. La suspensión visual observa la física existente; no
introduce cuatro contactos de neumático independientes ni cambia el circuito.
Los rivales conservan su cálculo de rodadura por distancia recorrida. Los
normales de ruedas conservan la aproximación del modelo anterior al girar.
4K es foto en pausa; conducción mantiene resolución adaptativa. Las mediciones
en el host y el emulador no equivalen a FPS medidos en el teléfono del usuario.

## APK de prueba local

`package-velocity-preview.py` combina los assets XI verificados con el shell
Android/JNI intacto de la APK 2.2. La aplicación de prueba tiene identidad
`com.reversepc.velocity.preview`, nombre visible `VELOCITY 2.3 PRUEBA`,
versionCode 23 y una firma de desarrollo propia. Se instala en paralelo a 2.2.
La firma v3 y la alineación de bibliotecas a 16 KiB se comprueban con las
herramientas oficiales Android 35. No se presenta como actualización firmada
con la clave original ni como una nueva compilación del shell Java/C++.

La publicación de la rama fue bloqueada por la revisión automática por falta
de autorización explícita para subir código al repositorio público. La rama y
los commits están guardados localmente; no se creó una PR ni se ejecutó CI
remota para esta versión. La APK de actualización con la firma anterior sigue
pendiente de la autorización para esa publicación y de su compilación.

Medición local A/B de render completo al arrancar, muestras intercaladas,
320×180: mediana 2.2 = 28,189 ms; mediana 2.3 = 31,934 ms (7 muestras
por versión después del calentamiento, aproximadamente +13,3 %). Incluye
arranque del CLI, lectura de fuente y persistencia; no son FPS de Android.
