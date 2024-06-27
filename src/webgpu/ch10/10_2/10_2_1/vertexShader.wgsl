struct Uniforms {
    projectionMatrix : mat4x4<f32>,
    modelViewMatrix : mat4x4<f32>,
};

struct VertexInput {
    @location(0) particle : vec4<f32>,
};

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) lifeSpan : f32,
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;

@vertex
fn vertexMain(input : VertexInput) -> VertexOutput {
    var output : VertexOutput;

    let vertex = uniforms.modelViewMatrix * vec4<f32>(input.particle.xyz, 1.0);

    output.lifeSpan = input.particle.w;
    output.position = uniforms.projectionMatrix * vertex;

    return output;
}
