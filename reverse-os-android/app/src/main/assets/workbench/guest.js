'use strict';
const guestUi={snapshot:null,busy:false,error:'',output:'',draft:'mem_store 90000 42\nmem_read 90000\n',steps:1000};
function refreshGuestViews(){for(const w of state.windows)if(w.app==='guest')renderWindowContent(w);}
function guestHTML(){
  if(nativeAvailable&&!guestUi.snapshot&&!guestUi.busy&&!guestUi.error)queueMicrotask(()=>guestOperation('guestInspect'));
  const g=guestUi.snapshot?.guest,disabled=guestUi.busy?' disabled':'';
  const row=(name,value)=>'<div class="diagnostic-row"><span>'+esc(name)+'</span><strong>'+esc(value)+'</strong></div>';
  const details=g?'<div class="diagnostic-table">'+row('Estado',g.halted?'Terminado · código '+g.exit_code:'Listo para ejecutar')+
    row('RAM lógica',Number(g.logical_ram_bytes).toLocaleString('es')+' bytes')+row('Programa conservado',g.immutable_image_bytes+' bytes')+
    row('Bytes diferentes',g.delta_overrides+' / '+g.max_delta_overrides)+row('Checkpoint',guestUi.snapshot.snapshot_bytes+' bytes')+
    row('Instrucciones ejecutadas',g.instructions)+row('Posición',g.pc)+'</div>':'<p>Aún no hay un invitado guardado. Crea la prueba o importa un ELF ARM64 estático.</p>';
  return '<div class="programs-layout guest-layout"><span class="eyebrow">REVERSE · ESTADOS MÍNIMOS</span><h2>Invitado ARM64</h2>'+
    '<p class="guest-boundary">Procesador experimental dentro de REVERSE. Ejecuta un subconjunto de ARM64; Android y Wild Rift todavía no arrancan.</p>'+
    '<div class="program-actions"><button class="primary-button" data-guest="demo"'+disabled+'>Crear prueba 6×7</button><button class="secondary-button" data-guest="import"'+disabled+'>Importar ELF</button><button class="secondary-button" data-guest="inspect"'+disabled+'>Consultar</button></div>'+
    '<p class="rxe-status" role="status">'+esc(guestUi.error||(guestUi.busy?'Procesando y guardando el invitado…':nativeAvailable?'La sesión se conserva al cerrar la ventana.':'Abre REVERSE en Android para ejecutar el invitado.'))+'</p>'+details+
    '<p class="guest-note">La RAM vacía se describe con una regla. El programa y sus cambios sí consumen memoria física; la RAM lógica no mide la RAM disponible del teléfono.</p>'+
    '<div class="program-actions"><label>Pasos <input class="guest-steps" type="number" min="1" max="10000" value="'+guestUi.steps+'" aria-label="Pasos del invitado"'+disabled+'></label><button class="primary-button" data-guest="run"'+(guestUi.busy||!g||g.halted?' disabled':'')+'>Ejecutar bloque</button><button class="secondary-button" data-guest="export"'+(guestUi.busy||!g?' disabled':'')+'>Exportar checkpoint</button></div>'+
    '<pre class="rxe-output" aria-label="Salida del invitado">'+esc(guestUi.output||'La salida aparecerá cuando el programa la produzca.')+'</pre>'+
    '<details><summary>XI sobre el delta de memoria</summary><p>XI y RXE conservan las diferencias. En direcciones sin imagen, el delta coincide con el byte; sobre el programa, se combina por XOR.</p><textarea class="guest-source" aria-label="Programa XI del delta" maxlength="65536" spellcheck="false"'+disabled+'>'+esc(guestUi.draft)+'</textarea><button class="secondary-button" data-guest="xi"'+(guestUi.busy||!g?' disabled':'')+'>Aplicar XI</button></details></div>';
}
async function guestOperation(operation,payload=''){
  if(guestUi.busy)return;
  if(!nativeAvailable){guestUi.error='Esta función necesita la aplicación Android.';refreshGuestViews();return;}
  guestUi.busy=true;guestUi.error='';refreshGuestViews();
  try{
    const response=await nativeRequest(operation,payload);guestUi.snapshot=response;
    if(operation==='guestDemo')guestUi.output='';
    if(response.stdout!==undefined||response.stderr!==undefined)guestUi.output=(response.stdout||'')+(response.stderr||'');
    if(response.xi_output!==undefined)guestUi.output=response.xi_output;
  }catch(error){guestUi.error=error.message;}
  finally{guestUi.busy=false;refreshGuestViews();}
}
window.ReverseGuest={imported(response){
  if(response.ok){guestUi.snapshot=response;guestUi.error='';guestUi.output='';}
  else guestUi.error=response.error||'ELF rechazado.';
  refreshGuestViews();
}};
document.addEventListener('input',event=>{
  if(event.target.matches('.guest-source'))guestUi.draft=event.target.value;
  if(event.target.matches('.guest-steps'))guestUi.steps=Math.max(1,Math.min(10000,Number(event.target.value)||1));
});
document.addEventListener('click',event=>{
  const button=event.target.closest('[data-guest]');if(!button||button.disabled)return;
  const action=button.dataset.guest;
  if(action==='demo'||action==='import'){
    if(guestUi.snapshot?.loaded&&!confirm('Esto reemplazará el invitado guardado. Exporta su checkpoint antes si deseas conservarlo. ¿Continuar?'))return;
    if(action==='demo')guestOperation('guestDemo');
    else if(typeof window.ReverseNative?.importGuestElf==='function')window.ReverseNative.importGuestElf();
  }
  if(action==='inspect')guestOperation('guestInspect');
  if(action==='run')guestOperation('guestRun',JSON.stringify({steps:guestUi.steps}));
  if(action==='xi')guestOperation('guestXi',guestUi.draft);
  if(action==='export'&&typeof window.ReverseNative?.exportGuest==='function')window.ReverseNative.exportGuest();
});
