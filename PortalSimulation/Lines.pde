
public class Line {
  
  private PVector origin;
  private PVector direction;
  
  public Line(PVector point1, PVector point2) {
    
    this.origin = point1.copy();
    this.direction = point2.copy().sub(point1);
  }
  
  public PVector getOrigin() {
    return origin.copy();
  }
  
  public PVector getDirection() {
    return direction.copy();
  }
  
  public PVector getPoint(float d) {
    return getOrigin().add(getDirection().mult(d));
  }
}

public class DefinedLine extends Line {
  
  public DefinedLine(PVector start, PVector end) {
    super(start, end);
  }
  
  @Override
  public PVector getPoint(float d) {
    return d < 0 || d > 1 ? null : super.getPoint(d);
  }
}
