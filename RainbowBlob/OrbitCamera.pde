import java.awt.Toolkit;

final static float screenDPI = Toolkit.getDefaultToolkit().getScreenResolution();
final static float spinThreshhold = 0.0001;

OrbitCamera singleton;

class OrbitCamera {

  //last recorded windows dimensions
  int pheight;
  int pwidth;

  //current camera properties
  PVector centerPos;
  float viewPlaneDist;
  float targetViewPlaneDist;
  float fov;
  float zoom;
  float yaw;
  float pitch;
  boolean isYUp;

  //properties the camera will transition to smoothly
  PVector targetCenterPos;
  float targetZoom;
  float targetYaw;
  float targetPitch;
  
  float mouseSensitivity;
  boolean stateChanged;
  boolean isOrtho;
  
  OrbitCamera() {
    singleton = this;
    centerPos = new PVector(0, 0, 0);
    targetCenterPos = new PVector();
    setFOV(60);
    setTargetZoom(1);
    zoom = .8f;
    setMouseSensitivity(.8f);
    setYUp(true);
    stateChanged = true;
    update();
  }
  
  //work around
  void toggleOrtho() {
    isOrtho = !isOrtho;  
    stateChanged = true;
  }
  
  PVector getEyePos() {
    return new PVector(
        viewPlaneDist * sin(-yaw) * cos(pitch),
        viewPlaneDist * sin(pitch),
        viewPlaneDist * cos(-yaw) * cos(pitch)).sub(this.centerPos);
  }

  /**
   * Calculates the direction the camera is looking towards.
   */
  PVector getDir() {
     return new PVector(
            sin(-yaw) * -cos(pitch),
            -sin(pitch),
            cos(-yaw) * -cos(pitch));
  }
  
  /**
   * Calculates the up vector of the camera.
   */
  PVector getUp() {
    return new PVector(
        sin(-yaw) * sin(pitch),
        -cos(pitch),
        cos(-yaw ) * sin(pitch)).mult((isYUp ? -1 : 1));
  }
  
  /**
   * Sets the center point for the camera
   */
  void setTargetPos(PVector v) {
    targetCenterPos.set(v);
  }
  
  void shiftTargetPos(PVector delta) {
    targetCenterPos.add(delta);  
  }
  
  /*
   * Aligns the camera target yaw & pitch to the x axis.
   * Rotates the camera by 180° if it is already aligned with the x axis.
   */ 
  void alignX() {
    if (targetYaw == -HALF_PI && targetPitch == 0) {
      targetYaw = HALF_PI;
    } else {
      targetYaw = -HALF_PI;
      targetPitch = 0;      
    }
  }
  
  void alignY() {
    if (targetYaw == 0 && targetPitch == HALF_PI) {
      targetPitch = -HALF_PI;
    } else {
      targetPitch = HALF_PI;      
      targetYaw = 0;
    }
  }

  void alignZ() {    
    if (targetYaw == 0 && targetPitch == 0) {
      targetYaw = PI;
    } else {
      targetYaw = 0;
      targetPitch = 0;      
    }
  }
  
   /**
   * Sets wether the y axis in the scene should be facing up or down (by default down)
   */
  void setYUp(boolean state) {
    isYUp = state;
    stateChanged = true;
  }
  
  void setFOV(float fov) {
    this.fov = max(30, min(120, fov));
    this.stateChanged = true;
  }
  
  void setTargetZoom(float zoom) {
    this.targetZoom = zoom;
  }

  void setYaw(float yaw) {
    this.yaw = yaw;
  }
  
  void setPitch(float pitch) {
    this.pitch = pitch;
  }  
  
  void setMouseSensitivity(float sensitivity) {
    this.mouseSensitivity = sensitivity;
  }
  
  boolean windowSizeChanged() {
     return pheight != height || pwidth != width;
  }
  
  /**
   * Adapts the camera to changes in window size or property changes
   */
  void update() {
    if (!windowSizeChanged() && !stateChanged) {
      return;
    }
    float radFOV = radians(fov);
    targetViewPlaneDist = .5f * max(width, height) / tan(.5f * radFOV);
    float aspectRatio = 1f * width / height;

    if (isOrtho) {
      float scale = 0.5 * aspectRatio;
      ortho(
          -scale * width / zoom, scale * width / zoom, 
          -scale * height / zoom, scale * height / zoom, 
          1, targetViewPlaneDist * 10);
    } else {
      perspective(radFOV, aspectRatio, 1, targetViewPlaneDist * 100); 
    }        
    camera(0, 0, 0, 0, 0, -1, 0, isYUp ? -1 : 1, 0);
    pheight = height;
    pwidth = width;
    stateChanged = false;
  }
  
  /**
   * Applies the camera rotation to the scene and updates rotational changes by the mouse
   */
  void applyRotation() {
    float dYaw = targetYaw - yaw;
    float dPitch = targetPitch - pitch;
    float transitionSpeed = .2f;
    
    yaw += dYaw * transitionSpeed;
    pitch += dPitch * transitionSpeed;
    
    PVector delta = targetCenterPos.copy().sub(centerPos);
    centerPos.add(delta.mult(transitionSpeed));
    
    float dZoom = targetZoom - zoom;
    if (zoom != 0) {
      if (abs(dZoom) > 0.001) {
        zoom += dZoom * transitionSpeed;
      } else {
        zoom = targetZoom;
      }
      viewPlaneDist = targetViewPlaneDist / zoom;
      stateChanged = true;
    }
    translate(0, 0, -viewPlaneDist);
    rotateX(pitch);
    rotateY(yaw);
    translate(centerPos.x, centerPos.y, centerPos.z);
  }
  
  /**
   * Calculates new target yaw & pitch by given mouse movement
   * @param dx delta x mouse movement
   * @param dy delty y mouse movement
   */
  void rotateTargetAxes(int dx, int dy) {
    int direction = isYUp ? -1 : 1;
    
    float dYaw = mouseSensitivity * dx / screenDPI * direction;
    float dPitch = mouseSensitivity * dy / screenDPI * direction;
    
    targetYaw += dYaw;
    targetPitch = max(-HALF_PI, min(HALF_PI, targetPitch - dPitch));
  }
  
  /**
   * Calculates new target pos by given mouse movement
   * @param dx delta x mouse movement
   * @param dy delty y mouse movement
   */
  void shiftTargetPos(int dx, int dy) {
    PVector dirY = singleton.getUp();
    PVector dirX = dirY.cross(singleton.getDir());
    shiftTargetPos(
        dirX.mult(dx)
        .add(dirY.mult(-dy))
        .mult(mouseSensitivity / zoom * (.0015f * targetViewPlaneDist)));
  }
  
  /**
   * Increases or decreses the target zooms by mouse wheel steps
   */
  void addScrollToTargetZoom(int scrollCount) {
     targetZoom = max(0.5, min(8, targetZoom + scrollCount / 2f));
  }
}

//registers mouse clicks and wheel movement
@Override
void handleMouseEvent(MouseEvent event) {
  super.handleMouseEvent(event);
  int action = event.getAction();

  if (action == MouseEvent.DRAG) {
    int dx = mouseX - pmouseX;
    int dy = mouseY - pmouseY;
    
    if (event.getButton() == LEFT) {
      singleton.rotateTargetAxes(dx, dy);
    }else if (event.getButton() == RIGHT) {
      singleton.shiftTargetPos(dx, dy);
    }
  }else if (action == MouseEvent.WHEEL) {
    singleton.addScrollToTargetZoom(-event.getCount());
  }
}

@Override
void handleKeyEvent(KeyEvent event) {
  super.handleKeyEvent(event);

  if (event.getAction() != KeyEvent.PRESS) {
    return;  
  }
  switch(key) {
    case ' ':
      singleton.toggleOrtho();
    case 'c':
      singleton.setTargetPos(new PVector());
      break;
    case 'x':
      singleton.alignX();
      break;
    case 'y':
      singleton.alignY();
      break;
    case 'z':
      singleton.alignZ();
      break;
  }
}

void testCamera() {
  OrbitCamera cam = new OrbitCamera();  
  cam.yaw = 0;
  cam.pitch = 0;
  assert(isSimilar(new PVector(0, 0, -1), cam.getDir()));
  assert(isSimilar(new PVector(0, -1, 0), cam.getUp()));
  
  cam.yaw = HALF_PI;
  cam.pitch = 0;
  assert(isSimilar(new PVector(1, 0, 0), cam.getDir()));
  assert(isSimilar(new PVector(0, -1, 0), cam.getUp()));

  cam.yaw = HALF_PI;
  cam.pitch = HALF_PI;
  assert(isSimilar(new PVector(0, -1, 0), cam.getDir()));
  assert(isSimilar(new PVector(-1, 0, 0), cam.getUp()));

  cam.yaw = 0;
  cam.pitch = -QUARTER_PI;
  println(cam.getDir(), cam.getUp());
  assert(isSimilar(new PVector(0, 0.7071, -0.7071), cam.getDir()));
  assert(isSimilar(new PVector(0, -0.7071, -0.7071), cam.getUp()));

}

boolean isSimilar(PVector v0, PVector v1) {
  float epsilon = 0.001f;
  return 
      abs(v1.x - v0.x) < epsilon &&
      abs(v1.y - v0.y) < epsilon &&
      abs(v1.z - v0.z) < epsilon;
}
