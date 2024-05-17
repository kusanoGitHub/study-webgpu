struct Uniforms {
  projectionMatrix : mat4x4<f32>,
  modelViewMatrix: mat4x4<f32>,
  normalMatrix : mat4x4<f32>,
  lightDirection : vec3<f32>,
  lightAmbient : vec3<f32>,
  lightDiffuse : vec3<f32>,
  lightSpecular : vec3<f32>,
  materialAmbient : vec3<f32>,
  materialDiffuse : vec3<f32>,
  materialSpecular : vec3<f32>,
  shininess : f32
};

struct VertexOutput {
  @builtin(position) position : vec4<f32>,
  @location(0) fragPos : vec3<f32>,
  @location(1) normal : vec3<f32>
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;

@fragment
fn fragmentMain(input: VertexOutput) -> @location(0) vec4<f32> {

  // 法線を正規化
  let N: vec3<f32> = normalize(input.normal);
  // 光の方向を正規化
  let L: vec3<f32> = normalize(uniforms.lightDirection);
  // 法線と光の方向の内積を計算する（ランバート項）
  let lambertTerm: f32 = max(dot(N, -L), 0.0);

  // 環境光(ambient)の計算
  let Ia: vec3<f32> = uniforms.lightAmbient * uniforms.materialAmbient;

  var Id: vec3<f32> = vec3<f32>(0.0, 0.0, 0.0); // 拡散反射(diffuse)
  var Is: vec3<f32> = vec3<f32>(0.0, 0.0, 0.0); // 鏡面反射(specular)

  // ランバート項が正の場合、拡散反射と鏡面反射を計算する
  if (lambertTerm > 0.0) {
    Id = uniforms.lightDiffuse * uniforms.materialDiffuse * lambertTerm;
    let eyeVec: vec3<f32> = normalize(-input.fragPos); // 視線ベクトル
    let R: vec3<f32> = reflect(L, N); // 反射ベクトル
    // 視線ベクトルと反射ベクトルの内積を用いて鏡面反射を計算する
    let specular: f32 = pow(max(dot(R, eyeVec), 0.0), uniforms.shininess);
    Is = uniforms.lightSpecular * uniforms.materialSpecular * specular;
  }

  // フラグメントの色をアンビエント、ディフューズ、スペキュラー光の和として計算する
  let fragColor: vec3<f32> = Ia + Id + Is;
  return vec4<f32>(fragColor, 1.0);
}