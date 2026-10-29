# Contrato arquitectónico inamovible: BBY Q → w4U → QdU

**Decisión del propietario (29-10-2026):** la identidad funcional de la plataforma tiene exactamente tres módulos bajo una autoridad: **BBY Q**, **w4U** y **QdU**. La grafía visible es canónica. Nadie debe transformar esta estructura en tres modelos independientes ni en otro agente maestro.

Este documento es un **contrato de diseño y revisión**. No afirma que toda la ruta de delegación ya esté implementada. Los componentes actuales se mantienen compatibles mientras se implementa la integración y se comprueban los resultados.

## Roles que no se pueden intercambiar

| Rol fijo | Autoridad y responsabilidades | Prohibiciones |
| --- | --- | --- |
| **BBY Q** | Inteligencia principal: conversación, comprensión de solicitudes, contexto, razonamiento, aprendizaje y memoria principal RVPC2 | No delegar su identidad ni sustituir su checkpoint por otro sin migración validada |
| **w4U** | Orquestador interno de BBY Q: objetivos, planes, herramientas autorizadas, seguimiento de pasos, permisos, evaluación de resultados, recuperación | No convertirse en un segundo cerebro, programador paralelo ni dueño de otro estado maestro |
| **QdU** | Especialidad programadora del mismo BBY Q: comprensión de requisitos de software, algoritmos, XI, ejecución aislada, depuración, pruebas, entrega de fuentes/RXE/PR | No transformarse en otra IA ni actuar con privilegios que w4U no haya otorgado |

**XI/Ether** sigue siendo el lenguaje/mecanismo existente de decisiones, reglas, representación, aprendizaje y ejecución; **REVERSE-PC** es el anfitrión, espacio de trabajo y sandbox; **ReverseCoding** es la aplicación de edición/ejecución **de QdU**, no una cuarta IA ni un orquestador. Los roles auxiliares de w4U (plan/explore/verify/advance) son funciones del mismo módulo. Los verificadores Java/JS son infraestructura independiente, no inteligencias nuevas.

### Camino objetivo para solicitudes de programación

```text
OPERADOR
   ↓ solicitud
BBY Q — entiende el propósito, contexto y límites; ofrece aclaración o abstención
   ↓ objetivo tipado (sin elevar privilegios)
w4U — verifica permisos, elige acciones, secuencia y presupuesto
   ↓ tarea de programación autorizada
QdU — inspecciona material permitido, diseña, genera XI/Ether, prueba y depura
   ↓ resultado, diff, logs, pruebas y estado; nunca autoridad nueva
w4U — revisa resultado, pruebas, rollback/entrega y registra finalización
   ↓ explicación y artefactos
BBY Q → OPERADOR
```

**Regla permanente:** una orden con efectos sobre archivos, proyectos, aplicaciones instaladas, memoria duradera o GitHub debe pasar por autorización/seguimiento de w4U. Una ejecución matemática temporal local en el sandbox, sin efectos y sin permisos, puede existir en ReverseCoding como herramienta; esa ejecución no demuestra la ruta autónoma completa.

## Diagnóstico actual (no confundir deseo con hecho)

- **BBY Q E025** está integrado/pinneado en la aplicación REVERSE 2.5.1; el candidato **E034** con composiciones relacionales fue comprobado por su rama, pero no se ha desplegado como reemplazo del E025 de la app. Sus checkpoints no se mezclan.
- **w4U 0.1** tiene un planificador XI de como máximo dos pasos, verificaciones tipadas de ventanas/RXE y una sola autoridad privada con BBY Q. No es todavía un administrador general de archivos, proyectos y PR.
- **QdU** procede de la rama ReverseCoding PR #59. Internamente aún se llama `qd`/`QdEngine`/`QdOrders`; actualmente sólo interpreta órdenes aritméticas de cinco familias con dos enteros 0..99 y ejecuta el código generado temporalmente.
- **FALTA LA CONEXIÓN:** la ruta actual `qd-studio.js → nativeRequest('qd') → WorkbenchPrograms.qd → QdEngine.handle → QdOrders.order` **no pasa por un plan w4U** ni usa la comprensión conversacional general de BBY Q. Por tanto, **BBY Q → w4U → QdU todavía es una arquitectura exigida, no un flujo demostrado**.
- 32 PR de REVERSE-PC y 11 de BBY-Q permanecían abiertas al último diagnóstico. `main` de REVERSE-PC seguía en `01829217cfb0a3a704d37f0c0f66527a23ec149d`, sin ReverseCoding. CI de una rama no equivale a integración ni APK instalada.

## Compatibilidad obligatoria

1. En la interfaz, manuales, tareas y reportes usar exactamente **BBY Q**, **w4U** y **QdU**. Los identificadores históricos `qd`, `QdEngine`, `QdOrders`, `qdDrafts`, `W4u`, `W4u.rxe` y las rutas previas de documentación son **alias técnicos existentes**, no módulos nuevos. No cambiar sus IDs, hashes, claves ni direcciones RVPC2 por estética.
2. El RVPC2 de BBY Q es la autoridad de memoria. Reservas internas de w4U/QdU no constituyen otra memoria maestra. No modificar conversaciones, checkpoints E025/E034, `writer.lock`, escritorio `session.rvp` ni paquetes firmados desde un ciclo de identidad.
3. REVERSE-PC mantiene sus propias sesiones de ejecución de escritorio; no confundirse con memoria principal del agente. Fuentes de entrenamiento se ejecutan en copia temporal sin persistencia y sin acceso a archivos, host ni red salvo permisos explícitos.
4. No introducir Python/C++ como inteligencia nueva. Los componentes de compilación heredados pueden utilizarse sin reescribirlos. Toda decisión semántica y composición de programación nueva permanece XI/Ether.
5. Ninguna etiqueta nueva es evidencia de razonamiento nuevo. El criterio funcional es medir la ruta verdadera, casos reservados, fallos, seguridad y regresiones contra la versión previa.

## Ciclos de desarrollo ordenados (una sola actividad a la vez)

**T0 — Identidad y trazabilidad.** Congelar nomenclatura, mapear rutas reales y contratos de memoria, actualizar textos visibles, añadir comprobación estática y actualizar la tarea diaria existente sin duplicarla. Mantener `main` intacta y PR de revisión. **Este ciclo no declara delegación funcional entre los tres módulos.**

**T1 — Delegación real de tareas de código.** BBY Q recibe una orden; w4U emite una tarea tipada de programación con ticket/permiso, QdU acepta únicamente esa tarea en un sandbox, entrega código/veredicto; w4U revisa la evidencia. Conservar un modo puramente local/temporal para el editor. Probar rechazos de tickets falsos, repetidos, caducados y permisos ausentes. No dotar de acceso a proyectos hasta que T1 apruebe.

**T2 — Comprensión y composición.** QdU debe convertir intenciones pequeñas con dos pasos y resultados intermedios a algoritmos XI, resolviendo entradas/salidas y dependencias. Al menos 20/24 problemas inéditos, 16 rechazos correctos, regresiones y estado inalterados. Distinguir sintaxis reconocida de aprendizaje nuevo.

**T3 — Depuración desde ReverseCoding.** Conectar el diagnosticador XI a la interfaz y ofrecer un diff de una sola falta, con aprobación del operador. Mantener archivos originales y checkpoint. Repetir 16/16 pruebas y 24/24 fuentes reservadas del depurador, más Android.

**T4 — Work de un archivo real.** Leer/editar sólo workspace autorizado, reproducir error, proponer diff, corregir, ejecutar, reportar. w4U verifica y coordina; QdU no se fusiona con BBY Q como agente independiente. Presupuestos duros de intentos, tiempo, memoria y efectos.

**T5 — Proyecto multarchivo y consolidación.** Resolver dependencias, crear RXE y PR separados, CI, revisión de compatibilidad, migración explícita y entrega a `main` únicamente tras validación. Las ramas de guest Android, REexplorer, Music y orientación se revisan de manera separada para evitar conflictos masivos.

### Criterio de aceptación prioritario para T1

- **Práctica y examen separados:** como mínimo 12 solicitudes nuevas de tareas aritméticas via conversación BBY Q → plan w4U → QdU, con al menos 10/12 completadas, y 12 controles de inyección, repetición, capacidad ausente o contradicción correctamente rechazados.
- **Prueba extremo a extremo:** la acción seleccionada y el ticket proceden de w4U; el trabajo programador real procede de QdU XI; el resultado vuelve a w4U y a BBY Q. Mostrar trazas con sus roles y verificación de estado.
- **Compatibilidad:** conservar 26/26 órdenes admitidas y 18/18 rechazos ReverseCoding, 164 comprobaciones Qd previas, 24/24 reparaciones, E025/w4U, migración y restauración Android.
- **Estado:** sandbox desechable, ningún archivo ni memoria privada alterados sin permiso, revisión/restauración al fallar; verificación mediante hashes/identidades, no únicamente afirmación verbal.

La prioridad de integración estable es **auditar ramas y consolidar el producto sin sustituir el núcleo experimental ni contaminar RVPC2**. Se puede preparar una rama de integración con CI, pero nunca describirla como integrada o distribuida sin verificar `main` y el certificado Android.

**Regla de salida por ciclo:** describir primero qué existe, qué falta y qué se midió. Si la ruta completa no pasó, no llamarla autónoma ni comparable funcionalmente con ChatGPT Work.
