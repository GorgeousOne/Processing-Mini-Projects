import java.util.List;

List<PVector> spline = new ArrayList<PVector>();
List<PVector> tangents = new ArrayList<PVector>();
List<PVector> bezierCurves = new ArrayList<PVector>();

void settings() { 
  size(800, 500);
}

float stepX = 100;

void setup() {}

void keyPressed() {
  float increment = 0.1;
  
  switch(keyCode) {
   case UP:
    curvatureFactor += increment;
    break;
  case DOWN:
    curvatureFactor -= increment;
    break;
  case BACKSPACE:
    if(spline.size() > 0)
      spline.remove(spline.size()-1);
    break;
      
  default:
    return;
  }
  
  if(spline.size() > 2) {
    calcTangents();
    calcCurves();
  }
}

void mouseReleased() {
  spline.add(new PVector(mouseX + -50, -mouseY + height/2));
  
  if(spline.size() > 2) {
    calcTangents();
    calcCurves();
  }
}

void calcTangents() {
  tangents.clear();
  int vertexCount = spline.size();

  for(int i = 1; i < vertexCount-1; i++) {
    tangents.add(getTangentVector(
        spline.get(i),
        spline.get(i-1),
        spline.get(i+1)));
  }
  tangents.add(0, new PVector());
  tangents.add(new PVector());
  //tangents.add(0, getMirroredTangent(
  //    spline.get(0),
  //    spline.get(1),
  //    tangents.get(0)));
  //tangents.add(getMirroredTangent(
  //    spline.get(vertexCount-1),
  //    spline.get(vertexCount-2),
  //    tangents.get(tangents.size()-1)));
}

private PVector getTangentVector(PVector vertex, PVector previous, PVector next) {
    PVector directionBackwards = vertex.copy().sub(previous).normalize();
    PVector directionForwards = next.copy().sub(vertex).normalize();
    return directionBackwards.add(directionForwards).normalize();
  }

private PVector getMirroredTangent(PVector pointWithoutTangent, PVector pointWithTangent, PVector tangent) {
  PVector mirrorNormal = pointWithoutTangent.copy().sub(pointWithTangent);
  Plane mirror = new Plane(new PVector(), mirrorNormal);
  return getMirroredVector(tangent.copy().mult(-1), mirror);
}

private PVector getMirroredVector(PVector point, Plane mirror) {
  Line line = new Line(point, mirror.getNormal());
  PVector mirrorCenter = mirror.getIntersection(line);
  return mirrorCenter.copy().sub(point.copy().sub(mirrorCenter));
}

//void calcTangents() {
//  tangents.clear();
//  int pCount = spline.size();
  
//  for(int i = 0; i < pCount; i++) {
//    PVector p0 = i > 0 ? spline.get(i-1) : new PVector(-stepX, 2*spline.get(0).y - spline.get(1).y);
//    PVector p1 = spline.get(i);
//    PVector p2 = i < pCount-1 ? spline.get(i+1) : new PVector(pCount*stepX, 2*spline.get(pCount-1).y - spline.get(pCount-2).y);
    
//    tangents.add(p1.copy().sub(p0).normalize().add(p2.copy().sub(p1).normalize()).normalize());
//    //tangents.add(p1.copy().sub(p0).add(p2.copy().sub(p1)).normalize());
//  }
//}

float curvatureFactor = 2.5;

void calcCurves() {
  bezierCurves.clear();
  int pCount = spline.size();

  for(int i = 0; i < pCount-1; i++) {
    PVector p0 = spline.get(i);
    PVector p1 = spline.get(i+1);
        
    PVector gradient0 = tangents.get(i);
    PVector gradient1 = tangents.get(i+1);
    float halfDist = p0.dist(p1)/curvatureFactor;
    
    Bezier2 curve = new Bezier2(
      p0, gradient0.copy().mult(halfDist),
      p1, gradient1.copy().mult(-halfDist));
      
    for(float f = 0; f < 1; f += 2/halfDist) {
      bezierCurves.add(curve.getPoint(f));
    }
  }  
}

float getTangentGradient(PVector p0, PVector p1, PVector p2) {
  float gradient01 = atan2(p1.y - p0.y, p1.x - p0.x);
  float gradient12 = atan2(p2.y - p1.y, p2.x - p1.x);
  return (gradient12 + (gradient01 - gradient12) / 2);
}

void draw() {
  background(255);
  translate(50, height/2);
  scale(1, -1);
  
  strokeWeight(2);
  fill(0);
  drawKnots();
  
  //if(spline.size() > 2) {
    //drawTangents();
  //}
  //drawLinear();
  drawBezier();
  //drawCos();
  
  //strokeWeight(1);
  //stroke(color(0, 0, 255));
  //drawCos();
  
}

void drawKnots() {
  fill(64, 64, 255);
  noStroke();
  
  for(PVector vertex : spline) {
    ellipse(vertex.x, vertex.y, 6, 6);
  }
}

void drawLinear() {
  stroke(0);
  
  for(int i = 0; i < spline.size()-1; i++) {
    PVector p1 = spline.get(i);
    PVector p2 = spline.get(i+1);
    
    line(p1.x, p1.y, p2.x, p2.y);
    ellipse(p1.x, p1.y, 4, 4);
  }
  PVector pLast = spline.get(spline.size()-1);
  ellipse(pLast.x, pLast.y, 2, 2);
}

void drawBezier() {
  stroke(curvatureFactor != 2.5 ? color(64, 64, 255) : color(255, 64, 64));
  
  for(int i = 0; i < bezierCurves.size(); i++) {
    PVector p0 = bezierCurves.get(i);
    point(p0.x, p0.y);
  }
}

void drawTangents() {
  stroke(128);
  
  for(int i = 0; i < spline.size(); i++) {
    PVector p = spline.get(i);
    PVector tangent = tangents.get(i);
    
    line(
      p.x,
      p.y,
      p.x + 25 * tangent.x,
      p.y + 25 * tangent.y);
  }  
}

void drawCos() {
  stroke(255, 0 ,0);
  
  for(int i = 0; i < spline.size()-1; i++) {
    PVector p1 = spline.get(i);
    PVector p2 = spline.get(i+1);

    for(float mu = 0; mu < 1; mu += 0.01) {
      float cubicY = cosineInterpolate(p1.y, p2.y, mu);
      float nextX = p1.x + mu * (p2.x - p1.x);
      point(nextX, cubicY);
    }
  }
}

float cosineInterpolate(float y1, float y2, float mu) {
   float mu2 = (1 - cos(mu*PI)) / 2;
   return(y1 * (1 - mu2) + y2 * mu2);
}
