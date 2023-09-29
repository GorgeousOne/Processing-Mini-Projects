
ArrayList<Slider> sliders = new ArrayList<Slider>();
Slider clickedSlider = null;

float sw = 200;
float sh = 6;
float offx = 5*sh;
float offy = 5*sh;

Slider createSlider() {
  Slider slider = new Slider(offx, -offy * (sliders.size() + 1), sw, sh);
  sliders.add(slider);
  return slider;
}

Slider createSlider(float min, float max) {
  return createSlider().setRange(min, max);
}

Slider createSlider(float min, float max, float step) {
  return createSlider().setRange(min, max, step);
}

void drawSliders() {
  
  for (Slider slider : sliders) {
    slider.display();
  }
}

@Override
void handleMouseEvent(MouseEvent event) {
  
  super.handleMouseEvent(event);
  
  if (event.getButton() != LEFT) {
    return;
  }
  
  switch(event.getAction()) {
    case MouseEvent.PRESS:
      for (Slider slider : sliders) {
        if (slider.contains(mouseX, mouseY)) {
          clickedSlider = slider;
          cursor(MOVE);
          break;
        }
      }
      break;
      
    case MouseEvent.RELEASE:
      clickedSlider = null;
      cursor(TEXT);
      break;
      
    case MouseEvent.DRAG:
      if (clickedSlider != null) {
        clickedSlider.drag(mouseX);
      }
  }
}

class Slider {
  
  float dx;
  float dy;
  float w;
  float h;
  float size;
  
  color fill = color(215);
  color stroke = color(90);
  
  float value = 0;
  float min = 0;
  float max = 10;
  float step = -1;
    
  Slider(float dx, float dy, float w, float h) {
    this.dx = dx;
    this.dy = dy;
    this.w = w;
    this.h = h;
    this.size = 2*h;
  }
  
  float getValue() {
    return value;
  }
  
  Slider setRange(float min, float max) {
    return setRange(min, max, this.step);
  }

  Slider setRange(float min, float max, float step) {
    this.min = min;
    this.max = max;
    this.step = Math.min(Math.abs(max-min), step);
    this.value = max(min, min(max, this.value));
    return this;
  }
  
  void drag(float mX) {
    
    float posX = getPosX();
    float targetX = max(posX, min(posX + w, mX));
    
    value = min + (targetX - posX) / w * (max - min);
    
    if (step > 0) {
      value = min(max, min + round((value - min) / step) * step);
    }
  }
  
  boolean contains(float x, float y) {
    float valueX = getPosX() + getValuePos();
    float valueY = getPosY() + h/2;    
        
    return
        x >= valueX - 2*h && x < valueX + 2*h &&
        y >= valueY - 2*h && y < valueY + 2*h;
  }
  
  float getPosX() {
    return dx + (dx < 0 ? width : 0);
  }
  
  float getPosY() {
    return dy + (dy < 0 ? height : 0);
  }
  
  float getValuePos() {
    return max(0, min(1, (value - min) / (max - min))) * w;
  }
  
  void display() { 
    float posX = getPosX();
    float posY = getPosY();
    
    fill(fill);
    stroke(stroke);
    rect(posX, posY, w, h, h);
    ellipse(posX + getValuePos(), posY + h/2, 3*h, 3*h);
  }
}
