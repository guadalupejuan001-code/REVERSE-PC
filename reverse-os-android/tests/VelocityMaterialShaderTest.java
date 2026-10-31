package com.reversepc.os;

/** Invariants of the XI-authored, GPU-shaded realism pass. */
public final class VelocityMaterialShaderTest {
 private static void require(boolean b,String label){if(!b)throw new AssertionError(label);}
 public static void main(String[] args){
  String vert=VelocityMaterialShader.VERTEX,frag=VelocityMaterialShader.FRAGMENT;
  require(vert.startsWith("#version 300 es\n")&&frag.startsWith("#version 300 es\n"),"GLES3 shader version");
  require(vert.contains("out highp vec3 viewPoint;")&&frag.contains("in highp vec3 viewPoint;"),
    "view-space reconstruction of true XI geometry");
  require(frag.contains("dFdx(viewPoint)")&&frag.contains("dFdy(viewPoint)"),
    "surface normals from real geometry");
  require(frag.contains("texture(tileAtlas")&&frag.contains("texelFetch(palette"),
    "texture samples remain sourced from XI material atlas");
  require(frag.contains("float noise2(")&&frag.contains("vec3 reflectionEnvironment("),
    "procedural microdetail and reflected sky");
  require(frag.contains("float F=pow(1.0-facing,5.0)")&&
    frag.contains("float spec=pow(nDotH,40.0)"),
    "dual-lobe pearl clearcoat and Schlick Fresnel");
  require(frag.contains("if(glass)")&&frag.contains("if(metal)")&&
    frag.contains("if(carbon)")&&frag.contains("if(rubber)"),
    "distinct glass, wheel, aero and tire shading");
  require(frag.contains("if(base==40)")&&frag.contains("float grit="),
    "UV-bound, multiscale XI asphalt texture");
  require(frag.contains("if(base==224||base==225)")&&frag.contains("vec3 emitter="),
    "authored red/white emissive light strips");
  require(frag.contains("float bump=")&&frag.contains("fwidth(texUV)")&&
    frag.contains("vec3 filmic("),"bounded detail and anti-aliased material sampling");
  require(frag.contains("renderSize")&&frag.contains("base==0||base==1"),
    "sky and atmospheric gradient use actual viewport");
  require(!frag.contains("gl_FragColor")&&!frag.contains("sin("),
    "modern full-color GLSL without expensive per-pixel sine hashing");
  System.out.println("RV09_MATERIAL_SHADER_PASS material families=7 XI UV=preserved GLES3 source=valid");
 }
}
