# REVERSE-PC

**El espacio lógico como medio de computación, no como una imagen.**

Este proyecto investiga la arquitectura que nació en Mundo X: el espacio
lógico guarda estados, aplica reglas y produce observaciones sin
materializar automáticamente todas sus direcciones.

El primer experimento reutiliza el **QuantumRuntime, InfiniteCore e
Inverse Ether Memory originales de Mundo X**. No hay un segundo núcleo
inventado ni un renderizador.

## Experimento: un estado, dos programas

Arrancamos con dos bytes clásicos (5 y 10) y un tercer byte lógico (5)
vinculado expresamente a los qubits 100...107. Guardamos una instantánea
completa. A partir de ella ejecutamos dos programas XI diferentes:

| | Programa A | Programa B |
| --- | --- | --- |
| Transformación | CNOT local, q100 controla q101 | HAll: regla global de Ether |
| Resultado del byte vinculado | 5 a **7** | **Indeterminado**, devuelve un handle |
| Probabilidad Z=1 en dirección lógica de 64 cifras | **0** | **0.5** |
| Almacenamiento de todo el espacio | No | No |
| Modifica los bytes clásicos iniciales | No | No |

CNOT calcula realmente un XOR controlado entre dos bits representados
en el núcleo. HAll aplica realmente una regla global a la simulación;
su efecto se comprueba en una dirección lejana sin materializarla.

Ambos programas parten del **mismo estado inicial**. Comprobamos además
repetibilidad, instantáneas binarias persistentes, lectura tras
restauración, cancelación de operaciones reversibles y rollback tras
una instrucción inválida.

## Ejecución en Linux

Requisitos: Git, CMake, compilador C++17 y Python 3.

~~~sh
bash scripts/setup-ether.sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON
cmake --build build -j 2
ctest --test-dir build --output-on-failure
./build/reverse_pc demo resultados
./build/reverse_pc run examples/inspect.xi resultados/program-a.rvp resultados/a-inspected.rvp
~~~

La demostración crea resultados/report.json y tres archivos de estado:
initial.rvp, program-a.rvp y program-b.rvp. Con el comando run puedes
cargar cualquier estado compatible, ejecutar un nuevo programa XI y
guardar el resultado; la memoria y el registro cuántico se guardan juntos.

## GitHub Actions

Si solo tienes Android, abre la pestaña **Actions** de este repositorio
y selecciona **REVERSE-PC symbolic computer experiment**. Las pruebas
se ejecutan en el servidor y publican el reporte como artefacto descargable.
No necesitas programar una APK para comprobar el principio computacional.

## Revisión del backend

Dependencia fijada:
guadalupejuan001-code/mundo-X@e2778d962af22f6f1a0794058dd4685fc2573966.

El script de instalación y CMake verifican esa revisión exacta. REVERSE-PC
mantiene su código y arquitectura propios, pero no duplica los archivos
fuente del núcleo Ether.

## Límites reales

Este experimento utiliza **simulación de qubits Clifford por software**
y memoria lógica por reglas. No constituye hardware cuántico, RAM física
infinita, una CPU de propósito general completa, ni demuestra ventaja
en velocidad frente a procesadores actuales.

El backend MIL/Reduced de 1.000 qubits de Mundo X es independiente y
**todavía no participa en REVERSE-PC**. Tampoco hay ejecución condicional
dependiente de datos, instrucciones de aritmética general ni una GPU.
La siguiente etapa es precisamente construirlas y evaluarlas.

Consulta docs/architecture.md para los criterios de investigación.


## Adaptive Reduced: factorización de estados separables

REVERSE-PC incorpora un ejecutable nuevo, `reverse_pc_factorized`, que
conserva por separado los bloques de qubits independientes en lugar de
expandir todas las combinaciones. Detecta algunos casos donde CX/CZ no
entrelazan, fusiona bloques cuando sí lo hacen y vuelve al Reduced canónico
si un bloque supera el límite establecido.

```sh
./build/reverse_pc_factorized --self-test
./build/reverse_pc_factorized --benchmark
./build/reverse_pc_factorized --run 4 examples/factorized-small.qxi
```

La prueba diferencial genera 260 circuitos aleatorios contra un oráculo
vectorial independiente; el benchmark ejecuta la **misma secuencia**
H/CNOT/T en Reduced y en la implementación factorizada (8–16 qubits),
comprueba amplitudes y reporta medianas y bytes estimados.
También prueba un producto de 1.000 qubits sin construir un vector denso.

**Alcance:** la optimización existe en la nueva ruta factorized, no dentro
del ejecutable XI `reverse_pc`; no modifica Mundo X. No elimina el coste
exponencial de circuitos arbitrarios. Detalles: [docs/factorization.md](docs/factorization.md).

## Separación dinámica de bloques

AdaptiveReduced recupera factores tras deshacer entrelazamiento, con una
comprobación de reconstrucción completa sin tolerancias. Incluye recuperación
de dos pares Bell, 1.000 factores lógicos y pruebas que conservan residuos
pequeños. Se recuperaron las suites pendientes del PR #5.

[Implementación, mediciones y costes](docs/dynamic-refactorization.md).
La búsqueda tiene sobrecoste en algunos circuitos entrelazados; los resultados
no son una ventaja universal ni describen hardware cuántico.

## Historial compacto y fallback desde el estado actual

Las cancelaciones exactas no acumulan entradas redundantes. Un producto de
qubits puede transferirse directamente al Reduced canónico con el presupuesto
de componentes conservado; los bloques entrelazados mantienen el replay.
[Resultados, corrección de compatibilidad y límites](docs/history-and-transfer.md).

## Transacciones XI con revisiones conservadas

El candidato privado de un programa reutiliza metadatos de propiedad exclusiva
sin agrupar instrucciones. Se compara con el código fijado original mediante
transcripts idénticos de salidas, errores, snapshots y RNG, hasta 4.096 activos.
[Contrato, mediciones y límites](docs/xi-program-candidates.md).

[Siguiente iteración de integración](docs/NEXT_ITERATION_2026-10-25.md).
