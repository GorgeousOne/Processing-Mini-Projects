
public class Block {
  
  World world;
  int x;
  int y;
  int z;
  color material;
  
  public Block(World world, int x, int y, int z) {
    this.world = world;
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  public int getX() {
    return x;
  }
  
  public void setX(int x) {
    this.x = x;
  }
  
  public int getY() {
    return y;
  }
  
  public void setY(int y) {
    this.y = y;
  }
  
  public int getZ() {
    return z;
  }
  
  public void setZ(int z) {
    this.z = z;
  }
  
  public color getMaterial() {
    return material;
  }
  
  public void setMaterial(color material) {
    this.material = material;
  }
  
  boolean hasMaterial() {
    return material != 0;
  }
  
  void display() {
    
    push();
    noStroke();
    fill(material);
    translate(x, y, z);
    
    if (!world.getBlockAt(x-1, y, z).hasMaterial()) {      beginShape();
      vertex(0, 0, 0);
      vertex(0, 1, 0);
      vertex(0, 1, 1);
      vertex(0, 0, 1);
      endShape(CLOSE);
    }
    
    if (!world.getBlockAt(x+1, y, z).hasMaterial()) {
      beginShape();
      vertex(1, 0, 0);
      vertex(1, 1, 0);
      vertex(1, 1, 1);
      vertex(1, 0, 1);
      endShape(CLOSE);
    }
    
    if (!world.getBlockAt(x, y-1, z).hasMaterial()) {
      beginShape();
      vertex(0, 0, 0);
      vertex(1, 0, 0);
      vertex(1, 0, 1);
      vertex(0, 0, 1);
      endShape(CLOSE);
    }
    
    if (!world.getBlockAt(x, y+1, z).hasMaterial()) {
      beginShape();
      vertex(0, 1, 0);
      vertex(1, 1, 0);
      vertex(1, 1, 1);
      vertex(0, 1, 1);
      endShape(CLOSE);
    }
    
    if (!world.getBlockAt(x, y, z-1).hasMaterial()) {
      beginShape();
      vertex(0, 0, 0);
      vertex(0, 1, 0);
      vertex(1, 1, 0);
      vertex(1, 0, 0);
      endShape(CLOSE);
    }
    
    if (!world.getBlockAt(x, y, z+1).hasMaterial()) {
      beginShape();
      vertex(0, 0, 1);
      vertex(0, 1, 1);
      vertex(1, 1, 1);
      vertex(1, 0, 1);
      endShape(CLOSE);
    }
    
    pop();
  }
}
