
/* End-to-End-Test MG (nur fuer Entwicklung, wird nie automatisch gestartet):
   simulierte Nacht -> echte v18-Rahmen mit Pruefsummen -> Zusammensetzen in Stuecken ->
   Bloecke im iOS-Format -> _wAtlasIngest1 ueber nachgestellte iPhone-Schnittstelle ->
   Funktions-Check. Arbeitet auf dem aktuellen Zustand; vorher sichern! */
function _e2eV18(o){const b=new Uint8Array(112),v=new DataView(b.buffer);b[0]=0x2F;b[1]=18;b[2]=0x80;v.setUint32(3,o.idx,true);v.setUint32(7,o.ts,true);
  b[14]=o.hr;const rr=(o.rr||[]).slice(0,4);b[15]=rr.length;rr.forEach((x,i)=>v.setInt16(16+2*i,x,true));
  v.setFloat32(33,o.dyn||0,true);v.setFloat32(37,o.gx,true);v.setFloat32(41,o.gy,true);v.setFloat32(45,o.gz,true);
  v.setUint16(49,o.steps&0xFFFF,true);b[55]=o.act||0;v.setInt16(61,330,true);v.setInt16(63,240,true);v.setInt16(65,Math.round((o.skin||0)*100),true);
  b[73]=((o.sleep||0)&3)<<4;b[74]=o.spo2||0;return b;}
window.atlasE2E=async function(opt){opt=opt||{};
  let sd=7;const rnd=()=>{sd=(sd*1103515245+12345)&0x7fffffff;return sd/0x7fffffff;},ga=()=>{let u=0,v=0;while(!u)u=rnd();while(!v)v=rnd();return Math.sqrt(-2*Math.log(u))*Math.cos(2*Math.PI*v);};
  const T=k=>Math.floor(k.getTime()/1000),y=new Date();y.setDate(y.getDate()-1);
  const at=(d,h,m)=>{const x=new Date(d);x.setHours(h,m||0,0,0);return T(x);};
  const t0=at(y,10),sOn=at(y,23),sOff=at(new Date(),7),t1=opt.endMin!=null?sOff+opt.endMin*60:at(new Date(),9),walk=[at(y,12),at(y,12,30)],cardio=[at(y,18),at(y,18,45)];
  const ser=new Uint8Array(0),chunks=[];let idx=1,steps=65000,bt=0;
  for(let t=t0;t<t1;t++){const sl=t>=sOn&&t<sOff,wk=t>=walk[0]&&t<walk[1],cd=t>=cardio[0]&&t<cardio[1];
    let hr=sl?54+3*Math.sin((t-sOn)/1800)+ga():wk?102+ga()*3:cd?146+ga()*2:74+ga()*4;hr=Math.round(hr);
    const rr=[];if(sl||!cd){let base=60000/hr;for(let i=0;i<Math.max(1,Math.round(hr/60));i++)rr.push(Math.round(base+(sl?40:15)*Math.sin(2*Math.PI*14/60*(t+i*base/1000))+ga()*(4+(opt.jitter||0))));}
    if(wk)steps=(steps+2)&0xFFFF;else if(cd)steps=(steps+3)&0xFFFF;
    const a=sl?0.002:wk||cd?0.25:0.04,el=sl?0.2:1.2;
    const sw=sl&&((t-sOn)%1200)<30;
    chunks.push(_e2eV18({idx:idx++,ts:t,hr,rr,gx:Math.cos(el)+ga()*a,gy:ga()*a,gz:Math.sin(el)+ga()*a,dyn:a,steps,act:wk||cd?(cd?2:1):0,skin:sl?34.5+ga()*0.05:32+ga()*0.2,sleep:sl?2:0,spo2:sw?96:0}));}
  // Rahmen bauen, in 180-Byte-Stuecken zusammensetzen (mit Konsolenpaketen auf einem anderen Kanal)
  const R=new WFrameReassembler(5),inners=[];let dropped=0;
  for(const inner of chunks){const fr=wbuildFrame(inner,5);for(let o=0;o<fr.length;o+=180)R.feed(fr.subarray(o,o+180)).forEach(f=>{if(f.crcOk)inners.push(f.inner);else dropped++;});}
  // iOS-Blockformat [u16 Laenge][Inhalt], ~2 MB je Block
  const segs=[];let cur=[],sz=0;const flush=()=>{if(!cur.length)return;const out=new Uint8Array(sz);let o=0;cur.forEach(x=>{out[o++]=x.length&255;out[o++]=x.length>>8;out.set(x,o);o+=x.length;});
    let bin='';for(let i=0;i<out.length;i+=8192)bin+=String.fromCharCode.apply(null,out.subarray(i,i+8192));segs.push({name:'seg-'+(1e12+segs.length)+'-g5.bin',b64:btoa(bin),gen:5});cur=[];sz=0;};
  inners.forEach(x=>{cur.push(x);sz+=x.length+2;if(sz>2e6)flush();});flush();
  const fake={status:async()=>({draining:false,segments:segs.length,gen:5,ready:true}),read:async()=>segs[0]||{},commit:async({name})=>{const i=segs.findIndex(x=>x.name===name);if(i>=0)segs.splice(i,1);}};
  const orig=window.wAtlasPlug;window.wAtlasPlug=()=>fake;wbleCfg().gen=5;
  let recs=0;try{recs=await _wAtlasIngest1();}finally{window.wAtlasPlug=orig;}
  return {records:chunks.length,parsed:inners.length,dropped,ingested:recs,check:wSystemCheck().map(x=>(x.ok?'✓ ':'○ ')+x.n+': '+(x.ok?x.v:x.why))};};
