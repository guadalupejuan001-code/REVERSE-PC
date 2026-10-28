# Compatibilidad ARM64 en el ejecutor existente de REVERSE

## Alcance real

La función se abre en **XI → ARM64**, dentro del mismo escritorio REVERSE.
No tiene un programa Guest independiente ni otra implementación de motor cuántico.
Los accesos a memoria usan `QuantumRuntime`/`InfiniteCore`/`InverseMemory` originales.
El módulo conserva una sesión de máquina propia, como los experimentos aislados:
no mezcla direcciones, puertas ni checkpoints con el trabajo del escritorio o BBY Q.

El decodificador ARM64 y el control clásico del procesador están escritos en C++.
Es emulación de instrucciones y de algunos dispositivos; **no es una traducción
ARM64→XI, una ejecución de Android en qubits, ni un acelerador cuántico del juego**.
XI/RXE transforman la autoridad de memoria que utiliza el módulo. MX, XASM, QX y
MXVM no adquieren compatibilidad automática con aplicaciones Android.

**Android completo y Wild Rift todavía no arrancan.** Esta entrega ejecuta
programas estáticos sencillos y un testigo de sistema propio. El cargador acepta
el protocolo de una Linux `Image` acotada, pero eso no demuestra un arranque Linux.
La CI compila Linux 6.1 y registra dónde se detiene el intérprete propio.

## Una base, reglas y diferencias exactas

`byte físico = imagen inmutable XOR delta XI/Ether`

- ELF o contenedor `RVI1` de Image/DTB/initrd se conserva como respaldo inmutable.
- RAM no modificada/BSS se describe con fondo cero. No se reserva un arreglo
  proporcional al espacio lógico declarado.
- Un store ARM64 usa una transacción de bytes tipados del mismo `QuantumRuntime`.
  Un bloque mantiene un candidato común para núcleo y memoria; evita volver a
  analizar texto XI y copiar metadatos por cada palabra. Las operaciones siguen
  llamando al `InverseMemory::store` original, con sus revisiones y enlaces cuánticos.
  Restaurar el byte de respaldo elimina la diferencia redundante. Escribir cero
  sobre una imagen no cero sí necesita una diferencia.
- XI/RXE pueden alterar ese delta y el núcleo cuántico original. Leer o escribir
  un byte cuántico no determinista falla sin medirlo ni borrar su estado.
- Registros, tablas escritas por el programa, bancos SP, excepciones, temporizador,
  control del GIC y cola serial son información necesaria y se conservan.
- Las copias candidatas comparten respaldo/shards sin cambios. Serializar un
  checkpoint sí crea temporales acotados; también tienen coste físico.

«Estados mínimos» tiene este alcance concreto. No se afirma una representación
matemáticamente mínima de todos los programas ni compresión universal. Muchas
escrituras distintas pueden hacer costoso el mapa de excepciones por byte. Una
memoria adaptativa por páginas sigue pendiente; ahora hay perfiles del arranque
parcial Linux y comparaciones de transacciones de bytes. Estos límites deben resolverse antes de pretender ejecutar un Android con datos de juego.

Una prueba prepara **4.096 qubits independientes** con XI y luego ejecuta el testigo
ARM64 sobre la misma autoridad. El snapshot/revisión del núcleo cuántico permanece
idéntico. Esto preserva la capacidad existente, sin afirmar simulación arbitraria
entre todos esos qubits ni mejora de FPS.

## Capacidades implementadas

| Parte | Alcance |
| --- | --- |
| Aplicación | ELF64 little-endian AArch64 ET_EXEC estático; shim `write`/`exit`/`exit_group` |
| Sistema | Un núcleo AArch64 EL1/EL0, bancos SP, DAIF/NZCV, MRS/MSR seleccionados, SVC/ERET |
| Excepciones | Síncronas/IRQ, VBAR/ELR/SPSR/ESR/FAR; permisos y fallos de traducción |
| MMU | Stage 1, TTBR0/TTBR1, 25–48 bits VA, granulo 4 KiB, bloques L1/L2 y páginas L3; AF/AP/APTable/PXN/UXN y prohibición de ejecutar en EL1 regiones escribibles por EL0 |
| Consola | Subconjunto PL011 con entrada/salida y cola acotada |
| Interrupciones | Subconjunto GICv2 de un grupo y un núcleo, 64 IDs; temporizadores físico/virtual |
| Tiempo | Un tick virtual por transición de ejecución; WFI puede avanzar hasta el siguiente plazo; no es reloj de pared |
| Arranque Image | Image AArch64 little-endian de 4 KiB, DTB v17 generado y opcional initrd |
| PSCI | VERSION, FEATURES seleccionadas, SYSTEM_OFF; otras llamadas devuelven NOT_SUPPORTED |
| FP/SIMD | Subconjunto escalar FP32/FP64 IEEE 754, conversiones FP16, registros V0–V31, memoria vectorial y operaciones NEON seleccionadas; FPCR/FPSR y trap FPEN |
| Checkpoint | RVG1/RVG2 conservan sus bytes cuando FP está en cero; RVG3 añade únicamente el estado FP/SIMD no nulo |

El subconjunto entero incluye las variantes implementadas en el decoder para
MOVN/Z/K, ADD/SUB inmediatos/desplazados/extendidos, ADC/SBC, lógica inmediata y con
registro, bitfields, EXTR, desplazamientos variables, CSEL, CCMP, RBIT/REV/CLZ/CLS, divisiones,
MADD/MSUB, ramas, cargas/stores enteros comunes y pares. Los exclusivos simples
LDXR/STXR se habilitan en modo sistema; LDAR/STLR usan memoria coherente síncrona.
El monitor exclusivo se invalida con escrituras/operaciones XI/RXE/excepciones y
se conserva en RVG2. No hay cobertura completa del ISA.

La aritmética FP usa Berkeley SoftFloat 3e fijado por hash, con configuración
ARM-VFPv2. El núcleo cuántico y la autoridad de memoria se mantienen. El fondo
de los 32 registros vectoriales es cero; RVG3 usa una máscara y 16 bytes por
registro no nulo: entre 20 y 532 bytes adicionales, más el campo de longitud.
FPCR/FPSR también se conservan. No se afirma cobertura completa de NEON: faltan,
entre otras, operaciones saturadas, reducciones y desplazamientos seleccionados,
criptografía y extensiones posteriores de Arm. No se implementan traps de
excepciones aritméticas FP; los bits de habilitación no se anuncian. AHP no se
admite. Los casos no soportados fallan de forma explícita.

No se implementan EL2/EL3, virtualización KVM, multicore, enlazado ELF
dinámico, arranque Android, Binder/ART/Bionic, almacenamiento/virtio, GPU de
invitado, audio o red de invitado. Registros/instrucciones/dispositivos no soportados
producen errores explícitos. Mantenimiento de caché seleccionado actúa sobre una
máquina coherente sin caché/TLB arquitectónico modelado; no se simula su latencia.

Un error de implementación no soportada descarta el bloque candidato completo.
Un fallo arquitectónico implementado entra en el vector del invitado y permite
que su manejador continúe. Un bloque con presupuesto agotado conserva el avance.

## Probar desde REVERSE

1. Abre **XI → ARM64**.
2. **Comprobar modo de sistema** prepara el testigo propio; no es Android/Linux.
3. **Ejecutar bloque** debe producir `REVERSE: EL1 MMU IRQ EL0 SVC FAULT OK`.
4. **Comprobar FP/SIMD**, seguido de **Ejecutar bloque**, verifica suma FP32,
   raíz FP64 y registros/memoria NEON; imprime `REVERSE: FP32 FP64 SIMD OK`.
   También puede ejecutarse con checkpoints entre bloques.
5. Los botones permiten importar ELF de aplicación, ELF de sistema o Linux Image.
   La imagen debe encajar en los límites y usar instrucciones/dispositivos soportados.
6. En modo sistema, **Consola → Enviar** agrega entrada a PL011. Ejecuta otro bloque
   para que el programa la procese. Cerrar/reabrir conserva la sesión de máquina.
7. **XI sobre el delta de memoria** modifica esa misma memoria. Una dirección sin
   respaldo tiene byte=delta; una dirección dentro de imagen combina por XOR.

El testigo monta tablas reales, activa la MMU, programa un timer/GIC, entra por
IRQ y retorna, pasa a EL0, ejecuta SVC y provoca una escritura denegada. Solo
imprime éxito después de verificar esos efectos. QEMU se usa únicamente en CI
para contrastar el ELF ensamblado independientemente; no se incluye en REVERSE.

El flavor Android de integración es el **REVERSE existente**, paquete
`com.reversepc.control.workbench`, versión de código 253. La compilación CI usa una
clave desechable de pruebas: no es una actualización con firma verificada para
el APK ya instalado por el usuario. No se pide desinstalar ni perder sus datos.

## Límites

| Recurso | Presupuesto |
| --- | --- |
| RAM lógica EL0 | 64 KiB–256 TiB; no representa RAM física disponible |
| RAM lógica de sistema | 64 MiB hasta rango físico de 48 bits; UI usa 128 MiB |
| RAM física de sistema | Comienza en `0x40000000` |
| Imagen total | 16 MiB; ELF hasta 64 PT_LOAD sin solapamientos |
| Excepciones de byte | 1–1.048.576; Android 65.536 |
| Snapshot CLI / transporte Android | 48 MiB / 32 MiB; exportador UI adicional de 8 MiB |
| Bloque CLI / Android | 1.000.000 / 10.000 transiciones máximo |
| Salida por bloque / entrada serial | 65.536 / 4.096 bytes |

El checksum FNV detecta corrupción accidental y no autentica snapshots. RVPC2 y
RXE mantienen sus formatos y rutas actuales. La UI no tiene importación RVG;
la restauración automática se realiza desde su archivo privado conservado.

## CLI y validación

```sh
bash scripts/setup-ether.sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target reverse_guest reverse_pc_minimal_guest reverse_pc_minimal_system reverse_pc_minimal_fp reverse_pc_minimal_bytes --parallel 2
build/reverse_pc_minimal_guest
build/reverse_pc_minimal_system
build/reverse_pc_minimal_fp
build/reverse_pc_minimal_bytes
build/reverse_guest fp-demo
build/reverse_guest system-demo-init inicial.rvg
build/reverse_guest run inicial.rvg parcial.rvg 30
build/reverse_guest run parcial.rvg final.rvg 1000
build/reverse_guest peek final.rvg 1073778696 8
build/reverse_guest system-init propio.elf propio.rvg
build/reverse_guest linux-init Image linux.rvg initrd.cpio
build/reverse_guest device-tree reverse.dtb
build/reverse_guest input linux.rvg entrada.txt con-entrada.rvg
build/reverse_guest xi final.rvg cambios.xi cambiado.rvg
build/reverse_guest rxe cambiado.rvg cambios.rxe continuado.rvg
```

El testigo de sistema conserva 128 MiB lógicos con una imagen de 4.391 bytes y
9 diferencias de byte al terminar. Es un test pequeño, no la huella de Android
ni de Wild Rift. Las pruebas originales aportan 8.234 aserciones; las nuevas
comprueban 54 condiciones de sistema/tabla/permisos/estado cuántico, además de
CLI, UBSan y oráculos clang/lld/QEMU. La integración Android ejercita WebView/JNI,
el ejecutor original y reinicio en emulador Android 15. No equivale a una prueba
física en el teléfono.

La prueba `examples/guest-fp-simd.S` compara resultados binarios, FPSR, NaN,
ceros con signo, redondeos, FZ/DN, conversiones y vectores con clang/lld/QEMU.
También exige igualdad completa entre ejecución continua y checkpoints cada
137 instrucciones. Las pruebas nativas comprueban aislamiento de redondeos entre
hilos, estado disperso, compatibilidad RVG1/RVG2 y rollback.

La transacción de bytes tiene 213 comprobaciones, incluyendo escrituras
cuánticas deterministas, lectura del candidato actual, rollback de ambos estados,
límites y 1.700 stores aleatorios contrastados con XI. Un benchmark separado
mide 12.000 stores; no predice FPS. Una variante de prueba traduce cada byte por
separado y debe producir exactamente el mismo checkpoint Linux de 500.000
instrucciones que la ruta que reutiliza el mapeo dentro de un acceso. No existe
un TLB persistente: cada acceso observa las tablas actuales. Se prueban páginas
no adyacentes, permisos y fallos sin stores parciales.

Referencias primarias: [arranque Linux AArch64](https://docs.kernel.org/arch/arm64/booting.html),
[Linux 6.1 fijado](https://github.com/torvalds/linux/tree/830b3c68c1fb1e9176028d02ef86f3cf76aa2476),
[ABI ELF AArch64](https://github.com/ARM-software/abi-aa/blob/main/aaelf64/aaelf64.rst),
[arquitectura de memoria Arm](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/Learn%20the%20Architecture/LearnTheArchitecture-MemoryManagement-101811_0100_00_en.pdf).
