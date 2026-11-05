# REVERSE Velocity 1.8 — Vista despejada, garaje XI y fotografía 4K

## Problemas observados por el jugador
- Con el rasterizador XI software a 3840 × 2160 activo durante la conducción, el teléfono cae a **1–2 FPS**. Es una medición del dispositivo reportada por el jugador, no una medida de CI.
- El cuadro de instrumentos animado cubre el centro del coche.
- Se necesita cambiar de coche, no solamente de color de pintura.

## Solución implementada
1. **Conducción fluida**: la ruta de conducción ejecuta `render.xi` a 320×180, 480×270 o 640×360 según el perfil Auto/Alta. Mantiene pasos físicos XI a 50 Hz. No se afirma que 4K a 60 FPS esté resuelto.
2. **Foto 4K real**: `Foto 4K` activa exclusivamente `render-native4k.xi` XFB5 de 3840×2160 después de congelar las físicas; un fotograma se publica y `VelocityFrameReuse` lo reutiliza mientras el estado, cámara y coche sean iguales. `Salir 4K` restaura exactamente el estado anterior de pausa o conducción. Cada cambio de cámara o vehículo invalida la imagen congelada y crea otra foto 4K.
3. **HUD despejado**: el panel central de velocímetro/medidores arranca oculto; `HUD libre` / `HUD tablero` lo muestran u ocultan. La velocidad y el rendimiento se muestran en la barra superior; ni la dirección, los pedales ni el centro del coche quedan cubiertos por nuevos botones. El minimapa y el panel se ocultan en foto 4K.
4. **Garaje**: selector nativo Android para tres carrocerías, visibles mediante transformación de vértices en XI antes de rotación y proyección:
   - `AERO X-01`: el modelo deportivo original.
   - `GRAN TURISMO X-02`: perfil un 13% más largo y 4% más estrecho, con techo elevado.
   - `TRACK X-03`: perfil un 8% más corto y 14% más ancho, con techo rebajado.
   El modelo elegido se pasa por entrada efímera XI `203`, tanto al render normal como al modo foto nativa; no sustituye la escena por fotos, no modifica el estado Ether ni usa OpenGL.
5. **Compatibilidad**: se mantienen física XI, rivales, tres vueltas, nitro, salto neumático, sombra, textura, firma de desarrollo y paquete `com.reversepc.velocity`; la nueva versión `18 / 1.8.0-garage-photo-xi` permite actualización desde 1.7 si mantiene la firma.

## Límites expresos
Los tres coches **comparten topología original y física de conducción**, pero sus siluetas se transforman realmente en 3D. No son tres mallas independientes diseñadas desde cero ni tienen motores/masas específicos. El procesamiento del 4K software sigue siendo caro: se evita sacrificar la conducción usándolo únicamente como fotografía, no se crea velocidad de render inexistente.

## Validación exigida
- Tres imágenes distintas XFS1 para los tres vehículos con idéntico estado, cámara y pintura.
- Tres capturas geométricas distintas XFG4 a 3840 × 2160.
- Autenticidad del fotograma XFB5, estado Ether intacto, cámara/garaje y frame reuse seguros.
- Compilar en Android 35; instalar APK firmado, comprobar HUD, garaje, cámara, pintura, Foto 4K y vuelta a conducción.
- No anunciar FPS en Galaxy A16 sin mediciones físicas.
