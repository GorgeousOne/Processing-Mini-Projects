import java.util.Arrays;
import java.util.List;

LinkedList<PVector> points = new LinkedList<PVector>(Arrays.asList(
new PVector(82,85),
new PVector(74,93),
new PVector(75,85),
new PVector(64,90),
new PVector(45,84),
new PVector(28,93),
new PVector(29,84),
new PVector(36,70),
new PVector(37,67),
new PVector(6,85),
new PVector(6,84),
new PVector(26,59),
new PVector(38,47),
new PVector(7,67),
new PVector(19,34),
new PVector(42,17),
new PVector(11,22),
new PVector(25,14),
new PVector(46,10)
));

List<PVector> hull;

final static float s = 5;
void setup() {
  size(500, 500);
  strokeWeight(1);
  hull = convexHull(new LinkedList<PVector>(points));
}

void draw() {
  background(128);
  scale(s, s);
  stroke(255, 0, 0);
  float weight = 0.5;
  
  for(int i = 0; i < hull.size(); ++i) {
    strokeWeight(weight);
    
    PVector p0 = hull.get(i);
    PVector p1 = hull.get((i+1) % hull.size());
    stroke(255, 0, 0);
    line(p0.x, p0.y, p1.x, p1.y);
    
    weight += 0.2;
  }
  
  stroke(255);
  weight = 0.5;

  for (PVector p : points) {
    strokeWeight(weight);
    point(p.x, p.y);
    weight += 0.2;
    //text(int(p.x) + "," + int(p.y), s * p.x, s * p.y + 15);
  }


}
