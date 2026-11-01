// PRISMA 2.0 — musical combo celebrations, deterministic and bounded.
// This module NEVER starts its own clock, inspects the microphone, or chooses a
// random explosion time. The only event source is MusicStageDirector's accent.
const clamp = (n, a, b) => Math.max(a, Math.min(b, n));
const finite = n => typeof n === 'number' && Number.isFinite(n);
const GOLDEN_ANGLE = 2.399963229728653;
const TIER = {
  spark:   { life: .46, rings: 1, shards: 8,  gain: .32, size: .32 },
  surge:   { life: .61, rings: 2, shards: 16, gain: .51, size: .46 },
  prism:   { life: .70, rings: 2, shards: 24, gain: .70, size: .56 },
  cascade: { life: .78, rings: 3, shards: 32, gain: .87, size: .66 },
  finale:  { life: .85, rings: 3, shards: 40, gain: 1.0, size: .75 }
};
export const SPECTACLE_MAX_EVENTS = 3;
export function comboTier(combo) {
  if (!Number.isInteger(combo) || combo < 10) return null;
  if (combo >= 100 && combo % 50 === 0) return 'finale';
  if (combo >= 50 && combo % 50 === 0) return 'cascade';
  if (combo === 30) return 'prism';
  if (combo === 20) return 'surge';
  if (combo === 10) return 'spark';
  return null;
}
export function createSpectacleEvent(accent) {
  const tier = comboTier(accent?.combo);
  if (!tier || !finite(accent?.t) || accent.t < 0 ||
      !finite(accent?.strength) || accent.strength < 0 || accent.strength > 1) return null;
  const spec = TIER[tier];
  const strength = clamp(accent.strength * .72 + (accent.drop ? .28 : .08), .10, 1);
  return Object.freeze({
    t: accent.t, combo: accent.combo, tier,
    drop: !!accent.drop, strength, life: spec.life,
    gain: spec.gain * (.60 + strength * .40),
    size: spec.size, rings: spec.rings, shards: spec.shards
  });
}
export function pruneSpectacles(events, t) {
  if (!Array.isArray(events) || !finite(t)) return [];
  return events.filter(e => e && finite(e.t) && finite(e.life) &&
    t >= e.t && t - e.t <= e.life).slice(-SPECTACLE_MAX_EVENTS);
}
export function spectacleEnvelope(events, time, reduced = false) {
  if (!finite(time)) return 0;
  let highest = 0;
  for (const e of events || []) {
    if (!e || !finite(e.t) || !finite(e.life)) continue;
    const age = time - e.t;
    if (age < 0 || age > e.life) continue;
    const fade = Math.pow(1 - age / e.life, 1.6);
    highest = Math.max(highest, fade * e.gain);
  }
  return clamp(highest * (reduced ? .12 : 1), 0, 1);
}

// Viewport-independent geometry; each fragment derives only from the note combo
// and exact audio time. No Math.random, timers or variable frame-step integration.
export function spectacleGeometry(event, time, { reduced = false, battery = false } = {}) {
  if (!event || !finite(time)) return null;
  const age = time - event.t;
  if (age < 0 || age > event.life) return null;
  const phase = clamp(age / event.life, 0, 1);
  const opacity = Math.pow(1 - phase, 1.35) * (reduced ? .18 : .85) * event.gain;
  const maxRings = reduced || battery ? 1 : event.rings;
  const maxShards = reduced ? 0 : battery ? Math.min(8,event.shards) : event.shards;
  const rings = [];
  for (let i = 0; i < maxRings; i++) {
    const stagger = i * .12, progress = clamp((phase-stagger) / (1-stagger), 0, 1);
    if (phase < stagger) continue;
    rings.push({
      radius: (0.08 + progress * event.size) * (1 + i * .17),
      alpha: clamp(opacity * (1 - i * .18) * (1 - progress * .45), 0, 1),
      width: reduced ? 1.3 : 2.2 + (1 - progress) * 2.4
    });
  }
  const shards = [];
  for (let i = 0; i < maxShards; i++) {
    const angle = i * GOLDEN_ANGLE + event.combo * .137;
    const drift = (i % 5) / 5;
    const radius = (0.06 + phase * (.25 + drift * .45)) * event.size;
    const spin = phase * ((i % 2) ? -.31 : .31);
    shards.push({
      x: Math.cos(angle) * radius, y: Math.sin(angle) * radius,
      angle: angle + spin, length: (.016 + ((i * 17) % 7) * .005) * (1 - phase * .45),
      alpha: opacity * (0.35 + ((i * 11) % 6) / 10),
      width: .008 + (i % 3) * .004
    });
  }
  return { tier: event.tier, combo: event.combo, drop: event.drop,
    age, phase, opacity, rings, shards, size: event.size };
}
