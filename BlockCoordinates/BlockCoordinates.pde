
int blockSize;
int blocksZ;
int blocksX; 

Transform trans;
Block cursorBlock;

void setup() {
  
  size(1420, 800);
  smooth();
  
  blockSize = 60;
  blocksZ = (int) (width/2 / blockSize);
  blocksX = (int) (height/2 / blockSize);
  
  cursorBlock = new Block(0, 0, blockSize);
  
  trans = new Transform();
  trans.setRotY180Deg();
  trans.setRotY90DegRight();
}

void draw() {
  
  background(250);
  
  pushMatrix();
  translate(width/2, height/2);
  
  drawGrid();
  trans.display();
  drawMouseBlock();
  popMatrix();
  
  drawMousePos();
}

void drawGrid() {
  
  fill(200);
  stroke(200);
  strokeWeight(1);

  int crossSize = 2;
  
  for(int z = -blocksZ; z <= blocksZ; z++) {
    for(int x = -blocksX; x <= blocksX; x++) {
      
      int vertexZ = z * blockSize;
      int vertexX = x * blockSize;

      line(vertexZ - crossSize, vertexX, vertexZ + crossSize, vertexX);      
      line(vertexZ, vertexX - crossSize, vertexZ, vertexX + crossSize);            
    }
  } 
  
  noStroke();
  fill(128);
  ellipse(0, 0, 6, 6);
}

void drawMouseBlock() {
  
  cursorBlock.x = getBlockX(mouseY);
  cursorBlock.z = getBlockZ(mouseX);
  
  Block transBlock = trans.getTransformedBlock(cursorBlock);
  
  PVector rotCenter = toScreenPos(trans.rotCenter);
  PVector blockPos1 = toScreenPos(cursorBlock.x, cursorBlock.z);
  PVector blockPos2 = toScreenPos(transBlock.x, transBlock.z);
  
  stroke(10, 0, 200);
  strokeWeight(2);

  line(rotCenter.x, rotCenter.y, blockPos1.x, blockPos1.y);
  line(rotCenter.x, rotCenter.y, blockPos2.x, blockPos2.y);
  
  cursorBlock.display();
  transBlock.display();
}

void drawMousePos() {
  
  int blockX = getBlockX(mouseY);
  int blockZ = getBlockZ(mouseX);
  
  fill(0);
  text("x " + blockX + " : z " + blockZ, mouseX+20, mouseY+30);
}

int getBlockX(int screenY) {
  
  float blockX = -screenY + height/2;  
  return (int) Math.floor(blockX / blockSize);
}

int getBlockZ(int screenX) {
  
  float blockX = screenX - width/2;
  return (int) Math.floor(blockX / blockSize);
}


PVector toScreenPos(int blockX, int blockZ) {
  return new PVector(blockZ * blockSize, -blockX * blockSize);
}

PVector toScreenPos(PVector vec) {
  return toScreenPos((int) vec.y, (int) vec.x);
}
