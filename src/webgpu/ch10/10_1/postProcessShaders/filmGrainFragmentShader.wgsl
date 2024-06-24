struct Uniforms {
    time: f32,
    width: f32,
    height: f32,
};

@group(0) @binding(0) var logoSampler: sampler;
@group(0) @binding(1) var logoTexture: texture_2d<f32>;
@group(0) @binding(2) var<uniform> uniforms : Uniforms;
@group(0) @binding(3) var noiseSampler: sampler; // ノイズ用
@group(0) @binding(4) var noiseTexture: texture_2d<f32>; // ノイズ用

struct FragmentInput {
    @location(0) texcoord: vec2<f32>,
};

@fragment
fn fragmentMain(input: FragmentInput) -> @location(0) vec4<f32> {
    let yInvertTexcoord = vec2(input.texcoord.x, 1.0 - input.texcoord.y); // 上下反転

    let grainIntensity: f32 = 0.1;
    let scrollSpeed: f32 = 4000;
    let frameColor = textureSample(logoTexture, logoSampler, yInvertTexcoord);
    let grain = textureSample(
        noiseTexture,
        noiseSampler,
        input.texcoord * 2.0 + uniforms.time * scrollSpeed * vec2<f32>(uniforms.width, uniforms.height)
    );
    return frameColor - (grain * grainIntensity);
}