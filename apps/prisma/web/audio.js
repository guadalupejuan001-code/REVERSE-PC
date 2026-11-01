const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
export const DEMO_BPM = 122;
export const DEMO_DURATION = 132 * 60 / DEMO_BPM;
export function seeded(seed = 1741) { return () => { seed ^= seed << 13; seed ^= seed >>> 17; seed ^= seed << 5; return (seed >>> 0) / 4294967296; }; }
export class RhythmAudio {
  constructor() { this.ctx = null; this.buffer = null; this.source = null; this.running = false; this.offset = 0; this.startedAt = 0; this.volume = .65; this.muted = false; }
  async init() {
    if (!this.ctx) {
      const Audio = window.AudioContext || window.webkitAudioContext;
      if (!Audio) throw new Error('Este navegador no admite el audio del juego. Prueba con Chrome, Safari o Firefox actualizado.');
      this.ctx = new Audio({ latencyHint: 'interactive' });
      this.gain = this.ctx.createGain(); this.gain.gain.value = this.muted ? 0 : this.volume;
      this.analyser = this.ctx.createAnalyser(); this.analyser.fftSize = 256; this.analyser.smoothingTimeConstant = .78;
      this.analyser.connect(this.gain); this.gain.connect(this.ctx.destination);
      this.bins = new Uint8Array(this.analyser.frequencyBinCount);
    }
    if (this.ctx.state !== 'running') await this.ctx.resume();
  }
  setVolume(value, muted = this.muted) { this.volume = value; this.muted = muted; if (this.gain) this.gain.gain.setTargetAtTime(muted ? 0 : value, this.ctx.currentTime, .025); }
  stop() { this.running = false; if (this.source) { try { this.source.stop(); } catch {} this.source.disconnect(); this.source = null; } }
  play(offset = 0, delay = 0) {
    this.stop(); this.offset = offset; this.startedAt = this.ctx.currentTime + delay;
    this.source = this.ctx.createBufferSource(); this.source.buffer = this.buffer; this.source.connect(this.analyser);
    this.source.start(this.startedAt, Math.max(0, offset)); this.running = true;
  }
  time() { return this.running ? this.offset + this.ctx.currentTime - this.startedAt : this.offset; }
  pause() { const t = clamp(this.time(), 0, this.buffer?.duration || 0); this.stop(); this.offset = t; return t; }
  energy() { if (!this.analyser || !this.running) return 0; this.analyser.getByteFrequencyData(this.bins); let sum = 0; for (let i = 1; i < 14; i++) sum += this.bins[i]; return sum / 3315; }
  swish(color = 0) {
    if (!this.ctx || this.ctx.state !== 'running') return;
    if (!this.swishBuffer) {
      const length = Math.round(this.ctx.sampleRate * .065);
      this.swishBuffer = this.ctx.createBuffer(1, length, this.ctx.sampleRate);
      const samples = this.swishBuffer.getChannelData(0);
      for (let i = 0; i < length; i++) samples[i] = (Math.random() * 2 - 1) * Math.sin(Math.PI * i / length) * Math.exp(-i / length * 3);
    }
    const source = this.ctx.createBufferSource(), filter = this.ctx.createBiquadFilter(), gain = this.ctx.createGain();
    source.buffer = this.swishBuffer; filter.type = 'highpass'; filter.frequency.value = color ? 2800 : 1800; gain.gain.value = .11;
    source.connect(filter); filter.connect(gain); gain.connect(this.gain); source.start();
    source.onended = () => { source.disconnect(); filter.disconnect(); gain.disconnect(); };
  }
  async decode(file) {
    await this.init();
    const bytes = await file.arrayBuffer();
    try { return await this.ctx.decodeAudioData(bytes); }
    catch { throw new Error('No se pudo reproducir este archivo. Prueba con un MP3, WAV, M4A u OGG compatible con tu navegador.'); }
  }
  async makeDemo() {
    if (this.demoBuffer) return this.demoBuffer;
    await this.init();
    const sr = 24000, len = Math.ceil(DEMO_DURATION * sr), left = new Float32Array(len), right = new Float32Array(len);
    const rnd = seeded(97431), beat = 60 / DEMO_BPM;
    const add = (time, duration, fn, pan = 0) => {
      const start = Math.round(time * sr), n = Math.min(Math.round(duration * sr), len - start);
      const gl = Math.sqrt((1 - pan) * .5), gr = Math.sqrt((1 + pan) * .5);
      for (let k = 0; k < n; k++) { const v = fn(k / sr, k); left[start + k] += v * gl; right[start + k] += v * gr; }
    };
    const midi = n => 440 * 2 ** ((n - 69) / 12);
    const bass = [33,33,36,33,29,29,31,31], melody = [69,76,72,76,67,74,71,74,65,72,69,72,67,74,71,76];
    for (let b = 0; b < 128; b++) {
      const t = b * beat, bar = Math.floor(b / 4), drop = bar % 16 === 15;
      if (b > 1 && !(drop && b % 4 > 1)) add(t, .55, x => { const phase = 2 * Math.PI * (42 * x + 85 * .028 * (1 - Math.exp(-x / .028))); return Math.sin(phase) * Math.exp(-x * 11) * .73 + (rnd() - .5) * .1 * Math.exp(-x * 150); });
      if (b > 7 && b % 2 === 1 && !drop) add(t, .22, x => ((rnd() * 2 - 1) * .37 + Math.sin(x * 2 * Math.PI * 175) * .13) * Math.exp(-x * 27));
      for (let h = 0; h < 2; h++) add(t + h * beat / 2, h ? .1 : .045, (x,k) => (rnd() * 2 - 1) * (k % 2 ? 1 : -.8) * Math.exp(-x * (h ? 48 : 95)) * (h ? .13 : .10), h ? .38 : -.35);
      const f = midi(bass[Math.floor(b / 4) % bass.length]);
      add(t, beat * .88, x => (Math.sin(2 * Math.PI * f * x) + Math.sin(4 * Math.PI * f * x) * .16 + Math.sin(6 * Math.PI * f * x) * .06) * Math.min(1,x * 200) * Math.exp(-x * 5.5) * .34);
      if (b > 7) {
        for (let h = 0; h < 2; h++) {
          if ((b + h) % 4 === 3) continue;
          const f2 = midi(melody[(b * 2 + h) % melody.length]), p = (b % 2 ? .4 : -.4);
          const tone = x => (Math.sin(2 * Math.PI * f2 * x) + .25 * Math.sin(4 * Math.PI * f2 * x)) * Math.min(1, x * 180) * Math.exp(-x * 11) * .12;
          add(t + h * beat / 2, .65, tone, p);
          add(t + h * beat / 2 + beat * .75, .65, x => tone(x) * .25, -p);
        }
      }
      if (b % 4 === 0) {
        const root = bass[Math.floor(b / 4) % bass.length] + 24;
        for (const interval of [0, 3, 7]) {
          const f3 = midi(root + interval);
          add(t, beat * 4.3, x => (Math.sin(2 * Math.PI * f3 * x) + .45 * Math.sin(2 * Math.PI * f3 * 1.003 * x)) * Math.sin(Math.PI * Math.min(1, x / (beat * 4.3))) * .039, interval === 0 ? -.5 : .5);
        }
      }
      if (b % 32 === 0) await new Promise(resolve => setTimeout(resolve, 0));
    }
    this.demoBuffer = this.ctx.createBuffer(2, len, sr);
    for (let ch = 0; ch < 2; ch++) {
      const dest = this.demoBuffer.getChannelData(ch), src = ch === 0 ? left : right;
      for (let i = 0; i < len; i++) { const fade = Math.min(1, i / (sr * .02), (len - i) / (sr * 2.2)); dest[i] = Math.tanh(src[i] * 1.05) * .85 * Math.max(0, fade); }
    }
    return this.demoBuffer;
  }
}
export function waveformOf(buffer, count = 160) {
  const data = buffer.getChannelData(0), other = buffer.numberOfChannels > 1 ? buffer.getChannelData(1) : data, out = [], stride = Math.max(1, Math.floor(data.length / count));
  for (let i = 0; i < count; i++) { let sum = 0, n = 0; for (let j = i * stride; j < Math.min(data.length, (i + 1) * stride); j += 23) { sum += (data[j] * data[j] + other[j] * other[j]) * .5; n++; } out.push(Math.sqrt(sum / Math.max(n, 1))); }
  const max = Math.max(.001, ...out); return out.map(v => v / max);
}
// Offline spectral analysis lives in a pure, testable module.
export { analyseMusicBuffer as analyseRhythm } from './music-analysis.js';
