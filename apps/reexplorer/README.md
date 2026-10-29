# REexplorer — núcleo propio RXE/XI de lectura incremental

**Estado: componente nativo ejecutable, NO navegador web completo ni reemplazo de Chromium.**

## Principio obligatorio

REexplorer es un producto de REVERSE-PC. **BBY-Q, W4u y Qd quedan fuera de este núcleo**. No se usa su memoria, intérprete, semilla ni sus comandos. REexplorer mantiene su espacio de trabajo XI/Ether independiente mediante la memoria RVPC2 del programa de prueba y un RXE de la máquina REVERSE-PC.

El código `apps/reexplorer/xi/stream-reader.xi` contiene el lector de bytes incremental y los estados mínimos:

- Estado 0: texto normal.
- Estado 1: marcador HTML.
- Estados 2 y 3: cuerpo de etiquetas `<script>` y `<style>` que se ignora, sin ejecutar JavaScript ni CSS.
- Estados 4 y 5: búsqueda de sus terminadores a través de límites de paquete.
- Tres contadores de 24 bits: bytes vistos, bytes visibles y bytes ocultos; otro contador registra etiquetas.
- Presupuesto máximo de 1 MiB por documento; por operación se admiten hasta 224 bytes. Un desbordamiento suspende el análisis hasta el siguiente `reset`.
- Recuperación sin reconstruir el documento: se conserva el estado incremental y se emiten solo bytes de texto seleccionados.

**Esto es lectura nativa de texto de páginas, no ejecución de sitios.** Los scripts se tratan como datos no ejecutables. El diseño sirve para comenzar una implementación propia de REexplorer, con una superficie de ataque deliberadamente pequeña y medible. No interpreta CSS, DOM completo, formularios, navegación por enlaces, sockets, TLS, HTTP/2, WebSocket, renderizado de fuentes ni inicio de sesión de Robinhood.

## Formato del programa

Todo ocurre en una región reservada de la memoria propia XI `8755000000000000000` y no en las regiones de BBY-Q.

| Desplazamiento | Significado |
|---|---|
| +0 | 1 = procesar paquete, 2 = consultar estadísticas, 3 = reiniciar |
| +1 | número de bytes recibidos (0–224) |
| +128 | inicio de la ventana de 224 bytes de entrada |
| +4096 | estado del autómata |
| +4097..4099 | bytes de entrada procesados |
| +4100..4102 | bytes visibles emitidos |
| +4103..4105 | marcadores HTML vistos |
| +4106..4108 | bytes ocultos |
| +4109 | longitud temporal del prefijo de etiqueta |
| +4110 | límite excedido (1 = bloquea nuevos paquetes) |
| +4120..4131 | pequeño prefijo de etiqueta |

Los bytes visibles se emiten en registros `r14`; los contadores se imprimen con los registros `r0`, `r1`, `r2`, `r3`, `r12` y `r13`. El procesador no crea objetos de página gigantes, no guarda copias completas de HTML, ni ejecuta script remoto.

Para construir y comprobar el RXE con el runtime del proyecto:

```sh
node apps/reexplorer/build.mjs /ruta/reverse_pc /ruta/evidence/reexplorer
node apps/reexplorer/tests/native-stream.mjs /ruta/reverse_pc /ruta/evidence/reexplorer /ruta/evidence/reexplorer/test
```

La CI fija Mundo X a `e2778d962af22f6f1a0794058dd4685fc2573966` y prueba la máquina original. La semilla RXE es propia y no incluye BBY-Q.

## ¿Cuánto internet llega y qué tan rápido se lee?

**El ancho de banda de red no es lo mismo que la velocidad de interpretación XI.** En una navegación real hay varias etapas:

```text
DNS → conexión → TLS → solicitud → primer byte → descarga/decodificación
    → lectura HTML → CSS/DOM → ejecución JavaScript → pintura/composición
```

Las magnitudes relevantes son:
- Latencia de primer byte (TTFB), en milisegundos.
- Bytes efectivamente recibidos por la red, bytes después de descompresión y velocidad efectiva en Mbit/s.
- CPU y memoria por byte leído en XI/Ether, en el propio dispositivo.
- Tiempo de construir texto/estructura y actualizar la pantalla.
- Revalidación del caché, cantidad de solicitudes paralelas, prioridades y trabajo de fondo.

Un ejemplo hipotético: si la red suministra 12 Mbit/s y la lectura procesa 200 Mbit/s, acelerar la lectura **no aumenta** los 12 Mbit/s físicos; puede, sin embargo, reducir la espera entre bytes y la aparición de la información en pantalla. Si el parser es el cuello de botella, reducir estados y copias sí puede ayudar. Se debe medir por separado antes de afirmar una ganancia.

El nombre Q-Stream hace referencia a la arquitectura de estados mínimos de REVERSE. No significa que se hayan utilizado qubits físicos o una aceleración cuántica demostrada; este módulo utiliza la ruta clásica determinista de XI/Ether.

## Próximos componentes necesarios para Robinhood funcional

1. **Transporte HTTPS real independiente de BBY-Q**: política URL, conexión y validación TLS con biblioteca de transporte auditada del dispositivo, redirecciones y control de IP/DNS a nivel de red.
2. **Navegador nativo de REVERSE-PC**: manejo de sesiones, cookies, historial y ventanas sin recurrir a BBY-Q. Aislamiento de orígenes.
3. **Renderizador web**: DOM/CSS y motor compatible con JavaScript para sitios modernos, más capacidades de autenticación que Robinhood acepte. Son subsistemas grandes y de alto riesgo; si se usa WebView como backend transitorio debe identificarse claramente como tal.
4. **Q-Stream medido**: ingestión de paquetes de red del transporte real, métricas de TTFB, bytes sobre el enlace, bytes descomprimidos, tiempo de RXE, repintado y caché.
5. **Pruebas**: abrir páginas públicas con pruebas reproducibles, casos hostiles y después verificar que la autenticación funciona sin debilitar TLS ni capturar credenciales.

**No afirmar conexión real, login Robinhood ni velocidad mejorada** únicamente porque un parser XI procesa entradas sintéticas. No actualizar la APK ni fusionar ramas de BBY-Q para instalar este módulo. 
