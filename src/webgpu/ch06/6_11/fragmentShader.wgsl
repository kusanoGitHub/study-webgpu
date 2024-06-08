struct Uniforms {
    projectionMatrix : mat4x4<f32>,
    modelViewMatrix : mat4x4<f32>,
    normalMatrix : mat4x4<f32>,
    lightPosition : vec3<f32>,
    lightDiffuse : vec4<f32>,
    lightAmbient : vec4<f32>,
    materialDiffuse : vec4<f32>, 
    materialAmbient : vec4<f32>, 
    wireframe : f32,
};

struct FragmentInput {
    @location(0) normal: vec3<f32>,
    @location(1) lightRay: vec3<f32>,
    @location(2) finalColor: vec4<f32>,
}

@group(0) @binding(0) var<uniform> uniforms: Uniforms;

@fragment
fn fragmentMain(input: FragmentInput) -> @location(0) vec4<f32> {
    if (uniforms.wireframe == 1) {
        return input.finalColor;
    } else {
        let L = normalize(input.lightRay);
        let N = normalize(input.normal);
        let lambertTerm = clamp(dot(N, -L), 0.0, 1.0);
        let Ia = uniforms.lightAmbient * uniforms.materialAmbient;
        let Id = uniforms.lightDiffuse * uniforms.materialDiffuse * lambertTerm;

        return vec4<f32>((Ia + Id).xyz, uniforms.materialDiffuse.a);
    }
}