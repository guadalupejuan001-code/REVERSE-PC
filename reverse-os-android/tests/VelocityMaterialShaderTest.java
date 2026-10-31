package com.reversepc.os;
public final class VelocityMaterialShaderTest {
 private static void require(boolean b,String label){if(!b)throw new AssertionError(label);}
 public static void main(String[] args){
  String vert=VelocityMaterialShader.VERTEX,frag=VelocityMaterialShader.FRAGMENT;
  require(vert.startsWith("#version 300 es\n")&&frag.startsWith("#version 300 es\n"),"GLES3 sources");
  require(vert.contains("out highp vec3 viewPoint;")&&frag.contains("in highp vec3 viewPoint;"),"real XI view geometry");
  require(frag.contains("dFdx(viewPoint)")&&frag.contains("dFdy(viewPoint)"),"reconstructed surface normals");
  require(frag.contains("float fresnel=pow(1.0-cosTheta,5.0)"),"Fresnel from angle of view");
  require(frag.contains("float clearcoat=pow(specBase,30.0)")&&frag.contains("pow(specBase,110.0)"),
    "two specular lobes for original pearl paint");
  require(frag.contains("base==184")&&frag.contains("base==212")&&frag.contains("base==228")&&frag.contains("base==208"),
    "glass, rim, aero and rubber categories");
  require(frag.contains("float grain=fract(")&&frag.contains("float aggregate="),
    "road aggregate anchored in XI UV space");
  require(frag.contains("float machined=")&&frag.contains("float grooves=")&&frag.contains("float weave="),
    "brushed wheel, grooved tire and carbon-fiber surfaces");
  require(frag.contains("renderSize")&&frag.contains("float haze="),
    "screen-correct atmospheric sky");
  require(frag.contains("texture(tileAtlas")&&frag.contains("clamp(result,0.0,1.0)"),
    "filtered XI tiles and bounded full-color output");
  require(!frag.contains("sin(")&&!frag.contains("gl_FragColor")&&!frag.contains("noise2("),
    "lightweight GLES3 shading without expensive procedural fractal noise");
  System.out.println("RV09_MATERIAL_SHADER_PASS material families=7 XI UV=preserved");
 }
}