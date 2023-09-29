import java.util.Arrays;

class Spike {
  
  PVector base;
  float length;
  float baseSize;
  float yaw;
  float pitch;
  
  List<PVector> ring;
  List<Float> ringSizes;
  
  Spike(PVector base, PVector tip, float baseSize) {
    this.base = base;
    this.baseSize = baseSize;
    ring = new ArrayList();
    
    PVector facing = tip.copy().sub(base);
    this.length = facing.mag();
    calcRotation(facing.normalize());
    genRing(12);
    setRingSizes(new ArrayList<>());
    noiseOffset = random(10f);
  }
  
  void calcRotation(PVector direction) {
    pitch = asin(direction.y);
    yaw = -atan2(direction.z, direction.x);
  }
  
  void genRing(int vertexCount) {
    ring.clear();
    float increment = TWO_PI / vertexCount;
    
    for (int j = 0; j < vertexCount; ++j) {
      ring.add(new PVector(0, cos(j * increment), sin(j * increment)));
    }
  }
  
  void setLength(float size) {
    this.length = size;
  }
  
  void setBaseSize(float size) {
    baseSize = size;
  }
  
  void setRingSizes(List<Float> sizes) {
    ringSizes = new ArrayList<>(sizes);
    //ringSizes.add(0, 1f);
    //ringSizes.add(0f);
  }
  
  void setRingVertexCount(int vertexCount) {
    genRing(vertexCount);
  }
  
  void setRingSize(int ringIndex, float size) {
    ringSizes.set(ringIndex, size);
  }
  
  float noiseOffset;
  
  void display() {    
    pushMatrix();
    translate(base.x, base.y, base.z);
    rotateY(yaw);
    rotateZ(pitch);
    float segmentLength = this.length / (ringSizes.size() - 1);
    
    for (int j = 0; j < ring.size(); ++j) {
      PVector v1 = ring.get(j % ring.size());
      PVector v2 = ring.get((j + 1) % ring.size());
      beginShape(TRIANGLE_STRIP);
      
      for (int i = 0; i < ringSizes.size(); ++i) {
        float offset = i * segmentLength;
        float size = baseSize * ringSizes.get(i);
        //float noiseScale = 1;
        //float noise1 = noiseScale * noise(noiseOffset + offset / 10f, v1.y / 10f, v1.z / 10f);
        //float noise2 = noiseScale * noise(noiseOffset + offset / 10f, v2.y / 10f, v2.z / 10f);
        //vertex(offset, v1.y * noise1 * size, v1.z * noise1 * size);
        //vertex(offset, v2.y * noise2 * size, v2.z * noise2 * size);
        vertex(offset, v1.y  * size, v1.z * size);
        vertex(offset, v2.y * size, v2.z * size);
      }
      endShape();
    }
    popMatrix();
  }
  
  //void display() {    
  //  pushMatrix();
  //  translate(base.x, base.y, base.z);
  //  rotateY(yaw);
  //  rotateZ(pitch);
  //  float segmentLength = this.length / (ringSizes.size() - 1);
    
  //  for (int i = 0; i < ringSizes.size() - 1; ++i) {
  //    float size1 = baseSize * ringSizes.get(i);
  //    float size2 = baseSize * ringSizes.get(i + 1);      
  //    beginShape(TRIANGLE_STRIP);
      
  //    for (int j = 0; j <= ring.size(); ++j) {
  //      PVector v1 = ring.get(j % ring.size());
  //      vertex(0, v1.y * size1, v1.z * size1);
  //      vertex(segmentLength, v1.y * size2, v1.z * size2);
  //    }
  //    endShape();
  //    translate(segmentLength, 0, 0);
  //  }
  //  popMatrix();
  //}
}
