struct Uniforms {
    projectionMatrix : mat4x4<f32>,
    modelViewMatrix : mat4x4<f32>,
    normalMatrix : mat4x4<f32>,
    lightPosition : vec3<f32>,
    lightDiffuse : vec3<f32>,
    lightAmbient : vec3<f32>,
    materialAmbient : vec3<f32>,
    materialDiffuse : vec4<f32>,
    shininess : f32,
    wireframe : f32,
    offScreen : f32,
};

struct FragmentInput {
    @location(0) normal: vec3<f32>,
    @location(1) lightRay: vec3<f32>,
    @location(2) eyeVector: vec3<f32>,
    @location(3) finalColor : vec4<f32>,
};

@binding(0) @group(0) var<uniform> uniforms: Uniforms;

@fragment
fn fragmentMain(input: FragmentInput) -> @location(0) vec4<f32> {
    if (uniforms.wireframe == 1) {
        return input.finalColor;
    } else if (uniforms.offScreen == 1) {
        return vec4f(uniforms.materialDiffuse); 
    } else {
        // ambient
        let Ia = uniforms.lightAmbient * uniforms.materialAmbient;

        // diffuse
        let L = normalize(input.lightRay);
        let N = normalize(input.normal);
        let lambertTerm = max(dot(N, -L), 0.33); // 0.33: 最低限の明るさを確保
        let Id = uniforms.lightDiffuse * uniforms.materialDiffuse.rgb * lambertTerm;

        // specular
        let E = normalize(input.eyeVector);
        let R = reflect(L, N);
        let specular = pow(max(dot(R, E), 0.5), uniforms.shininess); // 0.5 最低限の明るさを確保
        let Is = vec4<f32>(0.5) * specular;

        return vec4<f32>(Ia.rgb + Id.rgb + Is.rgb, uniforms.materialDiffuse.a);
    }
}