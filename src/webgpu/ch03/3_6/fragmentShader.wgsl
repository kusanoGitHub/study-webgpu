struct VertexOutput {
  @builtin(position) position : vec4<f32>, // パイプラインに渡す。かつ@fragmentに渡す
  @location(0) fragColor : vec4<f32> // @fragmentに渡す。location(0)はフラグメントシェーダーのfragmentMainの引数location(0)に対応
};

@fragment
fn fragmentMain(output :VertexOutput) -> @location(0) vec4<f32> {
  // 頂点シェーダーから受け取った色をそのまま出力
  return output.fragColor;
}