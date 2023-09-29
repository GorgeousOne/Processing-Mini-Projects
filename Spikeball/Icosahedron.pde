import java.util.List;

//golden ratio
static float phi = (sqrt(5) + 1) / 2;
//inverse if the legnth of the diagonale in a rectangle with golden ratio-ed sides
static float rho = 1f / sqrt(phi * phi + 1);

class Icosahedron {
  
  PVector[] vertices;

  Icosahedron(float vertexRadius) {
    float radius = vertexRadius * rho;

    vertices = new PVector[] {
      new PVector(0, -1, -phi).mult(radius),
      new PVector(0, -1,  phi).mult(radius),
      new PVector(0,  1, -phi).mult(radius),
      new PVector(0,  1,  phi).mult(radius),
      new PVector(-phi, 0, -1).mult(radius),
      new PVector(-phi, 0,  1).mult(radius),
      new PVector( phi, 0, -1).mult(radius),
      new PVector( phi, 0,  1).mult(radius),
      new PVector(-1, -phi, 0).mult(radius),
      new PVector(-1,  phi, 0).mult(radius),
      new PVector( 1, -phi, 0).mult(radius),
      new PVector( 1,  phi, 0).mult(radius)};
  }
  
  void display() {
    for (PVector v : vertices) {
      pushMatrix();
      translate(v.x, v.y, v.z);
      box(3);
      popMatrix();
    }
  }
}
