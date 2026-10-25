# REVERSE-PC — Auditoría arquitectónica y entrega para Work (25-10-2026)

> Fuente de verdad: código y pruebas reales de GitHub. Nunca confundir qubits
> **lógicos simulados** con hardware cuántico ni memoria lógica con RAM física.

## Repositorios y revisiones

- Proyecto: https://github.com/guadalupejuan001-code/REVERSE-PC
- Base auditada en main: `7e4678a52040e680ce08a328e4cd57deb8973ba7` (PR #6 fusionada).
- Dependencia **fijada**, no actualizar por accidente:
  `guadalupejuan001-code/mundo-X@e2778d962af22f6f1a0794058dd4685fc2573966`.
- PR #5: https://github.com/guadalupejuan001-code/REVERSE-PC/pull/5
  Batería adicional de auditoría (100 circuitos aleatorios, 96 programas XI,
  180 archivos dañados, direcciones lógicas hasta 4096 dígitos, ASan/UBSan).
  **No fusionada**; examinar diferencias antes de reutilizar.
- PR #6: https://github.com/guadalupejuan001-code/REVERSE-PC/pull/6
  AdaptiveReduced: **fusionada** a main.
- PR #7: https://github.com/guadalupejuan001-code/REVERSE-PC/pull/7
  Caracterización de problemas de arquitectura y este handoff.

## Lo que ya funciona

`src/reverse_pc.cpp`: QuantumRuntime+InfiniteCore+InverseMemory con
programas XI, instantáneas .rvp y transacciones. No ejecuta el
motor Reduced no-Clifford en esa misma sesión.

`src/adaptive_reduced.hpp`: representa estados separables como productos
de bloques, combina bloques cuando una puerta los entrelaza y retrocede
al Reduced canónico si excede `max_dense_block`.

`src/factorization_benchmark.cpp`: nueva ruta C++ `reverse_pc_factorized`,
con `--run`, `--self-test` y `--benchmark`. Aún no es el intérprete XI
principal ni persiste los estados `.rvp` del nuevo backend.

Referencia verificada en GitHub Actions del 25-10-2026,
https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40163369346 :
en el circuito separable H/CNOT/T de 16 qubits, Reduced estimó
17,826,532 bytes de payload lógico y 65,536 componentes; AdaptiveReduced
estimó 3,072 bytes y 32 amplitudes en 16 bloques.
Medianas (5 repeticiones): 43.246715 ms vs 0.0068 ms en ese entorno.
El caso estructurado de 1000 qubits factorizados estimó 194,304 bytes
y 0.101984 ms, **sin baseline Reduced equivalente**. No extrapolar
a todos los programas, y no presentar estimaciones como RSS físico.

## Sospechas / limitaciones fundadas en código

### P0 — Bloques que no se vuelven a separar

`src/adaptive_reduced.hpp`: dentro de `apply()` (uniones entre líneas
106-140), al unir dos bloques por CX/CZ, no existe operación posterior
para detectar si el estado resultante se ha vuelto separable.

Reproductor: `tests/architecture_bottleneck_probe.cpp`, alternando CX
sobre un control en |+> y objetivo |0>, y la misma CX para revertirlo.
El estado físico vuelve a ser producto, pero el contenedor conserva
la unión; tras suficientes repeticiones alcanza el límite del bloque
y reproduce todo el historial en Reduced.

Hipótesis: separación exacta de bloques después de operaciones
que desentrelazan, y compresión de la descomposición local.
Validación obligatoria: vector denso/oráculo independiente para tamaños
pequeños, amplitudes y fases coherentes, reversibilidad, GH Actions.

### P1 — Historial de puertas que crece incluso si la operación es identidad

`AdaptiveReduced::history_` guarda cada puerta antes de la ejecución.
Secuencias equivalentes a identidad, como X/X, acumulan entradas
y aumentan `estimated_payload_bytes()`. No hay eliminación de
circuitos cancelados ni consolidación de segmentos equivalentes.

Hipótesis: cancelaciones algebraicas demostrablemente seguras y/o
puntos de control compactos, sin perder ni precisión ni capacidad de
retroceder a Reduced en cualquier momento.

### P1 — Coste de reejecutar desde el principio para fallback

`AdaptiveReduced::apply()` líneas 106-118 construye Reduced nuevo y
reproduce todas las puertas de `history_` antes de la próxima puerta.
El coste del cambio puede depender más de la longitud del programa
que del estado actual. Medir cola de latencia y RAM, no solo la
mediana del caso separable.

Hipótesis: conversión de bloques a representación del Reduced canónico
sin replay, **únicamente** si existe una conversión exacta validada.
No crear un motor paralelo oculto ni cambiar resultados.

### P1 — Copia de metadatos por cada puerta XI separada

Mundo X, `native/include/mundo_x/infinite_core.hpp`, `apply()`
clona un `State` que incluye un `std::map` de localizaciones; cada
puerta individual puede replicar metadatos. `begin/end` evita copias
repetidas al agruparlas, pero **cambia el contador de revisión**.
No agrupar a ciegas si la revisión es observable o se requieren
transacciones por instrucción. Ver prueba en PR #7.

### P2 — Límites de integración y métricas

- `reverse_pc_factorized` es independiente de la sesión
  `QuantumRuntime`; sin unión de estados, persistencia `.rvp`,
  ni flujo de control universal XI.
- `estimated_payload_bytes()` y `logical_payload_bytes()`
  no equivalen a `peak RSS`; medir peak RSS y consumo en dispositivo
  real si es objetivo.
- `AdaptiveReduced::dense()` materializa `2^n` (máximo 20 qubits)
  **solo para oráculos de verificación**. No llamarlo desde el
  camino crítico para 1000 qubits.
- `refresh_owners()` recorre los bloques tras cada unión,
  `local()` busca linealmente: revisar si dominan el coste tras
  solucionar el problema P0.

## Prueba nueva preparada

```sh
bash scripts/setup-ether.sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON
cmake --build build --parallel 2
ctest --test-dir build --output-on-failure
./build/reverse_pc_architecture_audit
```

Emite JSON y mide 4 casos: `uncompute`, `history`,
`replay` y `runtime_batch`. Los asserts verifican corrección;
los problemas de rendimiento se caracterizan, no se tratan como
propiedades deseables. Véase GH Actions de PR #7 para cifras exactas.

## Siguiente trabajo de ingeniería (orden prioritario)

1. Reproducir todos los hallazgos antes de modificar código y
   separar problemas *confirmados* de hipótesis.
2. Diseñar una partición/refactorización de bloques guiada por estructura
   (p. ej., comprobación de rango de Schmidt uno para particiones candidatas
   pequeñas), conservando fase, norma y observables. No tolerar poda
   aproximada sin un presupuesto de error cuantificado y opt-in.
3. Evitar logs de instrucciones equivalentes y medir el coste de fallback;
   comparar la conversión directa exacta con el replay canónico.
4. Perfil del overhead de copia de metadatos en `QuantumRuntime/InfiniteCore`.
   Establecer contrato sobre atomicidad, revisión, RNG y snapshots ANTES
   de agrupar operaciones o sustituir estructuras.
5. Plan de integración real entre AdaptiveReduced, XI, InverseMemory y
   persistencia; documentar garantías y compatibilidad de formatos.
6. Repetir benchmarks con circuitos separables, parcialmente entrelazados,
   circuitos aleatorios con T y casos adversariales; medir mediana/p95,
   peak RSS, tiempo de cambio de backend, pérdida de precisión y
   costes de restauración. Añadir pruebas que fallen ante regresiones.

## Criterios de aceptación

- Todas las pruebas previas siguen pasando (incluyendo pruebas en
  PR #5 tras conciliarlas sin modificar resultados originales).
- Oráculo complejo independiente en circuitos pequeños (hasta fase global),
  observables, normas, deshacer operaciones y transacciones.
- ASan/UBSan, presupuestos de memoria y rechazo atómico de errores.
- Antes/después comparados para las **mismas tareas y hardware**,
  sin cronometrar de modo asimétrico conversiones/compilación/serialización.
- Sin alterar la dependencia fijada de Mundo X ni `main` sin CI verde.
- No afirmar hardware cuántico, recursos infinitos ni ventaja universal.

## Para Work

Ir a **ChatGPT Work** con el repositorio GitHub accesible y usar el
prompt completo del chat. Leer primero este archivo, PR #7, PR #5, PR #6,
`src/adaptive_reduced.hpp`, `src/reverse_pc.cpp` y el backend canónico
fijado de Mundo X. Abrir PRs pequeños revisables; documentar
resultados/limitaciones y concluir con un balance técnico.
