

void hilbert(List<PVector> vs, int level, PVector pos, PVector dir, int winding) {
  if (level <= 0) {
    return;
  }
  right(dir, winding);
  hilbert(vs, level-1, pos, dir, -winding);
  
  forward(vs, pos, dir);
  left(dir, winding);
  hilbert(vs, level-1, pos, dir, winding);

  forward(vs, pos, dir);
  hilbert(vs, level-1, pos, dir, winding);

  left(dir, winding);
  forward(vs, pos, dir);
  hilbert(vs, level-1, pos, dir, -winding);
  
  right(dir, winding);
}

void forward(List<PVector> vs, PVector pos, PVector dir) {
  pos.add(dir);
  vs.add(pos.copy());
}

//turn right in y-axis facing down coordinate system
void right(PVector dir, int winding) {
  float x = dir.x;
  dir.x = winding * -dir.y;
  dir.y = winding * x;   
}

void left(PVector dir, int winding) {
  float x = dir.x;
  dir.x = winding * dir.y;
  dir.y = winding * -x;
}
