# PRISMA 2.4.0 — Discoteca galáctica
Fecha: 2026-11-01

## Alcance implementado
- Seis cabezas móviles mecánicas con bases articuladas, motores de inclinación,
  lentes y colores ópticos independientes de las notas jugables.
- Coreografía determinista según compás/energía: reposo, órbita, persecución,
  abanico, cruces y barrido. Modos «Galaxia viva», «Club orbital» y «Concierto clásico».
- Nebulosas, halos orbitales, neblina, proyecciones al suelo, haces cruzados y polvo
  estelar con límites adaptados a calidad / batería / movimiento reducido.
- Las celebraciones añaden rayos de supernova solo tras hit de combo válido +
  acento musical real; nunca se dispara un temporizador independiente.
- Se repara la demo musical: antes no tenía energía y todos sus compases eran
  silenciosos para el escenario. El audio sintetizado se analiza una vez y alimenta
  la coreografía sin modificar las notas ni la puntuación XI.
- La capa gráfica de lentes en Ether Render X utiliza colores ópticos galácticos
  y sus materiales nativos existentes (metal y lente), sin añadir qubits ni
  modificar el contrato de los 64 objetos RXE.

## Preservación y seguridad
- El gameplay y las notas tienen prioridad en el paquete nativo sobre los
  elementos decorativos; no se reserva una ranura de render para luces.
- Movimiento reducido congela el pan/tilt y apaga rayos de supernova; modo
  batería deja dos cabezas y elimina halos costosos.
- Se limita la energía por foco, sin flashes de pantalla completa ni
  bombardeos estroboscópicos.
- La versión RXE 2.4.0 se publica bajo nueva bandera de instalación y admite
  migrar únicamente el hash exacto del PRISMA 2.3.0 verificado de Actions:
  9332f95a8405d248bd52a13d4669c301c81793aeef3f1d7b20d85ee7374fc543.
  Conserva origen WebView para récords; instalaciones personalizadas o eliminadas
  permanecen intactas.

## Qué es y qué NO es
Las cabezas se representan con los materiales de Ether Render X y los haces,
niebla y reflejos son composiciones Canvas/WebGL de pantalla. No se afirma
trazado volumétrico físico, ray tracing real, audio de latencia nula ni
resultados FPS certificados en un Galaxy físico.

## Pruebas
- node tests/prisma-galactic-stage.mjs
- node tests/prisma-concert-rig.mjs
- node tests/prisma-combo-spectacle.mjs
- node tests/prisma-gameplay-qa.mjs
- GitHub Actions: compilar Android ARM64/x86_64 + ejecutar Android 15 y
  las regresiones de migración, restauración, sonido y materiales.
