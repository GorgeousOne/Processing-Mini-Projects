import java.util.List;
import java.util.LinkedList;


color blue = color(40, 46, 79);
float size = 20;

int maxLevel = 6;

List<List<PVector>> curves = new ArrayList<>();

void setup() {
  size(800, 800);
  stroke(255);
  strokeWeight(3);
  noFill();
  //noLoop();

  for (int level = 1; level <= maxLevel; ++level) {
    List<PVector> vs = new ArrayList<>();
    PVector pos = new PVector();
    PVector dir = new PVector(1, 0);
    vs.add(pos.copy());

    hilbert(vs, level, pos, dir, 1);
    curves.add(vs);
  }
}

int stageTime = 20;
  float val = 3;

void draw() {
  background(blue);
  scale(1, -1);
  translate(0, -height);

  int imgSize = 600;
  translate(.5 * width, .5 * height);
  
  //int stage = 1 + constrain(frameCount / stageTime, 0, maxLevel - 2);
  int stage = 1 + frameCount / stageTime;
  float t = 1f * frameCount % stageTime / stageTime;
  //t = slerp(0, 1, t);
  float thick = pow(val, maxLevel - stage - 1);
  float thick2 = pow(val, maxLevel - stage - 2);
  
  PImage img = drawCurveSlime(stage, imgSize, thick, thick2, t);
  image(img, -.5 * imgSize,  -.5 * imgSize);
  if (frameCount / stageTime >= maxLevel - 1) {
    exit();
  }
}

  
void drawCurve(int level) {
  float off = .5 * (pow(2, level) - 1);
  PVector offset = new PVector(off * size, off * size);
  translate(.5 * width - offset.x, .5 * height - offset.y);

  beginShape();
  for (PVector v : curves.get(level - 1)) {
    vertex(v.x * size, v.y * size);
  }
  endShape();
}

PImage drawCurveSlime(int level, int size, float borderRadius1, float borderRadius2, float t) {
  t = constrain(t, 0, 1);
  PImage img = new PImage(size, size, ARGB);
  img.loadPixels();
  float invImgSize = 1f / size;

  for (int x = 0; x < size; ++x) {
    for (int y = 0; y < size; ++y) {
      float normX = invImgSize * (x + .5);
      float normY = invImgSize * (y + .5);
      float dist1 = getPointToCurveDist(normX, normY, (level - 1) % (maxLevel - 1) + 1);
      float dist2 = getPointToCurveDist(normX, normY, level % (maxLevel - 1) + 1);

      float mergedDist = slerp(dist1, dist2, t);
      //float mergedDist = max(dist1 * (1- t), dist2 * t);
      //float mergedDist = slerp(imgDist1, 0, t) + slerp(0, imgDist2, t);
      //float imgDist1 = dist1 * size - borderRadius1;
      //float imgDist2 = dist2 * size - borderRadius2;

      float alpha = constrain(128 - (mergedDist * mergedDist) * 1024, 0, 255);
      img.pixels[y * size + x] = color(255, alpha);
    }
  }
  updatePixels();
  return img;
}

float slerp(float start, float end, float t) {
  return start + (end - start) * (3 * t * t - 2 * t * t * t);  
}

float getPointToCurveDist(float normX, float normY, int level) {
  float curveSize = pow(2, level);
  int vertexCount = (int) pow(4, level);

  float curveX = normX * curveSize - .5;
  float curveY = normY * curveSize - .5;
  int vertexIdx = findCurveVertexIdx(normX, normY, level, 0);
  int startIdx = constrain(vertexIdx - 1, 0, vertexCount);
  int endIdx = constrain(vertexIdx + 5, 0, vertexCount);
  float dist = getCurveDist(curveX, curveY, curves.get(level - 1).subList(startIdx, endIdx));
  
  return dist; // / curveSize;
}

int findCurveVertexIdx(float normX, float normY, int level, int startIndex) {
  if (level == 1) {
    return startIndex;
  }
  int lvlVertexCount = (int) pow(4, level - 1);
  if (normX < .5) {
    normX = normX * 2 - .5;

    if (normY < .5) {
      normY = normY * 2 - .5;
      return findCurveVertexIdx(.5 + normY, .5 + normX, level - 1, startIndex);
    } else {
      normY = 2 * normY - 1.5;
      return findCurveVertexIdx(.5 + normX, .5 + normY, level - 1, startIndex + lvlVertexCount);
    }
  } else {
    normX = 2 * normX - 1.5;

    if (normY < .5) {
      normY = normY * 2 - .5;
      return findCurveVertexIdx(.5 - normY, .5 - normX, level - 1, startIndex + lvlVertexCount * 3);
    } else {
      normY = normY * 2 - 1.5;
      return findCurveVertexIdx(.5 + normX, .5 + normY, level - 1, startIndex + lvlVertexCount * 2);
    }
  }
}

float getCurveDist(float x, float y, List<PVector> line) {
  PVector v1;
  PVector v2 = line.get(0);
  float minDist = dist(x, y, v2.x, v2.y);

  for (int i = 1; i < line.size(); ++i) {
    v1 = v2;
    v2 = line.get(i);
    minDist = min(minDist, dist(x, y, v2.x, v2.y));
    minDist = min(minDist, getLineSegmentDist(x, y, v1, v2));
  }
  return minDist;
}

float getLineSegmentDist(float x, float y, PVector v1, PVector v2) {
  if (abs(v1.x - v2.x) < EPSILON) {
    if (v1.y < v2.y) {
      return y >= v1.y && y <= v2.y ? abs(x - v1.x) : 99999;
    } else {
      return y >= v2.y && y <= v1.y ? abs(x - v1.x) : 99999;
    }
  } else {
    if (v1.x < v2.x) {
      return x >= v1.x && x <= v2.x ? abs(y - v1.y) : 99999;
    } else {
      return x >= v2.x && x <= v1.x ? abs(y - v1.y) : 99999;
    }
  }
}

//PImage createHilbertPatch(int size, float t, float borderRadius) {
//  t = constrain(t, 0, 1);
//  PImage patch = new PImage(size, size, ARGB);
//  patch.loadPixels();

//  for (int x = 0; x < size; ++x) {
//    for (int y = 0; y < size; ++y) {
//      float normX = (x + .5) / size;
//      float normY = (y + .5) / size;
//      float dist1 = getHilbertDist(normX, normY);

//      normX = (2 * normX) % 1;
//      normY = (2 * normY) % 1;
//      float dist2 = getHilbertDist(normX, normY);

//      float lerpDist = lerp(dist1, dist2, t) * size;
//      float borderDist = lerpDist - borderRadius;
//      float alpha = constrain(128 - borderDist * 255, 0, 255);
//      //float alpha = lerpDist > borderSize ? 0 : 255;
//      patch.pixels[y * size + x] = color(255, alpha);
//    }
//  }

//  return patch;
//}

//PVector sectorVertex = new PVector(.25, .25);

//float getHilbertDist(float normX, float normY) {
//  float sectorX = abs(normX - .5);
//  float sectorY = abs(normY - .5);

//  float distX = 999;
//  float distY = 999;
//  float distVertex = 999;

//  if (normY <= .25 || normY >= .75 && sectorX >= .25) {
//    distVertex = sectorVertex.dist(new PVector(sectorX, sectorY));
//  }
//  if (sectorX <= .25) {
//    distY = abs(normY - .75);
//  }
//  if (sectorY <= .25) {
//    distX = abs(sectorX - .25);
//  }
//  return min(min(distX, distY), distVertex);
//}
