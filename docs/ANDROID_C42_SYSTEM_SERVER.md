# C42 — completar Zygote y verificar system_server

Fuente única inicial: C41, 19.316.342.731 instrucciones, SHA-256 `079cc299c91f95ac30f313c24aedb6cb8db84534256dbcf06687c83292eba1a0`, productor `0b1d2aec6613975fdca2ab88461b73df4b940be2`, artefacto 13113618839 del run 41381667947. El contrato de cuatro archivos se autentica antes de ejecutar.

## Diagnóstico inicial observado

El PID 567 sigue siendo `/system/bin/app_process64 --zygote --start-system-server`, hijo de init, vivo y ejecutable. Su tiempo de CPU pasó de 1.158.009.000 ns en R2 a 1.566.692.000 ns en C41. Su pila mostraba `mas_store_prealloc`, `vms_gather_munmap_vmas`, `do_vmi_munmap` y `__arm64_sys_munmap`: hay actividad y cambio de trabajo, no prueba de un bloqueo fijo. No hay system_server ni socket Zygote receptivo verificados.

## Criterio de éxito

Un proceso `system_server` debe estar vivo conforme al estado real de task_struct, tener espacio de usuario, ejecutable `/system/bin/app_process64` comprobado desde el mm del invitado y padre igual a un Zygote vivo cuyo ejecutable y argumentos/nombre fueron comprobados. Se rechazan procesos muertos, detenidos, nombres de hilos de kernel, ejecutables distintos, padres incorrectos y ambigüedades. Esto no equivale a Android gráfico ni a `sys.boot_completed=1`.

## Procedimiento

1. Autenticar y observar C41 sin escribir bytes del invitado.
2. Ejecutar 1.000.000 de instrucciones reales dos veces desde C41: transacciones de 50.000 y de 200.000. Exigir igualdad de los RVG completos y sus hashes. Solo la salida limpia e idéntica del segundo modo se publica y puede continuar.
3. Mantener la misma CPU C41, XI/Ether, RAM, reloj, disco, SELinux y odsign. Las opciones de host C39 de 200.000 instrucciones por transacción y checkpoints de 120 s/200 millones se utilizan después de la comparación; no modifican tiempo virtual ni estado arquitectónico.
4. Hasta ocho continuaciones separadas de hasta 500 millones de instrucciones y 15 minutos de CPU anfitriona por etapa. Después de cada una, autenticar contrato, procedencia, integridad, seguridad y progreso de Zygote; publicar el checkpoint y un informe pequeño antes de continuar.
5. Parar automáticamente cuando system_server esté verificado. Ante ISA desconocida, pánico, falta de progreso o fallo de contrato, no autorizar la salida: conservar la última etapa limpia publicada y el candidato fallido aparte como observación.

La cantidad de instrucciones no es el criterio de éxito. Si termina el presupuesto de etapas sin system_server verificado, la comprobación final falla explícitamente y conserva todos los checkpoints limpios publicados. Los informes distinguen CPU creciente, proceso ejecutable y espera de E/S; no presentan una espera puntual como prueba de deadlock.

Los diarios temporales de host se eliminan después de publicar el checkpoint. Se mantienen las últimas copias locales necesarias para continuar; las anteriores siguen disponibles en sus artefactos de GitHub durante 90 días. Los estados fallidos nunca se convierten en fuentes de continuación.

La rama sigue experimental y no modifica main.
