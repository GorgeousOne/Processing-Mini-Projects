import java.util.List;
Slider bend;

List<PVector> line1;
List<PVector> line2;

List<Ring> rings;

float bandLength = 1000;
float bandWidth = 100;
float ringSize = 50;

void setup() {
  size(1500, 800, P2D);
  
  bend = createSlider(0.001, 1);
  bend.w = 400;
  
  line1 = new ArrayList<PVector>();
  line2 = new ArrayList<PVector>();

  float scale = bandLength / 100;
  for (int i = 0; i < 100; ++i) {
    line1.add(new PVector(0, scale*i));
    line2.add(new PVector(bandWidth, scale*i));
  }
  
  rings = new ArrayList<Ring>();
  float scale2 = bandLength / (ringSize/2);
  println(scale2);
  
  for (int i = 0; i < scale2; ++i) {
    rings.add(new Ring(new PVector(
        i%2 == 0 ? bandWidth/4 : bandWidth*3/4,
        i * (ringSize/2)),
        ringSize, 50));
  }
  
  smooth();
}

color border = color(82, 87, 255);

void draw() {
  
  background(255);
  stroke(border);
  strokeWeight(2);

  //push();
  //translate(100, 100);  
  
  //fill(255);
  //for (Ring ring : rings) {
  //  drawRing(ring, false, 0);
  //}
  
  //noFill();
  //drawShape(line1, false);
  //drawShape(line2, false);
  //pop();
  
  float perimeter = bandLength / bend.value;
  float radius = perimeter / TWO_PI;  
  
  push();
  translate(900, 100);
  translate(0, bend.value * (height-200)/2);
  
  fill(255);
  for (Ring ring : rings) {
    drawRing(ring, true, radius);
  }
  
  if (bend.value > 0.1) {
    noFill();
    stroke(255);
    strokeWeight(100);
    float circ = 2*radius + bandWidth + 200;
    ellipse(-radius, 0, circ, circ);
    
    fill(255);
    noStroke();
    ellipse(-radius, 0, 2*radius, 2*radius);
  }
  
  strokeWeight(2);
  noFill();
  stroke(border);
  drawShape(getBent(line1, radius), bend.value == 1);
  drawShape(getBent(line2, radius), bend.value == 1);
  
 
  pop();
  drawSliders();  
}

List<PVector> getBent(List<PVector> vertices, float radius) {
  List<PVector> newVs = new ArrayList<PVector>();
  
  for (PVector v : vertices) {
    float angle = v.y / radius;
    float dist = radius + v.x;
    newVs.add(new PVector(
        cos(angle) * dist - radius,
        sin(angle) * dist));
  }
  return newVs;
}

void drawRing(Ring ring, boolean bent, float radius) {
  if (bent) {
    drawShape(getBent(ring.vertices1, radius), true);    
    drawShape(getBent(ring.vertices2, radius), true);    
    drawShape(getBent(ring.vertices3, radius), true);    

  }else {
    drawShape(ring.vertices1, true);      
    drawShape(ring.vertices2, true);      
    drawShape(ring.vertices3, true);      
  }
}
void drawShape(List<PVector> vertices, boolean close) {
  beginShape();
  for (PVector v : vertices) {
    vertex(v.x, v.y);
  }
  if (close) {
    endShape(CLOSE);
  }else {
    endShape();
  }
}
