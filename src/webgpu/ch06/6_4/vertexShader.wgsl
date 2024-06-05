/*
* webGPUでは、webGL2のようにバリイングに配列を使うことが出来ない。
* @location' は数値スカラー型または数値ベクター型の宣言にのみ適用する必要があるようなので
* それぞれ定義する。
*/

struct Uniforms {
    projectionMatrix : mat4x4<f32>,
    modelViewMatrix : mat4x4<f32>,
    normalMatrix : mat4x4<f32>,
    materialDiffuse : vec4<f32>,
    lightPosition : array<vec3<f32>, 3>,
};

struct VertexInput {
    @location(0) position : vec3<f32>,
    @location(1) normal : vec3<f32>,
};

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) normal: vec3<f32>,
    @location(1) lightRay0: vec3<f32>,
    @location(2) lightRay1: vec3<f32>,
    @location(3) lightRay2: vec3<f32>,
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;

@vertex
fn vertexMain(input : VertexInput) -> VertexOutput {
    var output : VertexOutput;

    let vertex = uniforms.modelViewMatrix * vec4<f32>(input.position, 1.0);

    output.normal = (uniforms.normalMatrix * vec4<f32>(input.normal, 1.0)).xyz;

    for (var i = 0; i < 3; i = i + 1) {
        let lightPosition = uniforms.modelViewMatrix * vec4<f32>(uniforms.lightPosition[i], 1.0);
        if (i == 0) {
            output.lightRay0 = vertex.xyz - lightPosition.xyz;
        } else if (i == 1) {
            output.lightRay1 = vertex.xyz - lightPosition.xyz;
        } else if (i == 2) {
            output.lightRay2 = vertex.xyz - lightPosition.xyz;
        }
    }

    output.position = uniforms.projectionMatrix * vertex;

    return output;
}
