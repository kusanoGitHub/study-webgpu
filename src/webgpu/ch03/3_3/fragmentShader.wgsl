struct VertexOutput {
  @builtin(position) position : vec4<f32>, 
  @location(0) fragColor : vec4<f32>
};

@fragment
fn fragmentMain(output :VertexOutput) -> @location(0) vec4<f32> {
  return output.fragColor;
}