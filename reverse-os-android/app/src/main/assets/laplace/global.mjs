import {huellaContenido} from './integridad.mjs';
const need=(c,m)=>{if(!c)throw Error(m)};
export async function verifyGlobalCapture(c){
  const {capture_sha256,...body}=c??{};
  need(['laplace-universo-global-u002-v1','laplace-universo-global-u003-v4'].includes(body.schema),'Captura mundial U002 incompatible');
  need(typeof capture_sha256==='string'&&/^[a-f0-9]{64}$/.test(capture_sha256),'Sello U002 ausente');
  need(capture_sha256===await huellaContenido(body),'La captura mundial fue modificada');
  const cov=body.coverage,state=body.universal_state;
  need(Number.isInteger(cov?.known_signals)&&cov.known_signals>0&&cov.known_signals<=2047&&cov.failed_sources>=0,'La captura global excede el presupuesto o tiene cobertura inválida');
  need(state?.known_states===cov.known_signals&&Array.isArray(state.states)&&state.states.length===cov.known_signals,'Snapshot U002 incompleto');
  need(state.complete_universe_observed===false,'Cobertura universal incoherente');
  const {snapshot_sha256,...snapshotBody}=state;
  const snapshotBytes=await crypto.subtle.digest('SHA-256',new TextEncoder().encode(JSON.stringify(snapshotBody)));
  need(snapshot_sha256===[...new Uint8Array(snapshotBytes)].map(x=>x.toString(16).padStart(2,'0')).join(''),'El snapshot mundial fue modificado');
  need(body.prediction_inputs_enabled===false&&body.automatic_trading===false,'U002 no debe activar predicción/trading automáticamente');
  need(Number.isFinite(Date.parse(body.at))&&Date.parse(body.at)<=Date.now()+60000,'Fecha U002 inválida');
  return c;
}
export function verifyGlobalProof(p,capture){
  need(p?.schema==='laplace-u002-native-xi-v1'&&p.backend==='XI/Ether · NativeRuntime','Prueba U002 nativa incompatible');
  need(p.records===capture.coverage.known_signals&&p.exact_roundtrip===true&&p.active_qubits===0,'U002 no completó el round-trip nativo');
  need(p.snapshot_sha256===capture.universal_state.snapshot_sha256,'U002 nativo no corresponde al snapshot recibido');
  need(p.capture_sha256===capture.capture_sha256&&p.prediction_generated===false,'Metadatos U002 nativos incoherentes');
  return p;
}
