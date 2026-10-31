package com.reversepc.os;
public final class VelocityMaterialShaderTest {
 private static void require(boolean b,String label){if(!b)throw new AssertionError(label);}
 public static void main(String[] args){
  String vert=VelocityMaterialShader.VERTEX,frag=VelocityMaterialShader.FRAGMENT;
  require(vert.startsWith("#version 300 es\n")&&frag.startsWith("#version 300 es\n"),"GLES3 sources");
  require(vert.contains("out highp vec3 viewPoint;")&&frag.contains("in highp vec3 viewPoint;"),"view-space position for highlights");
  require(frag.contains("dFdx(viewPoint)")&&frag.contains("dFdy(viewPoint)"),"surface normals from real geometry");
  require(frag.contains("pow(1.0-cosTheta,5.0)"),"Fresnel grazing angle reflection");
  require(frag.contains("base==184")&&frag.contains("base==212")&&frag.contains("base==228"),"individual material categories");
  require(frag.contains("base==40")&&frag.contains("float largeGrain=texel/15.0"),"filtered XI-asphalt grain");
  require(frag.contains("renderSize")&&frag.contains("base==0||base==1"),"atmospheric sky gradient");
  require(frag.contains("texture(tileAtlas")&&frag.contains("clamp(result,0.0,1.0)"),"filtered tiles and full-color output");
  require(!frag.contains("gl_FragColor"),"modern GLSL output");
  System.out.println("RV08_MATERIAL_SHADER_PASS GLES3 real geometry + full-color shade");
 }
}
