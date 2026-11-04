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

// Hann-windowed FFT, stereo power and positive spectral flux. The analysis
// keeps real onset times; BPM never snaps a cut away from its audible attack.
function fft(real,imag){
  const n=real.length;
  for(let i=1,j=0;i<n;i++){
    let bit=n>>1;for(;j&bit;bit>>=1)j^=bit;j^=bit;
    if(i<j){[real[i],real[j]]=[real[j],real[i]];[imag[i],imag[j]]=[imag[j],imag[i]];}
  }
  for(let width=2;width<=n;width*=2){
    const angle=-2*Math.PI/width,wr=Math.cos(angle),wi=Math.sin(angle);
    for(let from=0;from<n;from+=width){
      let ar=1,ai=0;
      for(let j=0;j<width/2;j++){
        const a=from+j,b=a+width/2,tr=ar*real[b]-ai*imag[b],ti=ar*imag[b]+ai*real[b];
        real[b]=real[a]-tr;imag[b]=imag[a]-ti;real[a]+=tr;imag[a]+=ti;
        const next=ar*wr-ai*wi;ai=ar*wi+ai*wr;ar=next;
      }
    }
  }
}
function* spectralFrames(buffer,hopSeconds=.01){
  if(!buffer||!(buffer.sampleRate>0)||!(buffer.length>0))throw new Error('No hay muestras de audio para analizar.');
  const sr=buffer.sampleRate,hop=Math.max(1,Math.round(sr*hopSeconds)),frames=Math.ceil(buffer.length/hop);
  let n=256;while(n<sr*.0213&&n<4096)n*=2;
  const bass=new Float32Array(frames),mid=new Float32Array(frames),treble=new Float32Array(frames),energy=new Float32Array(frames);
  const fluxBass=new Float32Array(frames),fluxMid=new Float32Array(frames),fluxTreble=new Float32Array(frames);
  const result={bass,mid,treble,energy,fluxBass,fluxMid,fluxTreble,hopSeconds:hop/sr};
  const bands=[bass,mid,treble],flux=[fluxBass,fluxMid,fluxTreble];
  const re=new Float64Array(n),im=new Float64Array(n),power=new Float64Array(n/2),previous=new Float64Array(n/2);
  const window=Float64Array.from({length:n},(_,i)=>.5-.5*Math.cos(2*Math.PI*i/(n-1)));
  const channels=Array.from({length:Math.min(2,buffer.numberOfChannels||1)},(_,i)=>buffer.getChannelData(i));
  for(let f=0;f<frames;f++){
    power.fill(0);let rms=0,count=0;
    for(const samples of channels){
      for(let k=f*hop;k<Math.min(samples.length,(f+1)*hop);k++){rms+=samples[k]**2;count++;}
      const start=f*hop-(n>>1);
      for(let k=0;k<n;k++)re[k]=(samples[start+k]||0)*window[k];
      im.fill(0);fft(re,im);
      for(let k=1;k<n/2;k++)power[k]+=(re[k]**2+im[k]**2)/channels.length;
    }
    energy[f]=Math.sqrt(rms/Math.max(1,count));
    const sum=[0,0,0],change=[0,0,0];
    for(let k=1;k<n/2;k++){
      const hz=k*sr/n,band=hz<190?0:hz<1700?1:2,magnitude=Math.sqrt(power[k])*2/n;
      sum[band]+=magnitude*magnitude;
      change[band]+=Math.max(0,magnitude-previous[k])**2;previous[k]=magnitude;
    }
    for(let b=0;b<3;b++){bands[b][f]=Math.sqrt(sum[b]);flux[b][f]=Math.sqrt(change[b]);}
    if(f%128===127)yield;
  }
  return result;
}
export function extractMusicBands(buffer,hopSeconds=.01){
  const frames=spectralFrames(buffer,hopSeconds);let next;
  do{next=frames.next();}while(!next.done);
  return next.value;
}

export function detectMusicalOnsets(bands, duration) {
  const n = bands.energy.length, hop = bands.hopSeconds;
  const parts = [bands.bass, bands.mid, bands.treble];
  const spectral = [bands.fluxBass, bands.fluxMid, bands.fluxTreble];
  // Shared loudness scale preserves real band balance (a bass tone must not
  // look like equally powerful high-frequency percussion).
  const activeEnergy=Array.from(bands.energy).filter(v=>v>1e-7);
  const reference = Math.max(0.000001, percentile(activeEnergy, 0.92));
  const flux = parts.map(() => new Float32Array(n));
  const smooth = [0, 0, 0], previous = [0, 0, 0];
  const aggregate = new Float32Array(n);
  let localEnergy=reference;
  for (let i = 0; i < n; i++) {
    localEnergy+=(bands.energy[i]-localEnergy)*.035;
    const adaptiveReference=Math.max(reference*.045,localEnergy*.7+reference*.15);
    for (let band = 0; band < 3; band++) {
      const level = clamp(parts[band][i] / reference, 0, 4);
      const onset = spectral[band]
        ? spectral[band][i]/adaptiveReference
        : Math.max(0, level - previous[band]) * 0.72 + Math.max(0, level - smooth[band]) * 0.28;
      flux[band][i] = onset;
      previous[band] = level;
      smooth[band] += (level - smooth[band]) * 0.20;
    }
    aggregate[i] = flux[0][i] * 1.1 + flux[1][i] * 0.85 + flux[2][i] * 0.95;
  }
  const maxFlux = Math.max(0, ...aggregate.subarray(0, Math.min(n, 10000)));
  let peakMax = maxFlux;
  for (let i = 10000; i < n; i++) peakMax = Math.max(peakMax, aggregate[i]);
  const rmsReference = Math.max(0.000001, percentile(activeEnergy, 0.90));
  const percentileFlux = percentile(aggregate, 0.90);
  const peakStrengthReference = Math.max(0.03, percentile(aggregate, 0.975));
  const rollingWindow = Math.max(3, Math.round(0.60 / hop));
  const minGap = Math.max(2, Math.round(0.080 / hop));
  const candidates = [];
  let rolling = 0;
  for (let i = 1; i < n - 1; i++) {
    rolling += aggregate[i];
    if (i >= rollingWindow) rolling -= aggregate[i - rollingWindow];
    const average = rolling / Math.min(i + 1, rollingWindow);
    const threshold = Math.max(0.012, peakMax * 0.055, percentileFlux * 0.15, average * 1.35);
    if (aggregate[i] <= threshold || aggregate[i] < aggregate[i - 1] ||
        aggregate[i] <= aggregate[i + 1] || Math.max(bands.energy[i],bands.energy[i+1]||0,bands.energy[i+2]||0) < rmsReference * 0.003) continue;
    const time = (i + 1.5) * hop;
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
    const lag = 60 / bpm / binSeconds;
    if (2 * lag >= n) continue;
    let first = 0, second = 0, denominator = 0;
    for (let i = Math.ceil(lag); i < n; i++) {
      const at=i-lag,lo=Math.floor(at),mix=at-lo;
      first += grid[i] * (grid[lo]*(1-mix)+(grid[lo+1]||0)*mix);
      if (i >= 2 * lag) { const at2=i-2*lag,l2=Math.floor(at2),m2=at2-l2;second += grid[i]*(grid[l2]*(1-m2)+(grid[l2+1]||0)*m2); }
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
  const qualified = (Array.isArray(peaks) ? peaks : []).filter(p => Number.isFinite(p.t) && Number.isFinite(p.strength))
    .sort((a,b)=>a.t-b.t);
  if (qualified.length < 6) return { bpm: fallback, segments: [{ t: 0, bpm: fallback, confidence: 0 }], variable: false };
  const whole = tempoInWindow(qualified, 0, Math.min(duration, 180), fallback);
  const globalBpm = whole?.bpm || fallback;
  if (duration < 16) return { bpm: globalBpm, segments: [{ t: 0, bpm: globalBpm, confidence: whole?.confidence || 0 }], variable: false };
  // All onsets are ordered. Slide two indices through the song instead of
  // rescanning EVERY onset for EACH overlapping 12-second tempo window.
  // This preserves the exact periodicity calculation for each local window.
  const observations = [];
  let left = 0, right = 0;
  for (let start = 0; start + 8 <= duration; start += 5) {
    const end = Math.min(duration, start + 12);
    while (left < qualified.length && qualified[left].t < start) left++;
    if (right < left) right = left;
    while (right < qualified.length && qualified[right].t < end) right++;
    const local = tempoInWindow(qualified.slice(left, right), start, end, globalBpm);
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
  const frames=spectralFrames(buffer);let next;
  do{next=frames.next();if(!next.done)await new Promise(resolve=>setTimeout(resolve,0));}while(!next.done);
  const bands=next.value;
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
    analysisMethod: 'stereo-spectral-flux-v3'
  };
}
