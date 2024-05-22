struct Uniforms {
    projectionMatrix: mat4x4<f32>,
    modelViewMatrix: mat4x4<f32>,
    normalMatrix: mat4x4<f32>,
    shininess: f32,
    distance: f32,
    lightPosition: vec3<f32>,
    materialDiffuse: vec3<f32>,
    materialAmbient: vec3<f32>,
    materialSpecular: vec3<f32>,
    lightDiffuse: vec3<f32>,
    lightAmbient: vec3<f32>,
    lightSpecular: vec3<f32>,
};

struct VertexInput {
    @location(0) vertexPosition: vec3<f32>,
    @location(1) vertexNormal: vec3<f32>,
};

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) normal: vec3<f32>,
    @location(1) lightRay: vec3<f32>,
    @location(2) eyeVector: vec3<f32>,
};

@binding(0) @group(0) var<uniform> uniforms: Uniforms;

@vertex
fn vertexMain(input: VertexInput) -> VertexOutput {
    var output: VertexOutput;

    let vertex = uniforms.modelViewMatrix * vec4<f32>(input.vertexPosition, 1.0);
    let light = uniforms.modelViewMatrix * vec4<f32>(uniforms.lightPosition, 1.0);

    output.normal = (uniforms.normalMatrix * vec4<f32>(input.vertexNormal, 1.0)).xyz;
    output.lightRay = vertex.xyz - light.xyz;
    output.eyeVector = -vertex.xyz;

    output.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * vec4<f32>(input.vertexPosition, 1.0);

    return output;
}