# REVERSE-PC

Computadora de software para computación cuántica simulada: espacio lógico por
reglas, componentes compactos y una autoridad de estado compartida por XI,
Ether e Inverse Ether Memory. Ejecuta en CPU clásica.

## Arquitectura integrada

InfiniteCore posee una tabla de direcciones y componentes. Cada componente
contiene exactamente una representación activa: CompactCore para Clifford,
AdaptiveReduced para bloques pequeños o Reduced para estados no-Clifford
anchos. T/T† promueven el estado **actual**, sin reproducir el historial.
Los componentes conectados se combinan mediante transferencias y tensores.

Ether mantiene el marco global y propaga los observables hacia atrás sobre el
mismo estado. InverseMemory conserva reglas, bytes y enlaces explícitos;
un byte no determinista devuelve un handle y no se mide automáticamente.
XI ejecuta todas esas operaciones con rollback conjunto de núcleo, memoria,
RNG, revisiones y salida.

[Contrato completo, precisión y capacidades pendientes](docs/unified-authority.md).

## Compilar y ejecutar

```sh
bash scripts/setup-ether.sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON
cmake --build build --parallel 2
ctest --test-dir build --output-on-failure
./build/reverse_pc init initial.rvp
./build/reverse_pc run examples/integrated-128.xi initial.rvp active.rvp
./build/reverse_pc run examples/integrated-128-continue.xi active.rvp continued.rvp
```

El ejemplo ejecuta entrelazamiento de 128 qubits, T/T†, Ether, memoria enlazada,
observación, guardado y continuación. `qstats` informa los tipos de componente,
coeficientes, amplitudes locales, payload estimado y norma.

RVPC2 guarda el estado actual y conserva también la revisión de memoria.
Se aceptan archivos RVPC1 anteriores. La prueba genera un RVPC1 con el código
y extensiones preservados de main anterior para comprobar la migración real.
En C++, la pareja durable usa `core_snapshot()` y
`memory_persistent_snapshot()`, con restauración conjunta.

## Pruebas y escala

Se conservan las pruebas históricas, la auditoría recuperada de PR #5,
oráculos densos independientes, reversibilidad, fuzzing de snapshots y
ASan/UBSan/LeakSanitizer en CI. La comparación Clifford histórica conserva
salidas, errores, snapshots y RNG idénticos en los 175 casos anteriores.

La ruta integrada se prueba con operaciones reales en 128, 256, 512 y 1000
qubits. La prueba CLI recorre esos tamaños y su modo `--hard` guarda/restaura
un grafo distribuido de 1000 qubits con 16 T independientes y 65536
coeficientes; la T 17 se rechaza sin sobrescribir estado ni archivos.

```sh
./build/reverse_pc_integrated_correctness
python3 tests/integrated_cli.py ./build/reverse_pc output ./build/reverse_pc_previous_cli --hard
```

[Prueba de persistencia local](docs/measurements/integrated-cli-local.json).
La campaña de rendimiento ampliada documenta por separado profundidad,
entrelazamiento, T, presupuestos, tiempo y RSS; no se identifica un registro
separable grande con un circuito genérico altamente entrelazado.

## Límites y dependencia

- Mundo X permanece fijado a `e2778d962af22f6f1a0794058dd4685fc2573966`.
  Las extensiones de compilación verifican SHA-256 de los encabezados; el
  checkout original no se modifica. CI publica el diff utilizado.
- Reduced admite componentes de hasta 1000 qubits; el presupuesto
  predeterminado es de 65536 coeficientes, con rechazo atómico al excederlo.
- Los vectores densos integrados son **locales**, de 8 qubits por defecto y
  hasta 14 configurables. No se crea un vector de 2^1000 amplitudes.
- Norma, amplitudes y observables usan precisión flotante explícita; no se
  podan contribuciones no nulas para aparentar una mejora.
- Payload lógico, memoria residente y dominio de direcciones son métricas
  distintas. Las ventajas dependen del circuito y de su estructura.
- Faltan partición/democión general de componentes Reduced grandes y control
  clásico de flujo XI. No se afirma rendimiento universal ni hardware cuántico.

## Informes anteriores y herramientas conservadas

- [Transferencias desde el estado actual](docs/current-state-transfer.md).
- [Factorización AdaptiveReduced y benchmark independiente](docs/factorization.md).
- [Separación de bloques: resultados y sobrecostes GHZ](docs/dynamic-refactorization.md).
- [Historial compacto y fallback de productos](docs/history-and-transfer.md).
- [Transacciones XI con revisiones conservadas](docs/xi-program-candidates.md).
- [Estado actualizado y siguiente iteración](docs/NEXT_ITERATION_2026-10-25.md).

Los informes anteriores conservan sus condiciones y revisiones originales.
Sus números particulares no se extrapolan a todos los programas.
