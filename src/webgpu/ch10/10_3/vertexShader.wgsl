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
    @location(1) normal : vec3<f32>,
    @location(2) tangent : vec3<f32>,
    @location(3) texcoord : vec2<f32>,
};

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) texcoord: vec2<f32>,
    @location(1) tangentLightDirection: vec3<f32>,
    @location(2) tangentEyeDirection: vec3<f32>,
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;

@vertex
fn vertexMain(input : VertexInput) -> VertexOutput {
    var output : VertexOutput;

    let vertex = uniforms.modelViewMatrix * vec4<f32>(input.position, 1.0);
    let normal = (uniforms.normalMatrix * vec4<f32>(input.normal, 1.0)).xyz; // 法線ベクトル
    let tangent = (uniforms.normalMatrix * vec4<f32>(input.tangent, 1.0)).xyz; // 接線ベクトル
    let bitangent = cross(normal, tangent); // 従法線ベクトル
    let tbn = mat3x3<f32>(
        tangent.x, bitangent.x, normal.x,
        tangent.y, bitangent.y, normal.y,
        tangent.z, bitangent.z, normal.z
    ); // 接空間行列

    let eyeDirection = -vertex.xyz;
    let lightDirection = uniforms.lightPosition - vertex.xyz;

    output.texcoord = input.texcoord;
    output.tangentLightDirection = lightDirection * tbn;
    output.tangentEyeDirection = eyeDirection * tbn;
    output.position = uniforms.projectionMatrix * vertex;

    return output;
}
