struct Uniforms {
  projectionMatrix : mat4x4<f32>,
  modelViewMatrix: mat4x4<f32>,
  normalMatrix : mat4x4<f32>,
  lightDirection : vec3<f32>,
  lightAmbient : vec3<f32>,
  lightDiffuse : vec3<f32>,
  materialDiffuse : vec3<f32>
};

struct VertexOutput {
  @builtin(position) position : vec4<f32>, // パイプラインに渡す。かつ@fragmentに渡す
  @location(0) fragColor : vec4<f32> // @fragmentに渡す。location(0)はフラグメントシェーダーのfragmentMainの引数location(0)に対応
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;

@vertex
fn vertexMain(
  @location(0) position : vec3<f32>,
  @location(1) normal : vec3<f32>
) -> VertexOutput {

  var output : VertexOutput;

  // 法線ベクトルの計算
  let N : vec3<f32> = normalize((uniforms.normalMatrix * vec4<f32>(normal, 0)).xyz);

  // ライトをモデル変換マトリックスにアタッチします。
  let light: vec3<f32> = normalize((uniforms.modelViewMatrix * vec4<f32>(uniforms.lightDirection, 0.0)).xyz);

  // 光源ベクトルの正規化
  let L : vec3<f32> = normalize(light);

  // 法線と光源のドット積計算
  let lambertTerm : f32 = dot(N, -L);

  // 環境光の計算
  let Ia : vec3<f32> = uniforms.lightAmbient;

  // ランバート反射に基づく拡散色の計算
  let Id : vec3<f32> = uniforms.materialDiffuse * uniforms.lightDiffuse * lambertTerm;

  // 頂点単位で色を計算
  output.fragColor = vec4<f32>(Ia +Id, 1.0);

  // 頂点位置をクリップ座標系に変換
  output.position = uniforms.projectionMatrix * (uniforms.modelViewMatrix * vec4<f32>(position, 1.0));

  return output;
}
