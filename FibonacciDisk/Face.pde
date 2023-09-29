
class Face {
  
  PVector p0;
  PVector p1;
  PVector p2;
  
  Face(PVector p0, PVector p1, PVector p2) {
    this.p0 = p0;  
    this.p1 = p1;  
    this.p2 = p2;  
  }
  
  void display() {
    beginShape();
    vertex(p0.x, p0.y, p0.z);
    vertex(p1.x, p1.y, p1.z);
    vertex(p2.x, p2.y, p2.z);
  }
}
