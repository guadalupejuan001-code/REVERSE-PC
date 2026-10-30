# REVERSE-PC — máquina programable XI v1

## Objetivo

Esta versión convierte el **mismo** runtime QuantumRuntime/InfiniteCore/InverseMemory en una máquina programable híbrida: control clásico con registros e instrucciones, y operaciones cuánticas simuladas dentro de una sola transacción. No crea otra autoridad de estado ni reemplaza Ether por una CPU x86. El checkout Mundo X permanece fijado al SHA existente y el único cambio en su intérprete se genera como overlay verificado por hash; la ruta XI histórica no se modifica.

## Cómo funciona

Los programas que empiezan exactamente con `#!reverse-pc-machine-v1` activan un nuevo perfil. Sin este marcador, el intérprete XI original sigue ejecutándose sin cambios, incluso si encuentra una instrucción de máquina desconocida.

1. **Compilación local:** las líneas y etiquetas se preparan, verificando nombres duplicados y saltos a etiquetas inexistentes. Se mantiene el máximo original de 131.072 instrucciones de texto y 16 MiB de fuente.
2. **Candidato privado:** QuantumRuntime copia su autoridad de estado COW una sola vez antes de ejecutar el programa. Todas las operaciones posteriores usan InfiniteCore y InverseMemory de esa misma candidata.
3. **Control clásico:** 16 registros `r0` a `r15`, enteros con signo de 64 bits. El intérprete procesa aritmética, comparaciones, saltos condicionales y ciclos, acotado a 1.000.000 pasos de máquina por ejecución.
4. **Interacción:** las instrucciones tradicionales H/S/X/Y/Z/CX/CZ/T/Tdg, Ether, `expect`, `probz`, `measure`, `mem_*`, `qstats` y lotes `begin/end` se ejecutan contra el estado compartido, bajo sus límites originales.
5. **Commit o rollback:** si algún paso falla (incluyendo desbordamientos, presupuesto de qubits o bucle infinito), se descarta toda la candidata. La salida JSONL no se publica. El CLI tampoco sustituye el destino RVPC2.

El perfil no crea un sistema de archivos ni convierte los registros en memoria permanente. Los registros se inicializan a cero **en cada ejecución**. Los bytes escritos con `store8` y el estado cuántico sí sobreviven al guardado/restauración RVPC2.

## Instrucciones nuevas

| Forma | Efecto |
|---|---|
| `set r0 123`, `mov r1 r0` | Carga entero o copia registro |
| `add/sub/mul/div/mod r0 r1` | Aritmética entera comprobada; admite inmediatos |
| `cmp r0 1000` | Compara enteros con signo, sin sustraer ni desbordar |
| `label nombre` | Define un destino; admite letras ASCII, dígitos después del primero y `_` |
| `jmp nombre` | Salto incondicional |
| `je/jne/jlt/jle/jgt/jge nombre` | Salto según la última comparación |
| `load8 r0 DIRECCION` | Consulta un byte determinista de InverseMemory; **no mide** qubits |
| `store8 DIRECCION r0` | Guarda byte 0–255; un byte cuántico no determinista se rechaza |
| `print r0` | Escribe un registro como una línea JSON |
| `halt` | Termina el programa con éxito |

Los nombres de instrucciones y registros no distinguen mayúsculas/minúsculas. Una instrucción con resultado fuera de `int64` produce error (no envolvimiento silencioso). División por cero y `INT64_MIN / -1` fallan. `load8` de un handle cuántico indeterminado falla en vez de provocar medición implícita.

### Direcciones dinámicas

En las instrucciones originales se puede utilizar `$r0`, `$r1`, etc. como sustitución decimal del registro actual:

```text
set r0 0
h $r0
set r1 127
cx $r0 $r1
expect Z:$r0 Z:$r1
```

El prefijo `$` también funciona para direcciones y valores de `mem_store`, `mem_bind`, `seed` y otros argumentos XI aceptados previamente. **No** convierte operadores arbitrarios en expresiones: únicamente inserta el número decimal del registro. Una dirección negativa es rechazada por la validación existente.

### Ejemplo de programa que mezcla control y cálculo cuántico

El archivo `examples/machine-ghz-128.xi` utiliza un bucle con direcciones calculadas para encadenar 127 puertas CX sobre un registro de 128 qubits, ejecuta T/T†, comprueba observables y calcula `gcd(1071,462)=21` mediante Euclides. Escribe 21 en InverseMemory, con un único commit transaccional.

```sh
bash scripts/setup-ether.sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON
cmake --build build --parallel 2
ctest --test-dir build --output-on-failure
./build/reverse_pc init blank.rvp
./build/reverse_pc run examples/machine-ghz-128.xi blank.rvp active.rvp
./build/reverse_pc run examples/machine-continue.xi active.rvp continued.rvp
```

La segunda ejecución empieza con registros limpios, carga el byte persistente 21, escribe 22 en otra dirección y consulta el mismo registro de 128 qubits guardado antes. El archivo de estado sigue siendo RVPC2; no se introduce una nueva versión.

## Pruebas y límites

- `reverse_pc_xi_machine`: algoritmo de Euclides y contador de 1.000 iteraciones, aritmética negativa, enteros extremos, 128 qubits reales con T/T†, direcciones lógicas extensas, persistencia, rechazo de lectura cuántica no determinista, límites de pasos y errores inyectados sin mutar Core/Memory/RNG.
- `reverse_pc_xi_machine_cli`: dos programas distintos sobre un archivo RVPC2, restauración y continuación, prueba de ciclo infinito/orden inválida sin sobrescribir archivos.
- CI ejecuta esas suites junto a las pruebas existentes Release, ASan/UBSan, el contrato XI histórico de 175 casos y la campaña grande 128/256/512/1000 de circuitos.
- Las puertas y modelos no-Clifford siguen sujetos a los presupuestos previos (1.000 qubits por componente Reduced, coeficientes, memoria y tamaños de archivos). Un programa largo **no** demuestra rendimiento ilimitado.
- Se preservan deliberadamente los opcodes originales y el formato. No existe todavía CPU física, sistema operativo, entrada/salida de dispositivos completa, máquina x86 general ni planificación de procesos.

## Siguiente etapa

Evaluar una ISA compacta en formato binario, memoria de registros persistente opcional, operaciones clásicas sobre palabras (64 bits) dentro de Ether, acceso a archivos/dispositivos con capacidades explícitas y una comparación de rendimiento con intérpretes clásicos equivalentes. Diseñar el hardware únicamente después de encontrar operaciones cuyo ahorro frente a CPU convencional justifique FPGA o acelerador.

## Extensión de observaciones 3D (Velocity 0.2)

La ejecución de fuente admite además estas primitivas genéricas. El compilador
RXE todavía no las codifica. No contienen reglas de conducción ni de carreras.

| Instrucción | Efecto |
| --- | --- |
| `load16 rD address`, `load32 rD address` | Lee u16/u32 little-endian determinista de InverseMemory. |
| `store16 address value`, `store32 address value` | Escribe u16/u32 little-endian en la misma transacción. |
| `localget rD index`, `localset index value` | Lee/escribe una de 4096 celdas i64 efímeras; empiezan en cero y no se serializan. |
| `meshbegin width height revision background` | Abre una observación con z-buffer y materiales temporales. |
| `meshvertex id x y z` | Define un vértice temporal. |
| `meshread rX rY rZ id` | Lee las tres coordenadas a destinos distintos. |
| `meshtri x0 y0 z0 x1 y1 z1 x2 y2 z2 material` | Rasteriza un triángulo ya proyectado, con profundidad positiva. |
| `meshtri3 x0 y0 z0 x1 y1 z1 x2 y2 z2 material focal centerX centerY near` | Recorta en espacio de cámara y proyecta/rasteriza. |
| `meshface id0 id1 id2 material focal centerX centerY near` | Equivalente indexado de `meshtri3`. |
| `meshend` | Publica la visibilidad como regiones XFS1; ninguna salida parcial se conserva en un error. |

Los accesos bulk aceptan direcciones decimales literales o `$rN`; se valida que
el último byte quepa en UINT64 antes de escribir. Los accesos byte anteriores
conservan su espacio lógico arbitrario. Los índices locales y de vértice
aceptan literal o registro, en 0..4095. Un vértice se inicializa expresamente
en cada `meshbegin`; leer una entrada no inicializada falla.

El viewport mesh se limita a 640×360, 4096 triángulos y ocho millones de pruebas
de píxel por observación. Los vértices de cámara quedan en ±1.000.000 y los
materiales en 0..255. La salida resuelta contiene fondo por fila y regiones
visibles disjuntas. Cada región contiene al menos un píxel: el máximo natural
es una región por píxel horizontal, más el fondo de la fila. Así, incluso una
fila de 640 materiales alternados se puede transmitir sin rechazar la imagen.
El presentador de Velocity reconoce esa semántica en la revisión 2 y mantiene
las reglas anteriores de profundidad para imágenes de revisión 1.

Las pruebas están en `tests/xi_machine_test.cpp` y `tests/xi_mesh_raster.cpp`.
