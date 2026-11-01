// PRISMA 2.0 — local, lightweight spectral-cue analysis.
// Three *frequency bands*, not instrument/stem separation or pitch recognition.
// The input is an AudioBuffer; no external services, downloads or microphone.
const clamp = (v, lo, hi) => Math.max(lo, Math.min(hi, v));
const percentile = (values, fraction) => {
  if (!values.length) return 0;
  const sorted = [...values].sort((a, b) => a - b);
  const index = clamp(fraction, 0, 1) * (sorted.length - 1);
  const floor = Math.floor(index);
  return sorted[floor] + (sorted[Math.min(floor + 1, sorted.length - 1)] - sorted[floor]) * (index - floor);
};

export function extractMusicBands(buffer, hopSeconds = 0.02) {
  if (!buffer || !(buffer.sampleRate > 0) || !(buffer.length > 0)) {
    throw new Error('No hay muestras de audio para analizar.');
  }
  const sampleRate = buffer.sampleRate;
  const stride = Math.max(1, Math.floor(sampleRate / 9000));
  const measuredRate = sampleRate / stride;
  const lowAlpha = 1 - Math.exp(-2 * Math.PI * 190 / measuredRate);
  const highAlpha = 1 - Math.exp(-2 * Math.PI * 1700 / measuredRate);
  const hop = Math.max(1, Math.round(sampleRate * hopSeconds));
  const frames = Math.ceil(buffer.length / hop);
  const bass = new Float32Array(frames);
  const mid = new Float32Array(frames);
  const treble = new Float32Array(frames);
  const energy = new Float32Array(frames);
  const left = buffer.getChannelData(0);
  const right = buffer.numberOfChannels > 1 ? buffer.getChannelData(1) : left;
  let lLow = 0, lWide = 0, rLow = 0, rWide = 0;
  for (let frame = 0; frame < frames; frame++) {
    let lowSum = 0, midSum = 0, trebleSum = 0, totalSum = 0, samples = 0;
    for (let sample = frame * hop; sample < Math.min(buffer.length, (frame + 1) * hop); sample += stride) {
      const l = left[sample], r = right[sample];
      lLow += (l - lLow) * lowAlpha; lWide += (l - lWide) * highAlpha;
      rLow += (r - rLow) * lowAlpha; rWide += (r - rWide) * highAlpha;
      const lm = lWide - lLow, rm = rWide - rLow;
      const lh = l - lWide, rh = r - rWide;
      lowSum += (lLow * lLow + rLow * rLow) * 0.5;
      midSum += (lm * lm + rm * rm) * 0.5;
      trebleSum += (lh * lh + rh * rh) * 0.5;
      totalSum += (l * l + r * r) * 0.5;
      samples++;
    }
    const count = Math.max(1, samples);
    bass[frame] = Math.sqrt(lowSum / count);
    mid[frame] = Math.sqrt(midSum / count);
    treble[frame] = Math.sqrt(trebleSum / count);
    energy[frame] = Math.sqrt(totalSum / count);
  }
  return { bass, mid, treble, energy, hopSeconds: hop / sampleRate };
}

export function detectMusicalOnsets(bands, duration) {
  const n = bands.energy.length, hop = bands.hopSeconds;
  const parts = [bands.bass, bands.mid, bands.treble];
  // Shared loudness scale preserves real band balance (a bass tone must not
  // look like equally powerful high-frequency percussion).
  const reference = Math.max(0.000001, percentile(bands.energy, 0.92));
  const flux = parts.map(() => new Float32Array(n));
  const smooth = [0, 0, 0], previous = [0, 0, 0];
  const aggregate = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    for (let band = 0; band < 3; band++) {
      const level = clamp(parts[band][i] / reference, 0, 4);
      const onset = Math.max(0, level - previous[band]) * 0.72 +
                    Math.max(0, level - smooth[band]) * 0.28;
      flux[band][i] = onset;
      previous[band] = level;
      smooth[band] += (level - smooth[band]) * 0.20;
    }
    aggregate[i] = flux[0][i] * 1.1 + flux[1][i] * 0.85 + flux[2][i] * 0.95;
  }
  const maxFlux = Math.max(0, ...aggregate.subarray(0, Math.min(n, 10000)));
  let peakMax = maxFlux;
  for (let i = 10000; i < n; i++) peakMax = Math.max(peakMax, aggregate[i]);
  const rmsReference = Math.max(0.000001, percentile(bands.energy, 0.90));
  const percentileFlux = percentile(aggregate, 0.90);
  const peakStrengthReference = Math.max(0.03, percentile(aggregate, 0.975));
  const rollingWindow = Math.max(3, Math.round(0.60 / hop));
  const minGap = Math.max(2, Math.round(0.115 / hop));
  const candidates = [];
  let rolling = 0;
  for (let i = 1; i < n - 1; i++) {
    rolling += aggregate[i];
    if (i >= rollingWindow) rolling -= aggregate[i - rollingWindow];
    const average = rolling / Math.min(i + 1, rollingWindow);
    const threshold = Math.max(0.012, peakMax * 0.055, percentileFlux * 0.15, average * 1.35);
    if (aggregate[i] <= threshold || aggregate[i] < aggregate[i - 1] ||
        aggregate[i] <= aggregate[i + 1] || bands.energy[i] < rmsReference * 0.018) continue;
    const time = i * hop;
    if (time < 0.12 || time > duration - 0.16) continue;
    const weighted = [flux[0][i] * 1.1, flux[1][i] * 0.85, flux[2][i] * 0.95];
    const total = weighted[0] + weighted[1] + weighted[2] + 1e-9;
    const source = weighted[0] / total > 0.43 ? 'bass' :
      weighted[2] / total > 0.40 ? 'percussion' :
      weighted[1] / total > 0.38 ? 'melody' : 'mixed';
    const p = {
      t: time,
      strength: clamp(aggregate[i] / peakStrengthReference, 0.03, 1),
      source,
      bands: [weighted[0] / total, weighted[1] / total, weighted[2] / total]
    };
    const previousPeak = candidates[candidates.length - 1];
    if (previousPeak && i - previousPeak.index < minGap) {
      if (aggregate[i] > previousPeak.raw) candidates[candidates.length - 1] = { ...p, raw: aggregate[i], index: i };
    } else candidates.push({ ...p, raw: aggregate[i], index: i });
  }
  return candidates.map(({ index, raw, ...event }) => event);
}

// Local periodicity from transient autocorrelation. Confidence is a heuristic,
// not a guarantee: ambiguous half/double-time songs must be tested separately.
export function tempoInWindow(peaks, start, end, previousBpm = 120) {
  const binSeconds = 0.025, n = Math.ceil((end - start) / binSeconds);
  if (n < 180) return null;
  const grid = new Float32Array(n), valid = [];
  for (const p of peaks) if (p.t >= start && p.t < end && p.strength >= 0.23) {
    const index = Math.floor((p.t - start) / binSeconds);
    if (index < 0 || index >= n) continue;
    const amp = Math.sqrt(p.strength);
    grid[index] = Math.max(grid[index], amp);
    if (index > 0) grid[index - 1] = Math.max(grid[index - 1], amp * 0.35);
    if (index + 1 < n) grid[index + 1] = Math.max(grid[index + 1], amp * 0.35);
    valid.push(p);
  }
  if (valid.length < 6) return null;
  let bestBpm = previousBpm, bestScore = -1;
  for (let bpm = 70; bpm <= 185; bpm++) {
    const lag = Math.round(60 / bpm / binSeconds);
    if (2 * lag >= n) continue;
    let first = 0, second = 0, denominator = 0;
    for (let i = lag; i < n; i++) {
      first += grid[i] * grid[i - lag];
      if (i >= 2 * lag) second += grid[i] * grid[i - 2 * lag];
      denominator += grid[i] * grid[i];
    }
    const periodicity = (first + second * 0.22) / Math.max(0.0001, denominator);
    // Favor continuity only for nearly tied tempi; do not lock tempo to 122 BPM.
    const prior = 1 - Math.min(0.035, Math.abs(bpm - previousBpm) / 1200);
    const preferred = (periodicity * prior) - (bpm > 155 ? 0.012 : 0);
    if (preferred > bestScore) { bestScore = preferred; bestBpm = bpm; }
  }
  if (bestScore < 0.095) return null;
  return { bpm: bestBpm, confidence: clamp(bestScore, 0, 1), t: start };
}

export function estimateTempoSegments(peaks, duration, priorBpm = 120) {
  const fallback = Number.isFinite(priorBpm) ? clamp(priorBpm, 70, 185) : 120;
  const qualified = (Array.isArray(peaks) ? peaks : []).filter(p => Number.isFinite(p.t) && Number.isFinite(p.strength));
  if (qualified.length < 6) return { bpm: fallback, segments: [{ t: 0, bpm: fallback, confidence: 0 }], variable: false };
  const whole = tempoInWindow(qualified, 0, Math.min(duration, 180), fallback);
  const globalBpm = whole?.bpm || fallback;
  if (duration < 16) return { bpm: globalBpm, segments: [{ t: 0, bpm: globalBpm, confidence: whole?.confidence || 0 }], variable: false };
  const observations = [];
  for (let start = 0; start + 8 <= duration; start += 5) {
    const local = tempoInWindow(qualified, start, Math.min(duration, start + 12), globalBpm);
    if (local) observations.push({ ...local, t: start });
  }
  if (observations.length < 3) return { bpm: globalBpm, segments: [{ t: 0, bpm: globalBpm, confidence: whole?.confidence || 0 }], variable: false };
  // Median of overlapping windows suppresses isolated octave errors.
  const smoothed = observations.map((o, i) => {
    const neighbors = observations.slice(Math.max(0, i - 1), Math.min(observations.length, i + 2));
    const candidates = neighbors.map(p => p.bpm).sort((a, b) => a - b);
    return { ...o, bpm: candidates[Math.floor(candidates.length / 2)] };
  });
  const segments = [{ t: 0, bpm: smoothed[0].bpm, confidence: smoothed[0].confidence }];
  for (let i = 1; i < smoothed.length; i++) {
    const next = smoothed[i], last = segments[segments.length - 1];
    if (Math.abs(next.bpm - last.bpm) <= 6) continue;
    if (i + 1 >= smoothed.length || Math.abs(smoothed[i + 1].bpm - next.bpm) > 7) continue;
    segments.push({ t: Math.round((next.t + 2.5) * 100) / 100, bpm: next.bpm, confidence: next.confidence });
  }
  return { bpm: segments[0].bpm, segments, variable: segments.some(s => Math.abs(s.bpm - segments[0].bpm) > 6) };
}

export async function analyseMusicBuffer(buffer) {
  const bands = extractMusicBands(buffer);
  await new Promise(resolve => setTimeout(resolve, 0));
  const detected = detectMusicalOnsets(bands, buffer.duration);
  const tempo = estimateTempoSegments(detected, buffer.duration);
  const fallback = detected.length < Math.min(8, buffer.duration / 3);
  const bpm = tempo.bpm;
  const peaks = fallback ? [] : detected;
  if (fallback) for (let t = Math.min(0.75, 60 / bpm); t < buffer.duration - 0.25; t += 60 / bpm) {
    peaks.push({ t, strength: 0.25, source: 'synthetic' });
  }
  return {
    bpm, peaks, fallback, energy: bands.energy,
    tempoSegments: tempo.segments, variableTempo: !fallback && tempo.variable,
    analysisMethod: 'three-band-transient-v2'
  };
}
