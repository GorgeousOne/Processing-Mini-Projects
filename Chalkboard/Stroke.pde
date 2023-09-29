import java.util.Random;



class Stroke {
  List<PVector> points;
  PVector min;
  PGraphics img;
  
  Stroke(List<PVector> points) {
    this.points = points;
    createCanvas();
    paintStroke();
  }
  
  void display() {
    image(img, min.x, min.y);
  }
  
  void createCanvas() {
    min = new PVector(width, height);
    PVector max = new PVector();
    
    for (PVector p : points) {
      if (p.x < min.x) min.x = p.x;
      if (p.y < min.y) min.y = p.y;
      if (p.x > max.x) max.x = p.x;
      if (p.y > max.y) max.y = p.y;
    }
    min.sub(3*weight, 3*weight);
    max.add(3*weight, 3*weight);
    
    img = createGraphics(
        int(max.x - min.x + 2* weight),
        int(max.y - min.y + 2* weight));
  }
  
  void paintStroke() {
    img.beginDraw();
    img.noStroke();
    
    for (int i = 0; i < points.size() - 1; ++i) {
      drawSegment(points.get(i), points.get(i + 1));
    }
    img.endDraw();
  }
  
  void drawSegment(PVector p1, PVector p2) {
    PVector dist = p2.copy().sub(p1);
    img.fill(255, 128);
    
    for (int i = 0; i < dist.mag() / scale * pointCount; ++i) {
      float rndX = rnd.nextFloat();
      float rndY = rnd.nextFloat();
      PVector rel = new PVector(
        smoothAcosSq(rndX) * weight,
        smoothAcosSq(rndY) * weight);
    
      PVector dot = p1.copy().sub(min).add(rel);
      dot.add(dist.copy().mult(rnd.nextFloat()));
      float dotSize = dotSizeMin + rnd.nextFloat() * (dotSizeMax - dotSizeMin);
      img.circle(dot.x, dot.y, dotSize);
    }
  }
}

float smoothCos(float x) {
  x = max(-1, min(1, x));
  return cos(x * HALF_PI);
}

float smoothAcos(float x) {
  x = max(0, min(1, x));
  return -acos(x) * QUARTER_PI + 1;
}

float smoothAcosSq(float x) {
  x = max(0, min(1, x));
  return -sqrt(acos(x) * 0.4) + 0.7;
}
