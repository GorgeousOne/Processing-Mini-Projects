class Edge {
  
  PVector origin;
  PVector direction;  
  PVector end;
  
  Arc leftArc;
  Arc rightArc;
  
  Edge(PVector pos, PVector dir, Arc leftArc, Arc rightArc) {
    this.origin = pos.copy();
    this.direction = dir.copy();
    this.leftArc = leftArc;
    this.rightArc = rightArc;
  }
  
  void setEnd(PVector point) {
    this.end = point;
  }
  
  PVector intersect(Edge other) {
    PVector delta = other.origin.copy().sub(origin);
    PVector dir1 = direction;
    PVector dir2 = other.direction;
    float oneDivByDet = 1.f / (dir1.x * dir2.y - dir2.x * dir1.y);
    
    float s = (dir2.y * delta.x - dir2.x * delta.y) * oneDivByDet;
    float t = (dir1.y * delta.x - dir1.x * delta.y) * oneDivByDet;
    
    if (s >= 0 && t >= 0) {
      return getPoint(s);
    }
    return null;
  }
  
  PVector getPoint(float r) {
    if (r >= 0) {
      return origin.copy().add(direction.copy().mult(r));
    }
    return null;
  }
  
  PVector getPointAtY(float y) {
    return getPoint((y - origin.y) / direction.y);     
  }
  
  void display(float directrix) {
    if (this.end != null) {
      line(origin.x, origin.y, this.end.x, this.end.y); 
    }else {
      PVector end = leftArc.intersect(rightArc, directrix);
      line(origin.x, origin.y, end.x, end.y); 
      //line(origin.x, origin.y, origin.x + 100000 * direction.x, origin.y + 100000 * direction.y);      
    }    
  }
  
  @Override
  public String toString() {
    return String.valueOf((int) (origin.x));
  }
}
