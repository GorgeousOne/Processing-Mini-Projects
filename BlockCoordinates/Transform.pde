public class Transform {
  
  private PVector translation;
  private PVector rotCenter;
  private int[][] rotYMatrix;
  
  public Transform() {
    translation = new PVector();
    rotCenter = new PVector();
    rotYMatrix = new int[][]{{1, 0}, {0, 1}};
  }
  
  protected Transform(PVector translation, PVector rotCenter, int[][] rotationY) {
    this.translation = translation;
    this.rotCenter = rotCenter;
    this.rotYMatrix = rotationY;
  }
  
  public void setTranslation(PVector delta) {
    this.translation = delta;
  }
  
  public void translate(PVector delta) {
    this.translation.add(delta);
  }
  
  public void setRotCenter(PVector rotCenter) {
    this.rotCenter = rotCenter;
  }
  
  public void setRotY90DegRight() {
    rotYMatrix[0][0] = 0;
    rotYMatrix[0][1] = -1;
    rotYMatrix[1][0] = 1;
    rotYMatrix[1][1] = 0;
  }
  
  public void setRotY90DegLeft() {
    rotYMatrix[0][0] = 0;
    rotYMatrix[0][1] = 1;
    rotYMatrix[1][0] = -1;
    rotYMatrix[1][1] = 0;
  }
  
  public void setRotY180Deg() {
    rotYMatrix[0][0] = -1;
    rotYMatrix[0][1] = 0;
    rotYMatrix[1][0] = 0;
    rotYMatrix[1][1] = -1;
  }
  
  boolean isRotY90DegRight() {
    return rotYMatrix[0][1] == -1;
  }
  
  boolean isRotY90DegLeft() {
    return rotYMatrix[0][1] == 1;
  }
  
  boolean isRotY180Deg() {
    return rotYMatrix[0][0] == -1;
  }
  
  boolean isRotY0Deg() {
    return rotYMatrix[0][0] == 1;
  }
  
  public Block getTransformedBlock(Block block) {
    
    Block transBlock = block.clone();
    rotateBlock(transBlock);
    translateBlock(transBlock);
    
    return transBlock;
  }
  
  private void rotateBlock(Block block) {
  
    //double transX = relativeVec.getX() + 0.5;
    //double transZ = relativeVec.getZ() + 0.5;

    //relativeVec.setX((int) Math.floor(rotYMatrix[0][0] * transX + rotYMatrix[0][1] * transZ));
    //relativeVec.setZ((int) Math.floor(rotYMatrix[1][0] * transX + rotYMatrix[1][1] * transZ));
    
    block.x -= rotCenter.x;
    block.z -= rotCenter.z;
    
    int transX = (int) block.x;
    int transZ = (int) block.z;

    block.x = (rotYMatrix[0][0] * transX + rotYMatrix[0][1] * transZ);
    block.z = (rotYMatrix[1][0] * transX + rotYMatrix[1][1] * transZ);
    
    
    block.x += rotCenter.x;
    block.z += rotCenter.z;
  }
  
  private void translateBlock(Block block) {
    
    block.x += translation.x;
    block.z += translation.z; 
  }
  
  void display() {
    
    ellipse(rotCenter.z * blockSize, -rotCenter.x * blockSize, 10, 10);
    
    fill(230, 0, 0);
    noStroke();
    ellipse(rotCenter.z * blockSize, -rotCenter.x * blockSize, 10, 10);

    noFill();
    stroke(230, 0, 0);
    strokeWeight(2);
    rect(rotCenter.z * blockSize, -rotCenter.x * blockSize, blockSize, -blockSize);
  }
  
  @Override
  public Transform clone() {
    return new Transform(translation.copy(), rotCenter.copy(), cloneRotY());
  }
  
  private int[][] cloneRotY() {
    return new int[][] {
        {rotYMatrix[0][0], rotYMatrix[0][1]},
        {rotYMatrix[1][0], rotYMatrix[1][1]}
    };
  }
}
