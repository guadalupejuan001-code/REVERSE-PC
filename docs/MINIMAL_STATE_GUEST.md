# Invitado ARM64 de estados mínimos — primera base ejecutable

## Qué funciona y qué falta

REVERSE incorpora un intérprete propio de un subconjunto entero AArch64 EL0.
Carga un **ELF64 little-endian estático**, ejecuta sus instrucciones dentro del
proceso de REVERSE y conserva el invitado en un checkpoint `RVG1`.
El intérprete no lanza el programa como una aplicación Android externa.

**Todavía no arranca Android ni ejecuta Wild Rift.** Faltan ejecución privilegiada,
MMU, excepciones/interrupciones, SIMD/FP, un sistema operativo invitado, runtime y
servicios Android, gráficos, audio y red del invitado. El shim de esta etapa solo
atiende `write` a stdout/stderr y `exit`/`exit_group` del ABI Linux AArch64.
Los syscalls e instrucciones no implementados producen un error explícito.

No se incorpora QEMU al producto. QEMU se usa únicamente en CI como referencia
independiente para comparar un ELF generado por clang/lld.

## Cómo se respetan los estados mínimos

La memoria física del invitado se consulta mediante:

`byte(dirección) = imagen_inmutable(dirección) XOR delta_XI(dirección)`

- La imagen es el archivo ELF conservado una sola vez. Las regiones BSS y la RAM
  que no pertenece a una imagen tienen fondo cero, sin arreglos proporcionales
  a su tamaño lógico.
- El delta usa el `QuantumRuntime` e `InverseMemory` originales y las extensiones
  ya verificadas de REVERSE. Una escritura se traduce a `mem_store` XI sobre
  esa autoridad; no mantiene otra copia mutable de RAM.
- Escribir el valor original elimina la excepción cuando coincide con el fondo
  del delta. Escribir cero sobre un byte no cero de la imagen sí necesita una
  excepción; no se confunde cero con ausencia de cambio.
- XI puede establecer reglas globales del delta, diferencias y enlaces
  cuánticos explícitos. RXE1 usa el compilador/cargador existente para aplicar
  los mismos programas. La CPU falla si encuentra un byte cuántico no
  determinista, sin medirlo ni inventar un valor clásico.
- Los registros, SP, PC, NZCV y contador son estado arquitectónico necesario.
  No se borra información del invitado para aparentar ahorro.

El intérprete de instrucciones está escrito en C++, como los intérpretes
existentes. **No se afirma que ARM64 se traduzca a instrucciones XI ni que MX,
XASM, QX o MXVM ejecuten automáticamente binarios Android.** En esta etapa XI y
RXE configuran y transforman el estado/delta del invitado; el código ARM64
conserva su ISA. Ether y el estado cuántico se guardan con la misma autoridad.

El objetivo de «estado mínimo» aquí tiene un alcance concreto: reglas, imagen
compartida y diferencias finitas exactas. No demuestra minimalidad matemática
universal ni compresión de datos arbitrarios. Un montón de datos diferentes
consume excepciones y puede ser más caro que páginas densas por su metadato.
La siguiente memoria para un Android real deberá evaluar una representación
adaptativa de páginas, con comparación de coste y sin pérdida de información.

## Límites de esta implementación

| Recurso | Presupuesto |
| --- | --- |
| Espacio lógico configurable en CLI | 64 KiB a 256 TiB; no equivale a RAM residente |
| Configuración inicial Android | 1 GiB lógico y 65.536 excepciones de byte |
| Presupuesto de excepciones configurable en CLI | 1 a 1.048.576 |
| Imagen ELF | 16 MiB, hasta 64 segmentos, sin solapamientos |
| Checkpoint CLI | 48 MiB |
| Transporte/checkpoint del anfitrión Android | 32 MiB |
| Salida por bloque de ejecución | 65.536 bytes entre stdout y stderr |
| Bloque de ejecución CLI | Hasta 1.000.000 instrucciones |
| Bloque desde la interfaz Android | Hasta 10.000 instrucciones |

Se implementan las variantes descritas por el decoder para MOVN/MOVZ/MOVK,
ADD/SUB inmediatos y con registro desplazado, lógica con registro desplazado,
ADR/ADRP, B/BL, B.cond, CBZ/CBNZ, TBZ/TBNZ, BR/BLR/RET, cargas/almacenamientos
enteros comunes, pares LDP/STP, aliases de desplazamiento/extensión, UDIV/SDIV y
MADD/MSUB. No se afirma cobertura completa de esas familias ni del ISA ARM64.

Los flags ELF se usan para validar la entrada, pero todavía no existe protección
de páginas ni un proceso Linux completo. No se cargan ELF dinámicos ni APKs.
No se prepara un stack Linux con argc/argv/auxv. El fixture empieza en `_start`
y no depende de ese estado de arranque.

Un bloque que encuentra un error descarta su estado candidato completo,
incluidos registros, memoria, núcleo y salida. Agotar un presupuesto válido
de instrucciones produce un **yield**, conserva el avance y permite continuar.

## Uso desde el escritorio Android

En **Aplicaciones → Invitado ARM64**:

1. **Crear prueba 6×7** carga un ELF propio de prueba, sin ejecutarlo.
2. **Ejecutar bloque** procesa instrucciones reales y conserva el checkpoint.
3. **Importar ELF** permite seleccionar un ELF estático compatible, de hasta
   16 MiB. Reemplaza la sesión del invitado después de validarlo.
4. **XI sobre el delta de memoria** aplica programas XI al mismo estado. En una
   dirección sin imagen, el delta coincide con el byte observado. Sobre la
   imagen, el byte observado se obtiene con el XOR indicado arriba.
5. **Exportar checkpoint** produce un `RVG1` para el CLI. El exportador actual del
   escritorio tiene un límite adicional de 8 MiB. En Android, la restauración
   automática usa el archivo privado conservado; no hay importador RVG en esta UI.

La edición **REVERSE Guest Preview**, paquete `com.reversepc.guest.workbench`,
permite probar este trabajo antes de integrarlo a la aplicación principal.
Tiene un espacio de datos propio. Su clave de desarrollo es de esa compilación;
no es una actualización firmada para el paquete REVERSE 2.5.1 del usuario.
Los programas y recursos BBY Q/W4u de la preview se recuperan de la publicación
propia 2.5.1 con SHA-256 verificado; no contiene la memoria privada del usuario.

## Uso nativo

```sh
bash scripts/setup-ether.sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target reverse_guest reverse_pc_minimal_guest --parallel 2
./build/reverse_guest demo
./build/reverse_guest demo-init inicial.rvg
./build/reverse_guest run inicial.rvg parcial.rvg 4
./build/reverse_guest run parcial.rvg final.rvg 100
./build/reverse_guest peek final.rvg 32768 8
./build/reverse_guest xi final.rvg cambios.xi cambiado.rvg
./build/reverse_guest rxe cambiado.rvg cambios.rxe continuado.rvg
```

El demo incorporado produce `REVERSE ARM64: 6*7 = 42`, guarda 42 en la dirección
32768 y termina después de 13 instrucciones. El fixture ensamblado por clang
usa un símbolo BSS equivalente; su dirección la decide el linker.

`RVG1` conserva imagen, segmentos reconstruibles desde ELF, estado de CPU y el
par durable core/InverseMemory con revisiones/RNG. El checksum FNV detecta
corrupción accidental, no autentica el archivo. RVPC2 y RXE no cambian de formato.
La imagen y los shards no modificados se comparten en copias candidatas. Guardar
o transportar un checkpoint crea copias temporales acotadas de esos bytes;
esas copias también tienen coste y no se presentan como memoria gratuita.

## Evidencia y alcance

Las pruebas nativas comparan lecturas/escrituras contra un arreglo denso
independiente, comprueban cero sobre imagen no cero, restauración del original,
agotamiento de excepciones, wrap/flags A64, bloque por instrucciones, continuidad
de checkpoints, RXE/XI y rechazo de bytes cuánticos sin medición.

La CI ensambla además `examples/guest-aarch64.S` con clang/lld y compara su salida
y código de terminación contra QEMU AArch64. Las pruebas Android operan la UI,
WebView, JNI, guardado y reinicio en emulador Android 15. La compilación ARM64
no sustituye una prueba física en el teléfono del usuario.

La [medición local](evidence/minimal-guest-host.json) es del anfitrión de desarrollo,
no de Android. Una ejecución de 13 instrucciones y un byte diferente no
representa la memoria ni los FPS de Android o Wild Rift.

## Próximo hito hacia Android

La base siguiente requiere ampliar y verificar el ISA, dispositivos de máquina,
MMU y excepciones hasta arrancar un kernel compatible. Después se podrán añadir
el entorno Android y sus servicios, y finalmente probar el cliente del juego.
Estos componentes no se declaran implementados por esta entrega.

Referencias primarias: [ABI ELF AArch64](https://github.com/ARM-software/abi-aa/blob/main/aaelf64/aaelf64.rst),
[ISA Armv8-A](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/Learn%20the%20Architecture/Armv8-A%20Instruction%20Set%20Architecture.pdf),
[ABI Linux AArch64 del kernel](https://github.com/torvalds/linux/blob/master/arch/arm64/include/uapi/asm/unistd.h).
