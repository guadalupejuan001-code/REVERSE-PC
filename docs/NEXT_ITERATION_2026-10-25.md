# Integración: estado actualizado y siguientes límites

## Integración implementada

La ruta XI ya usa los componentes CompactCore/AdaptiveReduced/Reduced de una
sola tabla InfiniteCore, con T/T† físicas bajo Ether, memoria enlazada,
transacciones y RVPC2 con revisiones/RNG. Véase el
[contrato vigente](unified-authority.md). Las propuestas de la sección de
historial siguiente describen el punto de partida anterior y ya no significan
que la ruta XI siga separada.

La siguiente campaña compara 128/256/512/1000 qubits, profundidad, crecimiento
adversarial, memoria residente y costes de observación. Siguen pendientes la
factorización/democión general de Reduced grande y el control de flujo XI.

## Historial anterior a la integración

## Estado entregado

- PR #8: separación dinámica, recuperación de factores, auditoría PR #5
  conciliada y comparaciones con RSS real. Fusión tras CI verde.
- PR #9: cancelaciones exactas, transferencia de productos sin replay,
  liberación de capacidades y límite de componentes importado. Fusión tras CI.
- Candidatos XI: eliminación de copias redundantes dentro de una transacción
  privada, conservando revisiones y contrato original; ver su PR y CI.
- El checkout Mundo X conserva e2778d962af22f6f1a0794058dd4685fc2573966.
  El código compilado incluye las extensiones locales explícitas de
  `prepare-ether-compat.py`; CI publica el diff completo.

Los ejecutables `reverse_pc` y `reverse_pc_factorized` **siguen siendo dos
rutas**, no una sesión unificada. No hay conversión implícita entre sus estados.

## Lo que revela el código fijado

| Límite real | Consecuencia para la integración |
| --- | --- |
| InfiniteCore::Component guarda un CompactCore y sus ids | El lugar natural de promoción es el componente conectado, no otra copia global del registro |
| InverseMemory lee y escribe mediante un InfiniteCore concreto | Hace falta un contrato de observación/puertas, manteniendo las asociaciones explícitas de ocho bits |
| Reduced admite from_product, phase y controlled_phase, pero no importar bloques arbitrarios ni snapshots completos | Falta una transferencia general con base estabilizadora, coeficientes, fase, norma y presupuesto |
| InfiniteCore conjuga puertas físicas mediante el marco Ether Clifford | Una T promovida debe actuar sobre el Pauli conjugado, no aplicarse a una dirección interna ignorando el marco |
| dense_from_reduced reconstruye su base mediante base_circuit_ | Importar solo base_.packed_state no basta para mantener el oráculo denso y la persistencia |
| MXIM1 guarda fondo, overrides y bindings, pero no la revisión de memoria | La restauración actual recupera esos datos y reinicia ese contador; definir una versión nueva antes de prometer que persiste |
| XI actual es una secuencia de órdenes sin saltos dependientes de bytes | Todavía falta control de flujo; no afirmar programación universal demostrada |

## Diseño propuesto y siguiente PR pequeño

1. Definir una interfaz de registro para gates, Pauli, determinismo de bits,
   límites y estado persistente. InverseMemory debe consultar esa interfaz
   sin medir automáticamente ni decidir que una probabilidad casi 0/1 es clásica.
2. Mantener una sola tabla de direcciones/componentes en InfiniteCore, con
   una variante de payload: CompactCore o AdaptiveReduced/Reduced. El fondo y
   marco Ether siguen siendo simbólicos. Un componente tiene **un** dueño de
   amplitudes; no se sincronizan dos registros divergentes.
3. Primer PR de integración: transferencia validada de **un componente
   estabilizador finito** al Reduced canónico, sin replay del programa y sin
   construir 2^n global. Conservar un camino original de comparación.
   Resolver primero la reconstrucción densa de su base para los oráculos pequeños.
4. Ampliar después a productos de bloques entrelazados, con presupuesto de
   componentes y picos temporales explícitos. Si una conversión no cabe,
   conservar el estado anterior; nunca podar amplitudes para hacerla caber.
5. Introducir la T física como combinación I/Pauli en el marco Ether. Solo
   después conectar `t` y `tdg` a XI y verificar equivalencia del marco antes y
   después de HAll/CZNeighbors. No interpretar T sobre el marco equivocado.
6. Persistencia versionada del estado activo, índices, coeficientes, norma,
   fase necesaria, RNG y revisiones de núcleo/memoria. Mantener lectura RVPC1;
   comprobar byte a byte y con circuitos continuados después de restaurar.
7. Añadir saltos y aritmética sobre bytes deterministas con límite de pasos y
   rollback del programa completo; un handle cuántico no es un bool clásico.

## Criterios de aceptación

- Igualdad de observables, fase coherente y norma contra oráculo independiente
  de 2–8 qubits; circuitos aleatorios Clifford+T, inversos y restauraciones.
- Ejemplos de memoria explícitamente vinculada antes/después de promoción:
  lectura determinista, handle en superposición y store rechazado sin medición.
- Copias de sesiones y fallo inyectado durante promoción no cambian la fuente,
  RNG, revisiones ni asociaciones de memoria.
- Marco Ether con cono finito validado y límites explícitos; rechazar acciones
  no soportadas en vez de usar un estado paralelo como respuesta.
- Mismos programas, compilador, calentamiento, semillas, mediana/p95, RSS y
  capacidades. Mantener el caso negativo de churn GHZ que hace más trabajo al
  separar/fusionar; explorar caché de procedencia o separación diferida antes
  de aumentar el ancho automático.
- Todas las suites Release y de corrección ASan/UBSan, incluidos los casos
  originales recuperados de PR #5. Ninguna fusión con CI pendiente o fallida.

## Reproducción actual

```sh
bash scripts/setup-ether.sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON
cmake --build build --parallel 2
ctest --test-dir build --output-on-failure
python3 tests/compare_runtime.py build/reverse_pc_runtime_reference build/reverse_pc_runtime_contract
python3 scripts/compare-runtime-resources.py build/reverse_pc_runtime_reference build/reverse_pc_runtime_contract
```

Los límites de representación y los contadores anteriores son propiedades
reales del código inspeccionado. Esta hoja de ruta no declara que la sesión
unificada o el control de flujo estén implementados.
