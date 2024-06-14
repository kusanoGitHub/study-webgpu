@group(0) @binding(1) var mySampler1: sampler;
@group(0) @binding(2) var myTexture1: texture_2d<f32>;
@group(0) @binding(3) var mySampler2: sampler;
@group(0) @binding(4) var myTexture2: texture_cube<f32>;

struct FragmentInput {
    @location(0) texcoord: vec2<f32>,
    @location(1) normal: vec3<f32>,
};

@fragment
fn fragmentMain(input: FragmentInput) -> @location(0) vec4<f32> {
    let texture1 = textureSample(myTexture1, mySampler1, input.texcoord);
    let texture2 = textureSample(myTexture2, mySampler2, input.normal);

    return texture1 * texture2;
}