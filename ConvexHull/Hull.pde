import java.util.Comparator;
import java.util.Collections;
import java.util.LinkedList;

LinkedList<PVector> convexHull(LinkedList<PVector> vertices) {
  LinkedList<PVector> hull = new LinkedList<PVector>();
  
  Collections.sort(vertices, new XyComparator());
  PVector start = vertices.getFirst();
  hull.addFirst(start);
  vertices.removeFirst();
  println(start);
  Collections.sort(vertices, new AngleComparator(start));
  
  hull.addFirst(vertices.getFirst());
  vertices.removeFirst();
  hull.addFirst(vertices.getFirst());
  vertices.removeFirst();
  
  while (!vertices.isEmpty()) {
    while (!turnsToRight(hull.get(1), hull.getFirst(), vertices.getFirst())) {
      hull.removeFirst();
    }
    hull.addFirst(vertices.getFirst());
    vertices.removeFirst();
  }
  return hull;
}

class XyComparator implements Comparator<PVector> {
  public int compare(PVector a, PVector b) {
    int compY = Float.compare(a.y, b.y);
    return compY != 0 ? compY : Float.compare(a.x, b.x);
  }
}

class AngleComparator implements Comparator<PVector> {
  PVector start;
  
  AngleComparator(PVector start) {
    this.start = start;  
  }
  
  public int compare(PVector a, PVector b) {
    return Float.compare(polarAngle(start, a), polarAngle(start, b));
  }
}

float polarAngle(PVector a, PVector b) {
  return atan2(b.x - a.x, b.y - a.y);
}

boolean turnsToRight(PVector pivot, PVector a, PVector b) {
  return turnsToRight(a.copy().sub(pivot), b.copy().sub(pivot));
}

boolean turnsToRight(PVector dir0, PVector dir1) {
  float dot = dir0.x * dir1.y - dir0.y * dir1.x;
  return dot < 0;
}
