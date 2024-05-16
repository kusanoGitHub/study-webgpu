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
  @location(0) fragColor : vec4<f32>
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;

@vertex
fn vertexMain(
  @location(0) position: vec3<f32>,
  @location(1) normal: vec3<f32>
) -> VertexOutput {
  var output: VertexOutput;

  // モデルビュー行列を使って頂点の位置を変換する
  let vertex : vec4<f32> = uniforms.modelViewMatrix * vec4<f32>(position, 1.0);
  // 法線行列を使って法線を変換し、xyz成分を取り出す
  let N: vec3<f32> = (uniforms.normalMatrix * vec4<f32>(normal, 1.0)).xyz;
  // 光の方向を正規化する
  let L: vec3<f32> = normalize(uniforms.lightDirection);
  // 法線と光の方向の内積を計算する（ランバート項）
  let lambertTerm: f32 = dot(N, -L);

  // 環境光(ambient)の計算
  let Ia: vec3<f32> = uniforms.lightAmbient * uniforms.materialAmbient; // 環境光(ambient)
  var Id: vec3<f32> = vec3<f32>(0.0, 0.0, 0.0); // 拡散反射(diffuse)
  var Is: vec3<f32> = vec3<f32>(0.0, 0.0, 0.0); // 鏡面反射(specular)

  // ランバート項が正の場合、拡散反射と鏡面反射を計算する
  if (lambertTerm > 0.0) {
    Id = uniforms.lightDiffuse * uniforms.materialDiffuse * lambertTerm;
    let eyeVec: vec3<f32> = -vertex.xyz; // 視線ベクトル
    let E: vec3<f32> = normalize(eyeVec);
    let R: vec3<f32> = reflect(L, N); // 反射ベクトル
    // 視線ベクトルと反射ベクトルの内積を用いて鏡面反射を計算する
    let specular: f32 = pow(max(dot(R, E), 0.0), uniforms.shininess);

    Is = uniforms.lightSpecular * uniforms.materialSpecular * specular;
  }

  // 頂点の色をアンビエント、ディフューズ、スペキュラー光の和として計算する
  output.fragColor = vec4<f32>(Ia.rgb + Id.rgb + Is.rgb, 1.0);
  // プロジェクション行列を使って頂点の位置を変換し、最終的な位置を決定する
  output.position = uniforms.projectionMatrix * vertex;
  return output;
}