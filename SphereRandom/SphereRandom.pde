
Camera camera;

float sphereRadius;
ArrayList<PVector> sphereMesh;

void setup() {
  
  size(1280, 720, P3D);  
  smooth(8);
  noStroke();

  camera = new Camera();
  camera.setSpinFriction(0);
  camera.setDragSensitivity(0.1);
  
  sphereRadius = 200;
  sphereMesh = createSphereMesh(1000, sphereRadius);
}

void draw() {
  
  background(255);
  camera.focus();
  
  PVector camPos = camera.getPos();
  float minCamDist = camPos.mag() - sphereRadius;
  
  for(PVector vertex : sphereMesh) {
    
    float camDist = vertex.copy().sub(camPos).mag();
    float relDist = (camDist - minCamDist) / (2 * sphereRadius);

    fill(relDist * 180);
    
    translate(vertex.x, vertex.y, vertex.z);
    box(5);
    translate(-vertex.x, -vertex.y, -vertex.z);
  }
}

ArrayList<PVector> createSphereMesh(int vertexCount, float sphereRadius) {
  
  ArrayList<PVector> vertices = new ArrayList<PVector>();
  
  for(int i = 0; i < vertexCount; i++) {
    
    float yaw = random(TWO_PI);
    float pitch = asin(random(-1, 1)); // - HALF_PI;  
        
    float cosPitch = cos(pitch);
    
    PVector vertex = new PVector(
        cos(yaw) * cosPitch,
        sin(pitch),
        sin(yaw) * cosPitch);
        
    vertex.mult(sphereRadius);
    vertices.add(vertex);
  }
  
  return vertices;
}
