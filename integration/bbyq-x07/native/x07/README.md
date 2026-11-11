X07 integra el conocimiento F001/F002/F003 con el agente X06 y lo conecta al transporte Android. La inferencia, el aprendizaje de lecciones, las reglas y la coordinación de programas siguen en XI. Java y Node transportan bytes, comprueban hashes, invocan el runtime y publican archivos.

El currículo inicial contiene 224 conceptos con definición y requisito: 448 hechos. F002 procede de PR45; F003 procede del candidato publicado en PR46, que seguía como borrador al recuperarlo. No se fusionaron esos PR ni otras ramas. El libro se incorporó mediante paráfrasis explícitas con fuente y páginas; no se entrenaron pesos neuronales ni se demostró comprensión autónoma del PDF completo.

El banco admite 512 conceptos. Una enseñanza nueva debe tener este formato UTF-8:

```
Aprende: farol de prueba
Definición: un ejemplo con resultado observable
Requiere: comparar lo esperado con lo observado
Fuente: usuario
Páginas: personal
```

Consultas: `que es farol de prueba`, `que requiere farol de prueba`, `que es farol de prueba y que requiere`, `de dónde sabes farol de prueba` y `@learn status`. Se admiten las variantes de prefijo declaradas en generate.mjs; la búsqueda del concepto es exacta, con normalización ASCII de mayúsculas.

Para corregir, cambia la primera línea a `Corrige lección: farol de prueba` y añade `Revisión: N` antes de Definición. Consulta antes la fuente para conocer N. Una revisión obsoleta y un alta conflictiva conservan la lección anterior. Repetir la misma enseñanza es idempotente. `Olvida lección: farol de prueba` borra esa lección; repetirlo es idempotente.

Límites en bytes: concepto 64, definición 224, requisito 224, fuente 32 y páginas 32; cada campo ocupa una línea. El transporte admite 16384 bytes de entrada y 65536 de salida. Los consumidores antiguos mantienen sus gramáticas de 255 bytes.

Las dos reglas iniciales son ahorro al 10% y reparto 10/20/70. `Aplica ahorro a 1001.05.` y `Aplica reparto a 1001.05.` calculan ejercicios en centavos. `Corrige ahorro revisión N: 37.` y `Corrige reparto revisión N: 50,50,0.` requieren la revisión vigente. El máximo es 10000000.00, con dos decimales; los porcentajes van de 0 a 100 y el reparto suma 100. Se redondea medio centavo hacia arriba; la segunda partida se limita al saldo y la última recibe el resto exacto. No se realizan operaciones financieras.

Ejemplo de ejecución real: `Crea y ejecuta un programa en XI que multiplique 12 por 7.` El anfitrión guarda el despacho autorizado antes de compilar; ejecuta en una memoria aislada y los roles nativos revisan el recibo. `Crea un programa que multiplique 12 por 7` solo genera la fuente. Una tarea con despacho incierto no se vuelve a ejecutar automáticamente.

El empaquetador reubica tres operandos del indicador temporal E029, que coincidía con la cabecera X06, a un byte temporal propiedad de X07. El archivo antiguo limpia ese byte al terminar. Esto permite continuar después de `@ctx` o de una afirmación archivada. La política antigua que puede archivar una declaración ambigua sigue pendiente; el banco nuevo exige enseñanza explícita.

Compilación nativa: `node build.mjs RUNTIME X06_FINAL F003_PAQUETE NUEVA_SALIDA`. Migración sobre copia: `node migrate.mjs RUNTIME X07_FINAL ENTRADA.rvp NUEVA_SALIDA.rvp`. Consulta: `node run.mjs RUNTIME X07_FINAL ENTRADA.rvp NUEVA_SALIDA.rvp --file mensaje.txt`. Los originales se conservan; las migraciones comprueban propiedad de las regiones antes de publicar.

Android usa la misma cápsula y código XI, el JNI original y la firma original de 2.8.1. Conserva archivos ajenos a esta integración y publica memoria e historial juntos. La compilación, firma y pruebas JNI sobre Linux no equivalen a una prueba en teléfono. Consulta PHONE-ACCEPTANCE.txt y el informe de evaluación para las condiciones pendientes.
