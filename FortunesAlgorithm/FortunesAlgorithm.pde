import java.util.Arrays;
import java.util.List;
import java.util.LinkedList;
import java.util.HashSet;
import java.util.Set;
import java.util.PriorityQueue;

List<PVector> sites;
PriorityQueue<Event> eventQueue;
float directrix;
List<Arc> beachArcs;

Set<Edge> edgesToDisplay;
PGraphics backgroundImg;

int cellCount;

void setup() {
  size(800, 800, P2D);
  //textAlign(LEFT, BOTTOM);
  //textSize(20);
  smooth();

  randomSeed(3);
  cellCount = 7;
  float cellSize = 1f * width / cellCount;
  
  sites = new LinkedList<>();
  //sites.addAll(Arrays.asList(
  //    new PVector (400, 0),
  //    new PVector (300, 400),
  //    new PVector (500, 400)
  //));
  for (int x = 0; x < cellCount; ++x) {
    for (int y = 0; y < cellCount; ++y) {
      sites.add(new PVector(
        cellSize * x + random(cellSize),
        cellSize * y + random(cellSize)));
    }
  }
  createBackground();
  reset();
}

void reset() {
  directrix = 0;
  beachArcs = new ArrayList<>();
  edgesToDisplay = new HashSet<>();
  eventQueue = new PriorityQueue<Event>();
  
  for (PVector site : sites) {
    eventQueue.add(new SiteEvent(site));
  }
}

void createBackground() {
  backgroundImg = createGraphics(width, height);
  backgroundImg.beginDraw();
  backgroundImg.background(0);
  backgroundImg.endDraw();
  backgroundImg.loadPixels();
  
  for (int i = 0; i < backgroundImg.pixels.length; ++i) {
    PVector pos = new PVector (i % width, i / width);
    float minDist = backgroundImg.width;
    PVector near = null;
    
    for (PVector site : sites) {
      float dist = site.dist(pos);
      if (dist < minDist) {
        near = site;
        minDist = dist;
      }
    }
    
    float minBorderDist = backgroundImg.width;
    
    for (PVector site : sites) {
      if (site == near) {
        continue;
      }
      PVector borderDir = site.copy().add(near).mult(0.5).sub(pos);
      PVector borderAlignment = site.copy().sub(near);
      float borderDist = borderDir.dot(borderAlignment) / borderAlignment.mag();
      minBorderDist = min(minBorderDist, borderDist);
    }
    backgroundImg.pixels[i] = color(32 + 128 * minBorderDist / 128);
  }
  backgroundImg.updatePixels();
}

void draw() {
  image(backgroundImg, 0, 0);

  if (spaceDown) {
    moveDirectrix();
  }
  while (!eventQueue.isEmpty() && eventQueue.peek().y <= directrix) {
    processEvent();
  }
  stroke(255);
  line(0, directrix, width, directrix);
  drawEvents();
  drawBeach(directrix);
  drawSites();
  drawBreakpoints(directrix);
}

void moveDirectrix() {
  directrix += 2;
}

float siteSize = 5;

void drawSites() {
  pushStyle();
  noStroke();
  fill(255, 0, 255);
  for (PVector site : sites) {
    rect(site.x - siteSize/2, site.y - siteSize/2, siteSize, siteSize);
  }
  pushStyle();
}

void drawEvents() {
  pushStyle();
  for (Event e : eventQueue) {
    if (e instanceof SiteEvent) {
      stroke(128);
      continue;
    } else {
      stroke(255, 128, 0);
    }
    line(0, e.y, width, e.y);
  }
  popStyle();
}

void drawBeach(float directrix) {
  pushStyle();
  noFill();
  stroke(0, 255, 0);

  float lastY = -1;
  float inc = 1;

  for (float x = 0; x < width; x += inc) {
    float y = getBeachY(x, directrix);

    if (lastY >= 0 || y >= 0) {
      line(x-inc, lastY, x, y);
    }
    lastY = y;
  }

  for (Edge edge : edgesToDisplay) {
    if (null == edge.end) {
      stroke(0, 255, 255);
    } else {
      stroke(255, 0, 0); 
    }
    edge.display(directrix);
  }
  popStyle();
}

void drawBreakpoints(float directrix) {
  pushStyle();
  noStroke();
  fill(0, 0, 255);

  for (int i = 0; i < beachArcs.size() - 1; ++i) {
    Arc arc1 = beachArcs.get(i);
    Arc arc2 = beachArcs.get(i + 1);

    PVector breakpoint = arc1.intersect(arc2, directrix);
    rect(breakpoint.x - siteSize/2, breakpoint.y - siteSize/2, siteSize, siteSize);
    //text(i + "-" + (i+1), breakpoint.x, breakpoint.y);
  }
  popStyle();
}

void drawMouse() {
  text(str(mouseX) + ", " + str(mouseY), mouseX, mouseY);
}

float getBeachY(float x, float directrix) {
  float beachY = -1;
  for (Arc arc : beachArcs) {
    beachY = max(beachY, arc.getY(x, directrix));
  }
  return beachY;
}

void processEvent() {
  if (eventQueue.isEmpty()) {
    return;
  }
  Event event = eventQueue.poll();

  if (event instanceof SiteEvent) {
    SiteEvent siteEvent = (SiteEvent) event;
    Arc arc = insortBeachSite(siteEvent.site, event.y);

    if (beachArcs.size() > 1) {
      createlEdgesOnSiteEvent(arc);
    }
  } else if (event instanceof CircleEvent) {
    CircleEvent circleEvent = (CircleEvent) event;
    Arc squishedArc = circleEvent.squishedArc;
    int arcIndex = beachArcs.indexOf(squishedArc);

    if (arcIndex == -1) {
      return;
    }
    Arc neighborLeft = beachArcs.get(arcIndex - 1);
    Arc neighborRight = beachArcs.get(arcIndex + 1);

    beachArcs.remove(arcIndex);
    neighborLeft.edgeRight.setEnd(circleEvent.intersection);
    neighborRight.edgeLeft.setEnd(circleEvent.intersection);

    Edge newEdge = createContinuedEdge(circleEvent.edge1, circleEvent.edge2, neighborLeft, neighborRight, circleEvent.intersection);
    neighborLeft.setRightEdge(newEdge);
    neighborRight.setLeftEdge(newEdge);

    checkEdgeIntersections(newEdge, neighborLeft, neighborRight);
    edgesToDisplay.add(newEdge);
  }
}

void checkEdgeIntersections(Edge newEdge, Arc leftArc, Arc rightArc) {
  if (null != leftArc.edgeLeft) {
    createCircleEvent(leftArc.edgeLeft, newEdge, leftArc);
  }
  if (null != rightArc.edgeRight) {
    createCircleEvent(newEdge, rightArc.edgeRight, rightArc);
  }
}

void createCircleEvent(Edge leftEdge, Edge rightEdge, Arc squishedArc) {
  if (null == leftEdge.intersect(rightEdge)) {
    return;
  }
  eventQueue.add(new CircleEvent(leftEdge, rightEdge, squishedArc));
}

Arc insortBeachSite(PVector site, float directrix) {
  Arc newArc;

  if (beachArcs.isEmpty()) {
    newArc = new Arc(site);
    beachArcs.add(newArc);
    return newArc;
  }
  if (beachArcs.size() == 1) {
    return addArcOntopArc(site, 0);
  }
  for (int i = 0; i < beachArcs.size() - 1; ++i) {
    Arc site1 = beachArcs.get(i);
    Arc site2 = beachArcs.get(i + 1);
    PVector breakpoint = site1.intersect(site2, directrix);

    if (breakpoint.x > site.x) {
      return addArcOntopArc(site, i);
    }
  }
  int beachSize = beachArcs.size();
  return addArcOntopArc(site, beachSize -1);
}

Arc addArcOntopArc(PVector site, int arcIndex) {
  Arc other = beachArcs.get(arcIndex);

  if (other.getFocus().equals(site)) {
    throw new IllegalArgumentException("Cannot create graph with 2 equal points (" + site + ").");
  }
  Arc newArc = new Arc(site);

  //add arc left or right to arc on same y height (only happens if starting sites are on same height)
  if (other.getFocus().y != site.y) {
    int newIndex = arcIndex + 1;
    beachArcs.add(newIndex, newArc);
    Arc rightArc = other.clone();
    rightArc.setRightEdge(other.edgeRight);
    beachArcs.add(newIndex + 1, rightArc);
    return newArc;
  }
  if (site.x < other.getFocus().x) {
    beachArcs.add(arcIndex, newArc);
  } else {
    beachArcs.add(arcIndex + 1, newArc);
  }
  return newArc;
}

void createlEdgesOnSiteEvent(Arc arc) {
  float focusY = arc.focus.y;
  int arcCount = beachArcs.size();
  int arcIndex = beachArcs.indexOf(arc);

  if (arcIndex < arcCount - 1) {
    Arc neighborRight = beachArcs.get(arcIndex + 1);
    Edge newEdge = createEdge(arc, neighborRight, arc.intersect(neighborRight, focusY), true);
    edgesToDisplay.add(newEdge);
  }
  if (arcIndex > 0) {
    Arc neighborLeft = beachArcs.get(arcIndex - 1);
    Edge newEdge = createEdge(neighborLeft, arc, arc.intersect(neighborLeft, focusY), false);
    edgesToDisplay.add(newEdge);
  }
}

Edge createEdge(Arc leftArc, Arc rightArc, PVector edgeOrigin, boolean facePositive) {
  PVector dist = leftArc.getFocus().sub(rightArc.getFocus());
  PVector edgeDir = new PVector(0, 0, 1).cross(dist).normalize();

  //makes edge extend positvely or negatively
  if (edgeDir.x != 0) {
    edgeDir.mult((facePositive ? 1 : -1) * Math.signum(edgeDir.x));
    //makes vertical edges always face positvely
  } else {
    edgeDir.mult(Math.signum(edgeDir.y));
  }
  Edge newEdge = new Edge(edgeOrigin, edgeDir, leftArc, rightArc);
  leftArc.setRightEdge(newEdge);
  rightArc.setLeftEdge(newEdge);

  checkEdgeIntersections(newEdge, leftArc, rightArc);
  return newEdge;
}

Edge createContinuedEdge(Edge edge1, Edge edge2, Arc leftArc, Arc rightArc, PVector edgeOrigin) {
  PVector dist = leftArc.getFocus().sub(rightArc.getFocus());
  PVector edgeDir = new PVector(0, 0, 1).cross(dist).normalize();
  
  if (edge1.direction.dot(edgeDir) < 0 || edge2.direction.dot(edgeDir) < 0) {
    edgeDir.mult(-1);
  }
  //edgeDir.mult(Math.signum(edgeDir.y));

  Edge newEdge = new Edge(edgeOrigin, edgeDir, leftArc, rightArc);
  leftArc.setRightEdge(newEdge);
  rightArc.setLeftEdge(newEdge);
  return newEdge;
}

boolean spaceDown;

void mouseMoved() {  
    reset();
    directrix = mouseY;
}
void keyPressed() {
  if (key == ' ') {
    spaceDown = true;
  } else if (key == 'S') {
    backgroundImg.save("cool-stuff-" + int(random(1000000)) + ".png");
    println("img saved.");
  }
}

void keyReleased() {
    if (key == ' ') {
    spaceDown = false;
  }
}
