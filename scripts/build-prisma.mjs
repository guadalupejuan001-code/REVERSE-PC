#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {execFileSync} from 'node:child_process';
import crypto from 'node:crypto';
const [runtimeArg,outArg,sourceArg]=process.argv.slice(2);
if(!runtimeArg||!outArg)throw Error('Usage: node scripts/build-prisma.mjs RUNTIME OUTPUT_DIR [SOURCE_SHA]');
const runtime=path.resolve(runtimeArg),out=path.resolve(outArg),root=path.resolve(import.meta.dirname,'..');
const source=sourceArg||execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim();
if(!/^[0-9a-f]{40}$/.test(source))throw Error('A verified source SHA is required');
fs.mkdirSync(out,{recursive:true});
const run=args=>execFileSync(runtime,args,{cwd:root,encoding:'utf8'}).trim();
const code=path.join(out,'prisma-code.rxe'),seed=path.join(out,'prisma-seed.rvp'),image=path.join(out,'PRISMA.rxe');
for(const file of [code,seed,image])if(fs.existsSync(file))throw Error('Preserve the previous build; choose an empty output directory');
run(['compile','apps/prisma/game.xi',code,'PRISMA — reglas XI']);run(['init',seed]);
const metadata=JSON.parse(run(['pack-graphics',code,seed,'apps/prisma/web',image,'org.reverse.prisma','PRISMA — Rhythm Cut','2.4.0',source]));
const manifest={...metadata,sha256:crypto.createHash('sha256').update(fs.readFileSync(image)).digest('hex'),web_assets:{}};
for(const file of fs.readdirSync(path.join(root,'apps/prisma/web')).sort())manifest.web_assets[file]=crypto.createHash('sha256').update(fs.readFileSync(path.join(root,'apps/prisma/web',file))).digest('hex');
fs.writeFileSync(path.join(out,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');console.log(JSON.stringify(manifest));
