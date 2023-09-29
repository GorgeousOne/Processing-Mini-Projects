import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.Map;
import java.util.Random;
import java.util.Collections;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

List<Pos> smokeBorder;
Map<Pos, Blot> parentCols;
Set<Blot> usedColors;

int range = 64;
int step = 256 / range;

List<List<Blot>> distances;

PGraphics smoke;
Random rnd = new Random();

void setup() {
  size(512, 512);
  //size(1920, 1080);

  smoke = createGraphics(width, height);
    smokeBorder = new ArrayList<>(2 * (width + height));
  parentCols = new HashMap<>();
  distances = new ArrayList<>(range);
  usedColors = new HashSet<>();
  
  listDistances();
  initSmoke();
}

boolean isSaved;

void draw() {
  background(0);
  image(smoke, 0, 0);  
  createSmoke();
  
  if (smokeBorder.isEmpty() && !isSaved) {
    LocalDateTime now = LocalDateTime.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yy-MM-dd-HH-mm-ss");
    String dateString = now.format(formatter);
    smoke.save(dateString + "smoke" + width + "x" + height + ".png");
    isSaved = true;
  }
}

void initSmoke() {
  println("init smoke");
  //Pos pos = new Pos(rnd.nextInt(width), rnd.nextInt(height));
  Blot col = new Blot(rnd.nextInt(range), rnd.nextInt(range), rnd.nextInt(range));
  //Pos pos = new Pos(1056, 390);
  //Blot col = new Blot(127, 62, 0);
  Pos pos = new Pos(256, 256);


  usedColors.add(col);
  expandBorder(pos, col);
  println(smokeBorder.size());
}

void createSmoke() {
  Pos pos;
  Blot col;
  
  int idx; // = pos.y * smoke.width + pos.x;

  smoke.beginDraw();
  smoke.loadPixels();
  //smoke.pixels[idx] = color(col.r, col.g, col.b);
  
  int i = 0;

  while(!smokeBorder.isEmpty()) {
    pos = smokeBorder.remove(rnd.nextInt(smokeBorder.size()));
    idx = pos.y * smoke.width + pos.x;
    col = closest(parentCols.get(pos));
    
    smoke.pixels[idx] = color(
        (col.r + 1) * step - 1, 
        (col.g + 1) * step - 1, 
        (col.b + 1) * step - 1);
    usedColors.add(col);
    
    expandBorder(pos, col);
    
    ++i;
    if (i == 1000) {
      for (List<Blot> deltas : distances) {
        Collections.shuffle(deltas);
      }
      println(smokeBorder.size(), parentCols.size());  
      break;
    }
  }
  smoke.updatePixels();
  smoke.endDraw();
}

Pos[] directions = new Pos[4];

void expandBorder(Pos pos, Blot col) {
  directions[0] = new Pos(pos.x, pos.y + 1);
  directions[1] = new Pos(pos.x + 1, pos.y);
  directions[2] = new Pos(pos.x, pos.y - 1);
  directions[3] = new Pos(pos.x - 1, pos.y);
  
  for (Pos other : directions) {
    if (!parentCols.containsKey(other) && isInBounds(other)) {
      smokeBorder.add(other);
      parentCols.put(other, col);
    }
  }
}


boolean isInBounds(Pos pos) {
  return 
      pos.x >= 0 && pos.x < smoke.width &&
      pos.y >= 0 && pos.y < smoke.height;
}

//create lists of possible color deltas sorted by increasing distances
void listDistances() {
  println("list distnaces");
  for (int i = 1; i <= range; ++i) {
    Set<Blot> deltas = new HashSet<>();

    for (int dr = 0; dr <= i; ++dr) {
      for (int dg = 0; dg <= i - dr; ++dg) {
        int db = i - dr - dg;
        deltas.add(new Blot( dr,  dg,  db));
        deltas.add(new Blot( dr,  dg, -db));
        deltas.add(new Blot( dr, -dg,  db));
        deltas.add(new Blot( dr, -dg, -db));
        deltas.add(new Blot(-dr,  dg,  db));
        deltas.add(new Blot(-dr,  dg, -db));
        deltas.add(new Blot(-dr, -dg,  db));
        deltas.add(new Blot(-dr, -dg, -db));
      }
    }
    List<Blot> deltasList = new ArrayList<>(deltas);
    Collections.shuffle(deltasList);
    distances.add(deltasList);
  }
}

//Color class
Blot closest(Blot blot) {
  Blot candidate = new Blot(0, 0, 0);
  
  for (List<Blot> deltas : distances) {
    for (Blot delta : deltas) {
      candidate.r = blot.r + delta.r;
      candidate.g = blot.g + delta.g;
      candidate.b = blot.b + delta.b;

      if (isColor(candidate)) {
        if (!usedColors.contains(candidate)) {
           return candidate;
        }
      }
    }
  }
  //println(blot.r + ", " + blot.g + ", " + blot.b + " failed");
  return new Blot(range/2, range/2, range/2);
}

boolean isColor(Blot col) {
  return
      col.r >= 0 && col.r < range &&
      col.g >= 0 && col.g < range &&
      col.b >= 0 && col.b < range;
}

//2d pixel pos class
class Pos {
  int x;
  int y;
  
  Pos(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  @Override
  public int hashCode() {
    int hash = 31 + x;
    hash = 31 * hash + y;
    return hash;
  }
    
  @Override
  public boolean equals(Object obj) {
    Pos other = (Pos) obj;
    return x == other.x && y == other.y;
  }
}

class Blot {
  int r;
  int g;
  int b;
  
  Blot(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
  
  @Override
  public int hashCode() {
    int hash = 53 + r;
    hash = 53 * hash + g;
    hash = 53 * hash + b;
    return hash;
  }
    
  @Override
  public boolean equals(Object obj) {
    Blot other = (Blot) obj;
    return r == other.r && g == other.g && b == other.b;
  }
  
  String toString() {
    return "(" + r + ", " + g + ", " + b + ")";
  }
}
