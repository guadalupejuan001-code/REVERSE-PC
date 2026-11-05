# Reverse Velocity 3.0 — Open Forest Road

La nueva dirección es exploración en una carretera forestal de un carril.
La versión 2.3 conserva su rama y su PR; 3.0 desarrolla un mundo finito con
principio y final, sin vueltas, rivales de carrera ni congelación al llegar.

## Alcance de esta primera versión jugable

- Carretera de 1,6 km y 3,6 m de ancho, distribuida en ocho sectores.
- Terreno lateral transitable, tres apartaderos de tierra y un claro final.
- Bosque de árboles con troncos, arbustos/hierba, flores, rocas y vegetación
  de ribera. Las instancias mantienen su semilla global al cambiar de sector.
- Un puente corto sobre el río y una laguna con ribera inclinada.
- Ciervos, aves, siluetas de peces e insectos ocasionales, con animación XI.
- Día, atardecer y noche, ciclo automático de ocho minutos y selección manual
  de hora. Cambiar la hora en pausa no integra movimiento ni avanza la física.
- Agua con variación de brillo y coordenadas de textura animadas, cielo
  indexado gradual, iluminación de materiales y una huella barata de faros.
- Sonido ambiental sintetizado opcional: viento/aves, noche o agua. Se prepara
  en un trabajador separado y se suspende al abandonar la aplicación.
- Se conservan los tres coches, sus materiales, rodadura por velocidad,
  dirección, resortes de carrocería, nitro, salto, cámara táctil y modo foto.

## Arquitectura y prioridades

| Sistema | Autoridad | Límite de trabajo |
|---|---|---|
| Mapa | Descriptor compacto emitido en `world.xi` | 81 puntos, ocho sectores, sin cierre |
| Conducción | `drive.xi`, 50 pasos lógicos/s | Velocidad, agarre, reversa y colisiones en XI |
| Vegetación | Instancias procedurales XI con semilla global | Tres sectores activos; hasta 120 candidatos |
| Preparación vial | Ventana del sector y vecinos | Hasta 31 muestras; siete bandas por tramo |
| Colisiones | XI, entorno y troncos/rocas cercanos | Hasta doce candidatos por paso; formas conservadoras |
| Fauna | Mallas XI pequeñas y ocasionales | Distancia, franja horaria y sector limitan su presencia |
| Tiempo | Estado XI y transacción `environment.xi` | Cambio visual independiente de mover el vehículo |
| Imagen | REgraphics / XI, raster de software | Cota conservadora de 3.440 triángulos, fuente <512 KiB |
| Android | Entrada, audio y presentación de píxeles | Interpolación de paletas y calidad con histéresis |

El descriptor de mapa permanece compacto y residente. La activación por sectores
genera y descarta candidatos; no descarga archivos del entorno durante la marcha.
La preparación de carretera pasa de 81 muestras y once bandas a una ventana de
hasta 31 muestras y siete bandas. Los tres rivales dejan de generar geometría,
física y colisiones. Las copas lejanas usan menos caras que los árboles cercanos.

## Ciclos de la nueva dirección

| Ciclo | Resultado implementado | Evidencia requerida |
|---|---|---|
| 1. Estabilidad y fluidez | Presupuestos de escena, sectores, semillas estables, culling, LOD, recuperación gradual de nitidez | Fuente reproducible, límites y pruebas Android |
| 2. Mundo | Carretera abierta, ocho sectores, apartaderos, río, puente y laguna | Recorrido de principio a final sin salto de posición |
| 3. Conducción | Asfalto/tierra/pasto/barro, altura de suelo, límites de ribera y colisión con troncos/rocas | Recorrido, reversa y prueba de contacto físico |
| 4. Materiales | Capas de vegetación, flores, ribera, suelo y agua animada | Fotogramas XI reales de entrada, puente y laguna |
| 5. Día y noche | Ciclo, control manual, paletas, faros y reloj | Cambios de hora en pausa y continuidad del ciclo |
| 6. Vida y presentación | Fauna ligera, ambiente opcional, HUD de exploración y empaquetado | Ablación de fauna, controles y ciclo de vida Android |

## Contratos de datos

Los primeros 26 campos conservan su orden. En exploración las vueltas y el
indicador de meta permanecen a cero; el progreso indica posición en la carretera
y nunca se calcula con un módulo que conecte el final con el inicio.

Se añaden altura del terreno, sector, fase horaria, iluminación, bioma y presencia
en el claro final. Android acepta el protocolo de 32 observaciones; la presentación
puede leer el protocolo legado de 26 campos. `environment.xi` publica la misma
observación completa y solo modifica el estado horario.

Se conservan RVPC2, Ether y el simulador XI existentes. El render observa una
copia privada del estado y descarta cualquier candidato de memoria resultante.
No se añade un rasterizador de terceros.

## Verificación

`open-forest-contract.cpp` ejecuta el XI real: recorre los ocho sectores con
el piloto, comprueba la parada final, la reversa en ambos extremos, la ausencia
de vueltas, el cambio de hora sin movimiento, persistencia RVPC2 y contacto con
un tronco visible. `open-forest-render-contract.cjs` verifica escenas deterministas,
agua visible, fauna con cobertura causal de píxeles, límites de geometría y
fotografía nativa 4K. `VelocityWorldLightTest` comprueba las paletas, la continuidad
del ciclo y la lectura nocturna de los faros. La compilación Android se valida
contra API 35 y la APK se instala para probar controles y ciclo de vida.

## Límites de esta entrega

El mundo es contenido, con una franja lateral de hasta unos 50 m respecto a la
carretera. Los apartaderos son desvíos cortos; no hay todavía una red de rutas.
La fauna usa animación procedural ligera y no una simulación ecológica o IA
de navegación. Las colisiones de vegetación son formas conservadoras.

El acabado gráfico sigue siendo estilizado y usa 256 colores y texturas pequeñas.
El agua, reflejos y faros son aproximaciones de sombreado. No se presenta como
fotogrametría, PBR completo, niebla volumétrica o calidad Forza. El modo 4K es
fotografía en pausa; conducir usa 320×180, 480×270 o 640×360 adaptativos.
Las mediciones en el host y un emulador no prueban la fluidez de un Galaxy A16.
El siguiente presupuesto de calidad debe decidirse con mediciones del teléfono.
