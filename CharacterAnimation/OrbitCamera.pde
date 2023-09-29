import java.awt.Toolkit;

// *** Example Project ***
//Camera cam;
//void settings() { 
//  size(1200, 800, P3D);
//  smooth();
//}
//void setup() {
//  cam = new Camera();
//  fill(128);
//}
//void draw() {
//  background(255);
//  lights();
//  cam.focus();
//  box(100);
//}
// **********************


final static float screenDPI = Toolkit.getDefaultToolkit().getScreenResolution();
final static float spinThreshhold = 0.0001;

OrbitCamera singelton;

class OrbitCamera {

  int pheight;
  int pwidth;
  
  float viewPlaneDist;
  float fov;
  float radius;
  float zoom;
  float yaw;
  float pitch;
  
  PVector pos;
  PVector mousePos;
  
  float mouseZoom;
  float mouseYaw;
  float mousePitch;
    
  float mouseSensitivity;
  boolean stateChanged;
  
  OrbitCamera() {
    pos = new PVector(0, 0, 0);
    mousePos = new PVector();
    singelton = this;
    setFOV(60);
    setZoom(2);
    zoom = 2;
    setMouseSensitivity(0.8);
  }
  
  PVector getPos() {
    return new PVector(radius * -sin(-yaw) * cos(-pitch),
                       radius * sin(-pitch),
                       radius * -cos(-yaw) * cos(-pitch));
  }
  
  PVector getDir() {
        return new PVector(sin(-yaw) * cos(pitch),
                           sin(pitch),
                           cos(-yaw) * cos(pitch));
  }
  
  PVector getUp() {
    return new PVector(sin(-yaw) * sin(-pitch),
                       cos(-pitch),
                       cos(-yaw) * sin(-pitch));
  }
  
  void setPos(PVector v) {
    mousePos.set(v);
  }
  
  void shift(PVector delta) {
    mousePos.add(delta);  
  }
  
  void alignX() {
    if (mouseYaw == -HALF_PI && mousePitch == 0) {
      mouseYaw = HALF_PI;
    } else {
      mouseYaw = -HALF_PI;
      mousePitch = 0;      
    }
  }
  
  void alignY() {
    if (mouseYaw == 0 && mousePitch == HALF_PI) {
      mousePitch = -HALF_PI;
    } else {
      mousePitch = HALF_PI;      
      mouseYaw = 0;
    }
  }

  void alignZ() {    
    if (mouseYaw == 0 && mousePitch == 0) {
      mouseYaw = PI;
    } else {
      mouseYaw = 0;
      mousePitch = 0;      
    }
  }

  void setFOV(float fov) {
    this.fov = max(30, min(120, fov));
    this.stateChanged = true;
  }
  
  void setZoom(float zoom) {
    this.mouseZoom = zoom;
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
  
  void update() {
    if (windowSizeChanged() || stateChanged) {
      float radFOV =  PI * fov/180;
      float aspectRatio = 1f * width / height;
      viewPlaneDist = min(width, height) / 2f / tan(radFOV / 2);
      radius = viewPlaneDist / zoom;

      perspective(radFOV, aspectRatio, 1, radius*10); 
      camera(0, 0, 0, 0, 0, -1, 0, 1, 0);
      
      pheight = height;
      pwidth = width;
      stateChanged = false;
    }
  }
  
  void applyRotation() {
    float dYaw = mouseYaw - yaw;
    float dPitch = mousePitch - pitch;
    float speed = 5;
    
    yaw += dYaw / speed;
    pitch += dPitch / speed;
    
    PVector delta = mousePos.copy().sub(pos);
    pos.add(delta.mult(1 / speed));
    
    float dZoom = mouseZoom - zoom;
    if (abs(dZoom) > 0.001) {
      zoom += dZoom / 5;
      radius = viewPlaneDist / zoom;
    }else if (dZoom != 0) {
      zoom = mouseZoom;
      radius = viewPlaneDist / zoom;
    }
    
    translate(0, 0, radius);
    rotateZ(-PI);
    rotateX(pitch);
    rotateY(yaw);
    translate(pos.x, pos.y, pos.z);
  }
  
  void rotateByMouseMove(int dx, int dy) {
    float dYaw = mouseSensitivity * dx / screenDPI;
    float dPitch = mouseSensitivity * dy / screenDPI;
    
    mouseYaw += dYaw;
    mousePitch = max(-HALF_PI, min(HALF_PI, mousePitch - dPitch));
  }
  
  void zoomByMouseWheel(int count) {
     mouseZoom = max(0.5, min(8, mouseZoom + count / 2f));
  }
}

//idk override the mouse event itself rather than using up mouseMoved() declaration
@Override
void handleMouseEvent(MouseEvent event) {
  super.handleMouseEvent(event);
  int action = event.getAction();

  if (action == MouseEvent.DRAG) {
    int dx = mouseX - pmouseX;
    int dy = mouseY - pmouseY;
    
    if (event.getButton() == LEFT) {
      singelton.rotateByMouseMove(dx, dy);
    }else if (event.getButton() == RIGHT) {
      PVector dirY = singelton.getUp();
      PVector dirX = singelton.getDir().cross(dirY);
      singelton.shift(dirX.mult(dx).add(dirY.mult(-dy)).mult(1 / singelton.zoom));
    }
    
  }else if (action == MouseEvent.WHEEL) {
    singelton.zoomByMouseWheel(-event.getCount());
  }
}

@Override
void handleKeyEvent(KeyEvent event) {
  super.handleKeyEvent(event);

  if (event.getAction() != KeyEvent.PRESS) {
    return;  
  }
  switch(key) {
    case 'c':
      singelton.setPos(new PVector());
      break;
    case 'x':
      singelton.alignX();
      break;
    case 'y':
      singelton.alignY();
      break;
    case 'z':
      singelton.alignZ();
      break;
  }
}
