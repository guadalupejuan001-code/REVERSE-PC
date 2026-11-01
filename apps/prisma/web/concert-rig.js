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
// Six individually addressed, physically anchored moving-head fixtures.
// These are optical stage colors, independent of the two gameplay note colors.
export const GALACTIC_HUES = Object.freeze([
  '#58dcff', '#c58bff', '#ff6ea9', '#67ffe0', '#ffba70', '#8aabff'
]);
const sectionAmplitude = { quiet: .03, groove: .51, build: .72, impact: .89, peak: .79, release: .18 };
const sectionFan = { quiet: 0, groove: .18, build: .37, impact: .80, peak: .60, release: .12 };
const showPatterns = Object.freeze({
  quiet: 'idle', groove: 'orbit', build: 'chase',
  impact: 'fan', peak: 'cross', release: 'sweep'
});
// Beat-space poses, not per-frame physics or random sweeps: pause, seek, replay
// and tempo changes produce the exact same mechanical head directions.
export function concertPose(program, time, cue = {}, { quality = 'auto', reduced = false, style = 'galaxy' } = {}) {
  const t = finite(time) ? Math.max(0, time) : 0;
  const section = concertSection(program, t);
  const sectionType = program.map?.fallback ? 'quiet' : section.kind;
  const beat = clamp(finite(cue.beat) ? cue.beat : 0, 0, 1);
  const energy = clamp(finite(cue.energy) ? cue.energy : section.energy, 0, 1);
  const phase = concertBeat(program, t);
  const barIndex = lowerBound(program.bars, t);
  const mode = ['classic', 'club', 'galaxy'].includes(style) ? style : 'galaxy';
  const show = reduced ? 0 : clamp(finite(cue.show) ? cue.show : 0, 0, 1);
  const pattern = showPatterns[sectionType] || 'orbit';
  const motion = reduced ? 0 : mode === 'classic' ? .38 : mode === 'club' ? 1.13 : 1;
  const amplitude = sectionAmplitude[sectionType] * motion;
  const fan = sectionFan[sectionType] * motion;
  const intensity = reduced ? .07 :
    clamp(.065 + energy * .135 + beat * .055 + show * .09, .045, .29);
  const stations = quality === 'battery'
    ? RIG_STATIONS.filter(station => station.depth === 1) : RIG_STATIONS;
  const fixtures = stations.map(station => {
    const side = station.side, depth = station.depth;
    const offset = depth * 1.08 + (side > 0 ? 1.27 : 0);
    const wave = Math.sin(phase * Math.PI / 4 + offset);
    const chase = Math.sin(phase * Math.PI / 2 - depth * Math.PI / 3 + side * .35);
    const sweep = Math.sin(phase * Math.PI / 4 + (side > 0 ? -.32 : .32));
    const cross = Math.sin(phase * Math.PI / 4 + depth * Math.PI / 2);
    const patternWave = pattern === 'chase' ? chase : pattern === 'sweep' ? sweep :
      pattern === 'cross' ? cross : wave;
    const opening = pattern === 'fan' || pattern === 'cross'
      ? side * fan : pattern === 'idle' ? 0 : -side * fan * .22;
    const pan = reduced ? 0 : clamp(
      patternWave * amplitude + opening + show * side * .09, -1.12, 1.12);
    const tilt = reduced ? 0 : clamp(
      Math.cos(phase * Math.PI / 8 + offset * .82) * amplitude * .60 +
      show * .16 + beat * .065, -.62, .62);
    const base = { x: station.x, y: station.y, z: station.z };
    const elbow = {
      x: station.x - side * .15 + pan * .09,
      y: station.y + .31, z: station.z - .10
    };
    const head = {
      x: station.x - side * .28 + pan * .42,
      y: station.y + .64 + tilt * .32,
      z: station.z - .25
    };
    // Optical endpoints remain outside the central gameplay strike zone.
    const focus = {
      x: side * Math.max(.67, 1.46 + depth * .19 - pan * side * 1.02),
      y: 1.42 + tilt * .47,
      z: Math.max(2.0, station.z - (4.20 + tilt))
    };
    return {
      id: station.id, color: station.color,
      lightColor: GALACTIC_HUES[station.id], base, elbow, head, focus,
      pan, tilt, angle: pan * .86, beamWidth: .28 + (1 + tilt) * .12,
      intensity: intensity * (1 - depth * .09),
      pulse: beat, section: sectionType, pattern
    };
  });
  return {
    time: t, beat: phase, barIndex, energy, section: sectionType,
    pattern, style: mode, quality, reduced, intensity, fixtures
  };
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
