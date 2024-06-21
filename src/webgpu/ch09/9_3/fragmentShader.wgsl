struct Uniforms {
    projectionMatrix : mat4x4<f32>,
    modelViewMatrix : mat4x4<f32>,
    normalMatrix : mat4x4<f32>,
    lightPositions : array<vec3<f32>, 4>,
    lightDiffuses : array<vec3<f32>, 4>,
    lightSpeculars : array<vec3<f32>, 4>,
    materialDiffuse : vec3<f32>,
    materialSpecular : vec3<f32>,
    padding: f32,
    shininess : f32,
    wireframe : f32,
    illuminationMode: f32,
    alpha: f32,
};

struct FragmentInput {
    @location(0) normal: vec3<f32>,
    @location(1) farLeftLightRay: vec3<f32>,
    @location(2) farRightLightRay: vec3<f32>,
    @location(3) nearLeftLightRay: vec3<f32>,
    @location(4) nearRightLightRay: vec3<f32>,
    @location(5) eyeVector: vec3<f32>,
    @location(6) finalColor : vec4<f32>,
};

@binding(0) @group(0) var<uniform> uniforms: Uniforms;

@fragment
fn fragmentMain(input: FragmentInput) -> @location(0) vec4<f32> {
    if (uniforms.wireframe == 1) {
        return input.finalColor;
    } 

    var color = vec3<f32>(0.0, 0.0, 0.0);

    let eye = normalize(input.eyeVector);
    let normal = normalize(input.normal);
    let farLeftLight = normalize(input.farLeftLightRay);
    let farRightLight = normalize(input.farRightLightRay);
    let nearLeftLight = normalize(input.nearLeftLightRay);
    let nearRightLight = normalize(input.nearRightLightRay);

    // フラットシェーディング
    if (uniforms.illuminationMode == 1) {
        // 法線とライトベクトルの内積を計算後、最小値0.0、最大値1.0に設定し、ライトの強さを計算
        color += uniforms.lightDiffuses[0] * uniforms.materialDiffuse * clamp(dot(normal, -farLeftLight), 0.0, 1.0);
        color += uniforms.lightDiffuses[1] * uniforms.materialDiffuse * clamp(dot(normal, -farRightLight), 0.0, 1.0);
        color += uniforms.lightDiffuses[2] * uniforms.materialDiffuse * clamp(dot(normal, -nearLeftLight), 0.0, 1.0);
        color += uniforms.lightDiffuses[3] * uniforms.materialDiffuse * clamp(dot(normal, -nearRightLight), 0.0, 1.0);
    }

    // フォンシェーディング
    if (uniforms.illuminationMode == 2) {
        // 反射ベクトルを計算
        let farLeftLightReflect = reflect(farLeftLight, normal); 
        let farRightLightReflect = reflect(farRightLight, normal);
        let nearLeftLightReflect = reflect(nearLeftLight, normal);
        let nearRightLightReflect = reflect(nearRightLight, normal);
        // ディフューズ成分の計算
        color += uniforms.lightDiffuses[0] * uniforms.materialDiffuse * clamp(dot(normal, -farLeftLight), 0.0, 1.0);
        color += uniforms.lightDiffuses[1] * uniforms.materialDiffuse * clamp(dot(normal, -farRightLight), 0.0, 1.0);
        color += uniforms.lightDiffuses[2] * uniforms.materialDiffuse * clamp(dot(normal, -nearLeftLight), 0.0, 1.0);
        color += uniforms.lightDiffuses[3] * uniforms.materialDiffuse * clamp(dot(normal, -nearRightLight), 0.0, 1.0);
        // スペキュラー成分の計算
        color += uniforms.lightSpeculars[0] * uniforms.materialSpecular * pow(max(dot(farLeftLightReflect, eye), 0.0), uniforms.shininess) * 4.0;
        color += uniforms.lightSpeculars[1] * uniforms.materialSpecular * pow(max(dot(farRightLightReflect, eye), 0.0), uniforms.shininess) * 4.0;
        color += uniforms.lightSpeculars[2] * uniforms.materialSpecular * pow(max(dot(nearLeftLightReflect, eye), 0.0), uniforms.shininess) * 4.0;
        color += uniforms.lightSpeculars[3] * uniforms.materialSpecular * pow(max(dot(nearRightLightReflect, eye), 0.0), uniforms.shininess) * 4.0;
    }

    return vec4<f32>(color, uniforms.alpha);
}