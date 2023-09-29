import java.awt.Toolkit;

Camera singeltonCamera;

class Camera {

  final float screenDPI = Toolkit.getDefaultToolkit().getScreenResolution();
  final float spinThreshhold = 0.0001;

  int pheight;
  int pwidth;
  
  float fov;
  float focusDist;

  boolean cameraDraggingEnabled;
  boolean pitchLockEnabled;
  
  float yaw;
  float pitch;
  float yawSpin;
  float pitchSpin;
  
  float dragSensitivity;
  float spinFriction;
    
  long lastFocus;
  long accumulator;
  
  Camera() {
    
    singeltonCamera = this;
    setFOV(60);
    
    setCameraDraggingEnabled(true);
    setDragSensitivity(0.25);
    setSpinFriction(0.05);
    setPitchLockEnabled(true);
    
    lastFocus = System.currentTimeMillis();
  }
  
  public PVector getPos() {
    return new PVector(focusDist * sin(-yaw) * cos(pitch),
                       focusDist * sin(pitch),
                       focusDist * cos(-yaw) * cos(pitch));
  }
  
  void setFOV(float newFOV) {
    fov = max(30, min(110, newFOV));
    focus(true);
  }
  
  void setYaw(float newYaw) {
    yaw = newYaw;
  }
  
  void setPitch(float newPitch) {
    pitch = newPitch;
  }
  
  void setYawSpin(float spin) {
    yawSpin = spin;
  }
  
  void setPitchSpin(float spin) {
    pitchSpin = spin;
  }
  
  void stopSpin() {
    yawSpin = 0;
    pitchSpin = 0;
    return;
  }
  
  void setCameraDraggingEnabled(boolean state) {
    
    cameraDraggingEnabled = state;
    
    if(!cameraDraggingEnabled) {
      yawSpin = 0;
      pitchSpin = 0;
    }
  }
  
  void setPitchLockEnabled(boolean state) {
    pitchLockEnabled = state;
  }
  
  void setSpinFriction(float friction) {
    spinFriction = friction;
  }
  
  void setDragSensitivity(float sensitivity) {
    dragSensitivity = sensitivity;
  }
  
  private boolean windowSizeChanged() {
     return pheight != height || pwidth != width;
  }
  
  void focus() {
    focus(false);
  }
  
  void focus(boolean force) {
    
    if(force || windowSizeChanged()) {
      
      float radFOV =  PI * fov/180;
      float aspectRatio = 1f * width / height;
      focusDist = min(width, height)/2f / tan(radFOV/2);
      
      camera(0, 0, focusDist, 0, 0, 0, 0, 1, 0);
      perspective(radFOV, aspectRatio, abs(focusDist)/10, abs(focusDist)*2); 
      
      pheight = height;
      pwidth = width;      
    }
    
    if(cameraDraggingEnabled)
      spinCamera();
    
    rotateZ(-PI);
    rotateX(pitch);
    rotateY(yaw);
    
    lastFocus = System.currentTimeMillis();
  }
  
  private void spinCamera() {
    
    if(yawSpin == 0 && pitchSpin == 0)
      return;
    
    accumulator += System.currentTimeMillis() - lastFocus;
    
    while(accumulator > 1000/60) {
      
      yaw += yawSpin;
      pitch += pitchSpin;
      
      yawSpin *= 1-spinFriction;
      pitchSpin *= 1-spinFriction;
      
      accumulator -= 1000/60;
    }

    if(abs(yaw) > PI)
      yaw = -Math.signum(yaw) * (TWO_PI - abs(yaw));
    
    if(pitchLockEnabled) {
      if(abs(pitch) > HALF_PI)
        pitch = Math.signum(pitch) * HALF_PI;
        
    }else if((abs(pitch) > PI))
      pitch = -Math.signum(pitch) * (TWO_PI - abs(pitch));
      
    if(mousePressed)
      stopSpin();
    
    if(abs(yawSpin) < spinThreshhold)
      yawSpin = 0;
    if(abs(pitchSpin) < spinThreshhold)
      pitchSpin = 0;
  }
  
  void performSpin() {
     
    if(!cameraDraggingEnabled)
      return;
      
    float spinX = dragSensitivity * (mouseX-pmouseX) / (screenDPI);
    float spinY = dragSensitivity * (mouseY-pmouseY) / (screenDPI);
    
    yawSpin   = -PI * spinX;
    pitchSpin =  PI * spinY;
  }
}

@Override
void handleMouseEvent(MouseEvent event) {
  
  super.handleMouseEvent(event);
  
  int action = event.getAction();

  if(action == MouseEvent.DRAG &&
     event.getButton() == LEFT) {
    
    singeltonCamera.performSpin();  
  }
}
