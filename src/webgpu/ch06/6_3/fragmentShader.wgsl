struct Uniforms {
    materialAmbient: vec4<f32>,
    materialDiffuse: vec4<f32>,
    lightAmbient: vec4<f32>,
    diffuseRedLight: vec4<f32>,
    diffuseGreenLight: vec4<f32>,
    diffuseBlueLight: vec4<f32>,
    wireframe: f32,
    lightSource: f32,
    cutOff: f32,
}

struct FragmentInput {
    @location(0) normal: vec3<f32>,
    @location(1) redRay: vec3<f32>,
    @location(2) greenRay: vec3<f32>,
    @location(3) blueRay: vec3<f32>,
}

@group(0) @binding(1) var<uniform> uniforms: Uniforms;

@fragment
fn fragmentMain(input: FragmentInput) -> @location(0) vec4<f32> {
    if (uniforms.wireframe == 1 || uniforms.lightSource == 1) {
        return uniforms.materialDiffuse;
    } else {
        let Ia = uniforms.lightAmbient * uniforms.materialAmbient;
        var Id1 = vec4<f32>(0.0, 0.0, 0.0, 1.0);
        var Id2 = vec4<f32>(0.0, 0.0, 0.0, 1.0);
        var Id3 = vec4<f32>(0.0, 0.0, 0.0, 1.0);

        let N = normalize(input.normal);

        let lambertTermOne = dot(N, -normalize(input.redRay));
        let lambertTermTwo = dot(N, -normalize(input.greenRay));
        let lambertTermThree = dot(N, -normalize(input.blueRay));

        if (lambertTermOne > uniforms.cutOff) {
            Id1 = uniforms.diffuseRedLight * uniforms.materialDiffuse * lambertTermOne;
        }

        if (lambertTermTwo > uniforms.cutOff) {
            Id2 = uniforms.diffuseGreenLight * uniforms.materialDiffuse * lambertTermTwo;
        }

        if (lambertTermThree > uniforms.cutOff) {
            Id3 = uniforms.diffuseBlueLight * uniforms.materialDiffuse * lambertTermThree;
        }


        return vec4<f32>((Ia.rgb + Id1.rgb + Id2.rgb + Id3.rgb), 1.0);
    }
}