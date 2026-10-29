# REVERSE / BBY Q — abrir Robinhood desde el chat

## Comportamiento añadido

BBY Q recibe una orden afirmativa como **«abre Robinhood»**, **«abre roobinhood en el navegador»** o **«open Robinhood»** y usa un programa **XI** para devolver la operación tipada **op=11, target=11**. La interpretación de palabras y la selección de acción están en `bbyq-interface/xi/open-robinhood.xi`; el Java y el JavaScript **no** interpretan el mensaje.

El host valida que la app que pidió el control sea el BBY Q original autorizado, registra un único ticket, compara el estado actual del escritorio, pide la apertura a Android y consume la acción. El único destino web disponible para esa operación es:

`https://robinhood.com/`

La URL se define como constante literal en `WorkbenchActivity`; ni el mensaje ni el agente suministran una dirección URL arbitraria al puente Android. Primero se intenta abrir en Chrome y, si no está instalado, Android muestra un selector de aplicaciones compatibles.

El navegador se abre **fuera del WebView de REVERSE**, que permanece en `https://reverse.local/` con la red desactivada y acceso al puente nativo. La autenticación, cookies, MFA, órdenes y saldos pertenecen únicamente al navegador/servicio externo. **BBY Q no recibe contraseñas ni acceso a la cuenta, no compra ni vende y no conecta ninguna API bursátil.**

## Contrato de ejecución

1. `WorkbenchPrograms.ask` delega un mensaje al `RxeAppStore` del BBY Q confiable.
2. Después de observar el escritorio, `BbyqInterface.tryOpenRobinhood` hace una prueba XI sobre una copia descartable del estado. Si no coincide la orden exacta, el turno sigue por E025/W4u sin perder memoria.
3. Si XI reconoce el comando, produce `op=11,target=11` y el texto preliminar «Voy a abrir Robinhood en el navegador». El resultado y un ticket se guardan antes de intentar la acción externa.
4. `bbyq-control.js` valida vista y ticket; invoca `openOfficialSite` mediante el puente nativo con el **identificador fijo** `robinhood`.
5. Android comprueba el identificador (sin aceptar URLs proporcionadas por JS), inicia el navegador y comunica el resultado.
6. `RxeAppStore.acknowledge` usa un programa de respuesta XI separado para confirmar éxito o fallo; no simula que W4u haya realizado un cambio de ventana. Un ticket no puede repetirse.

La apertura de un navegador **no** crea ventanas ficticias en REVERSE ni cambia el fondo, los iconos, la distribución, los modos horizontal/vertical ni la memoria de E025. En entornos sin Android nativo se informa que no está disponible.

### Alcance de lenguaje

Se admiten varias formulaciones afirmativas en español e inglés, entre ellas `abre Robinhood`, `abre roobinhood`, `abre la página de Robinhood`, `puedes abrir Robinhood`, `open Robinhood`, y variantes `en el navegador`. Las comparaciones son exactas tras ignorar mayúsculas ASCII, un signo inicial `¿` y una puntuación terminal `?` o `.`.

Frases negadas o ambiguas como `no abras Robinhood`, `abre Robinhood y compra bitcoin`, `qué es Robinhood`, `cierra Robinhood` o dominios diferentes **no** devuelven ninguna acción de navegación. No se pretende reconocer cualquier reformulación lingüística.

## Validación

La CI ejecuta el intérprete XI en el runtime fijado de REVERSE-PC, verifica acciones, salidas ES/EN, negativas y limpieza del buzón; y prueba el contrato JS de ticket único, rechazo de vista obsoleta, fallo y destino restringido. La compilación Android comprueba las modificaciones Java, sin presentar un navegador externo ficticio.

La apertura y autenticación con un navegador real requieren una prueba en el dispositivo: una CI de escritorio no puede confirmar que el usuario terminó de iniciar sesión.

**Este cambio se apila sobre** `feature/reverse-portrait-landscape-20261028` (PR #50) para preservar la interfaz compacta, el fondo, los iconos y las dos orientaciones. No modifica la APK que el usuario ya tiene instalada.
