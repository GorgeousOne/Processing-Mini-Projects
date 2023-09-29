import java.util.Collections;
import java.util.List;
import java.util.LinkedList;
import java.util.stream.Stream;
import java.util.stream.Collectors;

PGraphics buffer;
PGraphics grid;
LinkedList<LinkedList<PVector>> lines = new LinkedList<>();

int facets = 12;
boolean isMirrored = true;

long lastScreen;

void setup() {
  size(1001, 1001); 
  buffer = createGraphics(width, height);
  grid = createGraphics(width, height);
  
  buffer.beginDraw();
  buffer.background(51);
  buffer.endDraw();
  
  drawGrid();
}

void drawGrid() {
  grid.beginDraw();
  grid.stroke(128);
  grid.translate(.5 * grid.width, .5 * grid.height);

  for (int i = 0; i < facets; ++i) {
    grid.rotate(TWO_PI / facets);
    grid.line(10, 0, grid.width, 0);
  }
  grid.endDraw();
}

void draw() {
  image(buffer, 0, 0);  
  image(grid, 0, 0);
  
  long dt = System.currentTimeMillis() - lastScreen;
  if (dt < 400) {
    float alpha = 1 - (dt / 400f);
    alpha *= alpha;
    fill(255, alpha * 128);
    rect(0, 0, width, height);
  }
}

void mousePressed() {
  lines.addFirst(new LinkedList<PVector>());
  lines.getFirst().add(new PVector(mouseX, mouseY));
}

void mouseDragged() {
  LinkedList<PVector> line = lines.getFirst();
  PVector p = new PVector(mouseX, mouseY);
  line.addFirst(p);
  
  if (line.size() < 2) {
    return;
  }
  drawLine(line.get(1), p);
}

void drawLine(PVector p1, PVector p2) {
  buffer.beginDraw();
  buffer.stroke(255);
  buffer.strokeWeight(3);
  buffer.translate(.5 * buffer.width, .5 * buffer.height);
  
  PVector p3 = p1.copy().sub(.5 * buffer.width, .5 * buffer.height);
  PVector p4 = p2.copy().sub(.5 * buffer.width, .5 * buffer.height);
  
  if (isMirrored) {
    int halfFacets = facets / 2;
    float angle = getUnrotateAngle(p3, facets);

    PVector p5 = mirrorPoint(p3, angle);
    PVector p6 = mirrorPoint(p4, angle);
    
    for (int i = 0; i < halfFacets; ++i) {
      buffer.rotate(TWO_PI / halfFacets);
      buffer.line(p3.x, p3.y, p4.x, p4.y);
      buffer.line(p5.x, p5.y, p6.x, p6.y);
    }
  } else {
    for (int i = 0; i < facets; ++i) {     
      buffer.rotate(TWO_PI / facets);
      buffer.line(p3.x, p3.y, p4.x, p4.y);
    }
  }
  buffer.endDraw();
}

float getUnrotateAngle(PVector p, int facets) {
  float facetAngle = TWO_PI / facets;  
  int rotatedFacets = floor((atan2(p.y, p.x)) / facetAngle);
  return rotatedFacets * facetAngle;
}

PVector mirrorPoint(PVector p, float unrotateAngle) {
  PVector unrotated = getRotatedIdiot(p, -unrotateAngle);
  unrotated.y *= -1;
  return getRotatedIdiot(unrotated, unrotateAngle);
}

PVector getRotatedIdiot(PVector p, float phi) {
  float cosPhi = cos(phi);
  float sinPhi = sin(phi);
  return new PVector(
      p.x * cosPhi - p.y * sinPhi,
      p.x * sinPhi + p.y * cosPhi);
}

void keyPressed() {
  if (key != 's') {
    return;
  }
  String dir = sketchPath() + "/data";
  List<String> files = Stream.of(new File(dir).listFiles())
      .filter(file -> !file.isDirectory())
      .map(File::getName)
      .filter(name -> name.startsWith("Screenshot"))
      .collect(Collectors.toList());
      
  int idx = 0;
  Collections.sort(files);
  
  if (!files.isEmpty()) {
    try {
      idx = Integer.parseInt(files.get(files.size() - 1).substring(10, 13));
    } catch(NumberFormatException e) {}
  }
  String newName = String.format("./data/Screenshot%03d.png", idx + 1);
  buffer.save(newName);
  println(newName);
  lastScreen = System.currentTimeMillis();
}
