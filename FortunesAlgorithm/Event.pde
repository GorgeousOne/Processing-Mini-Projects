import java.util.Collections;

class Event implements Comparable<Event> {
  //y coordinate at which this event happens
  float y;
  
  public Event(float y) {
    this.y = y;
  }
  
  @Override
  int compareTo(Event other){
    return (int) (this.y - other.y);
  }
}

//called when a new node is reached by the sweep line
class SiteEvent extends Event {
  PVector site;
  
  SiteEvent(PVector site) {
    super(site.y);
    this.site = site;
  }
}

//called when two cell edges merge (with the y of the directrix)
class CircleEvent extends Event {
 
  Edge edge1;
  Edge edge2;
  Arc squishedArc;
  PVector intersection;
      
  CircleEvent(Edge edge1, Edge edge2, Arc squishedArc) {
    super(calcIntersectionDirectrix(edge1, edge2));
    this.edge1 = edge1;
    this.edge2 = edge2;
    this.intersection = edge1.intersect(edge2);
    this.squishedArc = squishedArc;
  }  
}

float calcIntersectionDirectrix(Edge leftEdge, Edge rightEdge) {
  PVector intersect = leftEdge.intersect(rightEdge);
  
  if (null != intersect) {
    return intersect.y + intersect.dist(rightEdge.leftArc.getFocus());
  }
  return 9999999;
}
