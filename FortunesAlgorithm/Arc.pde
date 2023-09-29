
class Arc {
  
  PVector focus;
  Edge edgeLeft;
  Edge edgeRight;

  Arc(PVector focus) {
    this.focus = focus;
  }
  
  public PVector getFocus() {
    return focus.copy();  
  }
  //https://jacquesheunis.com/post/fortunes-algorithm/ has nice formula explanation
  float getY(float x, float directrix) {
    if (focus.y == directrix) {
      return 0;
    }
    return pow(x - focus.x, 2) / (2 * (focus.y - directrix)) + (focus.y + directrix) / 2;
  }
  
  void setLeftEdge(Edge edge) {
    this.edgeLeft = edge;
  }
  
  void setRightEdge(Edge edge) {
    this.edgeRight = edge;
  }
  
  PVector intersect(Arc other, float directrix) {
    PVector siteA = focus;
    PVector siteB = other.focus;
    
    if (siteA.y == siteB.y) {
      float midX = (siteA.x + siteB.x) / 2;
      if (directrix == siteA.y) {
        return new PVector(midX, -9999);
      }else {
        return new PVector(midX, getY(midX, directrix)); 
      }
    }
    if (siteA.y == directrix) {
      return new PVector(siteA.x, other.getY(siteA.x, directrix));
    }
    if (siteB.y == directrix) {
      return new PVector(siteB.x, getY(siteB.x, directrix));
    }
    
    float deltaA = siteA.y - directrix;
    float deltaB = siteB.y - directrix;
    float deltaBA = siteB.y - siteA.y;
    
    float xASquare = siteA.x * siteA.x;
    float xBSquare = siteB.x * siteB.x;
    
    //p-q formula
    float p = 2 * (siteB.x * deltaA - siteA.x * deltaB) / deltaBA;
    float q = (xASquare * deltaB - xBSquare * deltaA) / deltaBA - deltaA * deltaB;
 
    p *= 0.5;  
    float x1 = -p - sqrt(p * p - q);
    float x2 = -p + sqrt(p * p - q);
    float rightX = siteA.y < siteB.y ? x1 : x2;
    return new PVector(rightX, getY(rightX, directrix));
  }
  
  @Override
  public Arc clone() {
    return new Arc(getFocus());  
  }
  
  @Override
  public String toString() {
    return String.valueOf((int) (focus.x));
  }
  
  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof Arc)) {
      return false;
    }
    Arc arc = (Arc) o;
    return 
        focus.equals(arc.focus) && 
        (edgeLeft == null || edgeLeft.equals(arc.edgeLeft)) &&
        (edgeRight == null || edgeRight.equals(arc.edgeRight));
  }
  
  @Override
  public int hashCode() {
     return focus.hashCode();
  }
}
