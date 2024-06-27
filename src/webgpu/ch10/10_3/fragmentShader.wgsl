struct Uniforms {
    projectionMatrix : mat4x4<f32>,
    modelViewMatrix : mat4x4<f32>,
    normalMatrix : mat4x4<f32>,
    lightPosition : vec3<f32>,
    lightDiffuse : vec4<f32>,
    lightAmbient : vec4<f32>,
    materialDiffuse : vec4<f32>, 
    materialAmbient : vec4<f32>, 
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;
@group(0) @binding(1) var mySampler: sampler;
@group(0) @binding(2) var myTexture: texture_2d<f32>;
@group(0) @binding(3) var normalSampler: sampler;
@group(0) @binding(4) var normalTexture: texture_2d<f32>;

struct FragmentInput {
    @location(0) texcoord: vec2<f32>,
    @location(1) tangentLightDirection: vec3<f32>,
    @location(2) tangentEyeDirection: vec3<f32>,
};

@fragment
fn fragmentMain(input: FragmentInput) -> @location(0) vec4<f32> {
    // 法線テクスチャのサンプル値を取り出し、[-1, 1]の範囲に正規化
    let normal = normalize(2.0 * (textureSample(normalTexture, normalSampler, input.texcoord).rgb - 0.5));
    // 入力の光の方向を正規化
    let lightDirection = normalize(input.tangentLightDirection);
    // Lambert拡散反射項を計算（最低値0.20を確保）
    let lamertTerm = max(dot(normal, lightDirection), 0.20);
    // 入力の視線方向を正規化
    let eyeDirection = normalize(input.tangentEyeDirection);
    // 反射方向ベクトルを計算
    let reflectDirection = reflect(-lightDirection, normal);

    // 鏡面反射
    let Is = pow(clamp(dot(reflectDirection, eyeDirection), 0.0, 1.0), 8.0);
    // 環境光
    let Ia = uniforms.lightAmbient * uniforms.materialAmbient;
    // 拡散反射
    let Id = uniforms.lightDiffuse * uniforms.materialDiffuse * textureSample(myTexture, mySampler, input.texcoord) * lamertTerm;

    return vec4<f32>(Ia + Id + Is);
}