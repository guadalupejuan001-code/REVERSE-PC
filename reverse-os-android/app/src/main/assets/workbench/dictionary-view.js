'use strict';
// Presentation only; every definition comes from the original native XI answer.
window.ReverseLexicon={format(text){
  let entry;try{entry=JSON.parse(text);}catch{return null;}
  if(!entry||typeof entry.word!=='string'||!['es','en'].includes(entry.language)||!Array.isArray(entry.senses)||entry.senses.length>128)return null;
  const strings=value=>Array.isArray(value)?value.filter(x=>typeof x==='string'):[];
  let html='<strong>'+esc(entry.word)+'</strong><br><small>Diccionario · '+esc(entry.language.toUpperCase())+'</small>';
  for(const [i,sense] of entry.senses.entries()){
    if(!sense||typeof sense!=='object')return null;
    const es=strings(sense.definition_es),en=strings(sense.definition_en);
    html+='<br><br><strong>'+(i+1)+'.</strong> '+(es.length?esc(es.join(' / ')):en.length?'<small>EN:</small> '+esc(en.join(' / ')):'Sin definición disponible en la fuente.');
    for(const language of ['es','en']){const words=strings(sense[language]);if(words.length)html+='<br><small>'+language.toUpperCase()+': '+esc(words.join(', '))+'</small>';}
  }
  return html;
}};
