# REgraphics XI — Ciclo 3: preparación predecodificada de escena

## Problema identificado

La escena 4K de Reverse Velocity contiene unas **12.870 instrucciones XI**.
El motor previo ejecutaba las instrucciones correctamente, pero durante cada
fotograma volvía a convertir operandos literales a enteros, resolver registros
por su nombre y comparar cadenas para determinar el opcode. Los saltos
resolvían además etiquetas en un mapa al ejecutarse.

El objetivo de este ciclo fue reducir **ejecución de escena antes de
rasterizar**, sin sustituir XI, usar una GPU externa ni cambiar física, color,
profundidad o formato XFB5.

## Optimización aplicada dentro del único intérprete XI

- Cada instrucción conserva su opcode normalizado y un ID interno compacto
  (MachineOpcode). La semántica del lenguaje sigue siendo la misma.
- Los operandos de hasta 14 posiciones se decodifican una vez al analizar
  el programa. Un arreglo de enteros de 64 bits y dos máscaras de 14 bits
  distingue literales, registros y tokens que deben usar la ruta tradicional.
- Las etiquetas ya validadas guardan el destino numérico de salto, evitando
  búsquedas repetidas por cada iteración.
- add, sub y mul usan operaciones enteras verificadas contra overflow mediante
  builtins disponibles en GCC/Clang. div y mod conservan errores por cero y
  por INT64_MIN/-1. La política de rollback transaccional no cambia.
- Un token inválido, desconocido o situado en una rama que nunca se ejecuta
  conserva el tratamiento de errores anterior: **no se valida de manera
  prematura** durante la predecodificación.
- El programa predecodificado pertenece a la caché inmutable y privada por
  hilo de la máquina XI. No guarda registros ejecutados, geometría, estados
  Ether, texturas modificadas ni resultados de física.
- El rasterizador paralelo, Ether Spatial, JNI directo, paleta de 256 colores,
  resolución 3840×2160 y XFB5 no cambian.

## Medición local de fases (CPU Linux, igual escena)

| Parte | XI previo | XI predecodificado |
|---|---:|---:|
| Parseo inicial | ~6–7 ms | ~9–11 ms |
| Instrucciones de escena excluyendo raster | ~37–41 ms | ~7–9 ms |

La predecodificación requiere algo más de trabajo inicial, pero lo recupera
al ejecutar la escena. En la muestra local con una escena 4K, el RSS máximo
observado fue aprox. 19,4 MB antes frente a 22,2 MB después. Es una
contrapartida de memoria de un proceso Linux, no RAM total Android.

## Comparación en GitHub Actions (mismo hardware, toolchain y escena)

CI recompila la fuente XI 1.5 **exacta** desde el commit
7fa759e937ea2fdb4687e9b2c02f1dd487c7dd2f como referencia y la
versión optimizada con el mismo rasterizador paralelo y compilador.

La prueba scripts/xi-preparation-ab.cjs verifica:
- 18 programas XI, incluidos saltos y etiquetas con mayúsculas,
  enteros límite, aritmética y desbordamientos, memoria local, store/load,
  errores de división y operandos inválidos. Exige misma salida, error y estado.
- 12 escenas 4K XFB5 (dos estados físicos, tres cámaras, dos pinturas),
  todas idénticas por SHA-256 píxel a píxel y estado Ether candidato.
- Ningún comando altera el archivo de instantánea fuente.
- Reporte reproducible en build/velocity/xi-preparation-ab.json.

En el workflow 41340779726, la suma de medianas de las 12 ejecuciones fue
**1.378,03 ms → 1.174,63 ms, un 14,76 % menos**. Es tiempo completo de
proceso host (incluye rasterizado, restauración y E/S), NO FPS Android.

También pasan las 4.196 comprobaciones tradicionales del raster,
la prueba de franjas paralelas y los contratos del puente JNI.
No afirmamos superioridad universal ni 60/120 FPS sostenidos.

## Pruebas Android de la versión 1.6

La distribución mantiene el mismo applicationId y certificado de
instalación de Reverse Velocity, cambiando versionCode a 16.
El APK debe superar el smoke test de Android con conducción, HUD, 4K,
cámaras y telemetría antes de considerarse validado para entrega.

## Siguiente límite

Tras predecodificar instrucciones y repartir las franjas de raster, los
principales pasos pendientes son cachear transformaciones geométricas
independientes de la cámara, evitar la reconstrucción de buffers idénticos
y estudiar renderizado incremental con reglas rigurosas de invalidación.
No conviene usar reutilización visual cuando la cámara cambia si no puede
demostrarse la equivalencia exacta con el render completo.
