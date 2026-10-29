# REexplorer Quantum — navegador nativo de REVERSE-PC, sin BBY Q

## Decisión arquitectónica del propietario

**REexplorer es una aplicación propia de REVERSE-PC. BBY Q no interpreta, abre ni controla páginas.** No se utiliza `BbyqInterface.tryOpenRobinhood` ni la acción web `op=11` de la rama experimental anterior. El chat y la memoria de BBY Q mantienen su propia ruta E025/W4u; una acción de navegación web empieza en el icono **REexplorer** del escritorio y en su barra de direcciones, nunca en el chat.

### Camino real de navegación

```
Operador
  └─ REVERSE Desktop → icono REexplorer → barra HTTPS
      └─ Bridge local Android: openReexplorer(url) y ReexplorerPolicy
          └─ ReexplorerActivity (proceso :reexplorer)
               ├─ REexplorer Q-Core → XI/Ether (RVPC2 independiente)
               │    ├─ clasifica un EVENTO TIPADO (no lee página/DOM/cookies)
               │    ├─ estado mínimo: modo, rechazos, cuarentena
               │    └─ ALLOW / BLOCK / QUARANTINE
               └─ Android System WebView (renderer HTML/CSS/JS + TLS)
                    └─ conexión HTTPS con el sitio
```

### Qué significa «cuántico» en esta etapa

El nombre **REexplorer Quantum** se refiere al uso real del runtime nativo de REVERSE con representación de estados lógicos **XI/Ether/RVPC2**, no a computación cuántica física, cifrado cuántico, anonimato absoluto ni aceleración demostrada del transporte. El núcleo `security/reexplorer/xi/reexplorer-qcore.xi` y la copia idéntica incluida en `assets/reexplorer/navigation-core.xi` computan decisiones y un cerrojo de cuarentena que sobrevive a varios eventos **de la misma sesión**.

`ReexplorerQuantumCore.java` únicamente:
- crea una **memoria RVPC2 propia** con `NativeRuntime.initialize()`;
- carga XI local y pasa *números tipados* para navegación, TLS, amenaza, permisos, descarga, bloqueo de ventana y cambio de origen;
- recibe decisiones `r0/r1/r2` verificadas; si hay error de ejecución, **rechaza toda navegación nueva**;
- no lee ni escribe el estado BBY Q ni el estado general de REVERSE.

Android mantiene la validación HTTPS, la denegación de certificados con errores, la validación de destinos y las restricciones de permisos: **una decisión XI permisiva no puede desactivar barreras nativas**. Los elementos de navegación de REexplorer permanecen propios del producto; el motor de presentación HTML/CSS/JS es Android System WebView actualizado. Desarrollar un sustituto de Chromium totalmente en XI que soporte Robinhood es un objetivo distinto y no completado.

### Lo que el usuario puede hacer ahora en la versión compilable

- Abrir REexplorer desde el escritorio de REVERSE, sin llamar a BBY Q.
- Escribir `https://robinhood.com/` u otra URL HTTPS pública, o tocar el acceso directo «Robinhood oficial».
- Navegar con controles de atrás/adelante/recargar/inicio.
- Abrir sitios web con JavaScript y cookies de primera parte habilitados, sin puentes al núcleo.
- Borrar datos locales del navegador con confirmación.
- Ver si Q-Core bloquea navegación insegura o mantiene una sesión en cuarentena por amenaza o certificado erróneo.

**Importante para Robinhood:** su documentación pública enumera Chrome, Safari, Firefox y Edge como navegadores compatibles; no incluye REexplorer ni WebView. La página de inicio puede ser accesible, pero **el inicio de sesión y todas sus funciones deben verificarse en un dispositivo real**; no inventar compatibilidad ni modificar identificadores para evadir restricciones. Fuente: https://robinhood.com/us/en/support/articles/360027026971/

## Seguridad y límites

Las solicitudes a HTTP, esquemas locales o destinos restringidos se rechazan por las reglas base de Android. El núcleo XI mantiene decisiones `ALLOW=0`, `BLOCK=2`, `QUARANTINE=3`; deniega descargas y permisos de sitios, y cierra la sesión por error TLS o amenaza conocida. Una cadena de tres destinos denegados termina también en cuarentena.

REexplorer sigue siendo **un componente Android del mismo paquete que REVERSE** aunque usa `android:process=":reexplorer"` y un directorio WebView separado: no representa un UID Linux independiente. No intercepta todos los paquetes DNS, conexiones, WebSocket, service workers ni conexiones internas del renderer; el filtrado de WebView es de cobertura parcial. El sitio web ve la conexión IP y los datos que el usuario decida compartir. No hay evidencia de que la aplicación sea más segura que los navegadores oficiales, ni de criptografía poscuántica negociada.

No utilizar una cuenta financiera con fondos reales sin una prueba adicional de compatibilidad y seguridad del navegador en el dispositivo.

## Pruebas

```sh
node security/reexplorer/tests/native-qcore.mjs /ruta/reverse_pc evidence/reexplorer-quantum
node security/reexplorer/tests/independent-browser.mjs
node reverse-os-android/tests/reexplorer-desktop.cjs
javac -d build/policy reverse-os-android/app/src/main/java/com/reversepc/os/ReexplorerPolicy.java reverse-os-android/tests/ReexplorerPolicyTest.java
```

CI `.github/workflows/reexplorer-guard.yml` compila el runtime original y ejecuta la política XI con entradas nuevas y adversarias, el escritorio sin BBY Q, la validación de URL y las clases Java Android. CI `.github/workflows/reexplorer-preview-apk.yml` construye una APK firmada de prueba con el navegador y el motor original. Una CI aprobada de ingeniería **no equivale a prueba de navegación ni inicio de sesión real**.

### Próximo ciclo verificable

1. Probar apertura real en Android de la APK de REexplorer, navegar un sitio público HTTPS y registrar errores y capturas sin credenciales.
2. Medir latencia real por decisión XI con dispositivo de recursos limitados; optimizar si bloquea la interfaz.
3. Separar los UID de REVERSE y del navegador mediante dos paquetes si se requiere aislamiento más fuerte.
4. Evaluar un firewall/VpnService completo con pruebas IPv4/IPv6, redirecciones, WebSocket y DNS; no confundirlo con `shouldInterceptRequest`.
