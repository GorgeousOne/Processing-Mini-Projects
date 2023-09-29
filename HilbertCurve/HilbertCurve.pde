import java.util.List;
import java.util.LinkedList;
float spacing = 100;
//Grid grid;
PVector gridOff;
color blue = color(40, 46, 79);

int w = 65;
int h = 66;

List<IntVec> vs = new LinkedList<>();
List<Integer> levels = new LinkedList<>();
void setup() {
  size(800, 800);
  //grid = new Grid(w, h);
  gridOff = new PVector (spacing, spacing);
  noStroke();
  //stroke(255, 0, 0);
  fill(blue);
  
  int level = 6;
  IntVec pos = new IntVec(1, 1);
  IntVec dir = new IntVec(1, 0);
  vs.add(pos.clone());
  vs.add(pos.add(0, 1).clone());
  hilbert(level, pos, dir, 1);
  vs.add(pos.add(0, -1));
  noLoop();
}

void draw() {
  background(255);
  scale(1, -1);
  translate(0, -height);
  
  float gridW = width - 2*spacing;
  //grid.display(gridOff, gridW);
  float sqSize = gridW / w;

  beginShape();
  for (IntVec v : vs) {
    vertex(gridOff.x + v.x * sqSize, gridOff.y + v.y * sqSize);
  }
  endShape(CLOSE);
}

//class Grid {
//  Square[][] sqs;
  
//  Grid(int columns, int rows) {
//    sqs = new Square[columns][rows];
    
//    for (int x = 0; x < columns; ++x) {
//      for (int y = 0; y < rows; ++y) {  
//        sqs[x][y] = new Square(x, y);
//      }
//    }
//  }
    
//  void setPaint(int x, int y, color c) {
//    try {
//      sqs[x][y].setPaint(c);
//    } catch(IndexOutOfBoundsException ex) {
//      println(x + ", "+ y + " out of bounds");
//    }
//  }
  
//  void display(PVector pos, float w) {
//    float sqSize = w / sqs.length;

//    for (int x = 0; x < sqs.length; ++x) {
//      for (int y = 0; y < sqs[0].length; ++y) {
//        sqs[x][y].display(pos, sqSize);
//      }
//    }
//  }
//}

//class Square {
//  int x;
//  int y;
//  color paint = color(255);
  
//  Square(int x, int y) {
//    this.x = x;
//    this.y = y;
//  }
  
//  void setPaint(color newPaint) {
//    paint = newPaint;
//  }
  
//  void display(PVector pos, float size) {
//    fill(paint);
//    rect(pos.x + x * size, pos.y + y * size, size, size);
//  }
//}
