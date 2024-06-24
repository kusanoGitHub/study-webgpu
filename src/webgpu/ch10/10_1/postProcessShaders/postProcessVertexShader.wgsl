struct VertexInput {
    @location(0) position : vec2<f32>,
    @location(1) texcoord : vec2<f32>,
};

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) texcoord: vec2<f32>,
};

@vertex
fn vertexMain(input : VertexInput) -> VertexOutput {
    var output : VertexOutput;

    output.texcoord = input.texcoord;
    output.position = vec4<f32>(input.position, 0.0, 1.0);

    return output;
}
