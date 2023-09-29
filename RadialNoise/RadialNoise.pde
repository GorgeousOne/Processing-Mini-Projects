
float dists[][];
float trigPhis[][][];
float noises[][][];
Slider zoom;
Slider speed;
Slider shadesCount;

//thoght I might want to describe what happens here, but actually I got no idea
void setup() {
  size(700, 700);
  
  dists = new float[width][height];
  trigPhis = new float[width][height][2];
  noises = new float[width][height][3];
  
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float dx = x - width/2;
      float dy = y - height/2;
      
      float phi = (float) Math.atan2(dx, dy);
      float dist = sqrt(dx*dx + dy*dy);
      float segPhi = map(phi % segAngle, 0, segAngle, 0, TWO_PI);
      
      dists[x][y] = dist;
      
      trigPhis[x][y][0] = 0.5 + cos(segPhi);
      trigPhis[x][y][1] = 0.5 + sin(segPhi);
      
      noises[x][y][0] = dist / maxDist * trigPhis[x][y][0];
      noises[x][y][1] = dist / maxDist * trigPhis[x][y][1];
      noises[x][y][2] = dist / maxDist;
    }
  }
  
  zoom = createSlider(0.2, 1);
  speed = createSlider(0.0, 0.05);
  shadesCount = createSlider(2, 255, 1);
  
  noiseSeed(97);
  //genShadeees();
}

//void genShadeees() {
//  float next = 1;
//  int steps = 256;
  
//  for (float i = 1; i < steps; i++) {
//    float value = gauss(i / steps);
//    distribution.add((next + value)/2 * i/steps);
//    next = value;
//  }
  
//  float sum = 0;
//  int stepper = 0;
  
//  if (shadeeesCount % 2 == 0) {
//    shades.add(0f);
    
//    for (int i = 1; i < shadeeesCount / 2; i++) {  
//      while(sum < PI * i / shadeeesCount) {
//        sum += distribution.get(stepper);
//        stepper++;
//      }
//      shades.add(1f * i / steps);
//    }

//  }else {
//    for (int i = 0; i < (shadeeesCount+1) / 2; i++) {  
//      while(sum < PI * (i + 0.5) / shadeeesCount) {
//        sum += distribution.get(stepper);
//        stepper++;
//      }
//      shades.add(1f * i / steps);
//    }
//  }
//}

//float getVal(float x) {
//  for (float i : shades) {
//    if   
//  }
//}


ArrayList<Float> distribution = new ArrayList<Float>();
ArrayList<Float> shades = new ArrayList<Float>();
float shadeeesCount = 5;

int segments = 12;
float segAngle = TWO_PI / segments;

float maxDist = sqrt(width*width + height*height);
float time = 0;

void draw() {
  
  background(255);
  loadPixels();
  
  float slideXY = pow(TWO_PI, zoom.value);
  float slideZ = pow(TWO_PI, 1-zoom.value);
  time += speed.value;
  
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
            
      float noiseX = noises[x][y][0] / slideXY;
      float noiseY = noises[x][y][1] / slideXY;
      float noiseZ = noises[x][y][2] * slideZ - time;
       
      if (filterOn) {
        
        pixels[x + y*width] = color(round(noise(noiseX, noiseY, noiseZ)) * 255);
      }else{
        pixels[x + y*width] = color(map(noise(noiseX, noiseY, noiseZ), 0, 1, 0, 255));
      }
      
      //pixels[x + y*width] = color(map(noise(dist/100), 0, 1, 0, 255));
      //pixels[x + y*width] = color(map(noise(10f * x/width, 10f * y/height), 0, 1, 0, 255));
      //pixels[x + y*width] = color(1f * x/width*255, 0, 1f * y/height*255);
    }
  }
  updatePixels();
  drawSliders();
}

float gauss(float x) {
  return pow(exp(x), -2);
}

boolean filterOn = false;
void keyPressed() {
  if (key == 'x') {
    filterOn = !filterOn;
  }
}
