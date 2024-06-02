struct Uniforms {
    projectionMatrix : mat4x4<f32>,
    modelViewMatrix : mat4x4<f32>,
    normalMatrix : mat4x4<f32>,
    lightPosition : vec3<f32>,
    lightDiffuse : vec4<f32>,
    lightAmbient : vec4<f32>,
    materialDiffuse : vec4<f32>,
    materialAmbient : vec4<f32>, 
    alpha : f32,
    useVertexColors : f32,
    useLambert : f32,
};

struct VertexInput {
    @location(0) position : vec3<f32>,
    @location(1) normal : vec3<f32>,
    @location(2) color : vec4<f32>,
};

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) color: vec4<f32>,
   
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;

@vertex
fn vertexMain(input : VertexInput) -> VertexOutput {
    var output : VertexOutput;

    let vertex = uniforms.modelViewMatrix * vec4<f32>(input.position, 1.0);

    var lambertTerm = 1.0;

    if (uniforms.useLambert == 1.0) {
        let normal = (uniforms.normalMatrix * vec4<f32>(input.normal, 1.0)).xyz;
        let lightDir = normalize(-uniforms.lightPosition);
        lambertTerm = max(dot(normal, -lightDir), 0.20);
    }

    let Ia = uniforms.lightAmbient * uniforms.materialAmbient;
    var Id = vec4<f32>(0.0);

    if (uniforms.useVertexColors == 1.0) {
        Id = uniforms.lightDiffuse * input.color * lambertTerm;
    } else {
        Id = uniforms.lightDiffuse * uniforms.materialDiffuse * lambertTerm;
    }

    output.color = vec4<f32>(Ia.rgb + Id.rgb, uniforms.alpha);
    output.position = uniforms.projectionMatrix * vertex;

    return output;
}
