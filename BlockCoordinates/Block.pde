
class Block {
  
  int x;
  int z;
  int size;
  color outline;
  
  Block(int x, int z, int size) {
    this.x = x;
    this.z = z;
    this.size = size;
    outline = color(200);
  }
  
  Block(int x, int z, int size, color outline) {
    this.x = x;
    this.z = z;
    this.size = size;
    this.outline = outline;
  }
  
  void display() {
    
    fill(outline);
    noStroke();
    ellipse(z * size, -x * size, 6, 6);

    noFill();
    stroke(outline);
    strokeWeight(2);
    rect(z * size, -x * size, size, -size);
  }
  
  Block clone() {
    return new Block(x, z, size, outline);
  }
}
