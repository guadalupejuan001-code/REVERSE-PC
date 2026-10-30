# C09 — reparación exacta de la instrucción detenida en C08

C08 real: run 40992715830, artefacto 12949654097, ejecutor 1b5fb59d421cc8f2e7be6a717c5cf4fca024a9e4.

## Avance observado, no simulado por el observador

La continuación C07→C08 ejecutó 99.775.385 transiciones adicionales, completó los 19 módulos originales, enlazó virtio-blk y virtio-gpu, enumeró vda1..vda8, montó /metadata con EXT4 y creó nueve dispositivos de partición lógica (dm-0..dm-8). GPU detectada NO significa pantalla Android visible; creación de particiones lógicas NO significa que system/vendor ya estén montados.

C08 se detuvo ante `Unsupported AArch64 instruction 0x2f10a442 at 0x4cc358`, a 6.450.570.741 transiciones, EL0. El journal guardó el prefijo completo; no hubo pánico del kernel. El run quedó correctamente en fallo, no en éxito ficticio.

## Reparación

`0x2f10a442` es `UXTL V2.4S,V2.4H`, alias de USHLL con desplazamiento cero. Se incorpora SSHLL/USHLL, variantes superiores y alias SXTL/UXTL en el decodificador nativo existente. Se preservan la selección de mitad fuente Q, extensión de signo, 128 bits de destino y alias Rd==Rn. Los desplazamientos del host se hacen sobre enteros sin signo. immh[3] sigue reservado y immh=0000 sigue perteneciendo al decodificador de inmediatos modificados.

Contrato de arquitectura consultado: documentación primaria de Arm A64, páginas USHLL/SSHLL (copia de referencia en Stanford, edición 2026-03). Implementación propia de las transiciones; no se incorporó otro emulador.

## Pruebas locales antes de publicar

La prueba nueva falla sobre el decodificador anterior con el opcode exacto. Con el cambio pasan 16.910 comprobaciones, 450 casos de instrucciones con todos los desplazamientos válidos, anchos, signos, mitades, alias, persistencia y rechazo de codificaciones reservadas; UBSan activo. Las 11.675 comprobaciones FP/SIMD anteriores también pasan. Hay 18 pruebas del verificador de evidencia C09. No son 28.603 arranques de Android.

## Continuidad

El workflow de la misma rama evoluciona a C09. Consume únicamente el C08 revisado, preserva C06 como raíz de entrada, comprueba el opcode aún no ejecutado y conserva kernel, ramdisk, disco, reloj, RAM y memoria XI/Ether. No vuelve a C07 ni se salta la instrucción. Repite las suites antes del arranque y conserva el nuevo journal incluso si aparece otro fallo. Resultado de ejecución: consultar el artefacto `reverse-c09-uxtl-exact-continuation`; no inferirlo de estas pruebas locales.

La reparación es del ejecutor nativo ya existente, no una migración a XI ni una afirmación de que todo el anfitrión sea XI. main queda intacto.
