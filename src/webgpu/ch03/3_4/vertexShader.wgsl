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

@vertex
fn vertexMain(
  @location(0) position: vec3<f32>,
  @location(1) normal: vec3<f32>
) -> VertexOutput {
  var output: VertexOutput;

  // モデルビュー行列を使って頂点の位置を変換する
  let vertex = uniforms.modelViewMatrix * vec4<f32>(position, 1.0);
  output.fragPos = vertex.xyz;
  // 法線行列を使って法線を変換し、xyz成分を取り出す
  output.normal = (uniforms.normalMatrix * vec4<f32>(normal, 1.0)).xyz;
  // プロジェクション行列を使って頂点の位置を変換し、最終的な位置を決定する
  output.position = uniforms.projectionMatrix * vertex;
  return output;
}
