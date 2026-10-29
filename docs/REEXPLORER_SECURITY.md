# REexplorer — navegador de REVERSE con defensa Ether Guard

## Qué se ha construido

**REexplorer** es una aplicación del escritorio REVERSE con barra de direcciones y un lector web nativo dentro del **mismo paquete Android**. El renderizado HTML/CSS/JavaScript y el protocolo TLS utilizan el componente **Android System WebView (basado en Chromium)**, mantenido por el proveedor Android. Esto no es todavía un navegador HTML ni un núcleo criptográfico escritos desde cero con XI/Ether; sería incorrecto presentar ese resultado como logrado.

La decisión de abrir Robinhood desde el chat sí nace en **XI/Ether**, en el programa `bbyq-interface/xi/open-robinhood.xi`: una orden positiva genera `op=11, target=11`. W4u/REVERSE comprueba el ticket y la vista del escritorio. La solicitud autorizada se transforma en una **intención explícita de Android dentro de la misma APK** que abre la actividad privada `ReexplorerActivity`, con la URL fija `https://robinhood.com/`.

Los enlaces se abren dentro de REexplorer, no en Chrome, Samsung Internet ni el WebView privilegiado de `reverse.local`. El botón de REexplorer permite introducir **manualmente** otra URL HTTPS pública. BBY Q no dispone de esa ruta arbitraria.

## Modelo de seguridad concreto

| Frontera | Control aplicado |
|---|---|
| Órdenes de IA | Reconocimiento XI limitado a órdenes positivas; `op=11,target=11` y URL oficial fija |
| Repetición | Ticket de un uso + comparación de la vista del escritorio; confirmación posterior XI |
| Aislamiento web | Activity no exportada en proceso `:reexplorer`; directorio WebView separado mediante `setDataDirectorySuffix` |
| Interfaz privilegiada | El WebView que presenta páginas **nunca** instala `addJavascriptInterface`; el escritorio `reverse.local` mantiene las cargas de red desactivadas |
| Red | HTTPS obligatorio; HTTP, esquemas locales y hosts reservados rechazados |
| TLS | Usa verificación del proveedor Android; `onReceivedSslError` **siempre cancela** |
| Safe Browsing | Habilitada en el motor Android; para URLs señaladas se pide `backToSafety` |
| Permisos | Cámara, micrófono, geolocalización, cliente certificado, autenticación HTTP, elección de archivos y descargas denegados |
| Sistema de archivos | `allowFileAccess`, `allowContentAccess`, y ambos accesos desde `file://` desactivados |
| Cookies | Primera parte permitida para sesión web; cookies de terceros desactivadas; el almacenamiento no comparte el directorio del escritorio |
| Contenido | No hay exportación de texto de páginas, formularios, contraseñas o cookies a BBY Q / XI / W4u |
| Borrado | Botón con confirmación que solicita limpieza de cookies, WebStorage, caché e historial del navegador |

### Alcance de la política

`ReexplorerPolicy.java` rechaza esquemas distintos de HTTPS, credenciales embebidas en la URL, puertos diferentes de 443, IP literales, `localhost` y dominios locales/reservados. No realiza resolución DNS y **no demuestra** que un nombre público esté protegido contra DNS rebinding o que un sitio HTTPS sea legítimo. La navegación manual puede ir a dominios públicos con identidad desconocida. La barra del navegador muestra el dominio real y recuerda verificarlo.

Las defensas se sitúan donde corresponde: reglas de acción en XI, restricciones de navegación en Android, certificados en el proveedor TLS y aislamiento en WebView. XI no sustituye el cifrado TLS, el sandbox de Chromium ni los parches de seguridad del dispositivo.

### Qué no se garantiza

- No es legítimo afirmar que sea «el navegador más seguro» sin auditoría externa, fuzzing y pruebas contra ataques reales. Un proceso Android separado **no supone un UID Linux completamente distinto**; sigue bajo los permisos de la aplicación. La seguridad depende también de Android System WebView, los parches del sistema, el proveedor de red y los sitios visitados.
- JavaScript del sitio está habilitado para compatibilidad con páginas modernas, incluido un posible inicio de sesión financiero. No se permite ningún puente JavaScript a capacidades de REVERSE. La navegación hacia contenido malicioso aún puede explotar fallos desconocidos del motor web.
- Un dominio con TLS válido puede ser una imitación o contener contenido engañoso. La navegación segura del proveedor puede fallar o no identificar amenazas nuevas.
- El borrado de datos **no revoca sesiones de los servidores**; el usuario debe cerrar sesión allí. Tampoco se promete eliminación forense de todo rastro en el dispositivo.
- Algunas plataformas financieras o flujos OAuth prohíben WebView y podrían requerir un navegador externo. Si se presenta una restricción, REexplorer debe informarlo; no debe intentar eludirla.
- No se automatiza el acceso a cuentas, extracción de saldos, compras, ventas ni introducción de credenciales.

## Integración en REVERSE

El icono REexplorer, su tarjeta en la mesa, el acceso desde el lanzador y la barra de inicio manual respetan el fondo e iconos ya existentes y admiten las dos orientaciones. La tarjeta ejecuta la operación `openReexplorer` con una URL introducida manualmente; `WorkbenchActivity` verifica la dirección con `ReexplorerPolicy` y abre la actividad segura. No renderiza una página remota dentro del WebView privilegiado de la mesa.

La primera versión admite una única sesión de navegación, atrás, adelante, actualizar, inicio, dirección y borrar datos. No afirma disponer ya de pestañas múltiples, extensiones ni sincronización.

## Pruebas y estado del despliegue

Pruebas propuestas en CI:
- `reverse-os-android/tests/ReexplorerPolicyTest.java`: validación positiva y negativa de direcciones y separación de la ruta específica del agente.
- `reverse-os-android/tests/reexplorer-desktop.cjs`: botón de escritorio, icono, orden tipada y garantía de no incrustar contenido remoto.
- `bbyq-interface/tests/robinhood-native.cjs`: verificación de intención **real XI** con casos adversarios.
- `bbyq-interface/tests/robinhood-desktop.cjs`: ticket único, vista obsoleta, comprobaciones de la actividad separada y ausencia de puente.
- Compilación de todas las clases Java con Android 35.
- **Falta** comprobar en un dispositivo real el lanzamiento, la compatibilidad de Robinhood y sus flujos de autenticación.

Este desarrollo está apilado en la rama de interfaz horizontal/vertical del PR #50. La integración de una rama no implica entrega de una APK actualizada.
