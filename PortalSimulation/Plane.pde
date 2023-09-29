
public class Plane {
  
  private PVector origin;
  private PVector normal;
  
  public Plane(PVector origin, PVector normal) {
    
    this.origin = origin.copy();
    this.normal = normal.copy().normalize();
    
    if (normal.magSq() == 0) {
      throw new IllegalArgumentException("normal cannot be 0");
    }
  }
  
  public PVector getOrigin() {
    return origin.copy();
  }
  
  public PVector getNormal() {
    return normal.copy();
  }
  
  public boolean contains(PVector point) {
    
    if (point == null) {
      return false;
    }
    
    PVector relPoint = getOrigin().sub(point);
    return Math.abs(getNormal().dot(relPoint)) < 0.0001;
  }
  
  public PVector getIntersection(Line line) {
    
    PVector normal = getNormal();
    
    float d = getOrigin().sub(line.getOrigin()).dot(normal) / line.getDirection().dot(normal);
    PVector intersection = line.getPoint(d);
    
    return contains(intersection) ? intersection : null;
  }
  
  public void translate(PVector delta) {
    origin.add(delta);
  }
}
