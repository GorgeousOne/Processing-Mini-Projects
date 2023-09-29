
class MazeAnimation {
  int w;
  int h;
  float size;
  
  MazeAnimation(int w, int h, float size) {
    this.w = w;
    this.h = h;
    //size as in height only
    this.size = size;
  }
  
  float getPathSize() {
      return size / (2 * h + 1);
  }
  
  PVector getCellPos(int x, int y) {
    float minY = .5 * height - .5 * size;
    float minX = .5 * width - .5 * size * aspect();
    float pathSize = pathSize();

    return new PVector(
      minX + (2 * x + 1) * pathSize,
      minY + (2 * y + 1) * pathSize);
  }
  
  float aspect() {
    return (2 * w + 1) / (2 * h + 1f);  
  }
  
  float pathSize() {
    return size / (2 * h + 1);
  }
  
  void display() {
    float minY = .5 * height - .5 * size;
    float minX = .5 * width - .5 * size * aspect();

    pushStyle();
    //stroke(latticeCol);
    //strokeWeight(5);
    //noFill();
    fill(latticeCol);
    rect(minX, minY, size * aspect(), size, latticeEdge);
    popStyle();
    
    float tileSize = size / (2 * h + 1);
    fill(cellCol);
    
    //for (int y = 0; y < h; ++y) {
    //  float tileY = minY + (2 * y + 1) * tileSize;

    //  for (int x = 0; x < w; ++x) {
    //    float tileX = minX + (2 * x + 1) * tileSize;
    //    rect(tileX, tileY, tileSize, tileSize, pathEdge);
    //  }
    //}
  }
}
