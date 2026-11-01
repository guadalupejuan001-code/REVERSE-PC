// Run: node tests/prisma-music-analysis.mjs
// Spectral cues are heuristics, NOT isolated stems or pitch transcription.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

async function load(path) {
  const text = readFileSync(new URL(path, import.meta.url));
  return import('data:text/javascript;base64,' + text.toString('base64'));
}
const { analyseMusicBuffer, extractMusicBands, detectMusicalOnsets,
  estimateTempoSegments } = await load('../apps/prisma/web/music-analysis.js');
const { makeMusicStage, makeIntelligentChart, MusicStageDirector,
  musicBpmAt } = await load('../apps/prisma/web/music-stage.js');

function fixture({ duration = 34, first = 100, last = 140, changeAt = 15,
                   bass = 75, treble = 2700, midOnly = false, silent = false, stereo = false } = {}) {
  const sampleRate = 8000, samples = new Float32Array(duration * sampleRate);
  const add = (startTime, frequency, level, decay) => {
    const base = Math.floor(startTime * sampleRate);
    for (let i = 0; i < 0.13 * sampleRate; i++) {
      const index = base + i;
      if (index >= samples.length) break;
      const x = i / sampleRate;
      samples[index] += Math.sin(2 * Math.PI * frequency * x) * level * Math.exp(-x * decay);
    }
  };
  if (!silent) {
    for (let t = .3; t < duration - .4; t += 60 / (t < changeAt ? first : last)) {
      if (midOnly) add(t, 440, .7, 42);
      else { add(t, bass, .55, 40); add(t + .2, treble, .3, 70); }
    }
  }
  const channels = stereo ? [samples, Float32Array.from(samples, v => -v)] : [samples];
  return {
    sampleRate, length: samples.length, duration, numberOfChannels: channels.length,
    getChannelData: index => channels[index]
  };
}

let assertions = 0;
const verify = (condition, reason) => { assert.ok(condition, reason); assertions++; };
const mixed = fixture();
const result = await analyseMusicBuffer(mixed);
verify(!result.fallback, 'Percussive song should not become a synthetic grid');
verify(result.analysisMethod === 'three-band-transient-v2', 'Wrong analysis path');
verify(result.peaks.filter(p => p.source === 'bass').length >= 20, 'Missed bass attacks');
verify(result.peaks.filter(p => p.source === 'percussion').length >= 20, 'Missed treble attacks');
verify(result.peaks.every(p => p.t > 0 && p.t < mixed.duration), 'Onset time out of song');
verify(result.variableTempo, 'The two-tempo fixture should expose a change');
verify(result.tempoSegments.length >= 2, 'Need two local tempo windows');
verify(Math.abs(result.tempoSegments[0].bpm - 100) <= 5, 'Wrong early tempo');
verify(Math.abs(result.tempoSegments.at(-1).bpm - 140) <= 5, 'Wrong later tempo');
verify(Math.abs(result.tempoSegments.at(-1).t - 15) <= 5, 'Tempo transition too far away');

const stage = makeMusicStage(result.peaks, {
  bpm: result.bpm, duration: mixed.duration, energy: result.energy,
  tempoSegments: result.tempoSegments, fallback: result.fallback
});
verify(Math.abs(musicBpmAt(stage, 3) - 100) <= 5, 'Stage ignores early tempo');
verify(Math.abs(musicBpmAt(stage, 27) - 140) <= 5, 'Stage ignores later tempo');

const flow = makeIntelligentChart(result.peaks, 'flow', 7721, stage);
const pulse = makeIntelligentChart(result.peaks, 'pulse', 7721, stage);
const vertigo = makeIntelligentChart(result.peaks, 'vertigo', 7721, stage);
verify(flow.length > 20 && flow.length < pulse.length &&
       pulse.length < vertigo.length, 'Difficulties must provide distinct note densities');
verify(pulse.some(p => p.source === 'bass' && p.row === 1), 'Bass must use the lower lane');
verify(pulse.some(p => p.source === 'percussion' && p.row === 0), 'Treble must alternate upper lanes');
verify(pulse.every(p => [0, 1, 2].includes(p.lane) && [0, 1].includes(p.row) &&
       [0, 1, 2, 3].includes(p.dir)), 'Invalid note descriptor');
verify(pulse.every((p, i) => !i || pulse[i - 1].t <= p.t), 'Beatmap out of time order');
verify(pulse.every(p => result.peaks.some(o => o.t === p.t)), 'Artificial, nonmusical note timing');
assert.deepEqual(pulse, makeIntelligentChart(result.peaks, 'pulse', 7721, stage));
assertions++;

const melody = await analyseMusicBuffer(fixture({
  duration: 7, first: 120, last: 120, midOnly: true
}));
verify(melody.peaks.some(p => p.source === 'melody'), 'Midrange notes should give melodic cues');
const melodyMap = makeMusicStage(melody.peaks, { duration: 7, bpm: melody.bpm });
const melodicNotes = makeIntelligentChart(melody.peaks, 'pulse', 12, melodyMap);
verify(melodicNotes.some(n => n.source === 'melody'), 'Melodic gesture missing');

const antiPhase = extractMusicBands(fixture({
  duration: 7, first: 120, last: 120, stereo: true
}));
verify(antiPhase.energy.some(n => n > 0.01), 'Anti-phase stereo should not cancel');
verify(detectMusicalOnsets(antiPhase, 7).length > 5, 'Stereo transient detection failed');

const stable = await analyseMusicBuffer(fixture({
  duration: 15, first: 120, last: 120, changeAt: 40
}));
verify(Math.abs(stable.bpm - 120) <= 5, 'Stable BPM was misidentified');
verify(!stable.variableTempo, 'Stable tempo should not be labeled variable');

const quiet = await analyseMusicBuffer(fixture({ duration: 4, silent: true }));
verify(quiet.fallback && quiet.peaks.every(p => p.source === 'synthetic'), 'Silent audio fallback failed');
const quietMap = makeMusicStage(quiet.peaks, {
  bpm: quiet.bpm, duration: 4, fallback: quiet.fallback
});
verify(new MusicStageDirector(quietMap).armCombo(10, 1) === false,
       'A synthetic beat must not trigger a major explosion');
verify(makeIntelligentChart(quiet.peaks, 'flow', 3, quietMap).length > 0,
       'Fallback should allow a low-intensity practice pattern');
verify(estimateTempoSegments([], 10).variable === false, 'Empty BPM history should be stable');

console.log(JSON.stringify({
  suite: 'prisma-cycle2', passed: assertions, peaks: result.peaks.length,
  difficulty: { flow: flow.length, pulse: pulse.length, vertigo: vertigo.length },
  tempi: result.tempoSegments
}));
