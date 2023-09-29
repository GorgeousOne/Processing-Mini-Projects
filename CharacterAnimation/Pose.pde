
class Pose {
  
  PVector offset;
  Map<String, PVector> rotations;
  
  Pose() {
    rotations = new HashMap<String, PVector>();    
    offset = new PVector();
  }
  
  Pose(Body body) {
    rotations = new HashMap<String, PVector>();
    
    for (BodyPart part : body.parts) {
      rotations.put(part.name, part.rot.copy());
    }
    offset = body.pos.copy();
  }
    
  void write(String fileName) {
    try {
      FileWriter writer = new FileWriter(fileName);
      writer.write("offset " + offset.x + " " + offset.y + " " + offset.z + "\n");
      
      for (String partName : rotations.keySet()) {
        PVector rot = rotations.get(partName);
        writer.write(partName + " " + rot.x + " " + rot.y + " " + rot.z + "\n");
      }
      writer.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
  }
  
  Pose read(String fileName) {
    Scanner lineScan = null;
    try {
      File file = new File(fileName);
      lineScan = new Scanner(file);    
    } catch (FileNotFoundException e) {
      e.printStackTrace();
    }
    while (lineScan.hasNextLine()) {
        Scanner wordScan = new Scanner(lineScan.nextLine());
        String identifier = wordScan.next();
        
        if ("offset".equals(identifier)) { 
          offset.set(          
            Float.parseFloat(wordScan.next()),
            Float.parseFloat(wordScan.next()),
            Float.parseFloat(wordScan.next()));
          continue;
        }
        PVector rot = new PVector();
        rot.x = Float.parseFloat(wordScan.next());
        rot.y = Float.parseFloat(wordScan.next());
        rot.z = Float.parseFloat(wordScan.next());
        rotations.put(identifier, rot);
        wordScan.close();
    }
    lineScan.close();
    return this;
  }
  
  void apply(Body body) {
    for (String partName : rotations.keySet()) {
      body.matchPart(partName).rot = rotations.get(partName);  
    }
    body.pos = offset;
  }
}
