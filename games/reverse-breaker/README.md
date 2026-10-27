# REVERSE BREAKER 1.0

Primer juego de REVERSE Workbench. Es un juego de romper bloques con gráficos y código propios: cinco sectores, tres vidas, control táctil, teclado, pausa, partida y récord persistentes. Incluido en Workbench 2.1.0 con el mismo paquete y firma de las versiones 2.0 y 2.0.1.

En Aplicaciones abre **REVERSE BREAKER → Jugar**. Arrastra dentro del tablero para mover la barra. También admite A/D o flechas, Espacio para jugar/pausar y R para empezar una partida. Mesa o Atrás vuelve al escritorio actual.

## Qué ejecuta cada parte

- `game.xi` contiene toda la física, colisiones, vidas, bloques, puntuación, récord y transición entre sectores. Son instrucciones clásicas de XI y bytes de Inverse Ether Memory, ejecutadas por el runtime existente. El juego no requiere puertas cuánticas.
- El archivo se compila a RXE1 / XI-machine-v1. Pesa 5.835 bytes en esta versión. El registro gráfico `breaker-v1` reconoce los bytes exactos del ejecutable incluido; un título parecido no concede esa capacidad.
- `rxe_game.hpp` y JNI solo transportan la entrada y la salida. Android Canvas dibuja el estado devuelto por XI y recibe controles. No hay un motor externo ni una segunda implementación de las colisiones en Java.
- Cada llamada hace de cero a cuatro pasos fijos de 1/60 s. El reloj anfitrión limita la recuperación de retrasos a cuatro pasos; los dispositivos lentos pueden bajar su ritmo. La interfaz muestra tiempo real de ejecución XI, pasos completados por segundo y dibujos por segundo. No se prometen FPS del teléfono a partir de un benchmark del servidor.
- La partida privada usa `reverse-breaker-v1.rvp` y `AtomicFile`. Se guarda al pausar/salir, periódicamente y en eventos. El escritorio y BBY Q conservan sus archivos de estado. Volver a abrir una partida empieza en pausa.

## Contrato

Entrada: paddle LE16 en 64, comando en 66 (0 continuar, 1 lanzar, 2 nueva), pasos en 67 (0 a 4). Inverse Memory guarda versión en 0, estado en 1 (0 listo, 1 jugando, 2 derrota, 3 victoria), vidas en 2 y sector en 3. El encabezado del XI documenta el resto de las direcciones.

La salida tiene 18 líneas JSON: x, y, vx, vy, barra, puntuación, vidas, estado, sector, bloques restantes, récord, evento, cinco máscaras de bloques y contador de pasos. El anfitrión consume esa salida; las máscaras y el contador proceden de XI.

## Verificación

`tests/breaker_test.cpp` comprueba lanzamiento, límites de control, paredes, pala, eliminación de bloques, puntuación y récord, vidas, derrota, siguiente sector, victoria y reinicio. Ejecuta 1.200 avances de hasta cuatro pasos, comprueba invariantes y continuación determinista después de restaurar RVPC2. Publica mediana y percentil 95 medidos.

La instrumentación Android abre el juego desde su ventana RXE mediante toques reales, mueve la barra, verifica pausa, guarda, cierra el proceso y verifica la restauración. También comprueba que el estado del escritorio no se modifique y que Mesa vuelva al Workbench actual. El workflow conserva las pruebas previas de actualización, BBY Q, calculadora y archivos.

Compilar con el runtime fijado:

```sh
bash scripts/setup-ether.sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target reverse_pc reverse_pc_breaker --parallel 2
./build/reverse_pc compile games/reverse-breaker/game.xi REVERSE-BREAKER.rxe 'REVERSE BREAKER'
./build/reverse_pc_breaker games/reverse-breaker/game.xi
```
