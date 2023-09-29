import controlP5.*;

ControlP5 cp5;
PGraphics3D g3;

OrbitCamera cam;
Icosahedron spikeBall;

List<Slider> sliders;
List<Spike> spikes;

void setup() {
  size(1200, 800, P3D);
  smooth();
  
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  g3 = (PGraphics3D)g;
  
  cam = new OrbitCamera();
  cam.setYUp(true);
  cam.setDefaultRadius(400);
  spikeBall = new Icosahedron(100);
  
  sliders = new ArrayList<>();
  spikes = new ArrayList<>();
  setupControls();
  createSpikes();
}

Slider sliderLength;
Slider sliderBaseSize;
Slider sliderSegments;
int sliderHeight = 15;

void setupControls() {
  sliderBaseSize = cp5.addSlider("length")
      .setPosition(20, 20)
      .setSize(200, sliderHeight)
      .setRange(100, 300);
      
  sliderBaseSize = cp5.addSlider("baseSize")
      .setPosition(20, 40)
      .setSize(200, sliderHeight)
      .setRange(10, 100);
      
  sliderBaseSize = cp5.addSlider("edges")
      .setPosition(20, 60)
      .setSize(200, sliderHeight)
      .setRange(3, 48)
      .setNumberOfTickMarks(46)
      .setValue(8);

  sliderSegments = cp5.addSlider("segmentCount")
      .setPosition(20, 80)
      .setSize(200, sliderHeight)
      .setRange(2, 10)
      .setNumberOfTickMarks(9)
      .setValue(10);
      
  for (int i = 0; i < sliderSegments.getMax(); ++i) {
    sliders.add(cp5.addSlider("segment" + i)
        .setPosition(20, 120 + i * (sliderHeight + 5))
        .setSize(200, sliderHeight)
        .setRange(.001f, 1)
        .setValue(.5f));
  }
  updateSegmentSliders();
}

void updateSegmentSliders() {
  int sliderCount = int(sliderSegments.getValue());
  
  for (int i = 0; i < sliderSegments.getMax(); ++i) {
    sliders.get(i).setVisible(i < sliderCount);
  }
  updateSpikes();
}

List<Float> getRingSizes() {
  List<Float> ringSizes = new ArrayList<>();
  
  for (Slider slider : sliders) {
    if (!slider.isVisible()) {
      break;
    }
    ringSizes.add(slider.getValue());
  }
  return ringSizes;
}

void createSpikes() {
  for (PVector v : spikeBall.vertices) {
    spikes.add(new Spike(new PVector(), v, 10));
  }
  updateSpikes();
}

void updateSpikes() {
  List<Float> ringSizes = getRingSizes();
    
  for (Spike spike : spikes) {
    spike.setRingSizes(ringSizes);
  }
}

void updateLength(float size) {
  for (Spike spike : spikes) {
    spike.setLength(size);
  }
}
void updateBaseSize(float size) {
  for (Spike spike : spikes) {
    spike.setBaseSize(size);
  }
}

void updateEdgeCount(int count) {
  for (Spike spike : spikes) {
    spike.setRingVertexCount(count);
  }
}

void updateRingSize(int ringIndex, float size) {
  for (Spike spike : spikes) {
    spike.setRingSize(ringIndex, size);
  }
}

void draw() {
  background(255);
  lights();
  
  drawGUI();
  cam.update();
  
  pushMatrix();
  cam.applyRotation();
  //spikeBall.display();
  noStroke();
  fill(255);
  
  for (Spike spike : spikes) {
    spike.display();
  }
  pushStyle();
  stroke(255, 0, 0);
  line(0, 0, 0, 100, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 100, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 100);
  popStyle();
  popMatrix();
}

void drawGUI() {
  PMatrix3D currCameraMatrix = new PMatrix3D(g3.camera);
  camera();
  cp5.draw();
  g3.camera = currCameraMatrix;
  cam.stateChanged = true;
}

public void controlEvent(ControlEvent event) {
  if (frameCount == 0) {
    return;
  }
  switch(event.getName()) {
    case "length":
      updateLength(event.getValue());
      return;
    case "segmentCount":
      updateSegmentSliders();
      return;
    case "baseSize":
      updateBaseSize(event.getValue());
      return;
    case "edges":
      updateEdgeCount(int(event.getValue()));
      return;
  }
  String controlName = event.getName();
  
  if (controlName.contains("segment")) {
    int sliderIndex = Integer.parseInt(controlName.substring(7, controlName.length()));
    updateRingSize(sliderIndex, event.getValue());
  }
}
