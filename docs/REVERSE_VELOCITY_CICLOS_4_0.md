# REVERSE VELOCITY 4.0 — ciclos de conducción y mundo

Base: 3.9 probada por X en su teléfono, donde reportó aproximadamente 90 FPS
estables conduciendo a máxima velocidad. Es una observación del usuario; esta
campaña no presupone que una actualización nueva conserve ese resultado.

| Ciclo | Trabajo | Estado |
| --- | --- | --- |
| C01 | Frenado prioritario, aceleración progresiva, seis marchas, freno motor, velocímetro y persistencia | Implementado; validación en curso |
| C02 | Más objetos y vida del bosque: conjuntos locales variados, fauna y movimiento ambiental con presupuestos por perfil | Pendiente del siguiente ciclo |
| C03 | Refinamiento de destinos, orillas, iluminación y detalles de materiales; revisar colisiones y legibilidad al conducir | Pendiente |
| C04 | Campaña de estabilidad, rendimiento y recorrido completo; APK final de la campaña | Pendiente |

## C01

El freno de servicio cancela acelerador y nitro en la misma transacción XI.
La aceleración tarda 0,5 segundos en aplicar todo el pedal. Las seis marchas
cambian el par, el régimen y el freno motor; los cambios automáticos usan
umbrales distintos de subida y bajada. Una reducción manual insegura queda
pendiente, sin recortar instantáneamente la velocidad del coche.

El modo inicial es automático. Los botones **−** y **+** seleccionan marchas
manuales; mantener pulsado el indicador o elegir **Transmisión** en el menú
restablece el automático. D/R conserva su cambio con detención previa. Las
teclas Q/E permiten verificar las marchas sin simular coordenadas táctiles.

El velocímetro consume velocidad, marcha y RPM del estado XI confirmado.
La ABI conserva las primeras 35 observaciones y añade tres de transmisión.
La selección manual viaja en el componente portátil de QSSD; la versión 2
del componente admite también la lectura del formato anterior de vista.
Los archivos completos siguen verificando el inventario exacto de recursos;
un guardado creado con otros programas no sustituye silenciosamente la sesión.

### Medición controlada frente a 3.9

La prueba nativa ejecuta el programa XI real a 50 pasos por segundo y mantiene
el punto de contacto en el mismo asfalto para comparar fuerzas. Son tiempos
de simulación de un juego arcade, no una medición física de neumáticos reales
ni de FPS en el teléfono.

| Prueba | 3.9 | C01 |
| --- | ---: | ---: |
| 0–100 km/h | 2,72 s | 6,12 s |
| Velocidad tras 1 s de acelerador | 37,37 km/h | 14,80 km/h |
| 100–0 km/h: tiempo | 1,14 s | 0,76 s |
| 100–0 km/h: recorrido | 15,28 m | 10,21 m |

Se prueban frenadas desde 30, 60, 100, 200 y 234 km/h, prioridad con ambos
pedales y nitro, las seis marchas automáticas, límite de primera, freno motor,
reducción insegura y continuación exacta después de restaurar RVPC2.
La exploración fuera del asfalto se verifica con más tiempo de aceleración,
porque la menor entrega de par cambia deliberadamente la distancia a igualdad
de segundos. Geometría, perfiles, CPU/GPU y autoridad QSSD conservan su ruta.

La comparación de transporte qSSD usa el mismo programa de conducción nuevo
en ambos runtimes; solo drive.xi y environment.xi están excluidos de la igualdad
con los recursos 3.7. Los otros recursos mantienen la comparación exacta.

Los ciclos siguientes se ejecutarán en orden cuando X pulse continuar; cada
cierre conservará su commit, evidencias, limitaciones y enlace de entrega.
