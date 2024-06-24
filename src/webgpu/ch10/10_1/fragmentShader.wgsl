@group(0) @binding(1) var mySampler: sampler;
@group(0) @binding(2) var myTexture: texture_2d<f32>;

struct FragmentInput {
    @location(0) color: vec4<f32>,
    @location(1) texcoord: vec2<f32>,
};

@fragment
fn fragmentMain(input: FragmentInput) -> @location(0) vec4<f32> {
    return input.color * textureSample(myTexture, mySampler, input.texcoord);
}