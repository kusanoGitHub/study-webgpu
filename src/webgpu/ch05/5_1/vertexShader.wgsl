struct Uniforms {
    projectionMatrix : mat4x4<f32>,
    modelViewMatrix : mat4x4<f32>,
    normalMatrix : mat4x4<f32>,
    lightPosition : vec3<f32>,
    lightDiffuse : vec3<f32>,
    lightAmbient : vec3<f32>,
    lightSpecular : vec3<f32>,
    materialDiffuse : vec3<f32>,
    materialAmbient : vec3<f32>,
    materialSpecular : vec3<f32>,
    padding: f32, // padding to align to 16 bytes
    shininess : f32,
    wireframe : f32,
    fixedLight : f32,
};

struct VertexInput {
    @location(0) position : vec3<f32>,
    @location(1) normal : vec3<f32>,
};

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) normal: vec3<f32>,
    @location(1) lightRay: vec3<f32>,
    @location(2) eyeVector: vec3<f32>,
    @location(3) finalColor : vec4<f32>,
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;

@vertex
fn vertexMain(input : VertexInput) -> VertexOutput {
    var output : VertexOutput;

    if (uniforms.wireframe == 1) {
        output.finalColor = vec4<f32>(uniforms.materialDiffuse, 1.0);
    } 

    let vertex = uniforms.modelViewMatrix * vec4<f32>(input.position, 1.0);
    var light = vec4<f32>(uniforms.lightPosition, 1.0);

    if (uniforms.fixedLight == 1) {
        light = uniforms.modelViewMatrix * vec4<f32>(uniforms.lightPosition, 1.0);
    }

    output.normal = (uniforms.normalMatrix * vec4<f32>(input.normal, 1.0)).xyz;
    output.lightRay = vertex.xyz - light.xyz;
    output.eyeVector = -vertex.xyz;
    output.position = uniforms.projectionMatrix * vertex;

    return output;
}
