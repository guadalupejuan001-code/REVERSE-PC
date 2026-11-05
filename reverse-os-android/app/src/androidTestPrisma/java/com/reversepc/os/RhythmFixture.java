package com.reversepc.os;

/** Known local PCM notes: long tones plus two four-note musical phrases. */
final class RhythmFixture {
    static String playScript(){return """
      (()=>{
        const notes=window.__fixturePulseNotes.map(n=>[n.t,n.dir,0]);
        let i=0;const releases=[],keys=['ArrowUp','ArrowRight','ArrowDown','ArrowLeft'];
        window.__fixtureEvents=[];window.__festivalMaxShells=0;window.__festivalMaxSparks=0;window.__festivalMaxRewards=0;
        window.__playTest=setInterval(()=>{
          const a=__audio,t=a.offset+__clock(a.ctx,performance.now(),true).time-a.when;
          const d=document.getElementById('game').dataset;
          __festivalMaxShells=Math.max(__festivalMaxShells,+d.fireworks||0);__festivalMaxSparks=Math.max(__festivalMaxSparks,+d.fireworkSparks||0);__festivalMaxRewards=Math.max(__festivalMaxRewards,+d.rewardFireworks||0);
          for(const r of releases)if(!r.done&&t>=r.t){document.dispatchEvent(new KeyboardEvent('keyup',{code:r.code,bubbles:true}));r.done=true;}
          // A valid anticipatory key leaves room for CI timer jitter. The game
          // still grades the real output-clock time through its normal input.
          while(i<notes.length&&t>=notes[i][0]-.05){
            const n=notes[i++],code=keys[n[1]];__fixtureEvents.push({actual:t,onset:n[0],code});document.dispatchEvent(new KeyboardEvent('keydown',{code,bubbles:true}));releases.push({code,t:n[0]+(n[2]||.035)});
          }
        },4);return true;
      })()
      """;}
    static String prepareScript(){return """
      (async()=>{
        const [{analyseMusicBuffer},{makeMusicStage},{makeChart,Scene}]=await Promise.all([import(location.origin+'/music-analysis.js'),import(location.origin+'/music-stage.js'),import(location.origin+'/engine.js')]);
        const ctx=new AudioContext(),buffer=await ctx.decodeAudioData(__fixtureBytes.slice(0)),a=await analyseMusicBuffer(buffer);
        const map=makeMusicStage(a.peaks,{bpm:a.bpm,duration:buffer.duration,energy:a.energy,tempoSegments:a.tempoSegments,fallback:a.fallback});map.mechanics=true;
        window.__fixturePulseNotes=makeChart(a.peaks,'pulse',Math.round(buffer.duration*173),map);await ctx.close();
        if(!window.__sceneCaptureInstalled){const render=Scene.prototype.render;Scene.prototype.render=function(t,dt,chart,...rest){window.__testScene=this;window.__testSceneTime=t;return render.call(this,t,dt,chart,...rest)};window.__sceneCaptureInstalled=true;}
        window.__fixtureReady=true;
      })().catch(e=>window.__fixtureError=String(e))
      """;}
    static String uploadScript(){return """
      (()=>{
        const sr=16000,duration=18,b=new ArrayBuffer(44+sr*duration*2),v=new DataView(b);
        const str=(at,s)=>{for(let i=0;i<s.length;i++)v.setUint8(at+i,s.charCodeAt(i));};
        str(0,'RIFF');v.setUint32(4,b.byteLength-8,true);str(8,'WAVE');str(12,'fmt ');
        v.setUint32(16,16,true);v.setUint16(20,1,true);v.setUint16(22,1,true);
        v.setUint32(24,sr,true);v.setUint32(28,sr*2,true);v.setUint16(32,2,true);v.setUint16(34,16,true);
        str(36,'data');v.setUint32(40,b.byteLength-44,true);
        for(const [t,len]of [[1,.95],[4,.12],[4.5,.12],[5,.12],[5.5,.12],[9,.95],[12,.12],[12.5,.12],[13,.12],[13.5,.12],[15,.95]]){
          for(let i=0;i<Math.round(len*sr);i++){
            const x=i/sr,env=Math.min(1,x/.008,(len-x)/.035);
            v.setInt16(44+(Math.round(t*sr)+i)*2,Math.round(.65*Math.sin(2*Math.PI*440*x)*env*32760),true);
          }
        }
        window.__fixtureBytes=b;const files=new DataTransfer();files.items.add(new File([b],'PRISMA-ritmo-prueba.wav',{type:'audio/wav'}));
        const input=document.getElementById('audioFile');input.files=files.files;input.dispatchEvent(new Event('change',{bubbles:true}));return true;
      })()
      """;}
}
