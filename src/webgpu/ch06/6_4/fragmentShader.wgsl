struct Uniforms {
    materialAmbient: vec4<f32>,
    materialDiffuse: vec4<f32>,
    lightAmbient: vec4<f32>,
    lightDiffuse: array<vec4<f32>, 3>,
    wireframe: f32,
    lightSource: f32,
    cutOff: f32,
};

struct FragmentInput {
    @location(0) normal: vec3<f32>,
    @location(1) lightRay0: vec3<f32>,
    @location(2) lightRay1: vec3<f32>,
    @location(3) lightRay2: vec3<f32>,
};

@group(0) @binding(1) var<uniform> uniforms: Uniforms;

@fragment
fn fragmentMain(input: FragmentInput) -> @location(0) vec4<f32> {
    if (uniforms.wireframe == 1.0 || uniforms.lightSource == 1.0) {
        return uniforms.materialDiffuse;
    } else {
        let Ia = uniforms.lightAmbient * uniforms.materialAmbient;
        var finalColor = vec4<f32>(0.0, 0.0, 0.0, 1.0);

        let N = normalize(input.normal);

        for (var i = 0; i < 3; i = i + 1) {
            var L : vec3<f32>;
            if (i == 0) {
                L = normalize(input.lightRay0);
            } else if (i == 1) {
                L = normalize(input.lightRay1);
            } else {
                L = normalize(input.lightRay2);
            };

            let lambertTerm = dot(N, -L);
            if (lambertTerm > uniforms.cutOff) {
                finalColor += uniforms.lightDiffuse[i] * uniforms.materialDiffuse * lambertTerm;
            }
        }

        return vec4<f32>((Ia.rgb + finalColor.rgb), 1.0);
    }
}
