struct Uniforms {
    projectionMatrix : mat4x4<f32>,
    modelViewMatrix : mat4x4<f32>,
    normalMatrix : mat4x4<f32>,
    lightPosition : vec3<f32>,
    lightDiffuse : vec3<f32>,
    lightAmbient : vec3<f32>,
    materialDiffuse : vec3<f32>,
    materialAmbient : vec3<f32>,
    materialSpecular : vec3<f32>,
    wireframe : f32,
};

struct VertexInput {
    @location(0) position : vec3<f32>,
    @location(1) normal : vec3<f32>,
};

struct VertexOutput {
    @builtin(position) position : vec4<f32>,
    @location(0) finalColor : vec4<f32>,
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;

@vertex
fn vertexMain(input : VertexInput) -> VertexOutput {
    var output : VertexOutput;
    
    if (uniforms.wireframe == 1) {
        output.finalColor = vec4<f32>(uniforms.materialDiffuse, 1.0);
    } else {
        let N = (uniforms.normalMatrix * vec4<f32>(input.normal, 0.0)).xyz;
        let L = normalize(-uniforms.lightPosition);
        var lambertTerm = dot(N, -L);
        
        if (lambertTerm == 0.0) {
            lambertTerm = 0.01;
        }
        
        let Ia = uniforms.lightAmbient;
        let Id = uniforms.materialDiffuse * uniforms.lightDiffuse * lambertTerm;
        
        output.finalColor = vec4<f32>(Ia.rgb + Id.rgb, 1.0);
    }
    
    output.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * vec4<f32>(input.position, 1.0);
    return output;
}
