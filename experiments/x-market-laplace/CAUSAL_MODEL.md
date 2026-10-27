# LAPLACE X v0.2 · Identificación causal de leyes (XI)

**Estado:** modelo experimental real, escrito en XI, sobre el QuantumRuntime de REVERSE-PC. No predice acontecimientos imposibles de observar y todavía no está conectado a una fuente bursátil externa ni al panel Android X MARKET.

## Hipótesis

Una función de transición puede describir relaciones que permanecen estables durante algún intervalo. La ecuación de investigación general es

```text
x(t+1) = F_theta(x(t), u(t)) + epsilon(t)
```

El demonio de Laplace presupone conocer el estado físico completo y sus leyes, no proporciona una fórmula numérica universal para acciones. La ecuación de Laplace para campos armónicos es otro objeto matemático y no predice el mercado por sí sola.

**Problema de ingeniería que resolvemos ahora:** inferir de una serie de observaciones cuál de varias leyes locales describe mejor el comportamiento pasado y emitir, antes de conocer el siguiente dato, una predicción que pueda ser auditada.

## Tres leyes candidatas implementadas en XI

Para precios enteros en céntimos `p[t]`:

- Experto 0 — persistencia: `P0(t+1) = p[t]`.
- Experto 1 — primera diferencia constante: `P1(t+1) = 2*p[t] - p[t-1]`.
- Experto 2 — segunda diferencia constante: `P2(t+1) = 3*p[t] - 3*p[t-1] + p[t-2]`.

En cada momento conocido `t`, XI calcula los errores absolutos de esos tres expertos para **como máximo ocho predicciones retrospectivas** `k` realizadas sobre `p[k-1]`, `p[k-2]`, `p[k-3]`. Elige el experto con menor suma de errores. Los empates favorecen la persistencia. No se ajustan parámetros después de mirar los resultados de la evaluación. El precio predicho queda limitado al rango de entrada.

La «señal» `r11` es una condición diagnóstica: pérdida absoluta promedio reciente de como máximo 40 céntimos. No es una probabilidad calibrada, una autorización de compra o una medida universal de confianza. Puede seleccionar equivocadamente una estrategia sobre un segmento corto.

## Memoria propia: contrato XI / Inverse Ether Memory

El programa `forecast-one.xi` lee el número **N de observaciones ya disponibles** desde la dirección 4096 (`0..220`). Las observaciones tienen índices `0..N-1` y se codifican en cuatro bytes por precio, little-endian, en direcciones `10000+4*k` hasta `10003+4*k`. El contrato de transporte acepta precios positivos de hasta 2.000.000.000 céntimos. Se usan valores int64 del perfil XI para evitar overflow durante las transformaciones.

Se requieren por lo menos 7 observaciones. El pronóstico se genera para el índice `N`, que todavía no ha sido escrito.

La memoria y el dueño de estado son los de QuantumRuntime/InverseMemory ya existentes; no se desarrolla otra memoria ni se introduce un motor externo de IA. El programa no ejecuta puertas H, T o CNOT porque no existe evidencia de ventaja cuántica para esta predicción en particular. El runtime sigue corriendo sobre CPU clásica.

## Prueba causal ordenada

El programa auxiliar `tests/x_market_predictor.js` es solamente un adaptador de datos CSV, controlador de experimentos y auditor. No contiene reglas del predictor ni calcula pronósticos alternativos. Escribe **una sola observación** por iteración mediante otro programa XI `store8` y crea un RVPC2 confirmado.

1. En el momento `t` introduce solo `p[t]` y actualiza el contador N.
2. Ejecuta `forecast-one.xi` sobre una instantánea RVPC2 y registra la salida antes de introducir `p[t+1]`.
3. Comprueba que la lectura no cambió el snapshot y contrasta que el RXE compilado es equivalente al XI textual.
4. Registra el SHA-256 del programa, el estado observado y la predicción emitida. Es un **checksum auditable**, no una firma de hora de un tercero.
5. Solo después revela `p[t+1]`, calcula error real, error de persistencia y porcentaje de pronósticos bajo el filtro diagnóstico.
6. Compara series con prefijo idéntico y futuro distinto: los pronósticos anteriores a la divergencia deben ser idénticos.

El lector JS sí dispone del CSV completo para validar la secuencia, pero el intérprete XI recibe exclusivamente el prefijo disponible en cada instante. **Esta garantía de aislamiento depende del contrato del controlador de pruebas y de su código auditable, no de un oráculo ni de un sensor físico.**

## Ensayos de laboratorio

CI ejecuta varios mundos **sintéticos** con 66 observaciones cada uno. Solo puntúa las 59 predicciones cuyo resultado ya se reveló, no la última pendiente:

| Serie | Resultado esperado cualitativo |
| --- | --- |
| Incrementos con aceleración constante | Experto de segunda diferencia identifica la regla; exactitud después del mínimo historial |
| Misma regla con choque externo desconocido | Primera predicción afectada falla y expone incertidumbre; adaptarse requiere nuevas observaciones |
| Variaciones generadas por ruido no revelado | Error no nulo y posible rendimiento inferior a persistencia |
| Escala de precios +80.000 céntimos | Debe conservarse equivalencia tras ampliación a 4 bytes |
| Series con el mismo pasado y futuros distintos | Los pronósticos previos a la divergencia deben permanecer iguales |
| Ejecución desde RXE y XI textual | Misma salida y snapshot RVPC2 sin mutaciones |

Los resultados se guardan como JSON de CI, no se promocionan como cifras de mercado real. **Las pruebas no demuestran que la bolsa obedezca alguna de estas tres leyes.**

## Uso con datos históricos reales propios

Preparar un CSV de un solo activo, cierres de una sola definición de precio (ej. ajustado o no ajustado, sin mezclarlos), fechas ISO crecientes y un cierre entero en céntimos. El ejemplo de formato es:

```csv
date,close_cents
2026-01-05,68432
2026-01-06,68490
2026-01-07,68518
...
```

El archivo real debe contener 8 a 220 registros ordenados; la muestra de tres líneas anterior es **solo ilustrativa**, no son cotizaciones verificadas. No introducir fechas futuras como observaciones actuales. Los feriados y fines de semana pueden estar ausentes, siempre que las fechas sean crecientes. Una fecha no representa una hora de disponibilidad en mercados intradía.

Reproducción desde la raíz del repositorio, con dependencias fijadas de Mundo X:

```sh
bash scripts/setup-ether.sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF
cmake --build build --target reverse_pc --parallel 2
node tests/x_market_predictor.js ./build/reverse_pc --ci
node tests/x_market_predictor.js ./build/reverse_pc mi-historial.csv reporte-laplace-x.json
```

El último comando guarda la secuencia cronológica de cada predicción ya emitida, la evaluación y las métricas. Solo trabaja con archivos locales; no consulta API bursátil, no opera dinero ni instala un sistema financiero.

## Para pasar de investigación a un producto útil

Antes de permitir predicciones financieras operativas, añadir: fuente de datos con procedencia, timestamps de disponibilidad, ajustes de splits/dividendos, baselines fuertes, evaluación con período independiente nunca usado al seleccionar el modelo, estimación de riesgo calibrada, simulación de costes/slippage, pruebas de cambio de régimen, límites de exposición y opción de abstenerse. No confundir acierto sobre precios con rentabilidad neta.

La siguiente ampliación científica debería identificar estados multivariados `x(t)`, entradas externas `u(t)`, relaciones aprendibles más generales, y analizar cuándo la incertidumbre crecerá más deprisa que nuestra capacidad de observación. Ese trabajo necesita evidencia independiente.
