struct Uniforms {
    projectionMatrix : mat4x4<f32>,
    modelViewMatrix : mat4x4<f32>,
    normalMatrix : mat4x4<f32>,
    lightPosition : vec3<f32>,
    lightDiffuse : vec4<f32>,
    lightAmbient : vec4<f32>,
    materialDiffuse : vec4<f32>, 
    materialAmbient : vec4<f32>, 
};

struct VertexInput {
    @location(0) position : vec3<f32>,
    @location(1) texcoord : vec2<f32>,
};

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) texcoord: vec2<f32>,
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;

@vertex
fn vertexMain(input : VertexInput) -> VertexOutput {
    var output : VertexOutput;

    let swappedUV = vec2<f32>(input.texcoord.y,  input.texcoord.x);
    output.texcoord = (input.texcoord * 3.0) - vec2<f32>(1.0, 1.0);
    output.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * vec4<f32>(input.position, 1.0);

    return output;
}
