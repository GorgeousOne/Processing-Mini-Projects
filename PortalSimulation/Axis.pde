public enum Axis {
  
  X(new PVector(0, 0, 1), new PVector(1, 0, 0)),
  Z(new PVector(1, 0, 0), new PVector(0, 0, 1));
  
  private PVector normal;
  private PVector crossNormal;
  
  private Axis(PVector normal, PVector crossNormal) {
    this.normal = normal;
    this.crossNormal = crossNormal;
  }
  
  public PVector getNormal() {
    return normal.copy();
  }
  
  
  public PVector getCrossNormal() {
    return crossNormal.copy();
  }
}
