@group(0) @binding(1) var mySampler: sampler;
@group(0) @binding(2) var myTexture: texture_2d<f32>;

struct FragmentInput {
    @location(0) lifeSpan : f32,
    @location(1) texCoord : vec2<f32>,
};

@fragment
fn fragmentMain(input: FragmentInput) -> @location(0) vec4<f32> {
    let texColor = textureSample(myTexture, mySampler, input.texCoord);

    // ライフスパンに応じてアルファ値を調整し、パーティクルが徐々に消えるようにする
    let alpha = texColor.a * input.lifeSpan;
    let fragColor = vec4<f32>(texColor.rgb, alpha);

    return fragColor;
}