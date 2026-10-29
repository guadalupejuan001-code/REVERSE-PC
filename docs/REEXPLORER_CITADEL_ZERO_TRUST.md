# REexplorer Citadel — arquitectura de navegación de confianza cero

**Estado: DISEÑO E INVARIANTES, NO IMPLEMENTACIÓN DEL AISLAMIENTO FINAL.**
Fecha de diseño: 2026-10-29.
Base comprobada: REVERSE-PC `feature/reverse-portrait-landscape-20261028`, commit `1b613026d360c897f93ac29652b8461a0522e452`; PR #50.
Se mantiene REexplorer actual y su interfaz. No sustituirlo a ciegas, no tocar la memoria privada de BBY Q ni afirmar que la separación de UID, el cortafuegos completo o la criptografía poscuántica ya estén desplegados.

## 0. Objetivo y límite demostrable

Objetivo del usuario: abrir sitios completos (incluidos inicio de sesión y servicios financieros) sin dar a contenidos externos autoridad para leer ni modificar **REVERSE, Ether, BBY Q, W4u, Qd, Laplace, archivos personales ni otras sesiones**. Contener ataques, minimizar huella rastreable y recuperar el navegador sin perder el estado del OS.

No es posible prometer acceso a páginas complejas sin que **esa página** reciba algún dato: dirección IP de salida (o IP de un relay), petición de conexión, información de cliente, cookies autorizadas y cualquier credencial/texto que el usuario envíe. Tampoco es posible garantizar que el software desconocido carezca de vulnerabilidades. La meta operativa es **separación verificable, mínimo de información compartida, fallos contenidos y visibilidad de exposición residual**.

### Datos por clasificación

- **C0 / Sistema soberano**: memoria XI/Ether, checkpoints, archivos de REVERSE, BBY-Q, Qd, W4u, Laplace, certificados/llaves del sistema. JAMÁS al navegador ni por intención, WebView, portapapeles automático o Binder genérico.
- **C1 / Perfil web**: cookies, datos WebStorage, historial, sesión de inicio de sesión de REexplorer. Solo en el UID/directorio del navegador; por sitio o perfil cuando sea técnicamente posible, nunca copiados hacia C0.
- **C2 / Consentimiento puntual**: archivo seleccionado expresamente, cámara/micrófono o copia al portapapeles; alcance limitado al recurso, origen y sesión, con permisos siempre revocables. En el modo financiero, no conceder C2 por defecto.
- **C3 / Metadatos**: origen validado, clase de evento (redirección, permiso, descarga, cambio TLS), presupuesto y resultado. El motor XI recibe solamente C3 indispensable; **no** formularios, DOM, contraseñas, cookies, texto de páginas, capturas ni claves.

## 1. Arquitectura destino

```text
 ┌──────────────────────────────────────────────────────────────┐
 │ REVERSE-PC / XI / Ether / W4u / BBY Q / Qd / Laplace          │
 │ UID A · datos C0 · sin páginas remotas, sin inyección web    │
 │                                                             │
 │  Solicitud tipada: OPEN_SERVICE(robinhood)                    │
 │        │  ticket único + validación de origen + intención    │
 └────────┼─────────────────────────────────────────────────────┘
          ▼
 ┌──────────────────────────────────────────────────────────────┐
 │ Citadel Broker · permiso mínimo, superficie IPC estrecha      │
 │ valida acción, token, sitio, modo y límite de sesión          │
 │ política base inmutable: TLS inválido / red privada = BLOQUEO│
 │ motor XI/Ether: sugerencias con metadatos C3; no privilegios │
 └────────┬─────────────────────────────────────────────────────┘
          ▼ solo URL autorizada / no memoria C0
 ┌──────────────────────────────────────────────────────────────┐
 │ REexplorer · APK/package separado · UID B ≠ UID A            │
 │ su almacenamiento C1, claves no exportables, perfil efímero │
 │ interfaz de navegación, motor WebView mantenido               │
 │ NO ReverseNative, no acceso al filesystem de REVERSE          │
 │ NO permisos SMS/contactos/archivos/accessibility              │
 └────────┬─────────────────────────────────────────────────────┘
          ▼ tráfico de salida bajo política
 ┌──────────────────────────────────────────────────────────────┐
 │ Guard Network · inspección de flujo, DNS/IP/redirecciones      │
 │ bloquea RFC1918/loopback/link-local/local network y egress   │
 │ fail-closed cuando ese modo ha sido activado                 │
 └────────┬─────────────────────────────────────────────────────┘
          ▼
      Internet HTTPS / sitio solicitado
```

**Primera frontera que falta**: REexplorer actual usa `:reexplorer` + `setDataDirectorySuffix` dentro de **la misma APK**, por tanto es separación de proceso/directorio, no separación de identidad Linux/UID. La prioridad 1 es una **APK independiente con package/UID diferentes**, una única actividad web sin el núcleo de REVERSE incluido, y comunicación interapp limitada. El renderizador WebView puede tener su propio sandbox adicional según el proveedor/dispositivo, pero eso no convierte al proceso anfitrión del navegador en un UID diferente del OS.

**Segunda frontera que falta**: bloquear un host `localhost` por cadena no es suficiente contra redirecciones, DNS rebinding, IPv4/IPv6 y sockets secundarios. `WebViewClient.shouldInterceptRequest` no cubre todas las clases de URL ni posteriores redirecciones. El control exigente debe operar por debajo del navegador, con una política de **egress** real (firewall/VPN/stack de red instrumentado, sujeto al dispositivo y permisos disponibles). Un VPN Android requiere consentimiento del usuario y ocupa la ranura de VPN del sistema: no debe reemplazar silenciosamente otro VPN del dispositivo.

**Tercera frontera**: la política debe ser determinista y verificable. Laplace/XI puede explorar escenarios y anticipar patrones de riesgo, pero **nunca** conceder lo que el núcleo de seguridad ha prohibido.

## 2. Motor de decisión dinámico — reglas formales

Al recibir cada evento `NAVIGATE`, `REDIRECT`, `DNS_RESOLVE`, `CONNECT`, `PERMISSION`, `DOWNLOAD`, `RENDERER_STALL`, `RENDERER_CRASH`, `PROFILE_CLOSE`, aplicar en este orden:

1. **Invariantes duros (no sobreescribibles)**: nunca exponer C0, no puentes JS nativos ni claves fuera de Android Keystore, no HTTPS con certificado inválido, no IP local/privada en modo endurecido, no `file:`/`content:`/`intent:` ni puertos no permitidos, no privilegios sin consentimiento real.
2. **Validación de red**: validar esquema y origen, resolver y verificar **cada IP de destino después de DNS** para IPv4, IPv6 y redirecciones, y controlar sockets reales. Si falla el guard de red en modo financiero, impedir nueva salida de tráfico (no hacer bypass silencioso).
3. **Perfil**: `GENERAL`, `FINANCE`, `EPHEMERAL`. Todo perfil tiene separación de cookies del OS; FINANCE exige navegación HTTPS, seguridad de certificados, confirmación de cambio de sitio principal y sin descargas/puentes.
4. **Señales de anomalía**: cambio de origen inesperado, cambio DNS a red privada, demasiadas redirecciones, petición de permiso sensible, descarga sin gesto, subrecurso hostil, renderer colgado, excepción del motor. Calcular riesgo **solo después** de las reglas anteriores.
5. **Acción tipada**: `ALLOW`, `ASK_USER`, `BLOCK`, `QUARANTINE`, `TERMINATE_RENDERER`. `ASK_USER` no podrá autorizar jamás un bloqueo inmutable. `QUARANTINE` elimina acceso de red y congela/descarta sesión según las capacidades del SO; no implica desinfectar un exploit desconocido.

Reglas de ejemplo, no evaluadas como protección real hasta el motor completo:
- `cert_invalid` ⇒ `BLOCK`; ninguna excepción del usuario o IA.
- `destination_is_private_ipv4_or_ipv6` ⇒ `BLOCK` en egress.
- `permission_request` ⇒ `ASK_USER` solamente si existe una función habilitada; `FINANCE` ⇒ `BLOCK` predeterminado.
- `download_without_user_gesture` ⇒ `BLOCK`; con gesto ⇒ `QUARANTINE` antes de ofrecer descarga.
- `renderer_unresponsive` repetido ⇒ `TERMINATE_RENDERER`, con recuperación del OS independiente.
- `unexpected_origin_change` ⇒ `ASK_USER` + anular concesiones temporales del origen anterior.
- `unknown_signal` en `FINANCE` ⇒ `BLOCK` si el sensor es indispensable y no funciona.

### Invariante de permisos

`effective_permissions = fixed_system_ceiling ∩ policy_for_current_origin ∩ explicit_user_grants`

Una puntuación de riesgo baja o el modelo de Laplace **nunca aumenta** el techo fijo. Los permisos del usuario son acotados, expiran y se borran al cerrar un perfil efímero o cambiar de origen. Las páginas no pueden invocar Qd ni herramientas de sistema desde el DOM.

## 3. Compatibilidad y privacidad

La navegación completa requiere JavaScript, cookies de primera parte y, en ciertos casos, autenticación persistente. El usuario elige un **modo** sin que la UI finja compatibilidad universal:

- **FINANCE**: operaciones web manuales, HTTPS obligatorio, sin fuentes C0, cookies solo del perfil financiero, sin transferencias automáticas; se prohíbe a BBY Q ver o manipular formularios de inversión. Si una plataforma no acepta WebView, se informa; no se eluden restricciones de autenticación del proveedor.
- **GENERAL**: sitios modernos, navegación manual, prompts granulares y aislamiento de origen. Tolerancia controlada a funciones necesarias, nunca un permiso global.
- **EPHEMERAL**: nuevo perfil o almacenamiento temporal, sin guardar historia/cookies al cerrar, y sin marcadores persistentes. El sitio sigue viendo cualquier dato que el usuario introdujo y puede guardar datos en su servidor.

**Lo que el sitio puede seguir observando**: IP pública (salvo que se use relay externo), navegador/UA, horario, comportamiento de uso, huella de funciones del motor y todos los campos enviados voluntariamente. Una VPN **local de filtrado** no oculta por sí sola la IP al sitio remoto. Una VPN/proxy/Tor con salida externa puede ocultar la IP del origen frente al destino, pero revela tráfico al relay, tiene costos y puede romper servicios financieros. No iniciar jamás una ruta proxy sin consentimiento; el proyecto prioriza operación local, sin servidor.

## 4. Contraseñas, claves y cifrado

- Almacenamiento local persistente del navegador: claves no exportables en **Android Keystore**, protegidas por hardware/StrongBox **solo cuando el dispositivo lo ofrezca y la atestación lo confirme**. Usar AEAD estándar (p. ej., AES-GCM); no derivar material criptográfico de qubits simulados, estados XI ni un algoritmo de Laplace.
- Red: TLS del proveedor de WebView, validación de certificado, sin `onReceivedSslError.proceed()`, y sin inventar un cifrado de transporte incompatible con el sitio.
- Criptografía poscuántica: usar mecanismos estandarizados (ML-KEM según NIST FIPS 203) **solo donde el protocolo y la biblioteca actualizados soporten negociación real**. No forzar ni afirmar negociación PQ sin evidencia de handshake. Una simulación cuántica XI **no** es distribución cuántica de claves ni demuestra invulnerabilidad.
- Credenciales/passkeys: usar soporte del sistema donde sea compatible con el sitio y WebView. No copiar credenciales a BBY Q, no registrar teclas de acceso, nunca desactivar advertencias de seguridad para forzar una sesión.
- El sitio al que el usuario inicia sesión por decisión propia recibe los datos de autenticación necesarios; el navegador no puede impedir ese flujo sin romper el login.

## 5. El papel exacto de XI/Ether y Laplace

**XI/Ether**:
- Autoridad para interpretar órdenes del operador y decidir solicitudes tipadas, no acceso libre a APIs del navegador.
- Reglas compactas/estados mínimos para `DENY/ALLOW/ASK/QUARANTINE`, sobre metadatos C3.
- Memoria de política única, con versionado, rollback verificable, sin datos secretos ni DOM; una política no validada queda en modo observación, nunca sustituye la barrera obligatoria.

**Laplace** (solo como módulo de análisis opcional):
- Explorar grafos de ataques, permutaciones de redirección, cambios de permisos, escenarios de fallos y secuencias de eventos.
- Generar casos de prueba antes de desplegar políticas; comparar heurísticas de riesgo frente a hechos observables.
- Separar predicción de seguridad y seguridad comprobada; ni una simulación exhaustiva de su modelo equivale a demostrar que cubre todas las vulnerabilidades del hardware y el mundo real.
- Nunca leer secretos ni adjudicarse permisos de navegación por una predicción favorable.

## 6. Pruebas de ingeniería obligatorias antes de usar dinero real

| Evidencia | Aceptación | Estado de la base |
|---|---|---|
| Paquetes separados | `UID(REVERSE) != UID(REexplorer)`, no `sharedUserId`, ni bibliotecas del core XI en APK navegador | **PENDIENTE** |
| IPC | Solo mensajes con contrato/URL validados, sin lecturas de C0, sin JS bridge, fuzz de 10k entradas malformadas | **PENDIENTE** |
| Egress | IPv4/IPv6, DNS rebinding, redirects, WebSocket, service workers y WebRTC se bloquean cuando salen a red privada; monitor de paquetes completo | **PENDIENTE** |
| Permisos | Cámara, audio, location, archivo, clipboard y descarga sin consentimientos no acceden a datos; con consentimiento, alcance delimitado | **PARCIAL**: denegación web, sin concesiones puntuales |
| Escalada | La secuencia `DENY→ALLOW` está prohibida para reglas duras, aun con entradas maliciosas a XI | **PENDIENTE** |
| Perfil | Crear/cerrar, aislar cookies, borrar almacenamiento efímero, verificar que BBY Q nunca ve C1 | **PARCIAL**: directorio WebView propio |
| Recuperación | Colgar o derribar renderer no cambia ni corrompe memoria/estado de REVERSE | **PARCIAL**: callback de fallo |
| Compatibilidad | Login y flujos legítimos, sin automatizar credenciales, en sitios de prueba controlados y luego servicios reales | **PENDIENTE** |
| Riesgos externos | Fuzzing de WebView/IPC, pruebas de phishing, inspección de dependencias, revisión independiente | **PENDIENTE** |
| Postcuántica | Validación de biblioteca/protocolo real; no presentar ML-KEM sin prueba de negociación | **PENDIENTE** |

**Ninguna puntuación de CI sobre este documento prueba las filas marcadas PENDIENTE.** Los controles parciales actuales se describen en `docs/REEXPLORER_SECURITY.md` y PR #60.

## 7. Orden de implementación recomendado

1. **P0: frontera de UID real**: extraer REexplorer a una app/paquete mínimo separado de REVERSE, conservar interfaz, entregar URL por canal tipado; no conectar memoria del SO.
2. **P1: pruebas de acceso**: instrumentar dos APK y ejecutar intentos de lectura desde navegador a archivos de REVERSE, más falsificación IPC, permisos sensibles y navegación hostil. Mantener la regla actual sin puente nativo.
3. **P2: control de red real**: investigar VPN local/guard de sockets, rutas IPv4/IPv6, DNS, redirecciones y bloqueo de fuga cuando ese guard no funciona; pedir permiso de VPN explícito y reconocer su incompatibilidad con una VPN ya activa.
4. **P3: perfiles y compatibilidad**: financiar modo financiero y sesión efímera, acceso condicional a funciones web, prueba de sitios que requieren OAuth/WebAuthn sin simular sesiones.
5. **P4: motor XI dinámico**: introducir señales C3, fallos adversarios, reglas sobre estados mínimos, verificador determinista y sugerencias Laplace siempre subordinadas a los bloqueos.
6. **P5: cifrado/custodia**: Keystore y cifrado local cuando exista estado guardado, medición de protección real y soporte PQ del proveedor (si lo ofrece), auditoría/fuzz y revisión independiente.

### Condiciones de promoción y despliegue

Prohibido decir que el usuario es «indetectable», «imposible de descifrar», «protegido al 100%», que «la mecánica cuántica» elimina las vulnerabilidades, o que REexplorer ya alcanza las fronteras P0–P5. Si falla cualquier prueba de núcleo o existe cobertura incompleta de egress, no activar `FINANCE` endurecido como protección completa. No fusionar PR de código de seguridad sin tests correspondientes. Mantener la APK previa y los datos de BBY Q.

## Referencias de autoridad

- Android sandbox y UID por aplicación: https://developer.android.com/guide/components/fundamentals
- Android WebView, directorio por proceso: https://developer.android.com/reference/android/webkit/WebView
- Límites de `WebViewClient.shouldInterceptRequest`: https://developer.android.com/reference/android/webkit/WebViewClient
- Riesgos del acceso a archivos WebView: https://developer.android.com/privacy-and-security/risks/webview-unsafe-file-inclusion
- VPN Android, consentimiento y exclusividad: https://developer.android.com/reference/android/net/VpnService
- Android Keystore: https://developer.android.com/privacy-and-security/keystore
- ML-KEM FIPS 203: https://csrc.nist.gov/pubs/fips/203/final
