import java.util.List;
import controlP5.*;

ControlP5 cp5;
float sliderTicks2 = 1.0;

PImage board;
PFont font;

List<String> teams;
List<List<PVector>> lines;
List<Stroke> strokes;
List<PVector> currentLine;

float fontSize = 100;

float scale;
float weight;
int pointCount;

float dotSizeMin = 0.1;
float dotSizeMax = 2.0;
Random rnd = new Random();

boolean isDrawing = false;

void setup() {
  size(1600, 900, P2D);  
  smooth();
  
  cp5 = new ControlP5(this);
  
  board = loadImage("chalkboard.jpg");
  font = createFont("DkCrayonCrumble-ddll.ttf", fontSize);
  surface.setResizable(true);
  
  teams = new ArrayList<>();
  lines = new ArrayList<>();
  strokes = new ArrayList<>();
  currentLine = new ArrayList<>();
  
  teams.add("Raid Jello Legends");
  teams.add("Sigma");
  teams.add("Millenium Falcon");
  
  textFont(font);  
  stroke(255);
  noLoop();
  setScale(1.0);
  
  cp5.addSlider("sliderTicks2")
     .setPosition(25, height - 25)
     .setWidth(400)
     .setRange(0.5, 5)
     .setValue(1.0)
     .setNumberOfTickMarks(10)
     .setSliderMode(Slider.FLEXIBLE);
}

void setScale(float newScale) {
  scale = newScale;
  weight = 10 * scale;
  strokeWeight(weight/2);
  
  pointCount = (int) (15 * scale * scale);
  dotSizeMin = 0.1;
  dotSizeMax = 2.0;
}

void draw() {
  background(0);
  image(board, 0, 0);  
  drawLines();
}

void drawLines() {
  for (Stroke s : strokes) {
    s.display();
  }
  drawLine(currentLine);
}

void drawLine(List<PVector> line) {
  for (int i = 0; i < line.size() - 1; ++i) {
    PVector p1 = line.get(i);
    PVector p2 = line.get(i+1);
    line(p1.x, p1.y, p2.x, p2.y);
  }
}

void mouseMoved() {
  redraw();  
}

void mousePressed() {
  if (mouseY < height - 50) {
    setScale(sliderTicks2);
    isDrawing = true;
  }
}
void mouseDragged() {
  if (isDrawing) {
    currentLine.add(new PVector(mouseX, mouseY));
  }
  redraw();  
}

void mouseReleased() {
  if (currentLine.size() > 0) {
    strokes.add(new Stroke(currentLine));
    lines.add(currentLine);
    currentLine = new ArrayList<>();
    redraw();
  }
  isDrawing = false;
}

void keyPressed() {
  if (key == BACKSPACE && strokes.size() > 0) {  
    strokes.remove(strokes.size() - 1);
    redraw();
  }
}

void windowResized() {
  redraw();
}
