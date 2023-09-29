import java.util.Arrays;
import java.util.List;
import java.util.LinkedList;
OrbitCamera cam;

void settings() {
  size(1200, 800, P3D);
  smooth();
}

void setup() {
  cam = new OrbitCamera();
  cam.setFOV(30);
  fill(128);
  textSize(56);
  strokeWeight(2);
}

D10 deca = new D10(200);
D4 tetra = new D4(200);
D8 octo = new D8(200);
D12 dode = new D12(100);

void draw() {
  background(255);
  //lights();
  cam.update();
  pushMatrix();
  cam.applyRotation();
  
  float spacing = 400;
  
  displayGrid();
  translate(-2 * spacing, 0, 0);
  tetra.display();
  translate(spacing, 0, 0);
  box(200);
  translate(spacing, 0, 0);
  octo.display();
  translate(spacing, 0, 0);
  deca.display();
  translate(spacing, 0, 0);
  dode.display();
  popMatrix();
}

void displayGrid() {
  float size = 50;
  pushStyle();
  strokeWeight(2);
  stroke(255, 0, 0);
  line(0, 0, 0, size, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, size, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, size);
  popStyle();
}
abstract class Polyhedron {
  PVector[] vertices;
  Integer[][] faces;

  Polyhedron(float radius) {
    this.vertices = calcVertices(radius);
    this.faces = listFaces();
  }

  abstract PVector[] calcVertices(float radius);
  abstract Integer[][] listFaces();

  void display() {
    for (Integer[] face : faces) {
      beginShape();
      for (Integer index : face) {
        PVector v = vertices[index];
        vertex(v.x, v.y, v.z);
      }
      endShape(CLOSE);
    }
  }
}
