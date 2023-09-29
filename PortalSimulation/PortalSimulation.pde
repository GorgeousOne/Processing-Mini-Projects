
import java.util.Map;
import java.util.HashSet;
import java.awt.event.KeyEvent;

Spectator spectator;
World world;

Portal counterPortal;
Portal portal;
Portal portal2;
Portal portal3;

Map<BlockVec, Block> blocksInFrustum = new HashMap<BlockVec, Block>();

void settings() {
  
  size(1200, 800, P3D);
  smooth(8);
}
  
void setup() {
  
  spectator = new Spectator(new PVector(-8, 5, -6), 70);
  spectator.pitch = 0;
  spectator.yaw = HALF_PI;
  
  int worldSize = 20;
  world = new World(-worldSize, -worldSize, -worldSize, worldSize, worldSize, worldSize);
  
  counterPortal = createPortal(new BlockVec(-4, 3, -4), 9, 9, Axis.Z, color(255, 150, 74));
  //portal = createPortal(new BlockVec(-5, 0, 2), 7, 7, Axis.X, color(255, 86, 74));
  //portal2 = createPortal(new BlockVec(-10, 0, -10), 5, 5, Axis.Z, color(255, 86, 74));
  //portal3 = createPortal(new BlockVec(10, 0, -10), 5, 5, Axis.X, color(255, 86, 74));
  
  //portal.setLinkedTo(counterPortal);
  //portal2.setLinkedTo(counterPortal);
  //portal3.setLinkedTo(counterPortal);
  
  //loadProjectionCachesOf(portal);
  //loadProjectionCachesOf(portal2);
  //loadProjectionCachesOf(portal3);

  fill(128);
  
  textMode(SHAPE);
  textSize(2.5);
}

void draw() {
  
  background(255);
  moveSpectator();
  spectator.focus();
  
  world.display();

  PVector facing = spectator.getFacing();
  ambientLight(128, 128, 128);
  directionalLight(128, 128, 128, facing.x, facing.y, facing.z);
  lightFalloff(1, 0, 0);
  
  pushMatrix();
  //scale(1, 1, -1);

  counterPortal.display();
  //portal.display();
  //portal2.display();
  //portal3.display();
  
  if (frustum != null) {
    frustum.display();
    
    for (Block block : blocksInFrustum.values()) {
      block.display();
    }
  }
  
  popMatrix();  
  
  displayCoords();
}

int textPos = -100;
int textPosY = -60;

void displayCoords() {

    //pretty stupid probably but I dont want to figure out how to rotate everything istead of useing the camera
  camera(0, 0, 0, 0, 0, 1, 0, 1, 0);
  scale(-1, 1, 1);
  
  PVector pos = spectator.pos;
   //<>//
  text("x: " + round(pos.x, 2), -102, -65, 100);
  text("y: " + round(pos.y, 2), -102, -60, 100);
  text("z: " + round(pos.z, 2), -102, -55, 100);
}

float round(float f, int decimals) {
  return (int) (f * pow(10, decimals)) / pow(10, decimals);
}

Set<Integer> pressedKeys = new HashSet<Integer>();

void keyPressed() {
  pressedKeys.add(keyCode);
}

void keyReleased() {
  pressedKeys.remove(keyCode);
}

ViewFrustum frustum;

void keyTyped() {
  
  switch(key) {
    
    case 'x':
      frustum = createFrustum(spectator.pos.copy(), counterPortal.getPortalRect(), 10);
      
      for (Block block : blocksInFrustum.values()) {
        block.setMaterial(0);
      }
      
      blocksInFrustum = frustum.getContainedBlocks(counterPortal.getFrontCache());
      
      //for (Block block : blocksInFrustum.values()) {
      //  block.setMaterial(color(128, 128));
      //}
      break;
      
    case '1':
      speed = 0.2;
      rotSpeed = 1.5;
      break;
    case '2':
      speed = 0.03;
      rotSpeed = 0.5;
      break;
    case '3':
      speed = 0.4;
      rotSpeed = 2;
      break;
  }
}

float speed = 0.2;
float rotSpeed = 1.5;

void moveSpectator() {
  
  if (!keyPressed)
    return;  
  
  if (pressedKeys.contains(KeyEvent.VK_W)) {
    spectator.move(speed, 0);
  }
  
  if (pressedKeys.contains(KeyEvent.VK_S)) {
    spectator.move(-speed, 0);
  }
  
  if (pressedKeys.contains(KeyEvent.VK_A)) {
    spectator.move(0, speed);
  }
  
  if (pressedKeys.contains(KeyEvent.VK_D)) {
    spectator.move(0, -speed);
  }
  
  if (pressedKeys.contains(KeyEvent.VK_SPACE)) {
    spectator.move(speed);
  }
  
  if (pressedKeys.contains(KeyEvent.VK_SHIFT)) {
    spectator.move(-speed);
  }
  
  if (pressedKeys.contains(KeyEvent.VK_DOWN)) {
    spectator.rotate(0, -rotSpeed);
  }
  
  if (pressedKeys.contains(KeyEvent.VK_UP)) {
    spectator.rotate(0, rotSpeed);
  }
  
  if (pressedKeys.contains(KeyEvent.VK_LEFT)) {
    spectator.rotate(rotSpeed, 0);
  }
  
  if (pressedKeys.contains(KeyEvent.VK_RIGHT)) {
    spectator.rotate(-rotSpeed, 0);
  }
}
