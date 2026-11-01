// PRISMA 2.0: pure musical cues. No DOM, GPU, or independent clock.
// Every effect is scheduled against the decoded track's audio timeline.
const clamp = (v, min, max) => Math.max(min, Math.min(max, v));
const numeric = value => typeof value === 'number' && Number.isFinite(value);
const percentile = (ordered, fraction) => {
  if (!ordered.length) return 0;
  const index = clamp(fraction, 0, 1) * (ordered.length - 1);
  const i = Math.floor(index);
  return ordered[i] + ((ordered[Math.min(i + 1, ordered.length - 1)] - ordered[i]) * (index - i));
};
const firstAfter = (events, time) => {
  let low = 0, high = events.length;
  while (low < high) {
    const middle = (low + high) >>> 1;
    if (events[middle].t < time) low = middle + 1;
    else high = middle;
  }
  return low;
};

export function musicLevelAt(map, time) {
  if (!map || !map.energyBins?.length || !numeric(time) || time < 0) return 0;
  return map.energyBins[clamp(Math.floor(time / map.energyStep), 0, map.energyBins.length - 1)];
}

export function makeMusicStage(peaks, { bpm = 120, duration = 60, energy = null, fallback = false, tempoSegments = null } = {}) {
  const safeDuration = numeric(duration) ? clamp(duration, 0.01, 14400) : 60;
  const safeBpm = numeric(bpm) ? clamp(bpm, 40, 260) : 120;
  const period = 60 / safeBpm;
  const samplePeriod = 0.25;
  const length = Math.max(1, Math.ceil(safeDuration / samplePeriod));
  const raw = new Float32Array(length);
  if (energy && typeof energy.length === 'number' && energy.length > 0) {
    for (let i = 0; i < length; i++) {
      const from = Math.floor(i * energy.length / length);
      const to = Math.max(from + 1, Math.floor((i + 1) * energy.length / length));
      let total = 0, samples = 0;
      for (let j = from; j < Math.min(to, energy.length); j++) {
        if (numeric(energy[j])) { total += Math.max(0, energy[j]); samples++; }
      }
      raw[i] = samples ? total / samples : 0;
    }
  }
  const volumeValues = Array.from(raw).sort((a, b) => a - b);
  const reference = Math.max(percentile(volumeValues, 0.90), 1e-5);
  const energyBins = Array.from(raw, value => clamp(value / reference, 0, 1));

  const onsets = (Array.isArray(peaks) ? peaks : [])
    .filter(p => p && numeric(p.t) && p.t >= 0 && p.t < safeDuration && numeric(p.strength))
    .map(p => ({ t: p.t, strength: clamp(p.strength, 0, 1) }))
    .sort((a, b) => a.t - b.t);
  const strengths = onsets.map(p => p.strength).sort((a, b) => a - b);
  const threshold = Math.max(0.12, percentile(strengths, 0.58));
  const majorThreshold = Math.max(0.25, percentile(strengths, 0.78));
  const minimumGap = clamp(period * 0.38, 0.15, 0.32);
  const accents = [];
  for (const onset of onsets) {
    if (onset.strength + 1e-6 < threshold) continue;
    const previous = accents[accents.length - 1];
    if (previous && onset.t - previous.t < minimumGap) {
      if (onset.strength > previous.strength) accents[accents.length - 1] = onset;
    } else {
      accents.push(onset);
    }
  }
  const cleanSegments = (Array.isArray(tempoSegments) ? tempoSegments : [])
    .filter(s => s && numeric(s.t) && numeric(s.bpm) && s.t >= 0 && s.t < safeDuration)
    .map(s => ({ t: s.t, bpm: clamp(s.bpm, 40, 260) }))
    .sort((a, b) => a.t - b.t);
  if (!cleanSegments.length || cleanSegments[0].t > 0) cleanSegments.unshift({ t: 0, bpm: safeBpm });
  const map = { bpm: safeBpm, duration: safeDuration, period, tempoSegments: cleanSegments,
    energyStep: safeDuration / length, energyBins, accents, fallback: !!fallback };
  map.accents = accents.map(p => {
    const major = p.strength + 1e-6 >= majorThreshold;
    const now = musicLevelAt(map, p.t);
    const before = musicLevelAt(map, Math.max(0, p.t - period * 2));
    return { ...p, major, drop: major && now >= 0.65 && now - before >= 0.32 };
  });
  return map;
}

export function musicBpmAt(map, time) {
  const segments = map?.tempoSegments;
  if (!Array.isArray(segments) || !segments.length) return map?.bpm || 120;
  const t = numeric(time) ? time : 0;
  let low = 0, high = segments.length;
  while (low < high) {
    const mid = (low + high) >>> 1;
    if (segments[mid].t <= t) low = mid + 1;
    else high = mid;
  }
  return segments[Math.max(0, low - 1)].bpm;
}

// Sound-derived event to player action, not arbitrary lane RNG.
// Bass: central/lower vertical cuts. Treble transients: alternating side cuts.
// Midrange/melodic energy: connected left-right gestures. Band labels are cues,
// not isolated instruments and not a true melody/pitch transcription.
export function makeIntelligentChart(peaks, level = 'flow', seed = 7721, map = null) {
  if (!Array.isArray(peaks)) return [];
  const spacing = { flow: 0.36, pulse: 0.18, vertigo: 0.13 }[level] || 0.36;
  const minStrength = { flow: 0.32, pulse: 0.19, vertigo: 0.10 }[level] || 0.32;
  const hasDynamics = !!map?.energyBins?.some(e => e > 0.005);
  const chart = [];
  const inputs = peaks.filter(p => p && numeric(p.t) && numeric(p.strength) && p.t >= 0)
    .slice().sort((a, b) => a.t - b.t);
  let previousTime = -Infinity, previousLane = 1;
  let nextPercussionSide = (seed & 1) ? 0 : 2;
  let melodyDirection = (seed & 2) ? 1 : -1;
  let melodicCount = 0;
  for (const p of inputs) {
    const localPeriod = 60 / musicBpmAt(map, p.t);
    const adjustedSpacing = spacing * clamp(Math.sqrt(localPeriod / 0.5), 0.79, 1.26);
    if (p.t - previousTime < adjustedSpacing) continue;
    const energy = hasDynamics ? musicLevelAt(map, p.t) : 0.55;
    const floor = minStrength + (energy < 0.17 ? 0.08 : energy > 0.72 ? -0.065 : 0);
    const source = ['bass', 'percussion', 'melody', 'mixed', 'synthetic'].includes(p.source) ? p.source : 'mixed';
    if (source !== 'synthetic' && p.strength < floor - (source === 'percussion' && level !== 'flow' ? 0.045 : 0)) continue;
    const beat = Math.round(p.t / localPeriod);
    let lane, row, dir, color;
    if (source === 'bass') {
      lane = beat % 4 === 2 ? (seed & 1 ? 0 : 2) : 1;
      row = 1; dir = beat % 2 ? 2 : 0; color = 1;
    } else if (source === 'percussion') {
      lane = nextPercussionSide; nextPercussionSide = 2 - nextPercussionSide;
      row = 0; dir = lane === 0 ? 1 : 3; color = 0;
    } else if (source === 'melody') {
      lane = clamp(previousLane + melodyDirection, 0, 2);
      if (lane === previousLane) { melodyDirection *= -1; lane = clamp(previousLane + melodyDirection, 0, 2); }
      row = melodicCount++ % 2;
      dir = lane > previousLane ? 1 : lane < previousLane ? 3 : row ? 0 : 2;
      color = melodicCount % 2;
    } else {
      lane = (Math.abs(seed % 3) + chart.length) % 3;
      row = chart.length % 2;
      dir = lane > previousLane ? 1 : lane < previousLane ? 3 : row ? 2 : 0;
      color = chart.length % 2;
    }
    const note = { t: p.t, lane, row, color, dir, source,
      accent: p.strength >= 0.75, hit: false, missed: false };
    chart.push(note);
    // A big musical accent can yield a synchronized two-handed cut in Vertigo;
    // both notes are part of the same detected onset, never an artificial beat.
    if (level === 'vertigo' && source !== 'synthetic' && p.strength > 0.82 &&
        energy > 0.58 && beat % 4 === 0 && source !== 'melody') {
      chart.push({ t: p.t, lane: lane === 1 ? (seed & 1 ? 0 : 2) : 2 - lane,
        row: 1 - row, color: 1 - color, dir: (dir + 2) % 4,
        source, accent: true, hit: false, missed: false });
    }
    previousTime = p.t; previousLane = lane;
  }
  return chart.sort((a, b) => a.t - b.t);
}

export class MusicStageDirector {
  constructor(map) { this.map = map; this.reset(0); }
  reset(time = 0) {
    this.lastTime = numeric(time) ? time : 0;
    this.cursor = firstAfter(this.map.accents, this.lastTime + 1e-6);
    this.lastAccent = this.cursor ? this.map.accents[this.cursor - 1] : null;
    this.pending = null;
  }
  cancelCombo() { this.pending = null; }
  armCombo(combo, time) {
    const milestone = combo === 10 || combo === 20 || combo === 30 || combo === 50 || (combo >= 100 && combo % 50 === 0);
    if (!milestone || !numeric(time) || this.map.fallback) return false;
    const horizon = clamp(60 / musicBpmAt(this.map, time) * 1.4, 0.36, 0.85);
    const start = firstAfter(this.map.accents, time - 0.065);
    for (let i = start; i < this.map.accents.length; i++) {
      const accent = this.map.accents[i];
      if (accent.t > time + horizon) break;
      if (accent.major) {
        this.pending = { t: accent.t, combo, strength: accent.strength, drop: accent.drop };
        return true;
      }
    }
    return false;
  }
  step(time) {
    if (!numeric(time)) time = this.lastTime;
    if (time < this.lastTime - 0.06) this.reset(time);
    while (this.cursor < this.map.accents.length && this.map.accents[this.cursor].t <= time + 1e-6) {
      this.lastAccent = this.map.accents[this.cursor++];
    }
    let explosion = null;
    if (this.pending && time >= this.pending.t - 1e-6) {
      // A late frame may be discarded, never converted into a random delayed explosion.
      if (time - this.pending.t <= 0.18) explosion = this.pending;
      this.pending = null;
    }
    this.lastTime = time;
    const delay = this.lastAccent ? time - this.lastAccent.t : Infinity;
    const beat = delay >= 0 && delay <= 0.6 ? this.lastAccent.strength * Math.exp(-delay * 9) : 0;
    const energy = musicLevelAt(this.map, time);
    return { time, beat, energy, period: 60 / musicBpmAt(this.map, time), intensity: clamp(energy * 0.7 + beat * 0.3, 0, 1), explosion };
  }
}
