
class IntVec {
  int x;
  int y;
  
  IntVec() {
    this(0, 0);  
  }
  
  IntVec(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  IntVec add(IntVec other) {
    this.x += other.x;
    this.y += other.y;
    return this;
  }
  
  IntVec add(int dx, int dy) {
    this.x += dx;
    this.y += dy;
    return this;
  }
  
  IntVec mult(int i) {
    this.x *= i;
    this.y *= i;
    return this;
  }
  
  IntVec clone() {
    return new IntVec(x, y);  
  }
  
  String toString() {
    return "(x:" + x + ", y:" + y + ")";
  }
}

void hilbert(int level, IntVec pos, IntVec dir, int facing) {
  if (level <= 0) {
    return;
  }
  right(dir, facing);
  hilbert(level-1, pos, dir, -facing);
  forward(pos, dir);

  left(dir, facing);
  hilbert(level-1, pos, dir, facing);

  forward(pos, dir);
  hilbert(level-1, pos, dir, facing);

  left(dir, facing);
  forward(pos, dir);
  hilbert(level-1, pos, dir, -facing);
  right(dir, facing);
}

void forward(IntVec pos, IntVec dir) {  
  pos.add(dir);
  vs.add(pos.clone());
}

//turn right in y-axis facing down coordinate system
void right(IntVec dir, int facing) {
  int x = dir.x;
  dir.x = facing * -dir.y;
  dir.y = facing * x;   
}

void left(IntVec dir, int facing) {
  int x = dir.x;
  dir.x = facing * dir.y;
  dir.y = facing * -x;
}

//IntVec leftNeighbor(IntVec dir) {
//  int deltaX = dir.x == 1 || dir.y == 1 ? 0 : -1;
//  int deltaY = dir.x == -1 || dir.y == 1 ? 0 : -1;
//  return new IntVec(deltaX, deltaY);
//}

//IntVec rightNeighbor(IntVec dir) {
//  int deltaX = dir.x == 1 || dir.y == -1 ? 0 : -1;
//  int deltaY = dir.x == 1 || dir.y == 1 ? 0 : -1;
//  return new IntVec(deltaX, deltaY);
//}
