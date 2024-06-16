"use strict";

// 3Dシーンとのユーザーインタラクションのための共通コントロールの抽象化
class Controls {
  constructor(camera, canvas) {
    this.camera = camera;
    this.canvas = canvas;
    this.picking = false;

    this.dragging = false;
    this.picking = false;
    this.ctrl = false;

    this.x = 0;
    this.y = 0;
    this.lastX = 0;
    this.lastY = 0;
    this.button = 0;
    this.key = 0;

    this.dloc = 0;
    this.dstep = 0;
    this.motionFactor = 10;
    this.keyIncrement = 5;

    // イベントハンドラの設定
    canvas.onmousedown = (event) => this.onMouseDown(event);
    canvas.onmouseup = (event) => this.onMouseUp(event);
    canvas.onmousemove = (event) => this.onMouseMove(event);
    window.onkeydown = (event) => this.onKeyDown(event);
    window.onkeyup = (event) => this.onKeyUp(event);
  }

  // 2D座標を返す
  get2DCoords(event) {
    let top = 0,
      left = 0,
      canvas = this.canvas;

    while (canvas && canvas.tagName !== "BODY") {
      top += canvas.offsetTop;
      left += canvas.offsetLeft;
      canvas = canvas.offsetParent;
    }

    left += window.scrollX;
    top -= window.scrollY;

    return {
      x: event.clientX - left,
      y: this.canvas.height - (event.clientY - top),
    };
  }

  onMouseUp() {
    this.dragging = false;
  }

  onMouseDown(event) {
    this.dragging = true;

    this.x = event.clientX;
    this.y = event.clientY;
    this.button = event.button;

    this.dstep =
      Math.max(
        this.camera.position[0],
        this.camera.position[1],
        this.camera.position[2]
      ) / 100;
  }

  onMouseMove(event) {
    this.lastX = this.x;
    this.lastY = this.y;

    this.x = event.clientX;
    this.y = event.clientY;

    if (!this.dragging) return;

    this.ctrl = event.ctrlKey;
    this.alt = event.altKey;

    const dx = this.x - this.lastX;
    const dy = this.y - this.lastY;

    if (this.picking) {
      return;
    }

    if (!this.button) {
      this.alt ? this.dolly(dy) : this.rotate(dx, dy);
    }
  }

  onKeyDown(event) {
    this.key = event.keyCode;
    this.ctrl = event.ctrlKey;

    if (this.ctrl) return;

    switch (this.key) {
      case 37:
        return this.camera.changeAzimuth(-this.keyIncrement);
      case 38:
        return this.camera.changeElevation(this.keyIncrement);
      case 39:
        return this.camera.changeAzimuth(this.keyIncrement);
      case 40:
        return this.camera.changeElevation(-this.keyIncrement);
    }
  }

  onKeyUp(event) {
    if (event.keyCode === 17) {
      this.ctrl = false;
    }
  }

  // ドリー操作
  dolly(value) {
    if (value > 0) {
      this.dloc += this.dstep;
    } else {
      this.dloc -= this.dstep;
    }

    this.camera.dolly(this.dloc);
  }

  // 回転操作
  rotate(dx, dy) {
    const { width, height } = this.canvas;

    const deltaAzimuth = -20 / width;
    const deltaElevation = -20 / height;

    const azimuth = dx * deltaAzimuth * this.motionFactor;
    const elevation = dy * deltaElevation * this.motionFactor;

    this.camera.changeAzimuth(azimuth);
    this.camera.changeElevation(elevation);
  }
}
