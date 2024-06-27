struct Uniforms {
    projectionMatrix : mat4x4<f32>,
    modelViewMatrix : mat4x4<f32>,
};

struct VertexInput {
    @builtin(vertex_index) vertexIndex : u32,
    @location(0) particle : vec4<f32>,
    @location(1) size : f32,
};

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) lifeSpan : f32,
    @location(1) texCoord : vec2<f32>,
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;

@vertex
fn vertexMain(input : VertexInput) -> VertexOutput {
    var output : VertexOutput;

    // テクスチャを貼り付ける四角形の頂点位置を定義
    let points = array(
        vec2<f32>(-1, -1),
        vec2<f32>(1, -1),
        vec2<f32>(-1, 1),
        vec2<f32>(-1, 1),
        vec2<f32>(1, -1),
        vec2<f32>(1, 1),
    );

    let pos = points[input.vertexIndex];
    let vertex = uniforms.modelViewMatrix * vec4<f32>(input.particle.xyz, 1.0);
    let adjustedSize = input.size * input.particle.w; // パーティクルの寿命に応じてサイズを小さくする
    let adjustedPos = pos * adjustedSize;

    output.lifeSpan = input.particle.w;
    output.texCoord = pos * 0.5 + 0.5; // テクスチャ座標を[-1, 1]から[0, 1]に変換
    output.position = uniforms.projectionMatrix * (vertex + vec4<f32>(adjustedPos, 0.0, 0.0));

    return output;
}
