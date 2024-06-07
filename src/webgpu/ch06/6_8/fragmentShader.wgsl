struct Uniforms {
    materialAmbient: vec4<f32>,
    materialDiffuse: vec4<f32>,
    lightAmbient: vec4<f32>,
    lightDiffuse: array<vec4<f32>, 3>,
    wireframe: f32,
    lightSource: f32,
    cutOff: f32,
    exponentFactor: f32,
};

struct FragmentInput {
    @location(0) lightRay0: vec3<f32>,
    @location(1) lightRay1: vec3<f32>,
    @location(2) lightRay2: vec3<f32>,
    @location(3) normal0: vec3<f32>,
    @location(4) normal1: vec3<f32>,
    @location(5) normal2: vec3<f32>,
};

@group(0) @binding(1) var<uniform> uniforms: Uniforms;

@fragment
fn fragmentMain(input: FragmentInput) -> @location(0) vec4<f32> {
    if (uniforms.wireframe == 1.0 || uniforms.lightSource == 1.0) {
        return uniforms.materialDiffuse;
    } else {
        let Ia = uniforms.lightAmbient * uniforms.materialAmbient;
        var finalColor = vec4<f32>(0.0, 0.0, 0.0, 1.0);

        var L : vec3<f32>;
        var N : vec3<f32>;
        var lambertTerm: f32;

        for (var i = 0; i < 3; i = i + 1) {
            if (i == 0) {
                L = normalize(input.lightRay0);
                N = normalize(input.normal0);
            } else if (i == 1) {
                L = normalize(input.lightRay1);
                N = normalize(input.normal1);
            } else if (i == 2) {
                L = normalize(input.lightRay2);
                N = normalize(input.normal2);
            };

            lambertTerm = dot(N, -L);

            if (lambertTerm > uniforms.cutOff) {
                finalColor += uniforms.lightDiffuse[i] * uniforms.materialDiffuse
                * pow(lambertTerm, uniforms.exponentFactor * uniforms.cutOff);
            }
        }

        return vec4<f32>((finalColor.rgb), 1.0);
    }
}
