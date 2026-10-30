# LAPLACE incluido en la próxima APK de REVERSE

La referencia de esta conversación es **LaPlaceDIG 06ebce4bddf25d615cefd85ed24081f37504a492**:
modelo M001, no la recalibración R015 descartada ni el filtro I015 de persistencia.

## Integración real

- El lanzador del escritorio ofrece **Laplace**. Abre una actividad propia incluida
  en la misma APK; Volver regresa a REVERSE. No cambia el fondo ni iconos existentes.
- Recursos empaquetados en `app/src/main/assets/laplace`, sin una página alojada
  ni un servidor Node obligatorio en el teléfono.
- Android suministra transporte HTTPS acotado, archivo privado atómico y exportación.
  No recibe URLs arbitrarias, credenciales ni operaciones bursátiles. Sólo se cargan
  documentos del origen local de la aplicación; los recursos remotos no ejecutan JS.
- La matemática de M001 sigue en JavaScript, como en LaPlaceDIG. El adaptador cambia
  únicamente la lectura de la huella de código y SHA-256 síncrono por WebCrypto
  asíncrono. Las pruebas comparan salidas completas, no sólo precios aproximados.
- No se modifica XI/Ether, el ejecutor nativo ni la memoria de BBY Q.

## Controles incluidos

Selector de 15/30/60/240/1440/10080 minutos, historia visible independiente,
selección de fuentes de contexto, gráfico temporal con precio de origen exacto,
exportación de la última lectura y vista del registro horario remoto con filtros.
Se publica el candidato aunque no haya demostrado ventaja; falta de patrones produce
«Sin cálculo», nunca una cifra inventada. Siete días suele tener soporte muy escaso.

La representación 3D utiliza perspectiva CSS del anfitrión WebView. Sus estados
cambian al iniciar/recibir/fallar consultas. Es una visualización del flujo de IO,
no un modelo causal del universo, ni un nuevo renderizador XI ni un indicador de
precisión. Los efectos se pueden desactivar y respetan reducción de movimiento.

Las fuentes opcionales son contexto. Activar NOAA, ETH, órdenes u operaciones no
finge aumentar su influencia sobre el precio. El cálculo usa la cotización y las
velas que necesita el M001 existente. No se han añadido otros activos predictivos.

## Dos registros que no deben confundirse

La última consulta manual se guarda en el archivo privado `laplace-m001-captura.json`.
Incluye entradas, candidatos y sello; no altera las memorias de otras aplicaciones.
No es un diario inmutable ni un servicio en segundo plano: conserva la última lectura.

La sección «Registro horario» lee `LaPlaceDIG/laplace-registro/seguimiento/resumen.json`.
Es el diario automático existente, con sus propios candidatos y evaluaciones.
Las consultas del teléfono NO se agregan silenciosamente al diario de GitHub.
Se indica la hora de actualización y no se mezclan las dos procedencias.

## Requisito de compilación

`verifyLaplaceIntegration` es obligatorio para las variantes **control/workbench**,
antes de combinar sus recursos y compilar Java. La compilación falla si faltan o se
sustituyen recursos, cambia la referencia fijada o falta el enlace del escritorio.
Se conserva el requisito previo BBY Q X01. No se cambia firma ni versionCode;
se ajustarán como parte de la próxima entrega que el propietario solicite.

Usar una revisión de REVERSE que contenga esta integración. Una rama antigua no
adquiere archivos nuevos por sí sola: hay que incorporar este commit antes de generar
una APK basada en ella. No se fusionan en este cambio ramas de Android invitado,
renderizadores experimentales, ni proyectos ajenos.

Comprobar:

    node laplace-android/prepare.mjs --check
    node laplace-android/verify.mjs
    node --test laplace-android/tests/modelo.test.mjs

Los assets están ya preparados: no es necesario descargar LaPlaceDIG al compilar.
`prepare.mjs` permite regenerar la adaptación con las fuentes verificadas incluidas.
El workflow de Workbench prueba la entrada real desde REVERSE en Android 15
(`mode=laplace`) y confirma que la memoria nativa no cambia. El workflow específico
prueba la paridad, compila el adaptador Java y usa Chromium con un puente simulado
para los controles. Los casos artificiales no son datos de mercado ni resultados de inversión.
