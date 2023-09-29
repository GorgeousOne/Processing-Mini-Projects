
class Bezier2 {
  
  Line2 controlLine0;
  Line2 controlLine1;
  Line2 controlLine2;
  Line2 interpolateLine0;
  Line2 interpolateLine1;
  Line2 finalLine;
  
  float lastFloat;
  
  Bezier2(PVector start, PVector controlVec1, PVector end, PVector controlVec2) {
    
    PVector controlPoint1 = start.copy().add(controlVec1);
    PVector controlPoint2 = end.copy().add(controlVec2);

    controlLine0 = new Line2(start, controlPoint1);
    controlLine1 = new Line2(controlPoint1, controlPoint2);
    controlLine2 = new Line2(controlPoint2, end);
    
    interpolateLine0 = new Line2(controlLine0.getPoint(), controlLine1.getPoint());
    interpolateLine1 = new Line2(controlLine1.getPoint(), controlLine2.getPoint());
    
    finalLine = new Line2(interpolateLine0.getPoint(), interpolateLine1.getPoint());
  }
  
  PVector getPoint(float f) {
    
    if(f < 0 || f > 1)
      throw new IllegalArgumentException("Do you even bezier?");
    
    adjustLines(f);
    return finalLine.getPoint().copy();    
  }
  
  PVector getTangent(float f) {
    
     if(f < 0 || f > 1)
      throw new IllegalArgumentException("Do you even bezier?");
      
    adjustLines(f);
    return finalLine.getDelta().normalize();  
  }
  
  private void adjustLines(float f) {
   
     if(lastFloat != f) {
      
      controlLine0.setPoint(f);
      controlLine1.setPoint(f);
      controlLine2.setPoint(f);
      interpolateLine0.setPoint(f);
      interpolateLine1.setPoint(f);
      finalLine.setPoint(f);

      lastFloat = f;
    }
  }
}


class Line2 {
  
  PVector start;
  PVector end;
  PVector lastPoint;
  
  Line2(PVector start, PVector end) {  
    this.start = start;
    this.end = end;
    this.lastPoint = start.copy();
  }
  
  PVector getDelta() {
    return end.copy().sub(start);    
  }
  
  void setPoint(float f) {
    lastPoint.set(start.copy().add(getDelta().mult(f)));
  }
  
  PVector getPoint() {
    return lastPoint;
  }
}
