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

    var frameColor = offsetLookup(-4.0, 0.0, yInvertTexcoord) * 0.05; // 5%
    frameColor += offsetLookup(-3.0, 0.0, yInvertTexcoord) * 0.09; // 9%
    frameColor += offsetLookup(-2.0, 0.0, yInvertTexcoord) * 0.12; // 12%
    frameColor += offsetLookup(-1.0, 0.0, yInvertTexcoord) * 0.15; // 15%
    frameColor += offsetLookup(0.0, 0.0, yInvertTexcoord) * 0.16; // 16%
    frameColor += offsetLookup(1.0, 0.0, yInvertTexcoord) * 0.15; // 15%
    frameColor += offsetLookup(2.0, 0.0, yInvertTexcoord) * 0.12; // 12%
    frameColor += offsetLookup(3.0, 0.0, yInvertTexcoord) * 0.09; // 9%
    frameColor += offsetLookup(4.0, 0.0, yInvertTexcoord) * 0.05; // 5%
    return frameColor;
}

fn offsetLookup(xOffset: f32, yOffset: f32, yInvertTexcoord: vec2<f32>) -> vec4<f32> {
    return textureSample(
        logoTexture,
        logoSampler, 
        vec2<f32>(
            yInvertTexcoord.x + xOffset * uniforms.width,
            yInvertTexcoord.y + yOffset * uniforms.height
        )
    );
}