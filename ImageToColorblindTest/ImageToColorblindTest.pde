
import java.util.Set;
import java.util.HashSet;
import java.util.Map;

PGraphics canvas;
DotsArea dots;

void setup() {
  size(960, 720);
  
  canvas = createGraphics(height, height);
  canvas.beginDraw();
  canvas.noStroke();
  canvas.endDraw();
  createDotsArea(.4 * canvas.height);  
}

void createDotsArea(float areaRadius) {
  float unit = areaRadius / 100.;
  float dotMinRadius = 1.4 * unit;
  float dotMaxRadius = 5.2 * unit;
  float spacing = .8 * unit;
  
  dots = new DotsArea(loadJSONObject("data/dots.json"));
  //dots = new DotsArea(areaRadius, dotMinRadius, dotMaxRadius, spacing, 100000);
  //saveJSONObject(dots.toJSON(), "data/dots.json");
}

int fps = 25;

void draw() {
  background(255);
  //PImage frame = loadImage(String.format("data/imgs/rick%04d.bmp", frameCount));
  PImage frame = loadImage(String.format("data/foot.png", frameCount));
  
  frame.resize(frame.width / 10, frame.height / 10);
  updateDots(frame);
  image(canvas, .5*width - .5*canvas.width, .5*height - .5*canvas.height);
  //saveFrame("/vid/rick####.jpg");
}

void updateDots(PImage frame) {
  canvas.beginDraw();
  canvas.clear();
  
  dots.displayImg(frame);
  dots.display(canvas);
  
  canvas.endDraw();
}
