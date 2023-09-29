import java.util.Scanner;
import java.io.FileNotFoundException;
import java.io.FileWriter;

void setup() {
  
  size(800, 800);
  colorMode(HSB);
  
  for (int i = 0; i < hueCount; i++) {
    Slider s = createSlider(0, 255, 1);
    s.w = 700;
    s.value = (256f / (hueCount - 1)) * i;
    pickers.add(s);
  }
  
  loadValues();
  bright = createSlider(0, 255);
  sat = createSlider(0, 255);

  bright.w = 256;
  sat.w = 256;
  bright.value = 256;
  sat.value = 256;
}

void loadValues() {
  try {
    File myObj = new File("C:/Users/Fred Feuerpferd/Sketches/colorpalette/colorvals.txt");
    Scanner myReader = new Scanner(myObj);
    
    int i = 0;
    while (myReader.hasNextLine() && i < hueCount) {
      
      float hue = Float.parseFloat(myReader.nextLine());
      pickers.get(i).value = hue;
      i++;
    }
    myReader.close();
  } catch (FileNotFoundException e) {
    e.printStackTrace();
  }
}

void saveValues() {
  try {
    FileWriter myWriter = new FileWriter("C:/Users/Fred Feuerpferd/Sketches/colorpalette/colorvals.txt");
    for (Slider picker : pickers) {
      myWriter.write(String.valueOf(picker.getValue()) + "\n");  
    }
    myWriter.close();
    System.out.println("Successfully wrote to the file.");
  } catch (IOException e) {
    System.out.println("An error occurred.");
    e.printStackTrace();
  }
}
void keyPressed() {
  
  if (key == ENTER) {
    saveValues();
  }else if (key == 'r') {
    loadValues();
  }
}

Slider bright;
Slider sat;

int hueCount = 13;
ArrayList<Slider> pickers = new ArrayList<Slider>();

void draw() {  
  noStroke();
  background(255);
  float rectWidth = 1f * width / hueCount;
  
  for (int hue = 0; hue < hueCount; ++hue) {
    fill(pickers.get(hue).getValue(), bright.value, sat.value);
    //rect(hue * rectWidth, 0, rectWidth, rectWidth);
    ellipse((hue + 0.5) * rectWidth, rectWidth, rectWidth*3/4, rectWidth*3/4);  
  }
  
  drawSliders();
}
