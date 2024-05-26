"use strict";

// A set of utility functions for ../common operations across our application
const utils = {
  // Find and return a DOM element given an ID
  getCanvas(id) {
    const canvas = document.getElementById(id);

    if (!canvas) {
      console.error(`There is no canvas with id ${id} on this page.`);
      return null;
    }

    return canvas;
  },

  // Given a canvas element, return the WebGL2 context
  getGPUContext(canvas) {
    return (
      canvas.getContext("webgpu") ||
      console.error("WebGPU is not available in your browser.")
    );
  },

  // Normalize colors from 0-255 to 0-1
  normalizeColor(color) {
    return color.map((c) => c / 255);
  },

  // De-normalize colors from 0-1 to 0-255
  denormalizeColor(color) {
    return color.map((c) => c * 255);
  },

  // バッファサイズのパディング

  padUint16ArrayToMultipleOf4(array) {
    const byteLength = array.byteLength;
    const paddingSize = (4 - (byteLength % 4)) % 4;
    const paddedArray = new Uint8Array(byteLength + paddingSize);
    paddedArray.set(new Uint8Array(array.buffer));
    return new Uint16Array(paddedArray.buffer);
  },

  // 頂点情報とインデックス情報を受け取り、法線情報を計算して返す
  createNormals(vertices, indices) {
    const x = 0,
      y = 1,
      z = 2;
    const normals = new Array(vertices.length).fill(0); // 法線を初期化

    // 各三角形について法線を計算
    for (let i = 0; i < indices.length; i += 3) {
      const i0 = indices[i] * 3;
      const i1 = indices[i + 1] * 3;
      const i2 = indices[i + 2] * 3;

      const v0 = [vertices[i0 + x], vertices[i0 + y], vertices[i0 + z]];
      const v1 = [vertices[i1 + x], vertices[i1 + y], vertices[i1 + z]];
      const v2 = [vertices[i2 + x], vertices[i2 + y], vertices[i2 + z]];

      // ベクトル v1 (v1 - v0)
      const vector1 = [v1[x] - v0[x], v1[y] - v0[y], v1[z] - v0[z]];
      // ベクトル v2 (v2 - v0)
      const vector2 = [v2[x] - v0[x], v2[y] - v0[y], v2[z] - v0[z]];

      // 外積による法線計算
      const normal = [
        vector1[y] * vector2[z] - vector1[z] * vector2[y],
        vector1[z] * vector2[x] - vector1[x] * vector2[z],
        vector1[x] * vector2[y] - vector1[y] * vector2[x],
      ];

      // 法線ベクトルの更新
      for (let j = 0; j < 3; j++) {
        const idx = indices[i + j] * 3;
        normals[idx + x] += normal[x];
        normals[idx + y] += normal[y];
        normals[idx + z] += normal[z];
      }
    }

    // 法線の正規化
    for (let i = 0; i < vertices.length; i += 3) {
      const len = Math.sqrt(
        normals[i + x] * normals[i + x] +
          normals[i + y] * normals[i + y] +
          normals[i + z] * normals[i + z]
      );
      if (len > 0) {
        normals[i + x] /= len;
        normals[i + y] /= len;
        normals[i + z] /= len;
      }
    }

    return normals;
  },

  // 各頂点に対して、その位置データの後にその法線データが続く形式の配列を作成
  calculateNormals(vs, ind) {
    const x = 0,
      y = 1,
      z = 2,
      ns = new Array(vs.length).fill(0); // 法線を初期化

    // 頂点毎に法線を計算
    for (let i = 0; i < ind.length; i += 3) {
      const v1 = [],
        v2 = [],
        normal = [];

      // 各頂点インデックス
      const i0 = 3 * ind[i],
        i1 = 3 * ind[i + 1],
        i2 = 3 * ind[i + 2];

      // ベクトル v1 (p2 - p1)
      v1[x] = vs[i2 + x] - vs[i1 + x];
      v1[y] = vs[i2 + y] - vs[i1 + y];
      v1[z] = vs[i2 + z] - vs[i1 + z];

      // ベクトル v2 (p0 - p1)
      v2[x] = vs[i0 + x] - vs[i1 + x];
      v2[y] = vs[i0 + y] - vs[i1 + y];
      v2[z] = vs[i0 + z] - vs[i1 + z];

      // 外積による法線計算
      normal[x] = v1[y] * v2[z] - v1[z] * v2[y];
      normal[y] = v1[z] * v2[x] - v1[x] * v2[z];
      normal[z] = v1[x] * v2[y] - v1[y] * v2[x];

      // 法線ベクトルの更新
      for (let j = 0; j < 3; j++) {
        const idx = 3 * ind[i + j];
        ns[idx + x] += normal[x];
        ns[idx + y] += normal[y];
        ns[idx + z] += normal[z];
      }
    }

    // 法線の正規化と頂点データとの結合
    const verticesWithNormals = new Float32Array(vs.length * 2);
    for (let i = 0; i < vs.length; i += 3) {
      const len = Math.sqrt(
        ns[i + x] * ns[i + x] + ns[i + y] * ns[i + y] + ns[i + z] * ns[i + z]
      );
      const scale = len > 0 ? 1.0 / len : 1.0;

      const vertexOffset = i * 2;
      verticesWithNormals[vertexOffset] = vs[i + x];
      verticesWithNormals[vertexOffset + 1] = vs[i + y];
      verticesWithNormals[vertexOffset + 2] = vs[i + z];
      verticesWithNormals[vertexOffset + 3] = ns[i + x] * scale;
      verticesWithNormals[vertexOffset + 4] = ns[i + y] * scale;
      verticesWithNormals[vertexOffset + 5] = ns[i + z] * scale;
    }

    return verticesWithNormals;
  },

  // A simpler API on top of the dat.GUI API, specifically
  // designed for this book for a simpler codebase
  configureControls(settings, options = { width: 300 }) {
    // Check if a gui instance is passed in or create one by default
    const gui = options.gui || new dat.GUI(options);
    const state = {};

    const isAction = (v) => typeof v === "function";

    const isFolder = (v) =>
      !isAction(v) &&
      typeof v === "object" &&
      (v.value === null || v.value === undefined);

    const isColor = (v) =>
      (typeof v === "string" && ~v.indexOf("#")) ||
      (Array.isArray(v) && v.length >= 3);

    Object.keys(settings).forEach((key) => {
      const settingValue = settings[key];

      if (isAction(settingValue)) {
        state[key] = settingValue;
        return gui.add(state, key);
      }
      if (isFolder(settingValue)) {
        // If it's a folder, recursively call with folder as root settings element
        return utils.configureControls(settingValue, {
          gui: gui.addFolder(key),
        });
      }

      const {
        value,
        min,
        max,
        step,
        options,
        onChange = () => null,
      } = settingValue;

      // set state
      state[key] = value;

      let controller;

      // There are many other values we can set on top of the dat.GUI
      // API, but we'll only need a few for our purposes
      if (options) {
        controller = gui.add(state, key, options);
      } else if (isColor(value)) {
        controller = gui.addColor(state, key);
      } else {
        controller = gui.add(state, key, min, max, step);
      }

      controller.onChange((v) => onChange(v, state));
    });
  },

  // Calculate tangets for a given set of vertices
  calculateTangents(vs, tc, ind) {
    const tangents = [];

    for (let i = 0; i < vs.length / 3; i++) {
      tangents[i] = [0, 0, 0];
    }

    let a = [0, 0, 0],
      b = [0, 0, 0],
      triTangent = [0, 0, 0];

    for (let i = 0; i < ind.length; i += 3) {
      const i0 = ind[i];
      const i1 = ind[i + 1];
      const i2 = ind[i + 2];

      const pos0 = [vs[i0 * 3], vs[i0 * 3 + 1], vs[i0 * 3 + 2]];
      const pos1 = [vs[i1 * 3], vs[i1 * 3 + 1], vs[i1 * 3 + 2]];
      const pos2 = [vs[i2 * 3], vs[i2 * 3 + 1], vs[i2 * 3 + 2]];

      const tex0 = [tc[i0 * 2], tc[i0 * 2 + 1]];
      const tex1 = [tc[i1 * 2], tc[i1 * 2 + 1]];
      const tex2 = [tc[i2 * 2], tc[i2 * 2 + 1]];

      vec3.subtract(a, pos1, pos0);
      vec3.subtract(b, pos2, pos0);

      const c2c1b = tex1[1] - tex0[1];
      const c3c1b = tex2[0] - tex0[1];

      triTangent = [
        c3c1b * a[0] - c2c1b * b[0],
        c3c1b * a[1] - c2c1b * b[1],
        c3c1b * a[2] - c2c1b * b[2],
      ];

      vec3.add(triTangent, tangents[i0], triTangent);
      vec3.add(triTangent, tangents[i1], triTangent);
      vec3.add(triTangent, tangents[i2], triTangent);
    }

    // Normalize tangents
    const ts = [];
    tangents.forEach((tan) => {
      vec3.normalize(tan, tan);
      ts.push(tan[0]);
      ts.push(tan[1]);
      ts.push(tan[2]);
    });

    return ts;
  },
};
