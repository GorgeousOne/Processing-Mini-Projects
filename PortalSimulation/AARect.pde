public class AxisAlignedRect {
  
  private Axis axis;
  private PVector pos;
  private float width;
  private float height;
  private Plane plane;
  
  public AxisAlignedRect(Axis axis, PVector pos, float width, float height) {
    
    this.axis = axis;
    this.pos = pos.copy();
    
    if (axis == Axis.X) {
      plane = new Plane(pos, new PVector(0, 0, 1));
    } else {
      plane = new Plane(pos, new PVector(1, 0, 0));
    }
    
    setSize(width, height);
  }
  
  Block block;
  
  void display() {
    
    PVector min = getMin();
    PVector max = getMax();
    line(min.x, min.y, min.z, max.x, max.y, max.z);
  }
  
  public Axis getAxis() {
    return axis;
  }
  
  public PVector getMin() {
    return pos.copy();
  }
  
  public PVector getMax() {
    return pos.copy().add(new PVector(
        axis == Axis.X ? width : 0,
        height,
        axis == Axis.Z ? width : 0));
  }
  
  public float width() {
    return width;
  }
  
  public float height() {
    return height;
  }
  
  public void setSize(float width, float height) {
    this.width = width;
    this.height = height;
  }
  
  public AxisAlignedRect translate(PVector delta) {
    pos.add(delta);
    plane.translate(delta);
    return this;
  }
  
  public Plane getPlane() {
    return plane;
  }
  
  public boolean contains(PVector pointInPlane) {
    
    PVector min = getMin();
    PVector max = getMax();
    
    float pointY = pointInPlane.y;
    
    if (pointY < min.y || pointY > max.y) {
      return false;
    }
    
    if (axis == Axis.X) {
      float pointX = pointInPlane.x;
      return pointX >= min.x && pointX <= max.x;
      
    } else {
      float pointZ = pointInPlane.z;
      return pointZ >= min.z && pointZ <= max.z;
    }
  }
  
  /**
   * Returns a normal vector for the plane of the rectangle.
   */
  public PVector getNormal() {
    return axis.getNormal();
  }
  
  /**
   * Returns a vector 90° to the plane normal vector
   */
  public PVector getCrossNormal() {
    return axis.getCrossNormal();
  }
  
  @Override
  public AxisAlignedRect clone() {
    return new AxisAlignedRect(getAxis(), getMin(), width(), height());
  }
}
