
Slider innserSize;
Slider outerSize;

Slider guideLine1;
Slider guideLine2;

Slider ringCount;
Slider outerRingSize;
Slider innerRingSize;

void setup() {
  size(800, 800);
  
  innserSize = createSlider(0, 500, 5);
  innserSize.w = 400;
  
  outerSize = createSlider(0, 500, 5);
  outerSize.value = 400;
  
  guideLine1 = createSlider(0, 0.5, 0.025);
  guideLine2 = createSlider(0.5, 1, 0.025);

  ringCount = createSlider(12, 24, 0.2);
  ringCount.w = 400;

  innerRingSize = createSlider(50, 250, 5);
  innerRingSize.w = 400;

  outerRingSize = createSlider(50, 250, 5);
  outerRingSize.w = 400;
  
  innserSize.value = 180;
  outerSize.w = 400;
  guideLine1.value = 0.125;
  guideLine2.value = 0.9;
  innerRingSize.value = 120;
  outerRingSize.value = 130;
  ringCount.value = 21;
}


color border = color(82, 87, 255);

void draw() {
  background(255);
  
  float iSize = innserSize.value;
  float oSize = outerSize.value;
  float guide1 = iSize + (oSize - iSize) * guideLine1.value;
  float guide2 = iSize + (oSize - iSize) * guideLine2.value;
  
  push();
  translate(width/2, height/3); 
  rotate(HALF_PI);
  float phi = TWO_PI / ringCount.value;
  float orSize = outerRingSize.value;
  float irSize = innerRingSize.value;
  
  for (float angle = 0; angle < TWO_PI; angle += phi) {
    float guide = round(angle/phi) % 2 == 0 ? guide1 : guide2;
    float size = round(angle/phi) % 2 == 0 ? irSize : orSize;
    float x = guide/2 * cos(angle);
    float y = guide/2 * sin(angle);
    
    fill(255);
    stroke(border);
    strokeWeight(5);
    ellipse(x, y, size, size);
    strokeWeight(2);

    ellipse(x, y, size * 2/3, size * 2/3);
    ellipse(x, y, size * 1/3, size * 1/3);
    
    
    //fill(196);
    //noStroke();
    //ellipse(x, y, 5, 5);
  }  
  
  int pad = 200;
  strokeWeight(pad);
  stroke(255);
  noFill();
  ellipse(0, 0, oSize+pad, oSize+pad);
  
  strokeWeight(5);
  stroke(border);
  
  noFill();
  ellipse(0, 0, oSize, oSize);
  fill(255);
  ellipse(0, 0, iSize, iSize);

  strokeWeight(1);
  noFill();
  stroke(196);
  //ellipse(0, 0, guide1, guide1);
  //ellipse(0, 0, guide2, guide2);

  pop();
  drawSliders();
}
