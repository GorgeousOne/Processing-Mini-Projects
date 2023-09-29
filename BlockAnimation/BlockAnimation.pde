
PGraphics img;
Block[][] grid;
boolean[][] ticked;
int[][] high;

int gSize = 9;

color red = color(255, 101, 101);
color turq = color(92, 247, 255);

void setup() {
  //size(1280, 854, P3D);
  size(640, 426, P3D);
  smooth();
  
  //img = createGraphics(1920, 1280, P3D);
  //size(720, 540, P3D);
  int w = 1920;
  int h = 1280;
  
  //img.beginDraw();
  ortho(-w/2, w/2, -h/2, h/2, 1, 10000);
  camera(1000, 1000, 1000, 0, 0, 0, 0, -1, 0);
  strokeWeight(2);
  //img.endDraw();

  grid = new Block[gSize][gSize];
  ticked = new boolean[gSize][gSize];
  high = new int[gSize][gSize];

  for (int z = 0; z < gSize; ++z) {
    for (int x = 0; x < gSize; ++x) {
      Block b = new Block(x, 0, z, color(255));
      
      float circDist = sqrt(pow(x +3, 2) + pow(z + 1, 2));
      if (circDist < 9) {
        high[z][x] = 1;
      }
      if (circDist < 6) {
        high[z][x] = 2;
      }
      if ((x == 1 || x == gSize - 2) && z > 0 && z < gSize - 1 ||
          (z == 1 || z == gSize - 2) && x > 0 && x < gSize - 1){
        b.c = red;
      }
      grid[z][x] = b;
    }
  }
  grid[2][1].c = turq;
  grid[6][7].c = turq;
  
}

void drawImg() {
  background(255);
  
  directionalLight(255, 255, 255, 0, -1, 0);
  directionalLight(242, 242, 242, -1, 0, 0);
  directionalLight(212, 212, 212, 0, 0, -1);
  
  
  for (int z = 0; z < gSize; ++z) {
    for (int x = 0; x < gSize; ++x) {
      Block b = grid[z][x];
      if (!ticked[z][x] && sin((b.pos.x) / 3 + frameCount/30f) < 0) {
        b.minY = high[z][x];
        b.vY = 0.3;
        ticked[z][x] = true;
      }
      b.physics();
      b.render();
    }
  }
  //img.endDraw(); 
}

void draw() {
  drawImg();
  //image(img, 0, 0, width, height);
}

float g = 0.01;

int bSize = 100;
int mid = bSize * gSize / 2;
int midY = (int) (2.5 * bSize);

class Block {
  
  PVector pos;
  color c;
  float vY;
  float minY;
  
  Block(int x, int y, int z, color c) {
    this.pos = new PVector(
        x, 
        y, 
        z);
    this.c = c;
  }
  
  void physics() {
    if (pos.y == minY && vY == 0) {
      return;
    }
    pos.y += vY;
    
    if (vY < 0 && pos.y < minY-0.0001) {
      pos.y = minY;
      vY = 0;
    } else {
      vY -= g;
    }
  }
  void render() {
    pushMatrix();
    translate(pos.x * bSize - mid, pos.y * bSize - midY, pos.z * bSize - mid);
    //translate(0, cos((pos.x - pos.z) / (1.5 * bSize) + frameCount/20f) * 0.5 * bSize, 0);
    fill(c);
    box(bSize);
    popMatrix();
  }
}
