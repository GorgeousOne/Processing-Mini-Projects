import java.util.Map;

class BodyPart {
  
  String name;
  PShape model;
  PVector rot;
  boolean highlighted;
  
  Map<BodyPart, PVector> limbs;
  
  BodyPart(String name) {
    this(name, new PVector());
  }

  BodyPart(String name, PVector defRot) {
    this.name = name;
    this.model = loadShape(name + ".obj");
    this.rot = defRot;
    this.limbs = new HashMap<BodyPart, PVector>();
  }
  
  void addLimb(BodyPart part, PVector offset) {
    limbs.put(part, offset);  
  }
  
  void toggleHighlight() {
    if (!highlighted) {
      model.setFill(color(255, 128, 0));
    }else {
      model.setFill(color(204, 0, 0));
    }
    highlighted = !highlighted;
  }
  
  void applyTranslate(PVector direction) {
    translate(direction.x, direction.y, direction.z);
}
  
  void applyRot() {
    //rotateZ(radians(rot.z));
    //rotateX(radians(rot.x));
    //rotateY(radians(rot.y));
    rotateY(radians(rot.y));
    rotateX(radians(rot.x));
    rotateZ(radians(rot.z));
}
  
  void display() {
    pushMatrix();
    applyRot();
    shape(model);
    
    for (BodyPart limb : limbs.keySet()) {
      pushMatrix();
      applyTranslate(limbs.get(limb));
      limb.display();          
      popMatrix();
    }
    popMatrix();
  }
}
