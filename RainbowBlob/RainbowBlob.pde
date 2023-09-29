import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

Sphere s;
List<PVector> backupVs;

OrbitCamera cam;

void setup() {
  noiseSeed(5);
  size(960, 540, P3D);
  colorMode(HSB, 360);
  noStroke();
  cam = new OrbitCamera();
  cam.targetYaw = PI / 6;
  cam.yaw = PI / 6;
  cam.setFOV(30);
  cam.setTargetZoom(1.9);
  cam.zoom = 1.9;
  cam.toggleOrtho();

  noiseDetail(3, 1); //3, .75
  smooth();

  s = new Sphere(200, 30);
  backupVs = deepClone(s.vs);
  //frameRate(24);
}

int frameLoop = 60 * 24;
float noiseScale = 1; //.8
float noiseAmplitude = .8; //1.5

void draw() {
  if (frameCount > frameLoop) {
    exit();
  }
  float t = frameCount % frameLoop / (1f * frameLoop);
  background(0);

  cam.update();
  addLights();
  cam.applyRotation();
  
  applyNoise(s, noiseScale, noiseAmplitude, t);
  s.display();
  //axes();
  filter(INVERT);
  //saveFrame("vid/blob_####.jpg");
}

void axes() {
  float l = 350;
  pushStyle();
  stroke(0, 360, 360);
  line(0, 0, 0, l, 0, 0);
  stroke(120, 360, 360);
  line(0, 0, 0, 0, l, 0);
  stroke(240, 360, 360);
  line(0, 0, 0, 0, 0, l);
  popStyle();
}

float bright = 360;

void addLights() {
  directionalLight(0, 0, bright, 0, 0, -1);
  lightFalloff(0, 0, 0);
}

void applyNoise(Sphere s, float scale, float amplitude, float t) {
  float phi = TWO_PI * constrain(t, 0, 1);
  float cosPhi = cos(phi);
  float sinPhi = sin(phi);
  float invRadius = scale / s.radius;
  float noiseWalkRadius = 2 * scale;

  float paintScale = 1.7;

  for (int i = 0; i < backupVs.size(); ++i) {
    PVector v = backupVs.get(i);
    PVector noisePos = v.copy().mult(invRadius).add(noiseWalkRadius, 0, 0);

    noisePos.set(
      cosPhi * noisePos.x - sinPhi * noisePos.z,
      noisePos.y,
      sinPhi * noisePos.x + cosPhi * noisePos.z);

    //offset noise to avoid symmmety
    noisePos.add(.5, .5, .5);
    float noiseVal = noise(noisePos.x, noisePos.y, noisePos.z);
    //noiseVal *= 2;
    //noiseVal = pow(noiseVal, 1.5);
    //noiseVal /= 2;
    PVector blobPos = v.copy().mult(1 + amplitude * noiseVal);
    s.vs.get(i).set(blobPos);

    noisePos.sub(.5, .5, .5);
    noisePos.mult(.2).add(1.5, .5, 1.5);

    noiseVal = noise(noisePos.x, noisePos.y, noisePos.z) * paintScale - .6 * paintScale;
    s.paints.set(i, color(360 * noiseVal, 360, 110));
  }
  if (withNormals) {
    s.smoothNormals();
  }
}

List<PVector> deepClone(List<PVector> original) {
  List<PVector> copy = new ArrayList<PVector>(original.size());

  for (PVector p : original) {
    copy.add(p.copy());
  }
  return copy;
}

boolean withNormals = true;

void keyPressed() {
  if (keyCode == 'W') {
    withNormals = !withNormals;
    println(withNormals ? "on" : "off");
  }
}
