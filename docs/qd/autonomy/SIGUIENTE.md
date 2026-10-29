# QdU — siguiente ciclo después de T1

## Arquitectura obligatoria

**BBY Q → w4U → QdU**. BBY Q es la única inteligencia principal y memoria; w4U es la coordinación; QdU programa en el mismo XI/Ether. ReverseCoding es una aplicación, no otra IA. Conservar IDs técnicos, RVPC2, W4u, E025 y el candidato E034 sin mezcla ni sobrescritura.

## Estado observado del ciclo T1

Rama `qdu/t1-delegation-20261029`, PR #65 apilada sobre #63 → #59 → #56 → #35 → #34, sin fusión. CI [nativa XI](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40915364219) **success**: 14/14 tareas explícitas de programación, 15/15 rechazos, 134 ejecuciones XI. Regresiones aprobadas: 26 órdenes, 18 rechazos, 164 comprobaciones Qd y 24 reparaciones reservadas.

La ruta probada usa clasificación léxica BBY Q XI, autorización consumible w4U XI, generación QdU XI, comprobación independiente w4U XI y confirmación tipada BBY Q XI. La CLI inicializa **un RVPC2 descartable con la marca de w4U**, no el estado E025 de producción. La API `delegate` está conectada a ReverseCoding y copia el estado auténtico bajo writer.lock, pero todavía **no se ha probado esta llamada en Android ni integrado al chat general BBY Q**. Android [workflow 40915364146](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40915364146) recompila esta clase y las regresiones anteriores: comprobar su conclusión real antes de reclamar APK lista.

## Siguiente ciclo T1.1 — autorización desde el chat y Android real

1. Resolver HEAD de los dos repos, PRs, workflows/runner, bloqueo activo y memoria E025/E034. Leer `docs/qd/autonomy/` y `BBY-Q/docs/autonomy/`; no tocar el ciclo general de BBY Q.
2. Reproducir el límite actual: chat BBY Q `ask` no deriva a w4U/QdU; ReverseCoding sí puede llamar `delegate` de forma explícita. Anotar baseline y aceptación antes de código.
3. Implementar un **contrato tipado** desde la solicitud de BBY Q, autorizado por w4U antes de cualquier ejecución, y conservar las conversaciones, tickets, hashes y confirmaciones de acciones de escritorio. No convertir entradas libres en poderes de archivos/red.
4. Crear una instrumentación Android 15 que ejecute de verdad la acción `delegate` sobre `BBY-Q.rxe` E025, dos órdenes positivas ES/EN, dos negativas, y confirme que `session.rxas` y `session.rvp` no cambian; fallar si no existe W4u válido.
5. Endurecer la unión de la tarea al texto y operandos originales en el verificador w4U; probar ticket modificado/repetido, permiso ausente, suplantación, ambigüedad, rollback y resultado numérico falso.
6. Aceptación: >=10/12 tareas **desde el chat** en examen reservado, 12/12 controles negativos, y todas las suites nativas previas + Android E025/w4U/migración/restore sin regresión. Medir tiempo/RSS si el runner lo registra; no inventar métricas físicas.
7. Publicar una PR apilada aislada; no fusionar en main antes de reconciliar otros cambios y validar la firma APK.

Después de T1.1, T2 composición de dos pasos, T3 depuración en editor, T4 tareas autorizadas de un archivo y T5 proyectos multarchivo. No proclamar autonomía estilo Work hasta comprobar tareas externas reales.
