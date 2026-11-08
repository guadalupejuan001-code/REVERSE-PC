#!/usr/bin/env python3
"""Reviewed one-time source migration; code is retained in the C04 branch."""
from pathlib import Path
import hashlib,json
v=Path('.');j=v/'reverse-os-android/app/src/main/java/com/reversepc/os';c=v/'reverse-os-android/app/src/main/cpp'
pin='376b1334dd2dde6093a2988ee12325590941573d'
if "versionName '4.0.0-c04-native-qssd'" in (v/'reverse-os-android/app/build.gradle').read_text():
    raise SystemExit(0)
def sub(p,a,b):
    s=p.read_text()
    if s.count(a)!=1: raise SystemExit(f'Unreviewed migration anchor: {p}: {a[:90]}')
    p.write_text(s.replace(a,b))
sub(c/'velocity_c12_frame.hpp','std::uint64_t steps=0,relation_nodes=0;',
    'std::uint64_t steps=0,relation_nodes=0,qssd_revision=0;\n  bool shared_source=false,reused=false;')
sub(j/'RegraphicsGeometry.java','    byte byteAt(int at){return source.get(at);}',
    '    ByteBuffer qssdSourceView(){return source.asReadOnlyBuffer().order(ByteOrder.LITTLE_ENDIAN);}\n    byte byteAt(int at){return source.get(at);}')
sub(c/'CMakeLists.txt','    target_include_directories(velocity_c12 PRIVATE "${GPU_C12_ROOT}/include")','''    set(QSSD_ROOT "${REPO_ROOT}/deps/qssd")
    execute_process(COMMAND git rev-parse HEAD WORKING_DIRECTORY "${QSSD_ROOT}"
      OUTPUT_VARIABLE QSSD_SHA OUTPUT_STRIP_TRAILING_WHITESPACE RESULT_VARIABLE QSSD_STATUS ERROR_QUIET)
    if(NOT QSSD_STATUS EQUAL 0 OR NOT QSSD_SHA STREQUAL "'''+pin+'''")
      message(FATAL_ERROR "Velocity C04 requires its exact original QSSD component revision")
    endif()
    find_package(Python3 COMPONENTS Interpreter REQUIRED)
    set(QSSD_GPU_COMPAT "${CMAKE_CURRENT_BINARY_DIR}/qssd-gpu-compat")
    foreach(script prepare_gpu.py prepare_c12.py)
      execute_process(COMMAND "${Python3_EXECUTABLE}" "${QSSD_ROOT}/scripts/${script}"
        "${GPU_C12_ROOT}/include" "${QSSD_GPU_COMPAT}" RESULT_VARIABLE QSSD_COMPAT_STATUS)
      if(NOT QSSD_COMPAT_STATUS EQUAL 0)
        message(FATAL_ERROR "Original QSSD/C12 shared-field ABI verification failed")
      endif()
    endforeach()
    target_sources(reverse_os PRIVATE velocity_qssd_jni.cpp)
    target_include_directories(reverse_os PRIVATE "${QSSD_ROOT}/include")
    target_compile_definitions(velocity_c12 PRIVATE REVERSE_PC_HAVE_BOUNDED_PRODUCT_IMPORT=1)
    target_include_directories(velocity_c12 PRIVATE "${QSSD_GPU_COMPAT}" "${QSSD_ROOT}/include"
      "${ETHER_PATCH}" "${ETHER_INCLUDE}" "${REPO_ROOT}/src" "${GPU_C12_ROOT}/include")''')
p=c/'velocity_c12_jni.cpp';s=p.read_text().replace('if(count==1||count%120==0)','if(!result.reused && (count==1||count%120==0))').replace('output=material_uniforms GLES=presenter",','output=material_uniforms GLES=presenter qssdSourceShared=%s qssdFieldRevision=%llu",').replace('static_cast<long long>(publication));','static_cast<long long>(publication), result.shared_source?"true":"false",\n        static_cast<unsigned long long>(result.qssd_revision));');p.write_text(s)
p=j/'VelocityGpuSurface.java'
sub(p,'vertices.invalidateGpuCopy();qssd.contextLost();atlasFilter=-1;','vertices.invalidateGpuCopy();qssd.contextCreated();atlasFilter=-1;')
sub(p,'        }catch(RuntimeException error){r.error=error;r.done.countDown();disable(error);}', '''        }catch(RuntimeException error){
            vertices.invalidateGpuCopy();qssd.contextLost();
            r.error=error;r.done.countDown();disable(error);
        }''')
a='    @Override public void onResume(){suspended=false;super.onResume();invalidated.run();requestRender();}'
sub(p,a,a+'\n    @Override protected void onDetachedFromWindow(){super.onDetachedFromWindow();qssd.close();}')
a='''        for(int row=0;row<16;row++){
            if((plan.atlasRowsMask&(1<<row))==0)continue;
            atlasBytes.clear();atlasBytes.put(plan.frame.atlas,row*128,128);atlasBytes.flip();
            glTexSubImage2D(GL_TEXTURE_2D,0,0,row,128,1,GL_RED,GL_UNSIGNED_BYTE,atlasBytes);
            textureUploadBytes+=128;
        }'''
sub(p,a,'''        // Adjacent dirty rows share one API upload; initial atlas uses one call.
        for(int row=0;row<16;){
            if((plan.atlasRowsMask&(1<<row))==0){row++;continue;}
            int first=row++;while(row<16&&(plan.atlasRowsMask&(1<<row))!=0)row++;
            int count=row-first;
            atlasBytes.clear();atlasBytes.put(plan.frame.atlas,first*128,count*128);atlasBytes.flip();
            glTexSubImage2D(GL_TEXTURE_2D,0,0,first,128,count,GL_RED,GL_UNSIGNED_BYTE,atlasBytes);
            textureUploadBytes+=128L*count;
        }''')
s=p.read_text().replace('" atlasVersion="+plan.frame.atlasRevision+" route=REgraphics_QSSD_GLES");','" atlasVersion="+plan.frame.atlasRevision+" route=REgraphics_QSSD_GLES component=QSSD_NATIVE adapter=JNI");');p.write_text(s)
p=j/'VelocityXiEngine.java';a='    private long retainedGpuIdentity,retainedGpuRevision;';sub(p,a,a+'\n    private int retainedPalettePhase=-1;\n    private int[] retainedPalette;')
sub(p,'        int[] colors=VelocityWorldLight.palette(palette,paletteDusk,paletteNight,state.dayPhase);','''        if(retainedPalette==null||retainedPalettePhase!=state.dayPhase){
            retainedPalette=VelocityWorldLight.palette(palette,paletteDusk,paletteNight,state.dayPhase);
            retainedPalettePhase=state.dayPhase;
        }
        int[] colors=retainedPalette;''')
p=v/'docs/QSSD_INTEGRATION_LOCK.json';d=json.loads(p.read_text());d['commit']=pin;d['scope']='Original native QSSD GraphicsPort/StateBus plus producer Field via Space and C12Window; Java is only JNI.';d['componentFiles']=[]
for name in ['graphics_port.hpp','state_space.hpp','c12_bridge.hpp']:
    path='include/qssd/'+name
    d['componentFiles'].append({'path':path,'sha256':hashlib.sha256((v/'deps/qssd'/path).read_bytes()).hexdigest()})
p.write_text(json.dumps(d,indent=2)+'\n')
p=v/'scripts/check-velocity-qssd.cjs';s=p.read_text().replace('9fe72bbf0d972d0baad9300971dfaabab5691447',pin)
s+='''\nif(process.argv[2])for(const item of lock.componentFiles){
 const raw=fs.readFileSync(path.join(process.argv[2],item.path));
 assert.equal(crypto.createHash('sha256').update(raw).digest('hex'),item.sha256,'original QSSD component differs: '+item.path);
}
const bridge=read(java+'VelocityQssdGraphicsBridge.java');
assert(bridge.includes('nativePublish(')&&bridge.includes('nativePlan(')&&bridge.includes('nativeConfirm('),'Java must delegate to QSSD');
assert(!bridge.includes('private Frame head,uploaded')&&!bridge.includes('atlasLayout('),'Java cannot duplicate the component');
const materials=read('reverse-os-android/app/src/main/cpp/velocity_c12_frame.cpp');
assert(materials.includes('qssd::Space component')&&materials.includes('qssd::C12Window window(source)')&&materials.includes('window.source_pointer_preserved()'),'original shared-source C12 integration is required');
''';p.write_text(s)
p=v/'scripts/check-velocity-native-only.cjs';s=p.read_text().replace("bus.includes('sourceRevision')&&bus.includes('contextLost()')", "bus.includes('nativePublish(')&&bus.includes('nativePlan(')&&bus.includes('contextLost()')");p.write_text(s)
for name in ['velocity-apk-package.cjs','velocity-apk-smoke.cjs','velocity-graphics-ui-smoke.cjs','velocity-performance-ab.cjs','velocity-state-space-smoke.cjs']:
    p=v/'reverse-os-android/tests'/name;s=p.read_text().replace('com.reversepc.velocity.c02','com.reversepc.velocity.c04').replace(r'com\.reversepc\.velocity\.c02',r'com\.reversepc\.velocity\.c04').replace("versionCode='45'","versionCode='46'").replace('versionCode:45','versionCode:46').replace('c03-qssd','c04-native-qssd').replace('REVERSE VELOCITY C03','REVERSE VELOCITY C04')
    if name=='velocity-apk-package.cjs':
        a=" assert(elf.includes(Buffer.from('Java_com_reversepc_os_NativeRuntime_velocityC12Frame')),'original GPU C12 per-frame JNI entry must be compiled into APK');"
        if a not in s: raise SystemExit('APK C12 assertion missing')
        s=s.replace(a,a+"\n for(const fn of ['nativePublish','nativePlan','nativeConfirm','nativeInvalidate'])assert(elf.includes(Buffer.from('Java_com_reversepc_os_VelocityQssdGraphicsBridge_'+fn)),'original QSSD native entry missing: '+fn);")
    if name=='velocity-graphics-ui-smoke.cjs':
        a=" check(true,'GLES presents qSSD leased geometry and material resources');"
        if a not in s: raise SystemExit('Android qSSD assertion missing')
        s=s.replace(a,a+"\n check(/component=QSSD_NATIVE adapter=JNI/.test(logs()),'native original QSSD owns the graphics port');\n check(/qssdSourceShared=true/.test(logs()),'C12Window consumes the QSSD pointer');")
    p.write_text(s)
p=v/'reverse-os-android/tests/velocity-c12-frame.cpp';s=p.read_text().replace('          assert(frame.steps>=9 && frame.relation_nodes>0);','          assert(frame.steps>=9 && frame.relation_nodes>0);\n          assert(frame.shared_source && frame.qssd_revision>0);')
a='  std::cout<<"VELOCITY_C12_REAL_EXECUTION_PASS cases="';s=s.replace(a,'''  const auto once=velocity_c12::evaluate({777,17,333,1});
  const auto twice=velocity_c12::evaluate({777,17,333,1});
  assert(twice.reused && once.qssd_revision==twice.qssd_revision && once.values==twice.values);
'''+a);p.write_text(s)
p=v/'.github/workflows/velocity-apk.yml';s=p.read_text().replace('feature/velocity-c03-qssd-renderbus-20261108, feature/regraphics-frame-cache','feature/velocity-c03-qssd-renderbus-20261108, feature/velocity-c04-qssd-component-20261108, feature/regraphics-frame-cache').replace('feature/velocity-c02-qssd-c12-pastures-drivability-20261107]','feature/velocity-c02-qssd-c12-pastures-drivability-20261107, feature/velocity-c03-qssd-renderbus-20261108]').replace("github.head_ref == 'feature/velocity-c03-qssd-renderbus-20261108'))","github.head_ref == 'feature/velocity-c03-qssd-renderbus-20261108' || github.head_ref == 'feature/velocity-c04-qssd-component-20261108'))")
s=s.replace('9fe72bbf0d972d0baad9300971dfaabab5691447',pin).replace('sparse-checkout: include/qssd','sparse-checkout: |\n            include/qssd\n            scripts').replace('REVERSE-VELOCITY-4.0-C03-QSSD-GPU.apk','REVERSE-VELOCITY-4.0-C04-NATIVE-QSSD.apk').replace('reverse-velocity-c02-lab-signing-v1','reverse-velocity-c04-native-signing-v1').replace('standalone C03 qSSD APK','standalone C04 native qSSD APK');p.write_text(s)
p=v/'.github/workflows/velocity-c02-quick.yml';s=p.read_text().replace('name: Velocity C03 - graphics qSSD bridge, C12 and driving','name: Velocity C04 - original native QSSD, JNI and C12Window').replace('feature/velocity-c03-qssd-renderbus-20261108]','feature/velocity-c03-qssd-renderbus-20261108, feature/velocity-c04-qssd-component-20261108]').replace('feature/velocity-c02-qssd-c12-pastures-drivability-20261107]\npermissions','feature/velocity-c02-qssd-c12-pastures-drivability-20261107, feature/velocity-c03-qssd-renderbus-20261108]\npermissions')
s=s.replace('      - uses: actions/setup-java@v4','''      - uses: actions/checkout@v4
        with:
          repository: guadalupejuan001-code/Virtual-qSSD-
          ref: '''+pin+'''
          path: deps/qssd
          persist-credentials: false
      - uses: actions/checkout@v4
        with:
          repository: guadalupejuan001-code/mundo-X
          ref: 1f925786522aba91f72707ad1638a8edcdd31a8f
          path: deps/mundo-x
          sparse-checkout: native/include
          persist-credentials: false
      - uses: actions/setup-java@v4''')
idx=s.index('      - name: Execute real XGPU-C12 material kernel');s=s[:idx]+'''      - name: Test original component, JNI and C12Window
        run: bash scripts/test-velocity-c04-native.sh
''';p.write_text(s)
p=v/'reverse-os-android/app/build.gradle';s=p.read_text().replace("applicationId 'com.reversepc.velocity.c02'","applicationId 'com.reversepc.velocity.c04'").replace("versionCode 45; versionName '4.0.0-c03-qssd'","versionCode 46; versionName '4.0.0-c04-native-qssd'").replace('REVERSE VELOCITY C03','REVERSE VELOCITY C04');p.write_text(s)
print('C04_NATIVE_QSSD_SOURCE_MIGRATION_COMPLETE')
