struct Uniforms {
    projectionMatrix: mat4x4<f32>,
    modelViewMatrix: mat4x4<f32>,
    normalMatrix: mat4x4<f32>,
    shininess: f32,
    distance: f32,
    lightPosition: vec3<f32>,
    materialDiffuse: vec3<f32>,
    materialAmbient: vec3<f32>,
    materialSpecular: vec3<f32>,
    lightDiffuse: vec3<f32>,
    lightAmbient: vec3<f32>,
    lightSpecular: vec3<f32>,
};

struct FragmentInput {
    @location(0) normal: vec3<f32>,
    @location(1) lightRay: vec3<f32>,
    @location(2) eyeVector: vec3<f32>,
};

@binding(0) @group(0) var<uniform> uniforms: Uniforms;

@fragment
fn fragmentMain(input: FragmentInput) -> @location(0) vec4<f32> {
    let L = normalize(input.lightRay);
    let N = normalize(input.normal);
    let lambertTerm = dot(N, -L);

    // Ambient
    let Ia = uniforms.lightAmbient * uniforms.materialAmbient;
    // Diffuse
    var Id = vec3<f32>(0.0, 0.0, 0.0);
    // Specular
    var Is = vec3<f32>(0.0, 0.0, 0.0);

    if (lambertTerm > 0.0) {
        // Update diffuse
        Id = uniforms.lightDiffuse * uniforms.materialDiffuse * lambertTerm;
        let E = normalize(input.eyeVector);
        let R = reflect(L, N);
        let specular = pow(max(dot(R, E), 0.0), uniforms.shininess);
        // Update specular
        Is = uniforms.lightSpecular * uniforms.materialSpecular * specular;
    }

    // Final fragment color takes into account ambient, diffuse, and specular
    return vec4<f32>(Ia.rgb + Id.rgb + Is.rgb, 1.0);
}
