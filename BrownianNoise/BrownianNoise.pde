
PGraphics img;

void setup() {
  size(800, 800);  
  img = createGraphics(width, height);
  drawNoise();
  noLoop();
}

void drawNoise() {
  float detail = 0.01;
  
  img.beginDraw();
  img.loadPixels();
  for (int x = 0; x < img.width; ++x) {
    for (int y = 0; y < img.height; ++y) {
      int index = y * img.width + x;
      img.pixels[index] = color(255 * pattern(new PVector(1f * x / width, 1f * y / height)));
      
    }
  }
  img.updatePixels();
  img.endDraw();
}

float pattern(PVector p )
{
    PVector q = new PVector(
        fbm(p), 
        fbm(PVector.add(p, new PVector(5.2, 1.3))));

    PVector r = new PVector(
        fbm(PVector.add(PVector.add(p, q), new PVector(1.7,9.2) )),
        fbm(PVector.add(PVector.add(p, q.mult(4.0)), new PVector(8.3,2.8))));

    return fbm(PVector.add(p, r.mult(4.0)));
}

float OCTAVES = 3;

float fbm (PVector st) {
    // Initial values
    float value = 0.0;
    float amplitude = .52;
    float frequency = 0.1;
    //
    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(st.x, st.y);
        st.mult(2.);
        amplitude *= .5;
    }
    return value;
}


void draw() {
  image(img, 0, 0);
}
