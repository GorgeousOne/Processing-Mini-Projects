import java.util.Scanner;
import java.io.FileNotFoundException;
import java.io.FileWriter;

OrbitCamera cam;
Body enemy;
Ui ui;

void settings() { 
  size(720, 720, P3D);
  smooth();
}

int highlightPart = -1;

void setup() {
  cam = new OrbitCamera();
  enemy = new Body();
  ui = new Ui(cam, enemy, dataPath("walking"));
  
  fill(255);
}

void draw() {
  background(255);
  scale(1, 1, -1);
  lights();
  cam.update();
  pushMatrix();
  cam.applyRotation();
  
  displayOrigin();
  
  pushMatrix();
  translate(0, -97.4361, 9);
  displayFloor(100);
  popMatrix();
  
  enemy.display();
  popMatrix();
  
  noLights();
  ui.display();
}

void drawUI() {
  translate(-width/2f, -height/2f, cam.viewPlaneDist);
  beginShape();
  vertex(10, 10, 0);
  vertex(20, 10, 0);
  vertex(20, 20, 0);
  vertex(10, 20, 0);
  endShape();
}

void displayOrigin() {
  pushStyle();
  stroke(255, 0, 0);
  line(0, 0, 0, 100, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 100, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 100);
  stroke(0);
  popStyle();
}

void displayFloor(float size) {
  beginShape();
  normal(0, 1, 0);
  vertex(-size, 0, -size);
  vertex(-size, 0,  size);
  vertex( size, 0,  size);
  vertex( size, 0, -size);
  endShape();
  
  for (int i = 0; i < size; i += 10) {
    line(-size, 0,  i, size, 0,  i);
    line(-size, 0, -i, size, 0, -i);
    line( i, 0, -size,  i, 0, size);
    line(-i, 0, -size, -i, 0, size);
  }
}

void mouseReleased(MouseEvent event) {
    ui.handleClick(mouseX, mouseY, event.getButton());  
}

boolean shiftPressed;
boolean rotateKeyTyped;
boolean translateKeyTyped;
boolean interpolateKeyTyped;

PVector transformAxis;
float startMouseX;

boolean rotationEnabled;
boolean translationEnabled;
PVector startRotation;
PVector startPos;

float mouseSensitivity = 0.2;
void mouseMoved() {
  float delta = mouseSensitivity * (mouseX - startMouseX);
  
  if (rotationEnabled) {
    enemy.parts[highlightPart].rot = startRotation.copy().add(transformAxis.copy().mult(delta));
  } else if (translationEnabled) {
    enemy.pos = startPos.copy().add(transformAxis.copy().mult(delta));
  }
}

void keyPressed() {
  switch(keyCode) {
    case SHIFT:
      shiftPressed = true;
      break;
    case TAB:
      highlightNext(shiftPressed? -1 : 1);
      break;
    case ESC:
      if (rotateKeyTyped) {
        rotateKeyTyped = false;
        rotationEnabled = false;
        enemy.parts[highlightPart].rot = startRotation;
      } else if (translateKeyTyped) {
        translateKeyTyped = false;
        translationEnabled = false;
        enemy.pos = startPos;
      }
      interpolateKeyTyped = false;
      key = 0;
      break;
    case ENTER:
      if (rotationEnabled) {
        rotateKeyTyped = false;
        rotationEnabled = false;
        ui.updateCurrentPose();
      } else if (translationEnabled) {
        translateKeyTyped = false;
        translationEnabled = false;
        ui.updateCurrentPose();
      }
      break;
  }
  if (key == ' ') {
    if (ui.isAnimating) {
      ui.stopAnimation();  
    } else {
      ui.playAnimation();  
    }
  }
  if (ui.isAnimating) {
    return;  
  }
  switch(key) {
    case 'd':
      ui.repeatCycleMirrored();
      break;
    case 'm':
      mirrorBody(enemy);
      ui.updateCurrentPose();
      break;
    case 's':
      ui.savePoses();
      break;
    case 'r':
      if (highlightPart != -1 && !rotationEnabled && !translationEnabled) {
        startRotation = enemy.parts[highlightPart].rot.copy();
        startMouseX = mouseX;
        rotateKeyTyped = true;
        translateKeyTyped = false;
        interpolateKeyTyped = false;
      }
      break;
    case 'g':
      if (!rotationEnabled && !translationEnabled) {
        startPos = enemy.pos;
        startMouseX = mouseX;
        translateKeyTyped = true;
        rotateKeyTyped = false;
        interpolateKeyTyped = false;
      }
      break;
    case 'i':
      if (!rotationEnabled && !translationEnabled) {
        interpolateKeyTyped = true;
        translateKeyTyped = false;
        rotateKeyTyped = false;
      }
  }
  if (rotateKeyTyped || translateKeyTyped) {
    switch(key) {
      case 'x':
        transformAxis = new PVector(1, 0, 0);
        break;
      case 'y':
        transformAxis = new PVector(0, 1, 0);
        break;
      case 'z':
        transformAxis = new PVector(0, 0, 1);
        break;
      default:
        return;
    }
    key = 0;
    
    if (rotateKeyTyped) {
      rotationEnabled = true;
    }else {
      translationEnabled = true;  
    }
  }
  if (interpolateKeyTyped && Character.isDigit(key)) {
    int steps = Character.getNumericValue(key);
    
    if (steps > 0) {
      ui.interpolatePoses(steps);
    }
    interpolateKeyTyped = false;   
  }
}

void keyReleased() {
  if (keyCode == SHIFT) {
    shiftPressed = false;
  }
  if (Character.isDigit(key)) {
    highlightPart(Math.floorMod(Character.getNumericValue(key) - 1, 10));
  }
}

void highlightPart(int index) {
  if (index < 0 || index >= enemy.parts.length || rotationEnabled) {
    return;
  }
  if (highlightPart != -1) {
    enemy.parts[highlightPart].toggleHighlight();  
  }
  enemy.parts[index].toggleHighlight(); 
  highlightPart = index;
}

void highlightNext(int dIndex) {
  highlightPart(Math.floorMod(highlightPart + dIndex, enemy.parts.length));
}

void mirrorBody(Body body) {
  body.pos.z *= -1;
  swarpRots(body.armLeft, body.armRight);
  swarpRots(body.handLeft, body.handRight);
  swarpRots(body.legLeft, body.legRight);
  swarpRots(body.footLeft, body.footRight);
  
  body.head.rot.z *= -1;
  body.head.rot.y *= -1;
  body.chest.rot.y *= -1;
}

void swarpRots(BodyPart part0, BodyPart part1) {
  PVector temp = part0.rot;
  part0.rot = part1.rot;
  part1.rot = temp;
  
  part0.rot.z *= -1;
  part0.rot.y *= -1;
  part1.rot.z *= -1;
  part1.rot.y *= -1;
}

float sign(float f) {
  return f > 0 ? 1 : f < 0 ? -1 : 0;
}
