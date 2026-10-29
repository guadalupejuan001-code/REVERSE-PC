'use strict';
// REexplorer is a launcher and address bar only. Remote HTML NEVER enters the
// privileged reverse.local Workbench WebView or its BBY Q JavaScript bridge.
function reexplorerHTML(){
  return '<section class="reexplorer-shell">'+
    '<div class="reexplorer-heading"><div class="reexplorer-emblem">'+icon('globe')+
    '</div><div><h2>REexplorer</h2>'+
    '<p>El navegador de REVERSE · protección de sesión separada</p></div></div>'+
    '<form class="reexplorer-form" data-reexplorer-form>'+
      '<label for="reexplorer-address">Dirección HTTPS</label>'+
      '<div class="reexplorer-address-row"><input id="reexplorer-address" name="url" '+
        'type="text" inputmode="url" maxlength="2048" value="https://robinhood.com/" '+
        'spellcheck="false" autocomplete="off" autocapitalize="off" '+
        'aria-label="Dirección HTTPS para REexplorer">'+
        '<button class="primary-button" type="submit">'+icon('globe')+' Abrir</button></div>'+
    '</form>'+
    '<div class="reexplorer-quick"><button type="button" class="secondary-button" data-reexplorer-robinhood>'+
    'Robinhood oficial</button><span>HTTPS obligatorio · sin puentes web a XI</span></div>'+
    '<div class="reexplorer-protection">'+
      '<p>'+icon('lock')+' <strong>Ether Guard — aislamiento</strong></p>'+
      '<div class="reexplorer-security-grid">'+
      '<span>Proceso de navegación independiente</span>'+
      '<span>Cookies separadas del escritorio</span>'+
      '<span>Certificados TLS obligatorios</span>'+
      '<span>Sin cámara, micrófono o archivos</span>'+
      '<span>Sin lectura de la sesión por BBY Q</span>'+
      '<span>Navegación segura del proveedor Android</span>'+
      '</div>'+
      '<small>El contenido se procesa mediante Android WebView actualizado, no mediante un motor HTML creado desde cero. '+
      'El aislamiento reduce riesgos; no garantiza protección absoluta.</small>'+
    '</div><p class="reexplorer-status" role="status" data-reexplorer-status>Listo para abrir una sesión privada del escritorio.</p>'+
    '</section>';
}
async function openReexplorerFromDesktop(form,url){
  const box=form.closest('.reexplorer-shell');
  const status=box?.querySelector('[data-reexplorer-status]');
  const controls=form.querySelectorAll('button,input');
  const value=String(url??'').trim();
  if(value.length<4||value.length>2048){if(status)status.textContent='Dirección fuera de los límites.';return;}
  if(!nativeAvailable){
    if(status)status.textContent='REexplorer requiere la APK Android de REVERSE.';
    return;
  }
  controls.forEach(el=>el.disabled=true);
  if(status)status.textContent='Solicitando REexplorer al sistema…';
  try{
    const result=await nativeRequest('openReexplorer',JSON.stringify({url:value}));
    if(status)status.textContent=result.opened===true?
      'Se solicitó la apertura de REexplorer.': 'No se confirmó la apertura.';
  }catch(error){
    if(status)status.textContent='REexplorer no se abrió: '+(error.message||'Error desconocido');
  }finally{controls.forEach(el=>el.disabled=false);}
}
document.addEventListener('submit',event=>{
  if(!event.target.matches('[data-reexplorer-form]'))return;
  event.preventDefault();
  const form=event.target;
  const url=form.querySelector('[name=url]')?.value||'';
  void openReexplorerFromDesktop(form,url);
});
document.addEventListener('click',event=>{
  const shortcut=event.target.closest('[data-reexplorer-robinhood]');
  if(!shortcut)return;
  const form=shortcut.closest('.reexplorer-shell')?.querySelector('[data-reexplorer-form]');
  if(form)void openReexplorerFromDesktop(form,'https://robinhood.com/');
});
