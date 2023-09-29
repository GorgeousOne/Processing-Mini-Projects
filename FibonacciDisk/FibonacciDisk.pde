import java.util.List;

Camera cam;

void settings() { 
  size(1200, 800, P3D);
}

List<PVector> points;

float goldenRatio = (1 + sqrt(5)) / 2;

void setup() {
  cam = new Camera();
  fill(128);
  points = genDisc(1000, goldenRatio, 200);
  //points = genSphere(1000, goldenRatio, 300);
}

void draw() {
  //points = genSphere(frameCount/2, goldenRatio, 200);
  background(255);
  lights();
  cam.focus();
  
  noStroke();

  for (int i = 0; i < points.size(); ++i) {
    PVector p = points.get(i);
    pushMatrix();
    translate(p.x, p.y, p.z);
    fill(255 * (1 - (float)(i) / points.size()));
        
    box(7);
    popMatrix();
  }
  
}

List<PVector> genDisc(int pointCount, float turnFraction, float radius) {
  List<PVector> points = new ArrayList<PVector>();
  
  for (int i = 0; i < pointCount; ++i) {
      float dist = pow(i / (pointCount - 1f), 0.5) * 300;
      float angle = TWO_PI * turnFraction * i;
      
      float x = dist * cos(angle);
      float z = dist * sin(angle);
      points.add(new PVector(x, 0, z));    
  }
  return points;
}

List<PVector> genSphere(int pointCount, float turnFraction, float radius) {
  List<PVector> points = new ArrayList<PVector>();
  
  for (int i = 0; i < pointCount; ++i) {
      float t = i / (pointCount - 1f);
      //apparently this is called azimuth and inclination/altidude
      float pitch = acos(1 - 2*t);
      float yaw = TWO_PI * turnFraction * i;

      float x = radius * sin(pitch) * cos(yaw);
      float z = radius * sin(pitch) * sin(yaw);
      float y = radius * cos(pitch);
      
      points.add(new PVector(x, y, z));    
  }
  return points;
}

List<Face> triangulateSphere(List<PVector> points) {
  List<Face> faces = new ArrayList<Face>();
  
  List<PVector> border = new ArrayList<PVector>();
  //border = 
  return faces;
}
