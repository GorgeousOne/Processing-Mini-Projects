import java.util.Arrays;

PImage inputImage;
PImage outputImage;

void setup() {
  size(480, 480);
  inputImage = loadImage("circ.png");
  outputImage = abberate(inputImage, 10);
  image(outputImage, 0, 0);
  //outputImage.save("C:/Users/Yoga 370/Desktop/gauss.png");
}

void draw() {
  // Display the output image
}

PImage abberate(PImage img, int radius) {
  int[][][] rgb = splitChannels(img);
  //float[] kernel = createGaussianKernel(radius, radius);
  //float[] kernel = createLinearKernel(radius);
  float[] kernel = createSmoothKernel(radius);

  println(Arrays.toString(kernel));
  
  int w = img.width;
  int h = img.height;

  PImage out = createImage(w, h, RGB);
  out.loadPixels();
  
  
  for (int y = 0; y < h; ++y) {
    
    for (int x = 0; x < w; ++x) {
      float r = applyKernel(rgb, x - radius, y, 0, kernel, radius, w);
      float g = applyKernel(rgb, x, y, 1, kernel, radius, w);
      float b = applyKernel(rgb, x + radius, y, 2, kernel, radius, w);
      out.pixels[x + y * w] = color(r, g, b);
    }
  }
  out.updatePixels();
  return out;
}

float applyKernel(int[][][] channels, int x, int y, int channel, float[] kernel, int radius, int w) {
  float sum = 0;

  for (int i = -radius; i <= radius; i++) {
      int offsetX = x + i;

      if (offsetX >= 0 && offsetX < w) {
        sum += channels[offsetX][y][channel] * kernel[i + radius];
      }
  }  
  return sum;
}

int[][][] splitChannels(PImage img) {
  img.loadPixels();
  int w = img.width;
  int h = img.height;
  int[][][] rgbChannels = new int[w][h][3];

  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      int pixelColor = img.pixels[x + y * w];

      // Extract Red, Green, and Blue channels using bit shifting
      rgbChannels[x][y][0] = (pixelColor >> 16) & 0xFF; // Red channel
      rgbChannels[x][y][1] = (pixelColor >> 8) & 0xFF;  // Green channel
      rgbChannels[x][y][2] = pixelColor & 0xFF;         // Blue channel
    }
  } 
  return rgbChannels;
}

float[] createSmoothKernel(int radius) {
  int size = 2 * radius + 1;
  float[] kernel = new float[size];
  float sum = 0;
  
  for (int i = 0; i <= radius; ++i) {
    float value =  smooth(1f * i / radius);
    kernel[i] = value;
    sum += value;
  }
  for (int i = 1; i <= radius; ++i) {
    float value = smooth(1f * (radius - i));
    kernel[i + radius] = smooth(1f * (radius - i));
    sum += value;
  }
  for (int i = 0; i < size; i++) {
    kernel[i] /= sum;
  }
  return kernel;
}

float smooth(float x) {
  x = max(0, min(1, x));
  return x * x * (3 - 2 * x);
}

float[] createLinearKernel(int radius) {
  int size = 2 * radius + 1;
  float[] kernel = new float[size];
  float invSum = 1f / (radius * radius);
  
  for (int i = 0; i < radius; ++i) {
    kernel[i] = (i + 1) * invSum;
  }  
  for (int i = 1; i < radius; ++i) {
    kernel[i + radius + 1] = (radius - i) * invSum;
  }
  return kernel;
}

float[] createGaussianKernel(int radius, float sigma) {
  int size = 2*radius + 1;  
  float[] kernel = new float[size];  
  float sum = 0;
  
  for (int i = 0; i < size; i++) {
    float distance = i - radius;
    float exponent = -(distance * distance) / (2 * sigma * sigma);
    float value = exp(exponent) / (sqrt(2 * PI) * sigma);
    
    kernel[i] = value;
    sum += value;
  }  
  // Normalize the kernel
  for (int i = 0; i < size; i++) {
    kernel[i] /= sum;
  }
  return kernel;
}
