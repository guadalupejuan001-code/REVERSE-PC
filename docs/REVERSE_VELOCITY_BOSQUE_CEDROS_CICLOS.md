# Reverse Velocity — Bosque de los Cedros
## Plan de ingeniería y entregables: C1–C4

**Versión objetivo:** 2.2.0-forest-assist-xi (Android ARM64/x86_64).

El objetivo no es un paisaje añadido a una foto: se sustituye el circuito, el
asfalto, la vegetación, los materiales y las rutas que lee la física. La
representación corre en REgraphics/XI; Android solo muestra los píxeles y lee
los controles. La carrera existente tiene 80 segmentos de aproximadamente
20 metros y estados persistentes de XI; conservar ese contrato protege las
vueltas, los rivales y el sistema de colisiones.

### C1 — Conducción asistida (motor XI)
**Problema:** recorrer un circuito nuevo y admirar la escena exige poder conducir
con menos esfuerzo sin perder la opción de controlar el coche.

**Diseño:** se añade la entrada XI 136, con tres estados.

| Estado | Dirección | Gas | Frenos | Intervención humana |
|---|---|---|---|---|
| Manual | Usuario | Usuario | Usuario | Todo manual |
| Asistida | Seguimiento del camino XI si el volante está neutro | Usuario | Ayuda antes de curvas | Volante y freno prevalecen |
| Piloto | Seguimiento del camino XI si el volante está neutro | Acelera automáticamente | Anticipa curvas | Volante y freno prevalecen |

El seguimiento utiliza posiciones del centro de la pista en 4096+8i, los
componentes de dirección del coche y el yaw en 108. Proyecta la diferencia
lateral de un punto a 40 m; el frenado lee la tangente de una curva próxima
en 5000+2i y reduce velocidad antes de una esquina pronunciada.
No hay un controlador de conducción oculto en Java ni un conjunto separado
de reglas de físicas. XI continúa ejecutando 50 pasos lógicos por segundo.
El modo manual sigue siendo el comportamiento por defecto.

**Pruebas:** acelerar sin presionar gas en modo Piloto; asistencia sin gas no
debe acelerar; volantazos manuales deben sobreescribir el asistente; la
asistencia no debe llevar el coche continuamente fuera de la carretera.

### C2 — Bosque transitable y ruta que cambia de verdad
**Problema:** el óvalo del estadio es repetitivo. Cambiar únicamente
el color del fondo no sería un mapa nuevo.

**Implementación:** `world.xi` pasa a contener una ruta original sinuosa,
creada con una curva cerrada muestreada a distancias casi iguales.
El autor reproducible es `scripts/author-velocity-forest.cjs`, pero
**la APK solamente ejecuta XI**: guarda los 81 puntos en el mapa de memoria
persistente y los 80 ángulos de tangente. El trazado conserva 3 vueltas y
12 sectores, y utiliza las mismas reglas de frontera de asfalto y bordes.

**Dimensiones medidas del autor:**
- Longitud: aproximadamente **159.904 cm**, equivalente a **1.599 m**;
- 80 tramos de aproximadamente 20 m;
- Radio mínimo aproximado de las curvas: **43 m**;
- Pista cerrada: el vértice 81 repite exactamente el primero;
- Coordenadas físicas aproximadas: X 0–412 m, Z -302–302 m.

No se añaden saltos en la carretera o árboles en la calzada; primero se
mantiene una ruta manejable. La carretera forestal y el minimapa son la
misma geometría calculada por XI.

### C3 — Bosque 3D dentro del techo real de REgraphics
**Problema:** con 4K software activo la conducción caía a 1–2 FPS
en el teléfono. Un bosque debe añadir siluetas y profundidad sin
multiplicar indiscriminadamente el coste.

**Implementación:** la distribución anterior de 40 objetos pasa de
20 árboles + 10 piedras + 10 plantas a
**32 cedros altos + 4 rocas + 4 grupos de vegetación baja**.
Las coníferas tienen un ápice de más de 11 m, copa asimétrica y tronco
cruzado, manteniendo 14 vértices por árbol. El programa de autoría
`velocity-landscape-post.cjs` los emite en XI, con sombras y culling de
cámara del motor existente.

La paleta REgraphics se modifica para el dosel verde oscuro, musgo,
asfalto húmedo, suelo forestal y cielo nuboso con claridad atmosférica.
Se mantienen transparencias y materiales que ya ejecuta REgraphics,
sin añadir un segundo motor ni descargar texturas ajenas. La niebla
es una decisión de paleta y planos distantes; no se afirma que exista
un algoritmo volumétrico.

**Techo:** el presupuesto peor caso del motor permanece limitado a
4.096 triángulos de escena y 256 colores indexados. Se verifica
`render.xi`, `render4k.xi` y `render-native4k.xi` con sus fuentes.

### C4 — Integración, rendimiento y entrega
**Validaciones bloqueantes:**
1. Compilar el intérprete XI y verificar que 81 puntos forman una sola ruta
   cerrada, sin cambios en la longitud prevista de las vueltas.
2. Ejecutar físicamente una carrera completa de 3 vueltas y 12 sectores;
   comparar observaciones y snapshots serializados.
3. Probar los controles Manual/Asistida/Piloto y la prioridad del volante y
   freno humano, primero con ejecución XI y después con Android emulado.
4. Renderizar vistas del bosque, garaje, cámara libre y Foto 4K a
   3840×2160; verificar que render no modifica el estado de la carrera.
5. Empaquetar APK `com.reversepc.velocity`, comprobar firma heredada,
   ABI ARM64 y x86_64, alineación de bibliotecas y prueba de arranque
   Android 35; publicar el artefacto y enlace de descarga.

**Límites transparentes:** la asistencia es un piloto experimental de
videojuego, no un sistema de conducción vehicular real. Los árboles
son objetos 3D simplificados; no son fotogrametría, ray tracing ni
simulación forestal compleja. Foto 4K es un fotograma en pausa: no se
promete 4K a 60/120 FPS en un teléfono.

**Prueba manual posterior:** al instalar, seleccionar Piloto y comprobar
que recorra varias curvas sin salirse; luego pulsar derecha y freno para
ver que se mantiene la prioridad manual. Usar Asistida con gas manual y
orbitar la cámara para inspeccionar el arbolado. Registrar FPS activos
a resolución Auto; contrastar con la versión 2.1.

### Criterios de finalización
El código escrito, la generación reproducible, los tests locales,
el APK compilado, la firma verificada y los controles observados en
Android son pruebas diferentes. No se confunden y se enumeran por
separado en el resultado final. Una captura bonita no implica que la
simulación ni el rendimiento estén validados.
