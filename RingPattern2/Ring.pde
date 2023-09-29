
class Ring {
  
  PVector pos;
  float radius;
  List<PVector> vertices1 = new ArrayList<PVector>();
  List<PVector> vertices2 = new ArrayList<PVector>();
  List<PVector> vertices3 = new ArrayList<PVector>();

  Ring(PVector pos, float radius, int count) {
    this.pos = pos.copy();
    this.radius = radius;
    
    for (int i = 0; i < count; ++i) {
      float phi = TWO_PI * i/count;
      float cosPhi = cos(phi);
      float sinPhi = sin(phi);
      vertices1.add(pos.copy().add(
          radius * cosPhi,
          radius * sinPhi));
      vertices2.add(pos.copy().add(
          radius * 2/3 * cosPhi,
          radius * 2/3 * sinPhi));
      vertices3.add(pos.copy().add(
          radius * 1/3 * cosPhi,
          radius * 1/3 * sinPhi));

    }
  }
}
