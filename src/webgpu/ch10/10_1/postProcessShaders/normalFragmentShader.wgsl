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

    // normal
    return textureSample(logoTexture, logoSampler, yInvertTexcoord);

    // greyscale
    // let frameColor = textureSample(logoTexture, logoSampler, yInvertTexcoord);
    // let luminance = frameColor.r * 0.3 + frameColor.g * 0.59 + frameColor.b * 0.11;
    // return vec4<f32>(luminance, luminance, luminance, frameColor.a);

    // invert
    // let frameColor = textureSample(logoTexture, logoSampler, yInvertTexcoord);
    // return vec4<f32>(1.0 - frameColor.r, 1.0 - frameColor.g, 1.0 - frameColor.b, frameColor.a);

    // wavy
    // let speed = 15.0;
    // let magnitude = 0.015;
    // var wavyCoord = vec2<f32>(0.0, 0.0);
    // wavyCoord.x = yInvertTexcoord.x + sin(uniforms.time + yInvertTexcoord.y * speed) * magnitude;
    // wavyCoord.y = yInvertTexcoord.y + cos(uniforms.time + yInvertTexcoord.x * speed) * magnitude;
    // return textureSample(logoTexture, logoSampler, wavyCoord);

    // blur
    // var frameColor = offsetLookup(-4.0, 0.0, yInvertTexcoord) * 0.05; // 5%
    // frameColor += offsetLookup(-3.0, 0.0, yInvertTexcoord) * 0.09; // 9%
    // frameColor += offsetLookup(-2.0, 0.0, yInvertTexcoord) * 0.12; // 12%
    // frameColor += offsetLookup(-1.0, 0.0, yInvertTexcoord) * 0.15; // 15%
    // frameColor += offsetLookup(0.0, 0.0, yInvertTexcoord) * 0.16; // 16%
    // frameColor += offsetLookup(1.0, 0.0, yInvertTexcoord) * 0.15; // 15%
    // frameColor += offsetLookup(2.0, 0.0, yInvertTexcoord) * 0.12; // 12%
    // frameColor += offsetLookup(3.0, 0.0, yInvertTexcoord) * 0.09; // 9%
    // frameColor += offsetLookup(4.0, 0.0, yInvertTexcoord) * 0.05; // 5%
    // return frameColor;

    // film grain
    // let grainIntensity: f32 = 0.1;
    // let scrollSpeed: f32 = 4000;
    // let frameColor = textureSample(logoTexture, logoSampler, yInvertTexcoord);
    // let grain = textureSample(
    //     noiseTexture,
    //     noiseSampler,
    //     input.texcoord * 2.0 + uniforms.time * scrollSpeed * vec2<f32>(uniforms.width, uniforms.height)
    // );
    // return frameColor - (grain * grainIntensity);
}

// blur
// fn offsetLookup(xOffset: f32, yOffset: f32, yInvertTexcoord: vec2<f32>) -> vec4<f32> {
//     return textureSample(
//         logoTexture,
//         logoSampler, 
//         vec2<f32>(
//             yInvertTexcoord.x + xOffset * uniforms.width,
//             yInvertTexcoord.y + yOffset * uniforms.height
//         )
//     );
// }