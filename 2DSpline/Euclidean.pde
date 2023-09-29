class Plane {

  private PVector origin;
  private PVector normal;
    
  public Plane(PVector origin, PVector normal) {
    
    this.origin = origin.copy();
    this.normal = normal.copy().normalize();
  }
  
  public PVector getOrigin() {
    return origin.copy();
  }
  
  public PVector getNormal() {
    return normal.copy();
  }
  
  public boolean contains(PVector point) {

    //calculate the distance of the point to the planes origin as a PVector.
    PVector delta = getOrigin().sub(point);

    //if the point is contained in the plane, then the delta PVector must have a 90° angle to the plane's normal PVector
    return Math.abs(getNormal().dot(delta)) < 0.01;
  }
  
  public PVector getIntersection(Line line) {
    
    float dividend = line.getGradient().dot(getNormal());

    //check if the line is running parallel to the plane
    if(dividend == 0) {

      //throw exception if the line is contained by the plane, cannot return infinite points
      if(contains(line.getOrigin()))
        throw new IllegalStateException("The passed line is contained by the plane.");
      //otherwise there will be no intersections
      else
        return null;
    }
    
    //this is simply the line equation put into the plane equation in point-normal form
    //and converted to the variable of the line.
    float lineVariable = getOrigin().sub(line.getOrigin()).dot(getNormal()) / dividend;
    return line.getPoint(lineVariable);
  }
}

public class Line {
  
  private PVector origin;
  private PVector gradient;
  
  public Line(PVector origin, PVector gradient) {
    
    this.origin = origin.copy();
    this.gradient = gradient.copy();
  }

  public PVector getOrigin() {
    return origin.copy();
  }

  public PVector getGradient() {
    return gradient.copy();
  }
  
  public PVector getPoint(float d) {
    return getOrigin().add(getGradient().mult(d));
  }
}
