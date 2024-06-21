struct Uniforms {
    projectionMatrix : mat4x4<f32>,
    modelViewMatrix : mat4x4<f32>,
    normalMatrix : mat4x4<f32>,
    lightPositions : array<vec3<f32>, 4>,
    lightDiffuses : array<vec3<f32>, 4>,
    lightSpeculars : array<vec3<f32>, 4>,
    materialDiffuse : vec3<f32>,
    materialSpecular : vec3<f32>,
    padding: f32,
    shininess : f32,
    wireframe : f32,
    illuminationMode: f32,
    alpha: f32,
};

struct VertexInput {
    @location(0) position : vec3<f32>,
    @location(1) normal : vec3<f32>,
};

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) normal: vec3<f32>,
    @location(1) farLeftLightRay: vec3<f32>,
    @location(2) farRightLightRay: vec3<f32>,
    @location(3) nearLeftLightRay: vec3<f32>,
    @location(4) nearRightLightRay: vec3<f32>,
    @location(5) eyeVector: vec3<f32>,
    @location(6) finalColor : vec4<f32>,
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;

@vertex
fn vertexMain(input : VertexInput) -> VertexOutput {
    var output : VertexOutput;

    if (uniforms.wireframe == 1) {
        output.finalColor = vec4<f32>(uniforms.materialDiffuse, uniforms.alpha);
    } 

    let vertex = uniforms.modelViewMatrix * vec4<f32>(input.position, 1.0);

    output.farLeftLightRay = vertex.xyz - uniforms.lightPositions[0];
    output.farRightLightRay = vertex.xyz - uniforms.lightPositions[1];
    output.nearLeftLightRay = vertex.xyz - uniforms.lightPositions[2];
    output.nearRightLightRay = vertex.xyz - uniforms.lightPositions[3];

    output.normal = (uniforms.normalMatrix * vec4<f32>(input.normal, 1.0)).xyz;
    output.eyeVector = -vertex.xyz;
    output.position = uniforms.projectionMatrix * vertex;

    return output;
}
