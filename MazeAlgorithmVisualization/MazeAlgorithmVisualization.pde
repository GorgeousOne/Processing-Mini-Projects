import java.util.List;
import java.util.LinkedList;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.HashSet;
import java.util.Stack;
import java.util.Collections;
import java.util.Arrays;

MazeAnimation maze;
PathAnimation path;
PathTree dfsTree;
PathTree primTree;
PathTree kruskalTree;


//maze animation lazy variables
float latticeEdge = 0;
float pathEdge = 0;

color bg = color(255);
color latticeCol = color(22, 38, 65); //color(78, 125, 206);
color cellCol = color(187, 210, 250);
color pathCol = color(255);

color green = color(81, 138, 88);
color red = color(186, 73, 73);
color blue = color(57, 112, 151);

color highlight = red;


void setup() {
  //size(1920, 1080);
  size(1280, 720);
  smooth();
  noStroke();
  frameRate(50);
  randomSeed(seed);
  
  //maze = new MazeAnimation(9, 16, 980);
  maze = new MazeAnimation(9, 16, 660);
  dfsTree = new DepthFirst(9, 16).generateMaze(4, 0, maze.getPathSize());
  primTree = new Prim(9, 16).generateMaze(4, 0, maze.getPathSize());
  kruskalTree = new Kruskal(9, 16).generateMaze(4, 0, maze.getPathSize());
  
  animDuration = kruskalTree.duration() * 2;
}

int seed = -14;
// in frames
int animStart = 0;
float animDuration;

void draw() {
  background(bg);
  float t = clamp((frameCount - animStart) / animDuration, 0, 1);
  t = smoothy(t) / 2.98;
  
  maze.display();
  highlight = red;
  dfsTree.displaySmooth(t);
  
  float offset = width / 3;
  
  pushMatrix();
  translate(offset, 0);
  maze.display();
  highlight = green;
  primTree.display(t);
  popMatrix();
  
  pushMatrix();
  translate(-offset, 0);
  maze.display();
  highlight = blue;
  kruskalTree.display(t);
  popMatrix();
}

float clamp(float t, float min, float max) {
  return min(max(t, min), max);
}


float smoothy(float t) {
  t = clamp(t, 0, 1);
  float t_sq = t * t;
  return 3 * t_sq - 2 * t_sq * t;
}

float nIn(float t, int n) {
  t = 1 - clamp(t, 0, 1);
  return 1 - pow(t, n);
}

void reset() {
  randomSeed(seed);
  dfsTree = new DepthFirst(9, 16).generateMaze(4, 0, maze.getPathSize());
  primTree = new Prim(9, 16).generateMaze(4, 0, maze.getPathSize());
  kruskalTree = new Kruskal(9, 16).generateMaze(4, 0, maze.getPathSize());
  animStart = frameCount;
  println(seed);
}

void keyPressed() {
  if (keyCode == LEFT) {
    seed -= 1;    
    reset();
  } else if (keyCode == RIGHT) {
    seed += 1;
    reset();
  }else if (key == 'r') {
    reset();
  }
}
