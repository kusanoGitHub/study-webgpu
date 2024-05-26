"use strict";

import {
  vec3,
  vec4,
  mat4,
} from "https://wgpu-matrix.org/dist/1.x/wgpu-matrix.module.js";

// 3Dシーンをカメラで構築および操作するための抽象化
export default class Camera {
  constructor(type = Camera.ORBITING_TYPE) {
    this.position = vec3.create();
    this.focus = vec3.create();
    this.home = vec3.create();

    this.up = vec3.create();
    this.right = vec3.create();
    this.normal = vec3.create();

    this.matrix = mat4.create();

    // これらのオプションをコンストラクタ経由で渡すこともできますし、
    // 使用者が直接変更できるようにすることもできます
    this.steps = 0;
    this.azimuth = 0;
    this.elevation = 0;
    this.fov = 45;
    this.minZ = 0.1;
    this.maxZ = 10000;

    this.setType(type);
  }

  // カメラが軌道モードにあるかどうかを返す
  isOrbiting() {
    return this.type === Camera.ORBITING_TYPE;
  }

  // カメラが追跡モードにあるかどうかを返す
  isTracking() {
    return this.type === Camera.TRACKING_TYPE;
  }

  // カメラの種類を変更する
  setType(type) {
    ~Camera.TYPES.indexOf(type)
      ? (this.type = type)
      : console.error(`Camera type (${type}) not supported`);
  }

  // カメラをホーム位置に戻す
  goHome(home) {
    if (home) {
      this.home = home;
    }

    this.setPosition(this.home);
    this.setAzimuth(0);
    this.setElevation(0);
  }

  // カメラをドリー（前後移動）する
  dolly(stepIncrement) {
    let normal = vec3.create();
    const newPosition = vec3.create();
    normal = vec3.normalize(this.normal);

    const step = stepIncrement - this.steps;

    if (this.isTracking()) {
      newPosition[0] = this.position[0] - step * normal[0];
      newPosition[1] = this.position[1] - step * normal[1];
      newPosition[2] = this.position[2] - step * normal[2];
    } else {
      newPosition[0] = this.position[0];
      newPosition[1] = this.position[1];
      newPosition[2] = this.position[2] - step;
    }

    this.steps = stepIncrement;
    this.setPosition(newPosition);
  }

  // カメラの位置を変更する
  setPosition(position) {
    this.position = vec3.copy(position);
    this.update();
  }

  // カメラの焦点を変更する
  setFocus(focus) {
    this.focus = vec3.copy(focus);
    this.update();
  }

  // カメラの方位角を設定する
  setAzimuth(azimuth) {
    this.changeAzimuth(azimuth - this.azimuth);
  }

  // カメラの方位角を変更する
  changeAzimuth(azimuth) {
    this.azimuth += azimuth;

    if (this.azimuth > 360 || this.azimuth < -360) {
      this.azimuth = this.azimuth % 360;
    }

    this.update();
  }

  // カメラの仰角を設定する
  setElevation(elevation) {
    this.changeElevation(elevation - this.elevation);
  }

  // カメラの仰角を変更する
  changeElevation(elevation) {
    this.elevation += elevation;

    if (this.elevation > 360 || this.elevation < -360) {
      this.elevation = this.elevation % 360;
    }

    this.update();
  }

  // カメラの方向を計算する
  calculateOrientation() {
    let right = vec4.fromValues(1, 0, 0, 0);
    right = vec4.transformMat4(right, this.matrix);
    this.right = vec3.copy(right);

    let up = vec4.fromValues(0, 1, 0, 0);
    up = vec4.transformMat4(up, this.matrix);
    this.up = vec3.copy(up);

    let normal = vec4.fromValues(0, 0, 1, 0);
    normal = vec4.transformMat4(normal, this.matrix);
    this.normal = vec3.copy(normal);
  }

  // カメラの値を更新する
  update() {
    mat4.identity(this.matrix);

    if (this.isTracking()) {
      mat4.translate(this.matrix, this.position, this.matrix);
      mat4.rotateY(this.matrix, (this.azimuth * Math.PI) / 180, this.matrix);
      mat4.rotateX(this.matrix, (this.elevation * Math.PI) / 180, this.matrix);
    } else {
      mat4.rotateY(this.matrix, (this.azimuth * Math.PI) / 180, this.matrix);
      mat4.rotateX(this.matrix, (this.elevation * Math.PI) / 180, this.matrix);
      mat4.translate(this.matrix, this.position, this.matrix);
    }

    // 追跡カメラの場合のみ位置を更新します。
    // 軌道カメラの場合は位置を更新しません。なぜ位置を更新しないと思いますか？
    if (this.isTracking()) {
      const position = vec4.fromValues(0, 0, 0, 1);
      vec4.transformMat4(position, this.matrix, position);
      vec3.copy(this.position, position);
    }

    this.calculateOrientation();
  }

  // ビュー変換行列を返す
  getViewTransform() {
    let matrix = mat4.create();
    matrix = mat4.inverse(this.matrix);
    return matrix;
  }
}

// カメラの2つの定義済みモード
Camera.TYPES = ["ORBITING_TYPE", "TRACKING_TYPE"];
Camera.TYPES.forEach((type) => (Camera[type] = type));
