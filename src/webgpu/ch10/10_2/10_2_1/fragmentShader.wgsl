struct FragmentInput {
    @location(0) lifeSpan : f32,
};

@fragment
fn fragmentMain(input: FragmentInput) -> @location(0) vec4<f32> {
    return vec4<f32>(1, 1, 1, input.lifeSpan);
}