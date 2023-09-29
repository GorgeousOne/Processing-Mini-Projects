
class Body {
  
  PVector pos;
  BodyPart chest;
  BodyPart head;
  BodyPart armLeft;
  BodyPart handLeft;
  BodyPart armRight;
  BodyPart handRight;
  BodyPart legLeft;
  BodyPart legRight;
  BodyPart footLeft;
  BodyPart footRight;
  
  BodyPart[] parts;

  PVector[] rots = {
      new PVector(),
      new PVector(),
      new PVector(0, 0, HALF_PI),
      new PVector(0, 0, HALF_PI),
      new PVector(0, 0, 0),
      new PVector(0, 0, 0),
      new PVector(0, 0, 0),
      new PVector(0, 0, 0)};
  
  Body() {
    pos = new PVector();
    
    //chest offset to ground 97.4361
    chest = new BodyPart("chest", new PVector(-PI/40, 0, -PI/60));
    head = new BodyPart("head");
    armLeft = new BodyPart("arm-left", new PVector(HALF_PI, 0, 0));
    handLeft = new BodyPart("hand-left");
    armRight = new BodyPart("arm-right", new PVector(HALF_PI, 0, 0));
    handRight = new BodyPart("hand-right");
    legLeft = new BodyPart("leg-left", new PVector(HALF_PI, 0, 0));
    footLeft = new BodyPart("foot-left");
    legRight = new BodyPart("leg-right", new PVector(HALF_PI, 0, 0));
    footRight = new BodyPart("foot-right");
    
    //chest.addLimb(head, new PVector(-2.93762, 63.9209, -2.6547));
    //chest.addLimb(armLeft, new PVector(-3.80979, 48.3269, -25.1092));
    //chest.addLimb(armRight,  new PVector(-5.91147, 50.3349, 16.7486));
    //chest.addLimb(legLeft, new PVector(0, 0, -6.3));
    //chest.addLimb(legRight, new PVector(0, 0, 6.3));
    
    //armLeft.addLimb(handLeft, new PVector(-23.991, 1.75708, -2.2336));
    //armRight.addLimb(handRight, new PVector(-23.599, 2.45541, 3.19166));
    //legLeft.addLimb(footLeft, new PVector(-43.1269, 0.8892, -0.91754));
    //legRight.addLimb(footRight, new PVector(-43.1269, 0.8892, 3.4825));
    
    chest.addLimb(head, new PVector(-2.6547, 63.9209, 2.93762));
    chest.addLimb(armLeft, new PVector(-25.1092, 48.3269, 3.80979));
    chest.addLimb(armRight,  new PVector(16.7486, 50.3349, 5.91147));
    chest.addLimb(legLeft, new PVector(-6.3, 0, 0));
    chest.addLimb(legRight, new PVector(6.3, 0, 0));
    
    armLeft.addLimb(handLeft, new PVector(-2.2336, 1.75708, 23.991));
    armRight.addLimb(handRight, new PVector(3.19166, 2.45541, 23.599));
    legLeft.addLimb(footLeft, new PVector(-0.91754, 0.8892, 43.1269));
    legRight.addLimb(footRight, new PVector(3.4825, 0.8892, 43.1269));
    
    parts = new BodyPart[] {
      head,
      chest,
      armLeft,
      handLeft,
      armRight,
      handRight,
      legLeft,
      footLeft,
      legRight,
      footRight
    };
  }
  
  BodyPart matchPart(String partName) {
    for (BodyPart part : parts) {
        if (part.name.equals(partName)) {
          return part;
        }
    }
    return null;
  }
  
  void display() {
    translate(pos.x, pos.y, pos.z);
    chest.display();
  }
}
