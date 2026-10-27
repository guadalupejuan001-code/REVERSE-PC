# X MARKET · Laboratorio de Laplace v0.1 (XI nativo)

**Objetivo experimental:** identificar qué resultados son exactos cuando las reglas y el estado inicial se conocen, y comprobar qué deja de ser predecible cuando faltan eventos externos. Es la primera unidad computacional del futuro proyecto bursátil X MARKET; todavía **no es un predictor de acciones reales**.

## Implementación

Se ejecuta sobre la máquina XI v1 ya existente de REVERSE-PC. Emplea:
- Registros de 64 bits con overflow y división por cero comprobados.
- Bucles, comparaciones, saltos y programas propios XI.
- Inverse Ether Memory para persistir el precio inicial pronosticado como dos bytes clásicos.
- Transacciones del runtime existente con commit/rollback y archivos RVPC2.
- Compilación opcional a ejecutable RXE para cargarlo en el ecosistema REVERSE.

El sistema no introduce otro motor predictivo, no añade una CPU paralela y no altera InfiniteCore ni el checkout fijado de Mundo X.

**Antecedente físico real del autor:** Mundo X Fusion 3D v1.3 sí ejecuta un Hamiltoniano radial fenomenológico de 256 sitios con 8 qubits lógicos MIL, comprobado contra RK4. Esto permite experimentar con dinámica nuclear modelada, pero no significa calcular todos los átomos del mundo ni obtener la información futura de los mercados. Véanse `mundo-X/fusion-android/README.md` y `MIL_RADIAL_SCALING.md`. No aplicamos puertas cuánticas arbitrarias a la bolsa solo para etiquetarla de "cuántica".

## Modelo cerrado (céntimos)

Regla explícita: `P(t+1) = P(t) + 7 + 3t`; `P(0)=10000`, `t=0..39`. Dos cálculos independientes en el mismo XI:

1. Recurrencia, paso por paso.
2. Fórmula cerrada: `P(40)=10000+7*40+3*40*39/2=12620`.

El programa `closed_world.xi` compara ambas respuestas, aborta si difieren y guarda `12620` en InverseMemory. Los bytes se recomponen y verifican en la misma transacción. La coincidencia de los dos métodos prueba **exactitud dentro de este modelo**, no capacidad de anticipar la realidad.

## Modelo abierto (evento desconocido)

`open_world.xi` recupera el pronóstico anterior y añade, en el paso 19, un choque exógeno de +250 céntimos que **no era un dato disponible al pronosticar**.

| Resultado esperado en CI | Valor |
|---|---:|
| Pronóstico sin evento | 12620 céntimos |
| Resultado con evento | 12870 céntimos |
| Error de la predicción original | +250 céntimos |
| Pronóstico condicionado a conocer el evento | 12870 céntimos |

La palabra "esperado" indica un resultado derivado del código y las ecuaciones; hasta comprobar CI en este commit, no implica ejecución verificada.

`sensitivity.xi` compara `F(x)=2x` desde 1 y 2 durante 15 iteraciones. La diferencia crece de 1 a 32768. Es una **demostración de amplificación de diferencias iniciales**, no una prueba formal de caos ni un modelo de dinámica bursátil.

`rollback.xi` falla adrede tras intentar escribir memoria; la prueba comprueba que el destino RVPC2 anterior no se sustituya.

## Reproducción

Desde la raíz de REVERSE-PC, con `deps/mundo-x` fijado a `e2778d962af22f6f1a0794058dd4685fc2573966`:

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF
cmake --build build --target reverse_pc --parallel 2
bash tests/x_market_laplace.sh ./build/reverse_pc
```

Para crear un ejecutable REVERSE de este experimento:

```sh
./build/reverse_pc compile experiments/x-market-laplace/closed_world.xi X-MARKET.rxe "X MARKET Laplace Lab"
```

El workflow de GitHub Actions también publica `X-MARKET-LAPLACE.rxe` como artefacto descargable para REVERSE Desktop.

**No produce una APK**: el archivo RXE necesita el runtime/intérprete del proyecto REVERSE. Los valores generados son sintéticos y no deben usarse para invertir.

## Hoja de ruta de la app real

1. Contrato de datos temporales: OHLCV y/o libro de órdenes con fecha de disponibilidad, sin fuga de futuro.
2. Baseline sin ventajas asumidas (persistencia, media móvil, probabilidad histórica), siempre con salida `sin señal` si procede.
3. Modelos causales o probabilísticos en XI con validación walk-forward, pronósticos sellados antes de observar el resultado y medición de calibración.
4. Comparación rigurosa de precisión, latencia, uso de memoria, costes y estrategias frente a referencias convencionales en el mismo hardware.
5. Interfaz X MARKET dentro de REVERSE OS, primero simulación y paper trading; sin operaciones reales automáticas.
6. Explorar aceleración real de Ether/Reduced únicamente sobre cálculos cuya equivalencia y ventaja estén demostradas.

## Límites físicos

Un algoritmo puede ser exacto en un mundo formal cerrado y fallar ante datos que no conoce. REVERSE-PC ejecuta una simulación cuántica en una CPU clásica; sus 1000 qubits estructurados no equivalen a información del futuro. Los modelos de MicroLab tampoco resuelven interacciones atómicas completas. No hay una predicción financiera infalible, un sensor universal ni una IA omnisciente implementados en esta etapa.
