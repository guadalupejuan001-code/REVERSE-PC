# C41 — Continuación real de Zygote a system_server

## Fuente y comprobación

- Origen único: C40 de REVERSE-PC, run 41363261111, rama `experiment/android-c40-zygote-launch-20261101`, commit productor `b626902e5ec2624b89c58fea30b8a0ab36983225`.
- La prueba C40 reconoce el ejecutable `/system/bin/app_process64`, PID 567 en C39, con argumentos auténticos `-Xzygote --zygote --start-system-server --socket-name=zygote`. **Esto no prueba que ya exista un socket Zygote operativo.**
- C41 espera a que C40 termine correctamente y solo acepta el checkpoint completo `reverse-c40-authenticated-android-checkpoint`. Nunca consume un snapshot parcial, ejecutado con fallo o sin contrato autenticado.

## Ejecución

El workflow `.github/workflows/android-c41-zygote-framework.yml` autentica el contrato de cuatro archivos y su procedencia desde el checkpoint C39 `094d5c9b9532fbb21ea029031b952f46c4df0e589c2f0d75a4dd64677bc49438`. Verifica que la ejecución C40 fuera real, sin panic, reboot ni pérdida de estado.

El observador del kernel revisa antes de ejecutar CPU los argumentos y ejecutable del proceso Zygote, la propiedad real `init.svc.zygote`, el hilo actual y el planificador. Luego compila el mismo XI/Ether con caché C39 validada, restaura el mismo disco Android original y continúa tres ciclos acotados de hasta 500 millones de instrucciones cada uno, manteniendo los límites de host.

Al finalizar vuelve a verificar el checkpoint, las propiedades `odsign.key.done=1` y `odsign.verification.done=1`, el proceso Zygote, `system_server`, `surfaceflinger`, `sys.boot_completed` y la salida gráfica.

## Criterio de verdad

El proyecto estará más cerca del arranque si una traza real demuestra que el lanzador terminó de inicializarse y que `system_server` apareció como proceso vivo, pero eso **todavía no demuestra** que el socket esté respondiendo o que Android haya terminado de iniciar. Un workflow exitoso demuestra que los pasos de CPU y evidencia terminaron limpiamente, no una pantalla Android funcional.

No se cambian kernel, SELinux, AVB, Keystore, RAM, reloj virtual, disco o la rama principal. No se fabrican propiedades ni procesos; se conserva el último checkpoint aprobado.
