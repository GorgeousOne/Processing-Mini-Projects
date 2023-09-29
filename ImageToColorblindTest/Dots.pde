
class Dot {
  PVector mid;
  float radius;
  color paint;

  int lastImgHeight = -1;
  Set<PVector> coveredPixels;
  
  Dot(PVector mid, float radius, color paint) {
    this.mid = mid;
    this.radius = radius;
    this.paint = paint;
  }
  
  float circDist(PVector p) {
    return this.mid.dist(p) - radius;
  }
  
  float circDist(Dot other) {
    return this.mid.dist(other.mid) - radius - other.radius;
  }
  
  void display(PGraphics g) {
    g.fill(paint);
    g.ellipse(mid.x, mid.y, 2*radius, 2*radius);
  }
  
  void displayAvgColor(PImage img, float scale) {
    if (img.height != lastImgHeight) {
      calcCoveredPixels(img, scale);
      lastImgHeight = img.height;
    }
    PVector colorSum = new PVector();

    for (PVector pixelPos : coveredPixels) {
      color c = img.pixels[(int) (pixelPos.y * img.width + pixelPos.x)];
      colorSum.add(c >> 16 & 0xFF, c >> 8 & 0xFF, c & 0xFF);
    }
    colorSum.mult(1f / coveredPixels.size());
    this.paint = color(colorSum.x, colorSum.y, colorSum.z);
  }
  
  void calcCoveredPixels(PImage img, float scale) {
    coveredPixels = new HashSet<>();
    float scaledDiameter = scale * 2 * radius;
    PVector scaledMin = mid.copy().sub(radius, radius).mult(scale).add(.5 * img.width, .5 * img.height);
    
    for (int dx = 0; dx <= scaledDiameter; ++dx) {
      for (int dy = 0; dy <= scaledDiameter; ++dy) {
        PVector pixelPos = scaledMin.copy().add(dx, dy);
        
        if (pixelPos.x < 0 || pixelPos.x >= img.width || 
            pixelPos.y < 0 || pixelPos.y >= img.height) {
          continue;
        }
        coveredPixels.add(new PVector((int) pixelPos.x, (int) pixelPos.y));
      }    
    }
  }
}

class DotsArea {
  
  float areaRadius;
  float minDotRadius;
  float maxDotRadius; 
  float spacing;
  int iters;
  Set<Dot> dots;
  
  DotsArea(JSONObject json) {
    dots = new HashSet<>();
    areaRadius = json.getFloat("r");
    JSONArray dotsData = json.getJSONArray("dots");

    for (int i = 0; i < dotsData.size(); ++i) {
      JSONObject dotJson = dotsData.getJSONObject(i); 
      float x = dotJson.getFloat("x");
      float y = dotJson.getFloat("y");
      float r = dotJson.getFloat("r");
      dots.add(new Dot(new PVector (x, y), r, color(0)));
    }
  }
  
  JSONObject toJSON() {
    JSONObject json = new JSONObject();
    json.setFloat("r", areaRadius);

    JSONArray dotsData = new JSONArray();
    int i = 0;
    
    for (Dot dot : dots) {
      JSONObject dotJson = new JSONObject();
      dotJson.setFloat("x", dot.mid.x);
      dotJson.setFloat("y", dot.mid.y);
      dotJson.setFloat("r", dot.radius);
      dotsData.setJSONObject(i, dotJson);
      ++i;
    }
    json.setJSONArray("dots", dotsData);
    return json;
  }
  
  DotsArea(
      float areaRadius, 
      float minDotRadius, 
      float maxDotRadius, 
      float spacing,
      int iters) {
    this.areaRadius = areaRadius;
    this.minDotRadius = minDotRadius;
    this.maxDotRadius = maxDotRadius;
    this.spacing = spacing;
    this.iters = iters;
    this.dots = new HashSet<>();
    genDots();
  }
  
  void display(PGraphics g) {
    g.translate(.5 * g.width, .5 * g.height);
    
    for (Dot dot : dots) {
      dot.display(g);
    }
  }
  
  void displayImg(PImage img) {
    float scale = min(img.width, img.height) / (2 * areaRadius);
    img.loadPixels();
    
    for (Dot dot : dots) {
      dot.displayAvgColor(img, scale);
    }
  }
  
  void genDots() {
    color paint = color(255, 128, 128);
    float maxRadialDist = areaRadius - minDotRadius;
    
    for(int i = 0; i < iters; ++i) {
      PVector mid = new PVector(
          random(-maxRadialDist, maxRadialDist), 
          random(-maxRadialDist, maxRadialDist));
       
      float radialDist = mid.mag();
       
      if (radialDist > maxRadialDist) {
        continue; 
      }
      float minDist = minDotDist(mid);
       
      if (minDist >= minDotRadius + spacing) {
        float radius = maxDotRadius;
        radius = min(radius, minDist - spacing);
        radius = min(radius, areaRadius - radialDist);
        dots.add(new Dot(mid, radius, paint));
      }
    }
  }
  
  float minDotDist(PVector mid) {
    float minDist = 99999;
    
    for (Dot dot : dots) {
      minDist = min(minDist, dot.circDist(mid));
    }
    return minDist;
  }  
}
