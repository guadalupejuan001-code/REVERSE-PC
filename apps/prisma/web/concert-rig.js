// PRISMA 2.0 — kinetic concert-stage choreography.
// Deterministic: input is the decoded song's energy/tempo map + audio clock.
// All six light-heads and their joints share one scene-space contract.
// "Beams" are screen-space stage lighting, not native volumetric photons.
const clamp = (v, low, high) => Math.max(low, Math.min(high, v));
const finite = n => typeof n === 'number' && Number.isFinite(n);
export const RIG_MAX_CUBOIDS = 64;
export const RIG_STATIONS = Object.freeze(
  [-1, 1].flatMap((side, row) => [0, 1, 2].map((depth, index) => Object.freeze({
    id: row * 3 + index, side, depth, x: side * 3.23, y: -2.42 + (depth % 2) * 0.08,
    z: 6.8 + depth * 7.5, color: row
  })))
);

function energyAt(map, time) {
  if (!map?.energyBins?.length || !finite(time) || time < 0) return 0;
  const step = map.energyStep > 0 ? map.energyStep : .25;
  return clamp(map.energyBins[clamp(Math.floor(time / step), 0, map.energyBins.length - 1)] || 0, 0, 1);
}
function bpmAt(map, time) {
  const segments = map?.tempoSegments;
  if (!segments?.length) return clamp(map?.bpm || 122, 40, 260);
  let low = 0, high = segments.length;
  while (low < high) {
    const middle = (low + high) >>> 1;
    if (segments[middle].t <= time) low = middle + 1;
    else high = middle;
  }
  return clamp(segments[Math.max(0, low - 1)].bpm, 40, 260);
}
const lowerBound = (values, time, field = 't') => {
  let left = 0, right = values.length;
  while (left < right) {
    const mid = (left + right) >>> 1;
    if (values[mid][field] <= time) left = mid + 1;
    else right = mid;
  }
  return Math.max(0, left - 1);
};
export function makeConcertProgram(map) {
  const defaultBpm = finite(map?.bpm) ? clamp(map.bpm, 40, 260) : 122;
  const segments = (Array.isArray(map?.tempoSegments) ? map.tempoSegments : [])
    .filter(s => s && finite(s.t) && s.t >= 0 && finite(s.bpm) && s.bpm > 0)
    .slice().sort((a, b) => a.t - b.t);
  if (!segments.length || segments[0].t > 0) segments.unshift({ t: 0, bpm: defaultBpm });
  const tempo = [];
  for (const s of segments) {
    const prev = tempo[tempo.length - 1];
    const beats = prev ? prev.beats + (s.t - prev.t) * prev.bpm / 60 : 0;
    // Repeated timestamps are harmless, and the last declaration wins.
    if (prev && s.t === prev.t) tempo.pop();
    tempo.push({ t: s.t, bpm: clamp(s.bpm, 40, 260), beats });
  }
  const duration = clamp(finite(map?.duration) ? map.duration : 60, .01, 14400);
  const bars = [];
  if (map?.fallback) {
    bars.push({ t: 0, end: duration, kind: 'quiet', energy: 0, delta: 0 });
  } else if (!map?.energyBins?.length) {
    bars.push({ t: 0, end: duration, kind: 'groove', energy: .32, delta: 0 });
  } else {
    let time = 0, prevEnergy = energyAt(map, 0);
    while (time < duration && bars.length < 15000) {
      const next = Math.min(duration, time + 4 * 60 / bpmAt(map, time));
      if (next <= time) break;
      const width = next - time;
      const measured = (
        energyAt(map, time + width * .12) +
        energyAt(map, time + width * .37) +
        energyAt(map, time + width * .63) +
        energyAt(map, time + width * .88)
      ) * .25;
      const delta = measured - prevEnergy;
      const kind = measured < .19 ? 'quiet' :
        measured > .72 && delta > .17 ? 'impact' :
        measured > .75 ? 'peak' :
        delta > .16 ? 'build' :
        delta < -.19 ? 'release' : 'groove';
      bars.push({ t: time, end: next, kind, energy: measured, delta });
      prevEnergy = measured; time = next;
    }
  }
  return { map: map || null, bars, tempo, duration };
}
export function concertBeat(program, time) {
  const t = finite(time) ? Math.max(0, time) : 0;
  const segment = program.tempo[lowerBound(program.tempo, t)];
  return segment.beats + (t - segment.t) * segment.bpm / 60;
}
export function concertSection(program, time) {
  return program.bars[lowerBound(program.bars, Math.max(0, time))] ||
    { t: 0, end: 60, kind: 'groove', energy: .3, delta: 0 };
}
const sectionAmplitude = { quiet: .045, groove: .23, build: .40, impact: .55, peak: .49, release: .13 };
const sectionFan = { quiet: 0, groove: .25, build: .52, impact: .76, peak: .60, release: .08 };

export function concertPose(program, time, cue = {}, { quality = 'auto', reduced = false } = {}) {
  const t = finite(time) ? Math.max(0, time) : 0;
  const section = concertSection(program, t);
  const beat = clamp(finite(cue.beat) ? cue.beat : 0, 0, 1);
  const energy = clamp(finite(cue.energy) ? cue.energy : section.energy, 0, 1);
  const phase = concertBeat(program, t);
  const sectionType = program.map?.fallback ? 'quiet' : section.kind;
  // Only a musically released combo accent supplies show energy. The safety
  // clamp prevents a gameplay milestone from creating a blinding stage wash.
  const show = reduced ? 0 : clamp(finite(cue.show) ? cue.show : 0, 0, 1);
  const amplitude = reduced ? 0 : sectionAmplitude[sectionType] + show * .09;
  const fan = reduced ? 0 : Math.min(.80, sectionFan[sectionType] + show * .15);
  const intensity = reduced ? .07 : clamp(.06 + energy * .12 + beat * .095 + show * .085, .04, .29);
  // Two fixtures remain in battery mode, one on each side. Other modes
  // retain the entire six-head stage; high quality adds a third body per arm.
  const stations = quality === 'battery' ? RIG_STATIONS.filter(s => s.depth === 1) : RIG_STATIONS;
  const fixtures = stations.map(station => {
    const side = station.side;
    const offset = station.depth * 1.1 + (side > 0 ? 1.1 : 0);
    const wave = Math.sin(phase * Math.PI / 4 + offset);
    const opening = (sectionType === 'impact' || sectionType === 'peak') ? side * fan : -side * fan * .34;
    const horizontal = clamp(wave * amplitude + opening, -.88, .88);
    const vertical = Math.cos(phase * Math.PI / 8 + offset * .7) * amplitude * .25;
    const base = { x: station.x, y: station.y, z: station.z };
    const elbow = {
      x: station.x - side * .15 + horizontal * .16,
      y: station.y + .32,
      z: station.z - .10
    };
    const head = {
      x: station.x - side * .28 + horizontal * .39,
      y: station.y + .60 + vertical,
      z: station.z - .25
    };
    const focus = {
      x: side * (1.55 + .27 * station.depth) - horizontal * 1.14,
      y: 1.30 + vertical * 1.35,
      z: Math.max(2.0, station.z - 4.0)
    };
    return {
      id: station.id, color: station.color, base, elbow, head, focus,
      angle: horizontal * .86, intensity: intensity * (1 - station.depth * .12),
      pulse: beat, section: sectionType
    };
  });
  return { time: t, beat: phase, energy, section: sectionType,
    quality, reduced, intensity, fixtures };
}

export function concertNativeParts(pose, available = RIG_MAX_CUBOIDS) {
  const budget = Math.max(0, Math.min(RIG_MAX_CUBOIDS, Math.floor(available)));
  const parts = [], heads = pose.fixtures;
  const push = (part, f) => {
    if (parts.length >= budget) return;
    const point = f[part];
    const isHead = part === 'head';
    parts.push({
      kind: part, id: f.id, x: point.x, y: point.y, z: point.z,
      size: part === 'base' ? .28 : part === 'elbow' ? .23 : .38,
      color: part === 'head' ? f.color : -1,
      alpha: isHead ? clamp(.50 + f.intensity * 1.5, 0, .95) : .88,
      rotation: isHead ? f.angle : 0,
      direction: -1, hot: isHead && !pose.reduced && f.pulse > .56
    });
  };
  // Head-first means a full packet drops decoration, NEVER gameplay notes.
  for (const f of heads) push('head', f);
  if (pose.quality !== 'battery') for (const f of heads) push('base', f);
  if (pose.quality === 'high') for (const f of heads) push('elbow', f);
  return parts;
}
