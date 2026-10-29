# Próximo ciclo único: T1 — delegación real BBY Q → w4U → QdU

## Contrato inamovible y contexto

Los únicos nombres de roles son **BBY Q**, **w4U** y **QdU**, en ese orden. Se respeta el [contrato oficial](../../BBYQ_W4U_QDU_CONTRACT.md). ReverseCoding es la aplicación de QdU, XI/Ether la ejecución y REVERSE-PC el host. No crear modelos independientes, nueva memoria maestra ni nuevo runtime; no cambiar identificadores persistentes heredados.

Esta rama es **T0 de documentación, auditoría y rotulación**; no garantiza delegación real. La rama ReverseCoding PR #59 ya logró 26 órdenes aritméticas válidas, 18 negativas, pruebas XI y Android 15, pero la ruta actual `qd-studio.js → WorkbenchPrograms.qd → QdEngine` **omite w4U**. La prioridad siguiente es corregir esta discontinuidad, no aumentar la cantidad de sinónimos.

Al reanudar, consultar HEAD reales, PRs y GitHub Actions de BBY-Q y REVERSE-PC, su ejecutor, sus dependencias y checkpoints. Conservar BBY Q/docs/autonomy, E025 desplegado, E034 candidato aislado, writer.lock, w4U y session.rvp. No construir sobre el ID ni el commit de este registro como supuesto de estado actual.

## Objetivo preciso T1

Demostrar una tarea de programación de principio a fin pasando por **BBY Q → w4U → QdU → w4U → BBY Q**. Comenzar con órdenes aritméticas que QdU ya conoce, pues prueban integración sin confundir capacidades nuevas de lenguaje. QdU mantiene el sandbox XI y ReverseCoding; w4U es el único autorizador de trabajos con efectos permanentes.

### Primero reproducir defecto y fijar examen

1. Observar de nuevo la ruta directa actual y ejecutar un caso de control desde ReverseCoding; comprobar que no hay plan ni ticket w4U. Registrar baseline y evidencia antes de editar.
2. Confirmar el contrato de `BBY Q.rxe`, las entradas/salidas `w4U plan/explore/verify/advance`, su número de operaciones, versión y direcciones RVPC2. Elegir un identificador de acción tipado disponible solo tras demostrar que no colisiona con los actuales. No inventar permisos ni modificar todos los handlers por estética.
3. Definir `TaskEnvelope` tipado con `task_id`, intención/entradas, origen BBY Q, alcance de permisos, capacidades, presupuesto, firma/nonce de acción según el mecanismo existente, destino QdU y referencias de evaluación; w4U debe emitir/validar la autorización real. Evitar serializar información privada como log de entrenamiento.
4. QdU sólo recibe ese sobre aprobado al ejecutar un trabajo delegado. En modo exploración, la edición de texto XI aislada puede seguir funcionando sin acceso al host; no convertir esa sesión de prueba en ejecución persistente con permisos.
5. w4U coteja salida, artefacto y pruebas. BBY Q comunica qué hizo realmente y distingue fallo, bloqueo, propuesta pendiente y entrega completa.
6. En caso de capacidad ausente, ticket falso, revisión obsoleta, duplicado, fallo de XI, límites de recursos o conflicto RVPC2: abortar/rollback y dejar registro, no repetir acciones con efectos.

### Aceptación predefinida antes de modificar

- Un examen separado de práctica con **12 tareas inéditas** de código aritmético que entren desde la conversación/solicitud BBY Q y recorran w4U, QdU, w4U y BBY Q; **al menos 10/12 correctas y trazadas**.
- **12/12** controles negativos rechazados: ticket ausente/duplicado, permisos insuficientes, cambio de revisión, órdenes ambiguas, fuentes no autorizadas, presupuesto agotado, fallo de la operación y respuesta de la herramienta falsamente positiva.
- Evidencia del mecanismo XI real para decisión de w4U y generación de código QdU, no sólo UI mock ni Java seleccionando operaciones.
- Regresión de ReverseCoding **26/26 órdenes y 18/18 abstenciones**, protocolo Qd original **164 checks/128 entradas**, depurador anterior **24/24**, W4u y E025, migración/restauración Android 15 sin pérdida de información.
- Hash/identidad de memoria principal RVPC2 y `session.rvp` antes/después conservados al operar únicamente en sandbox. Cualquier persistencia explícita debe ser permitida por w4U y probada con `writer.lock`.
- Documentar tiempos/RAM reales donde haya medidas, tamaño de artefacto, compromisos y diferencias frente a T0. No proclamar autonomía Work si sólo se completan ejercicios.

## Integración de ramas y orden posterior

Mantener las PR Qd previas **#34 → #35 → #56 → #59** hasta revisión/CI; revisar el contrato T0 apilado antes de integrar. Para consolidación estable, auditar las ramas combinadas de escritorio (Music/PRISMA/Laplace, orientación, REexplorer) con sus conflictos; las ramas de Android guest/PCI/gráficos permanecen experimentales y no se mezclan ciegamente con el ejecutor del producto.

**Después de T1**: T2 composición de instrucciones y requisitos, T3 depuración en editor, T4 tarea de un archivo como Work, T5 multarchivo y CI/PR autónomos revisables. No saltar a T4 por tener una interfaz con botones.

Si T1 no puede construirse sin dañar estado, compatibilidad o dependencia, detener el ciclo, registrar el bloqueo exacto en `docs/qd/autonomy/` y conservar el checkpoint. Ejecutar **un ciclo** por activación; no duplicar BBY Q/w4U ni crear nuevas automatizaciones.
