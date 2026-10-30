# C08: continuación verificada desde C07

Base: `7c21e6aae7f0528805444910c207e9aef6463573`, rama C07 / PR #72.

## Corrección

El cargador sólo admitía la pareja C06 y el control del ciclo exigía EL0. El C07 original está en EL1. Se admite la pareja exacta C07 estado/informe, se verifica el estado completo y se conserva C06 como raíz de la primera entrada. No se sustituyen CPU, XI/Ether, kernel, ramdisk, disco, RAM ni reloj.

## Validación local reproducida

24 comprobaciones del control de reanudación con UBSan y 80 pruebas Node: todas pasan. Auditoría SHA-256 y checksum interno del C07 original: correcta. Estas pruebas no ejecutan Android. Los tres archivos modificados se cotejaron con los blobs originales de la revisión base; el parche se aplica sin conflictos.

## Prueba de integración

El workflow `android-c08-continue-reviewed.yml` descarga el C07 del run `40975381521` y el disco original del run `40910284394`, compila el motor existente, repite cuatro suites nativas y continúa desde 6.350.795.356 instrucciones. Mundo-X permanece fijado a `e2778d962af22f6f1a0794058dd4685fc2573966`.

La ejecución conserva dos generaciones completas de estado e informe y una referencia atómica. El registro informa instrucciones, PC, EL, UART y guardados; el límite de ejecución termina de manera controlada. La recolección `always()` preserva el último prefijo comprometido aunque la siguiente operación falle. No se certifican bucles de pánico, estados detenidos ni informes mezclados.

Los resultados del workflow y su artefacto son la autoridad para determinar el avance real. Hasta observarlos, la nueva continuación sigue sin estar demostrada. Android gráfico y juegos no se declaran disponibles. No se modifica ni fusiona `main`.
