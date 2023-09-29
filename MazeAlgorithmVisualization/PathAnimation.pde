
class PathTree {
  LinkedList<PathAnimation> paths;

  PathTree() {
    this.paths = new LinkedList<>();
  }
  
  float duration() {
    float duration = 0;

    for (PathAnimation p : paths) {
      duration += p.duration();
    }
    return duration;
  }
  
  float durationSmooth() {
    float duration = 0;

    for (PathAnimation p : paths) {
      duration += p.durationSmooth();
    }
    return duration;
  }
  
  void display(float t) {
    t *= duration();

    float iter = 0;
    for (PathAnimation p : paths) {

      if (iter < t) {
        float localT = (t - iter) / p.duration();
        p.display(localT);
        iter += p.duration();
      } else {
        break;
      }
    }
  }
  
  void displaySmooth(float t) {
    t *= durationSmooth();

    float iter = 0;
    for (PathAnimation p : paths) {

      if (iter < t) {
        float localT = (t - iter) / p.durationSmooth();
        p.displaySmooth(localT);
        iter += p.durationSmooth();
      } else {
        break;
      }
    }
  }
}


class PathAnimation {

  int bezierDetail = 12;
  float squareInDist = 1;
  float pathWidth;
  List<PVector> cells;

  PathAnimation(float w) {
    this.pathWidth = w;
    cells = new LinkedList<>();
  }

  void addCell(PVector tilePos) {
    cells.add(tilePos);
  }
  
  float duration() {
    return cells.size() - 1;
  }
  
  float durationSmooth() {
    int numConnections = cells.size() - 1;
    
    if (numConnections < 1) {
      return 0;
    }
    return numConnections + 2 * squareInDist;
  }

  void display(float t) {

    if (cells.size() < 2) {
      return;
    }
    t = clamp(t, 0, 1);

    int numConnections = cells.size() - 1;
    float dist = t * numConnections;
    int fullConnections = floor(dist);
    float partConnection = dist % 1;

    drawFull(fullConnections);
    drawPercent(fullConnections, partConnection, numConnections);
  }
  
  void displaySmooth(float t) {
    fill(pathCol);

    if (cells.size() < 2) {
      return;
    }
    /**
     * sry Aaron you'll never understand this again :(
     * this is a function to linear-in the animation velocity aka cubic-in the animated path distance
     * the distance aka the integral of the square-in is then F(t) = 1/2 (a * t)^2
     * where "a" is a factor to control the duration of the square-in.
     * Because the lienar-in velocity is f(t) = d^2 * t reaches is
     * It's calculated: a = sqrt(1 / d) where "d" is the duration of the square-in.
     
     */
    int numConnections = cells.size() - 1;

    float squareInTime = 2 * squareInDist;
    float squareInFactor = sqrt(1 / squareInTime);
    float duration = numConnections + squareInTime;

    t = clamp(t, 0, 1);
    t *= duration;
    float dist = 0;

    if (t < squareInTime) {
      dist += 0.5 * pow(squareInFactor * t, 2);
    } else {
      dist += squareInDist;

      if (t < duration - squareInTime) {
        dist += t - squareInTime;
      } else {
        dist += duration - 2 * squareInTime;
        dist += squareInDist - 0.5 * pow(squareInFactor * (duration - t), 2);
      }
    }
    int fullConnections = floor(dist);
    float partConnection = dist % 1;

    drawFull(fullConnections);
    drawPercent(fullConnections, partConnection, numConnections);
  }
  
  void drawFull(int fullConnections) {
    fill(pathCol);

    //draw all connections that a fully created by this time
    for (int i = 0; i < fullConnections; ++i) {
      PVector rectMin = new PVector();
      PVector rectSize = new PVector();
      calcRect(cells.get(i), cells.get(i + 1), 1, rectMin, rectSize);
      rect(rectMin.x, rectMin.y, rectSize.x, rectSize.y, pathEdge);
    }
  }
  
  void drawPercent(int fullConnections, float partConnection, int numConnections) {
    fill(highlight);
    
    //draw the connection that is currently being connected
    if (fullConnections < numConnections) {
      PVector rectMin = new PVector();
      PVector rectSize = new PVector();
      calcRect(cells.get(fullConnections), cells.get(fullConnections + 1), partConnection, rectMin, rectSize);
      rect(rectMin.x, rectMin.y, rectSize.x, rectSize.y, pathEdge);
    }
  }
  
  /**
   * Calculate
   *
   *
   */
  void calcRect(PVector tile1, PVector tile2, float t, PVector outRectMin, PVector outRectSize) {
    outRectMin.set(tile1.x, tile1.y);
    
    //return the rect of the full connection
    if (t == 1) {
      outRectSize.x = abs(tile2.x - tile1.x) + pathWidth;
      outRectSize.y = abs(tile2.y - tile1.y) + pathWidth;

      if (tile2.x < tile1.x) {
        outRectMin.x = tile2.x;
      } else if (tile2.y < tile1.y) {
        outRectMin.y = tile2.y;
      }
    } else {
      if (tile1.x != tile2.x) {
        outRectSize.x = t * abs(tile2.x - tile1.x) + pathWidth;
        outRectSize.y = abs(tile2.y - tile1.y) + pathWidth;

        if (tile2.x < tile1.x) {
          outRectMin.x -= t * (tile1.x - tile2.x);
        }
      } else {
        outRectSize.x = abs(tile2.x - tile1.x) + pathWidth;
        outRectSize.y = t * abs(tile2.y - tile1.y) + pathWidth;

        if (tile2.y < tile1.y) {
          outRectMin.y -= t * (tile1.y - tile2.y);
        }
      }
    }
  }
}
