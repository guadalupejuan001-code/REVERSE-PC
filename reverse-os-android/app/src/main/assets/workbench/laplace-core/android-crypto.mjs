// SHA-256 transport only. U001/I015 equations and decisions remain in the original modules.
export function createHash(algorithm){
 if(algorithm!=='sha256')throw Error('Hash no admitido');let text='';
 return {update(value){if(typeof value!=='string')throw Error('Texto de hash inválido');text+=value;return this;},
 digest(format){if(format!=='hex'||!globalThis.ReverseNative?.laplaceHash)throw Error('SHA-256 Android no disponible');return globalThis.ReverseNative.laplaceHash(text);}};
}
