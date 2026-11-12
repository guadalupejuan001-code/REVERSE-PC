'use strict';
/* Real C08 GPU-VIRTUAL camera_indices -> physical WebGL draw + QSSD receipt.
   The driver may be hardware on a phone or SwiftShader on the CI emulator. */
window.ReverseGpuPhysical=(()=>{
  const W=640,H=400,TW=256,TH=256,GW=16,GH=24;
  const COLORS=[0x000000,0x0000aa,0x00aa00,0x00aaaa,0xaa0000,0xaa00aa,0xaa5500,0xaaaaaa,0x555555,0x5555ff,0x55ff55,0x55ffff,0xff5555,0xff55ff,0xffff55,0xffffff];
  const cache=new WeakMap(),pending=new Set();
  let last={status:'idle',glyphs:0,draw_calls:0,pixels:0};
  const errorText=e=>String(e?.message||e);
  function shader(gl,kind,code){
    const s=gl.createShader(kind);if(!s)throw Error('WebGL shader unavailable');
    gl.shaderSource(s,code);gl.compileShader(s);
    if(!gl.getShaderParameter(s,gl.COMPILE_STATUS))throw Error('WebGL compile: '+gl.getShaderInfoLog(s));
    return s;
  }
  function create(canvas){
    const gl=canvas.getContext('webgl',{alpha:false,depth:false,stencil:false,antialias:false,preserveDrawingBuffer:true,powerPreference:'high-performance'});
    if(!gl)throw Error('WebGL no disponible en Android/WebView');
    const v=shader(gl,gl.VERTEX_SHADER,
      'attribute vec2 position;attribute vec2 uv;attribute vec3 color;varying vec2 t;varying vec3 c;'+
      'void main(){gl_Position=vec4(position,0.,1.);t=uv;c=color;}');
    const f=shader(gl,gl.FRAGMENT_SHADER,
      'precision mediump float;uniform sampler2D atlas;varying vec2 t;varying vec3 c;'+
      'void main(){float mask=texture2D(atlas,t).a;if(mask<.28)discard;gl_FragColor=vec4(c,1.);}');
    const program=gl.createProgram();gl.attachShader(program,v);gl.attachShader(program,f);
    gl.linkProgram(program);
    if(!gl.getProgramParameter(program,gl.LINK_STATUS))throw Error('WebGL link: '+gl.getProgramInfoLog(program));
    gl.deleteShader(v);gl.deleteShader(f);
    gl.useProgram(program);
    const atlas=document.createElement('canvas');atlas.width=TW;atlas.height=TH;
    const ctx=atlas.getContext('2d');if(!ctx)throw Error('VGA font atlas unavailable');
    ctx.clearRect(0,0,TW,TH);ctx.font='bold 18px monospace';ctx.fillStyle='white';
    ctx.textBaseline='alphabetic';ctx.textAlign='center';
    for(let code=32;code<128;code++){
      const slot=code-32;
      ctx.fillText(String.fromCharCode(code),(slot%16)*GW+GW/2,Math.floor(slot/16)*GH+GH-4);
    }
    const texture=gl.createTexture();gl.activeTexture(gl.TEXTURE0);gl.bindTexture(gl.TEXTURE_2D,texture);
    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL,true);
    gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE);
    gl.texImage2D(gl.TEXTURE_2D,0,gl.RGBA,gl.RGBA,gl.UNSIGNED_BYTE,atlas);
    const buffer=gl.createBuffer(),elements=gl.createBuffer();
    if(!buffer||!elements)throw Error('WebGL buffer unavailable');
    gl.bindBuffer(gl.ARRAY_BUFFER,buffer);
    for(const [name,count,offset] of [['position',2,0],['uv',2,8],['color',3,16]]){
      const location=gl.getAttribLocation(program,name);if(location<0)throw Error('WebGL attribute '+name);
      gl.enableVertexAttribArray(location);gl.vertexAttribPointer(location,count,gl.FLOAT,false,28,offset);
    }
    gl.uniform1i(gl.getUniformLocation(program,'atlas'),0);
    gl.disable(gl.DEPTH_TEST);gl.disable(gl.CULL_FACE);gl.disable(gl.SCISSOR_TEST);gl.disable(gl.BLEND);
    const item={gl,program,buffer,elements,texture};cache.set(canvas,item);return item;
  }
  function mesh(cells){
    if(!Array.isArray(cells)||cells.length>2000)throw Error('C08 plan exceeds VGA');
    const verts=new Float32Array(cells.length*28),indices=new Uint16Array(cells.length*6);
    let previous=-1;
    for(let i=0;i<cells.length;i++){
      const item=cells[i];
      if(!Array.isArray(item)||item.length!==3)throw Error('Invalid GPU plan entry');
      const [id,code,attribute]=item;
      if(!Number.isInteger(id)||id<=previous||id<0||id>=2000||
         !Number.isInteger(code)||code<33||code>126||
         !Number.isInteger(attribute)||attribute<0||attribute>255)
        throw Error('GPU-VIRTUAL returned noncanonical VGA cell');
      previous=id;
      const x=id%80*8,y=Math.floor(id/80)*16;
      const left=x/W*2-1,right=(x+8)/W*2-1,top=1-y/H*2,bottom=1-(y+16)/H*2;
      const glyph=code-32,c=glyph%16,r=Math.floor(glyph/16);
      const u0=c*GW/TW,u1=(c+1)*GW/TW,v0=1-r*GH/TH,v1=1-(r+1)*GH/TH;
      const rgb=COLORS[attribute&15],red=(rgb>>16&255)/255,green=(rgb>>8&255)/255,blue=(rgb&255)/255;
      const corners=[[left,top,u0,v0],[right,top,u1,v0],[right,bottom,u1,v1],[left,bottom,u0,v1]];
      for(let k=0;k<4;k++)verts.set([corners[k][0],corners[k][1],corners[k][2],corners[k][3],red,green,blue],i*28+k*7);
      indices.set([i*4,i*4+1,i*4+2,i*4,i*4+2,i*4+3],i*6);
    }
    return {verts,indices};
  }
  function status(canvas,message){
    const label=canvas.closest('.window')?.querySelector('[data-reverse-gpu-status]');
    if(label)label.textContent=message;
  }
  function present(report){
    const canvas=document.querySelector('.window [data-reverse-vga-gpu]');
    const gpu=report?.gpu_qssd,plan=gpu?.vga_plan;
    if(!canvas||!plan)return false;
    if(plan.width!==W||plan.height!==H||plan.cols!==80||plan.rows!==25)
      throw Error('VGA dimensions disagree with physical plan');
    if(!Number(gpu.plan_revision))return false; // No initial native VGA plan to draw or acknowledge.
    const serial=Number(gpu.qssd_serial),cells=plan.cells;
    if(!Number.isSafeInteger(serial)||serial<1||!Array.isArray(cells)||
       cells.length!==Number(gpu.camera_candidates)||
       cells.length*6!==Number(gpu.planned_vertex_invocations))
      throw Error('GPU-VIRTUAL selected work does not match actual C08 plan');
    const context=cache.get(canvas)||create(canvas),gl=context.gl;
    if(gl.isContextLost())throw Error('WebGL context lost');
    const {verts,indices}=mesh(cells),started=performance.now();
    gl.viewport(0,0,W,H);gl.clearColor(.015,.026,.04,1);gl.clear(gl.COLOR_BUFFER_BIT);
    gl.useProgram(context.program);
    gl.activeTexture(gl.TEXTURE0);gl.bindTexture(gl.TEXTURE_2D,context.texture);
    gl.bindBuffer(gl.ARRAY_BUFFER,context.buffer);
    gl.bufferData(gl.ARRAY_BUFFER,verts,gl.DYNAMIC_DRAW);
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER,context.elements);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER,indices,gl.DYNAMIC_DRAW);
    const draws=indices.length?1:0;
    if(draws)gl.drawElements(gl.TRIANGLES,indices.length,gl.UNSIGNED_SHORT,0);
    gl.finish();
    if(gl.getError()!==gl.NO_ERROR)throw Error('Physical WebGL submission returned an error');
    const rgba=new Uint8Array(W*H*4);
    gl.readPixels(0,0,W,H,gl.RGBA,gl.UNSIGNED_BYTE,rgba);
    if(gl.getError()!==gl.NO_ERROR)throw Error('GPU framebuffer readback error');
    let count=0;
    for(let i=0;i<rgba.length;i+=4)if(rgba[i]>70||rgba[i+1]>70||rgba[i+2]>70)count++;
    if(cells.length>0&&count===0)throw Error('GPU rendered a blank frame from visible work');
    const ms=performance.now()-started;
    last={status:'submitted',serial,glyphs:cells.length,draw_calls:draws,pixels:count,elapsed_ms:ms,backend:String(gl.getParameter(gl.RENDERER)),qssd_confirmed:!!gpu.submitted_webgl};
    const fallback=canvas.closest('.window')?.querySelector('[data-reverse-vga-fallback]');
    if(fallback)fallback.hidden=true;
    canvas.hidden=false;
    status(canvas,cells.length+' glifos · '+draws+' draw call · '+count+' píxeles · '+ms.toFixed(1)+' ms');
    if(!gpu.submitted_webgl&&!pending.has(serial)&&typeof nativeRequest==='function'){
      pending.add(serial);
      const receipt=[serial,cells.length,draws,count].join(':');
      nativeRequest('fabric',JSON.stringify({action:'gpu_presented',program:receipt}))
        .then(response=>{
          if(response?.gpu_qssd?.submitted_webgl!==true)throw Error('QSSD rechazó presentación WebGL');
          window.reverseFabricReport=response;
          last.qssd_confirmed=true;
          const visible=document.querySelector('.window [data-reverse-vga-gpu]');
          if(visible)status(visible,last.glyphs+' glifos · '+last.draw_calls+' draw WebGL · QSSD confirmado');
        })
        .catch(e=>{
          last.status='qssd-rejected';last.error=errorText(e);
          const visible=document.querySelector('.window [data-reverse-vga-gpu]');
          if(visible)status(visible,'GPU dibujó, pero QSSD rechazó: '+last.error);
        })
        .finally(()=>pending.delete(serial));
    }
    return true;
  }
  function schedule(report){
    requestAnimationFrame(()=>{
      try{present(report);}
      catch(e){
        last={status:'failed',error:errorText(e)};
        const canvas=document.querySelector('.window [data-reverse-vga-gpu]');
        if(canvas){
          canvas.hidden=true;
          const fallback=canvas.closest('.window')?.querySelector('[data-reverse-vga-fallback]');
          if(fallback)fallback.hidden=false;
          status(canvas,'Sin presentación GPU: '+last.error);
        }
      }
    });
  }
  return {present,schedule,status:()=>({...last})};
})();
