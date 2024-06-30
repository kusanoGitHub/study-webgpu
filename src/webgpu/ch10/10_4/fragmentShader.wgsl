struct Uniforms {
    time: f32,
    width: f32,
    height: f32,
};

// 複数の戻り値を定義するために必要
struct IntersectionResult {
    t: f32,
    normal: vec3<f32>,
    color: vec3<f32>,
};

struct FragmentInput {
    @builtin(position) position: vec4<f32>,
};

@group(0) @binding(0) var<uniform> uniforms : Uniforms;

@fragment
fn fragmentMain(input: FragmentInput) -> @location(0) vec4<f32> {
    let lightDirection = normalize(vec3<f32>(-0.1, 0.5, 0.5)); // ライトの方向を正規化
    let eyePos = vec3<f32>(10.0, 0.0, 10.0); // カメラ位置
    let backgroundColor = vec3<f32>(0.2); // 背景色
    let ambient = vec3<f32>(0.05, 0.1, 0.1); // 環境光の色

    var spheres: array<vec4<f32>, 3>; // 球の配列
    var sphereColors: array<vec3<f32>, 3>; // 球の色の配列
    let maxDistance = 1024.0; // 最大交差距離

    // 時間に応じて球の位置を更新
    spheres[0] = vec4<f32>(1.5 * sin(uniforms.time), -8.0, 0.5 * cos(uniforms.time * 3.0), 1.0);
    spheres[1] = vec4<f32>(3.0 * sin(uniforms.time), -10.0, 0.5 * cos(uniforms.time * 3.0 + 3.0), 1.0);
    spheres[2] = vec4<f32>(4.5 * sin(uniforms.time), -12.0, 0.5 * cos(uniforms.time * 3.0 + 6.0), 1.0);

    // 球の色を設定
    sphereColors[0] = vec3<f32>(0.9, 0.8, 0.6);
    sphereColors[1] = vec3<f32>(0.6, 0.8, 0.9);
    sphereColors[2] = vec3<f32>(0.9, 0.4, 0.4);

    // UV座標を計算
    let inversePosition = vec2<f32>(1.0 - input.position.x, 1.0 - input.position.y);
    let uv = inversePosition * vec2<f32>(uniforms.width, uniforms.height);
    let aspectRatio = uniforms.height / uniforms.width; // アスペクト比を計算
    let ro = eyePos; // レイの開始点
    let rd = normalize(vec3<f32>(-0.5 + uv * vec2<f32>(aspectRatio, 1.0), -1.0)); // レイの方向を正規化

    var rayColor = backgroundColor; // レイの色を背景色で初期化

    // 交差判定の結果を取得
    let result = intersect(ro, rd, spheres, sphereColors, maxDistance);

    // 交差距離が最大距離未満であれば、交差したとみなす
    if (result.t < maxDistance) {
        let diffuse = clamp(dot(result.normal, lightDirection), 0.0, 1.0); // 拡散反射の強度を計算
        rayColor = result.color * diffuse + ambient; // レイの色を計算
    }

    return vec4<f32>(rayColor, 1.0); // 最終的な色を返す
}

// 球の交差距離を計算する関数
fn sphereIntersection(ro: vec3<f32>, rd: vec3<f32>, s: vec4<f32>) -> f32 {
    let oro = ro - s.xyz; // 球の中心からレイの開始点へのベクトル
    let a = dot(rd, rd); // rdの長さの二乗
    let b = 2.0 * dot(oro, rd); // 二次方程式のb項
    let c = dot(oro, oro) - s.w * s.w; // 二次方程式のc項
    let d = b * b - 4.0 * a * c; // 判別式

    if (d < 0.0) { // 判別式が負の場合、交差なし
        return d;
    }

    return (-b - sqrt(d)) / 2.0; // 最小の交差距離を返す
}

// 球の法線ベクトルを計算する関数
fn sphereNormal(pt: vec3<f32>, s: vec4<f32>) -> vec3<f32> {
    return (pt - s.xyz) / s.w; // 球の中心から交差点へのベクトルを球の半径で割る
}

// レイと球の交差判定を行う関数
fn intersect(ro: vec3<f32>, rd: vec3<f32>, spheres: array<vec4<f32>, 3>, sphereColors: array<vec3<f32>, 3>, maxDistance: f32) -> IntersectionResult {
    var distance = maxDistance; // 初期交差距離を最大距離に設定
    var normal: vec3<f32> = vec3<f32>(0.0); // 初期法線ベクトル
    var color: vec3<f32> = vec3<f32>(0.0); // 初期色

    // すべての球について交差判定を行う
    for (var i = 0u; i < 3u; i = i + 1u) {
        let intersectionDistance = sphereIntersection(ro, rd, spheres[i]); // 交差距離を計算

        // 交差距離が正で現在の最小交差距離より小さい場合
        if (intersectionDistance > 0.0 && intersectionDistance < distance) {
            distance = intersectionDistance; // 最小交差距離を更新
            let pt = ro + distance * rd; // 交差点を計算
            normal = sphereNormal(pt, spheres[i]); // 交差点の法線を計算
            color = sphereColors[i]; // 交差した球の色を取得
        }
    }

    return IntersectionResult(distance, normal, color); // 交差結果を返す
}