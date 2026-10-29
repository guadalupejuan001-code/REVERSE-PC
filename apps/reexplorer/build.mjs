#!/usr/bin/env node
// Transport/packaging only. The entire document stream state machine lives in XI.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
const [runnerArg,destinationArg]=process.argv.slice(2);
if(!runnerArg||!destinationArg)throw Error('usage: node apps/reexplorer/build.mjs REVERSE_NATIVE_CLI OUTPUT');
const runner=path.resolve(runnerArg),destination=path.resolve(destinationArg);
const source=path.resolve('apps/reexplorer/xi/stream-reader.xi');
fs.mkdirSync(destination,{recursive:true});
const app=path.join(destination,'REexplorer-Q-Stream.rxe');
execFileSync(runner,['compile',source,app,'REexplorer Q Stream XI/Ether'],
 {stdio:'inherit',maxBuffer:16*1024*1024});
const inspect=JSON.parse(execFileSync(runner,['inspect-rxe',app],{encoding:'utf8'}));
const sha=crypto.createHash('sha256').update(fs.readFileSync(app)).digest('hex');
const result={product:'REexplorer Q Stream',format:'RXE1',runtime:'XI/Ether',
  binary:path.basename(app),sha256:sha,inspect,
  imported_from_bbyq:false,
  parser:'read-only, deterministic, transactional incremental document text',
  capacity_bytes:1048576,
  chunk_bytes:2048,
  transport:'not yet provided by XI runtime; a separate HTTPS host broker is needed',
  renders_html_css_javascript:false,
  production_browser_ready:false};
fs.writeFileSync(path.join(destination,'build.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result,null,2));
