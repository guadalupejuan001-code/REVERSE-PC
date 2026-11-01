// Run with: node tests/prisma-stage.mjs
// Uses a data: module because the Android RXE assets intentionally remain .js
// without changing the repository-wide Node module type.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const source = readFileSync(new URL('../apps/prisma/web/music-stage.js', import.meta.url));
const { makeMusicStage, musicLevelAt, MusicStageDirector } =
  await import('data:text/javascript;base64,' + source.toString('base64'));

const peaks = Array.from({ length: 24 }, (_, i) => ({
  t: 0.5 + i * 0.25,
  strength: i % 2 === 0 ? 0.98 : 0.2,
}));
const levels = Float32Array.from({ length: 300 }, (_, i) => i < 150 ? 0.08 : 0.8);
const map = makeMusicStage(peaks, { bpm: 120, duration: 7, energy: levels });
assert.equal(map.period, 0.5);
assert.ok(map.accents.length >= 10, 'keep strong musical onsets');
assert.ok(map.accents.every(a => a.major), 'weak interstitial peaks are not main accents');
assert.ok(musicLevelAt(map, 1) < musicLevelAt(map, 5), 'lighting follows real loudness');
const director = new MusicStageDirector(map);
assert.equal(director.armCombo(9, 1), false, 'ordinary combo never arms a stage explosion');
assert.equal(director.step(1).explosion, null);
assert.equal(director.armCombo(10, 1.22), true, 'milestone can schedule an upcoming downbeat');
assert.equal(director.step(1.35).explosion, null, 'do not fire before accent');
let result = director.step(1.51);
assert.equal(result.explosion?.combo, 10, 'release on audio-timeline accent');
assert.equal(result.explosion?.t, 1.5);
assert.equal(director.step(1.54).explosion, null, 'never replay explosion on later frames');
assert.equal(director.armCombo(20, 2.22), true);
director.cancelCombo();
assert.equal(director.step(2.51).explosion, null, 'miss cancels pending celebration');
assert.equal(director.armCombo(30, 3.22), true);
assert.equal(director.step(3.73).explosion, null, 'discard a missed late visual cue');
director.reset(1);
assert.equal(director.step(1.51).explosion, null, 'seek does not replay old events');
const ambient = makeMusicStage(peaks, { bpm: 120, duration: 7, fallback: true });
assert.equal(new MusicStageDirector(ambient).armCombo(10, 1.2), false, 'synthetic ambient grids are not musical evidence');
const empty = makeMusicStage([{ t: Number.NaN, strength: 1 }], { duration: 4 });
assert.equal(empty.accents.length, 0, 'ignore invalid onsets');
assert.equal(new MusicStageDirector(empty).armCombo(10, 1), false, 'no arbitrary effects without accents');
console.log(JSON.stringify({ passed: 14, accents: map.accents.length, musicStage: 'ok' }));
