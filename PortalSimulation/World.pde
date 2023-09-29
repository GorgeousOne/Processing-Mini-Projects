
class World {
  
  BlockVec min;
  BlockVec max;
  Block[][][] blocks;
    
  World(int x0, int y0, int z0, int x1, int y1, int z1) {
    
    //floor = loadImage("floor.png");
    
    min = new BlockVec(x0, y0, z0);
    max = new BlockVec(x1, y1, z1);
    
    blocks = new Block[width()][height()][depth()];
    
    for (int x = 0; x < width(); x++) {
      for (int y = 0; y < height(); y++) {
        for (int z = 0; z < depth(); z++) {
          blocks[x][y][z] = new Block(this, min.x + x, min.y + y, min.z + z);
        }
      }  
    }
  }
  
  int width() {
    return max.x - min.x;  
  }

  int height() {
    return max.y - min.y;  
  }

  int depth() {
    return max.z - min.z;  
  }

  Block getBlockAt(BlockVec blockPos) {
    return getBlockAt(blockPos.getX(),
                      blockPos.getY(),
                      blockPos.getZ());
  }
  
  Block getBlockAt(int x, int y, int z) {
    
    if (!contains(x, y, z))
      return null;
      
    return blocks
        [x - min.getX()]
        [y - min.getY()]
        [z - min.getZ()];
  }
  
  boolean contains(BlockVec loc) {
    return contains(loc.getX(), loc.getY(), loc.getZ());
  }
  
  boolean contains(int x, int y, int z) {
    return x >= min.getX() && x < max.getX() &&
           y >= min.getY() && y < max.getY() &&
           z >= min.getZ() && z < max.getZ();
  }
    
  void display() {
    
    pushStyle();

    fill(255);
    stroke(190);
    
    beginShape();
    vertex(min.x, -0.02, min.z);
    vertex(min.x, -0.02, max.z);
    vertex(max.x, -0.02, max.z);
    vertex(max.x, -0.02, min.z);
    endShape(CLOSE);    
    
    
    for (int x = min.x; x <= max.x; x++) {
      line(x, 0, min.z, x, 0, max.x);
    }
    
    for (int z = min.z; z <= max.x; z++) {
      line(min.x, 0, z, max.x, 0, z);
    }
    
    fill(190);
    for (int x = min.x; x <= max.x; x+=5) {
      for (int z = min.z; z <= max.x; z+=5) {
        
        pushMatrix();
        translate(x, 0, z);
        box(0.1);
        popMatrix();
      }
    }
    
    strokeWeight(2);
    stroke(255, 0, 0);
    line(0, 0, 0, 1, 0, 0);
    stroke(0, 0, 255);
    line(0, 0, 0, 0, 0, 1);
    
    popStyle();
  }
}
