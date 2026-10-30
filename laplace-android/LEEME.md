# LAPLACE en REVERSE — M001 + XN01

## Arquitectura empaquetada

LAPLACE queda dentro de la APK de REVERSE con dos rutas explícitas:

- **BTC/USD · M001:** mantiene el candidato multihorizonte existente (15m, 30m, 1h, 4h, 24h y 7d).
- **Bolsa · XN01:** SPY, AAPL y NVDA calculan la dirección del siguiente intervalo cerrado de 5 minutos en la **XI Machine de REVERSE sobre NativeRuntime/InverseMemory**.

La ruta bursátil es:

```
serie pública OHLCV
      ↓
LaplaceActivity / LaplaceXiCompiler
(validación, continuidad, serialización a bytes)
      ↓
x001-native.xi
(estado 4 bits + aprendizaje de conteos + probabilidad + dirección)
      ↓
NativeRuntime.initialize + NativeRuntime.execute
      ↓
InverseMemory / salida JSONL de registros
      ↓
interfaz Laplace
```

JavaScript **no calcula SUBIDA/BAJADA**. `x001.mjs` normaliza la respuesta bursátil y conserva evidencia histórica del experimento anterior; la decisión viva procede del programa `x001-native.xi`.

XN01 usa cuatro propiedades enteras calculadas dentro de XI:

1. cierre de 5 minutos no menor al anterior;
2. cierre actual no menor al de 15 minutos antes;
3. movimiento absoluto de 5 minutos mayor que la media absoluta de 30 minutos;
4. volumen actual mayor que la media de 30 minutos.

Los precios se transportan a XI en centavos enteros y el volumen como entero uint32. Las pausas de mercado se marcan como límites de continuidad y no se aprenden como transiciones de cinco minutos.

## Aislamiento

XN01 ejecuta un estado nativo aislado creado con `NativeRuntime.initialize()`. No modifica el checkpoint `session.rvp` del escritorio REVERSE. La memoria usada durante el cálculo sigue siendo la InverseMemory real del runtime.

## Interfaz

La interfaz incluye selector BTC/SPY/AAPL/NVDA, navegación inferior en móvil, Resumen/Datos/Flujo/Registro, gráficos temporales y manejo acotado de HTTP 429/502/503. Una acción bursátil muestra dirección, confianza interna, soporte, prior, máscara y estado de los cuatro bits; no inventa un precio futuro.

## Pruebas obligatorias

La integración no debe fusionarse ni compilarse como próxima APK si fallan:

- contrato SHA-256 de recursos;
- paridad M001;
- adaptador bursátil sin predictor JavaScript;
- ejecución de `x001-native.xi` en el `reverse_pc` real y coincidencia con referencia independiente;
- compilación Java/Android del puente;
- navegación Chrome en escritorio, vertical y horizontal;
- prueba Android 15 que ejecuta XN01 mediante JNI y verifica que el checkpoint principal queda intacto.

El contrato está en `laplace-android/integration-lock.json` y `NEXT_APK_LAPLACE.json`.
