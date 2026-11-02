# C41 — instrucción real que detuvo C40 y C40R3

La recuperación C40R del run 41375758933 validó y publicó R1 (18.643.448.839 instrucciones) y R2 (18.893.448.839). R3 se detuvo exactamente en 19.066.342.718, igual que C40: `Unsupported AArch64 instruction 0x5ee1b801 at 0x7c9aaeb1cc`. El diario verificó SHA-256, no hubo watchdog, señal, pánico ni reinicio; el intérprete devolvió 2 por `architectural_stop`.

El opcode es **FCVTZS D1,D0**, conversión de punto flotante a entero con truncamiento hacia cero y destino SIMD. Existía la conversión a registro general mediante `ArmFloat::to_int`; faltaba la variante escalar AdvSIMD. El decodificador ahora reconoce FCVTZS/FCVTZU S/D, reutiliza la aritmética SoftFloat ya fijada, verifica acceso FP y borra la parte superior del destino. No cambia el reloj, la memoria, XI/Ether, el formato RVG, el disco ni la seguridad Android.

Referencia primaria: Arm A64 ISA DDI 0602, marzo de 2025, sección FCVTZS (vector, integer), variante Scalar single-precision and double-precision, páginas 1330–1331: https://documentation-service.arm.com/static/67e40f3398aa3c3b6eea6a85.

La prueba nativa reproduce primero el rechazo del opcode exacto en el código anterior. Tras la corrección verifica 4.533 casos, todas las parejas de registros, alias, anchos de 32/64 bits, variantes con/sin signo, ceros, fracciones, infinitos, NaN, saturación, FPSR acumulativo, independencia del redondeo FPCR, subnormales, restauración y trampas de acceso FP. Los resultados se comprueban con constantes especificadas independientemente, sin usar la función de conversión como oráculo.

La nueva ejecución parte **solo del R2 limpio**: SHA-256 `56821dfcec37af1031221247d8dd42f894e176c67fbf8ea3e87b3e14894d36a8`, contrato de cuatro archivos, productor `d8e5c796a6a40e716ef22f24f90185252f55558b`. No se promueve ni utiliza el R3 incompleto. El éxito exige superar el contador del fallo original, autenticar la salida y observar nuevamente las propiedades odsign y SELinux. Los candidatos fallidos se conservan aparte como observación, nunca como fuentes autorizadas.

El arranque completo de Zygote y Android requiere evidencia posterior; una prueba nativa o un proceso anfitrión aprobado no lo demuestra.
