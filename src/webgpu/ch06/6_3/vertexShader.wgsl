struct Uniforms {
    projectionMatrix : mat4x4<f32>,
    modelViewMatrix : mat4x4<f32>,
    normalMatrix : mat4x4<f32>,
    materialDiffuse : vec4<f32>,
    positionRedLight : vec3<f32>,
    positionGreenLight : vec3<f32>,
    positionBlueLight : vec3<f32>,
};

struct VertexInput {
    @location(0) position : vec3<f32>,
    @location(1) normal : vec3<f32>,
};

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) normal: vec3<f32>,
    @location(1) redRay: vec3<f32>,
    @location(2) greenRay: vec3<f32>,
    @location(3) blueRay: vec3<f32>,
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;

@vertex
fn vertexMain(input : VertexInput) -> VertexOutput {
    var output : VertexOutput;

    let vertex = uniforms.modelViewMatrix * vec4<f32>(input.position, 1.0);

    let redLightPosition = uniforms.modelViewMatrix * vec4<f32>(uniforms.positionRedLight, 1.0);
    let greenLightPosition = uniforms.modelViewMatrix * vec4<f32>(uniforms.positionGreenLight, 1.0);
    let blueLightPosition = uniforms.modelViewMatrix * vec4<f32>(uniforms.positionBlueLight, 1.0);

    output.normal = (uniforms.normalMatrix * vec4<f32>(input.normal, 1.0)).xyz;
    output.redRay = (vertex - redLightPosition).xyz;
    output.greenRay = (vertex - greenLightPosition).xyz;
    output.blueRay = (vertex - blueLightPosition).xyz;
    output.position = uniforms.projectionMatrix * vertex;

    return output;
}
