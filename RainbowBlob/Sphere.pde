
//ico sphere that divides the 20 triangles into strips of 4 and subdivides each int many smaller strips
//I'm sorry future me that I couldn't document this better ;-;
class Sphere {

  //horizontal angle of pentagon slice
  float hAngle = TWO_PI / 5;
  //vertical angle of pentagon ring elevation in icosahedron
  float vAngle = atan(.5);
  
  float radius;
  List<PVector> vs;
  List<int[]> faces;

  List<PVector> vNormals;
  List<PVector> fNormals;
  List<Integer> paints;
  
  List<List<Integer>> triStrips;
  Map<Integer, Set<Integer>> facesPerVs;
  
  Sphere(float radius, int subdivs) {
    this.radius = radius;
    this.vs = new ArrayList<>();
    this.faces = new ArrayList<>();
    this.vNormals = new ArrayList<>();
    this.fNormals = new ArrayList<>();
        
    this.triStrips = new ArrayList<>();
    
    createMainVs();
    createTriStrips(subdivs);
    normalize();

    this.facesPerVs = new HashMap<>();
    listFaces();
    
    this.paints = new ArrayList<>();
    for (int i = 0; i < vs.size(); ++i) {
      paints.add(color(0, 0, 180));
    }
  }
  
  void display() {
    for (List<Integer> strip : triStrips) {
      beginShape(TRIANGLE_STRIP);
      for (int idx : strip) {
        PVector v = vs.get(idx);

        if (withNormals) {
          PVector n = vNormals.get(idx);
          normal(n.x, n.y, n.z);
        }
        fill(paints.get(idx));
        vertex(v.x, v.y, v.z);
      }
      endShape();
    }
  }
  
  void listFaces() {
    int i = 0;
    
    for (List<Integer> strip : triStrips) {
      for (int j = 1; j < strip.size() - 1; ++j) {
        int i0 = strip.get(j);
        int i1 = strip.get(j % 2 == 0 ? j + 1 : j - 1);
        int i2 = strip.get(j % 2 == 0 ? j - 1 : j + 1);
        
        faces.add(new int[]{i0, i1, i2});
        addFaceToV(i0, i);
        addFaceToV(i2, i);
        addFaceToV(i1, i);
        fNormals.add(calcFNormal(i));
        ++i;
      }
    }
  }
  
  PVector calcFNormal(int f) {
    PVector v0 = vs.get(faces.get(f)[0]);
    PVector d1 = vs.get(faces.get(f)[1]).copy().sub(v0);
    PVector d2 = vs.get(faces.get(f)[2]).copy().sub(v0);
    return d2.cross(d1).normalize();
  }
  
  PVector calcVNormal(int v) {
    PVector normal = new PVector();
    for (int f : facesPerVs.get(v)) {
      normal.add(fNormals.get(f));
    }
    return normal.normalize();
  }
  
  void addFaceToV(int vIdx, int fIdx) {
    facesPerVs.computeIfAbsent(vIdx, s -> new HashSet<>());
    facesPerVs.get(vIdx).add(fIdx);
  }
  
  void smoothNormals() {
    for (int i = 0; i < faces.size(); ++i) {
      fNormals.get(i).set(calcFNormal(i));
    }
    for (int i : facesPerVs.keySet()) {
      vNormals.get(i).set(calcVNormal(i));
    }
  }
  
  void normalize() {
    for (PVector v : vs) {
      v.normalize().mult(radius);
    }
  }
  
  //create 20 main vertices of icosahedron
  void createMainVs() {
    //top verex
    addVertex(new PVector(0, 0, radius));
    addVertex(new PVector(0, 0, -radius));
    float z  = radius * sin(vAngle);
    float xy = radius * cos(vAngle);
    // compute 10 vertices of pentagon rings
    for (int i = 0; i < 5; ++i) {
      addVertex(new PVector(
        xy * cos(i * hAngle),
        xy * sin(i * hAngle), z));
      addVertex(new PVector(
        xy * cos((i + .5) * hAngle),
        xy * sin((i + .5) * hAngle), -z));
    }
  }
  
  //creates 5 sets of triangle strip coordinates that each cover 4 triangles of the icosahedron
  void createTriStrips(int subdivs) {
    for (int i = 0; i < 5; ++i) {
      List<List<Integer>> l = createStrip(
          vs.get(0),
          vs.get(2 + (i * 2) % 10),
          vs.get(2 + (i * 2 + 2) % 10),
          vs.get(3 + (i * 2) % 10),
          vs.get(3 + (i * 2 + 2) % 10),
          vs.get(1),
          subdivs);
      triStrips.addAll(l);
    }
  }
  
  //takes vertices for 4 (big) triangles and subdivides them in overcomplicated manner xD
  //returns lists with indices for set of triangle strips
  //@param v0 - v5, vertices that form a triangle strip with 4 (big) triangles to subdivide
  List<List<Integer>> createStrip(PVector v0, PVector v1, PVector v2, PVector v3, PVector v4, PVector v5, int subdivs) {
    List<Integer> subVIndices = getTrisSubdivided(v0, v1, v2, v3, v4, v5, subdivs);
    
    //array to store rows of subvertex indices once ordered
    int[][] rowVIdxs = new int[subdivs + 1][2 * subdivs + 1];
    //count of subvertices in subdivided triangle
    int subVCount = (subdivs + 2) * (subdivs + 1) / 2;
    
    //iterates through rows of subdivision stripes to collect vertices in each row
    for (int row = 0; row <= subdivs; ++row) {
      int rowInv = subdivs - row;
      //start index of each row based on formula i = sum_{n=1}^{subdivs+1}n - sum_{n=1}^{subdivs+1 - row}n
      int vIdxOffset = row * (2 * (subdivs + 1) - row + 1) / 2;
      int vIdxOffsetInv = rowInv * (2 * (subdivs + 1) - rowInv + 1) / 2;
      
      rowVIdxs[row][0] = subVIndices.get(vIdxOffset);
      int col = 1;
      
      //iterates over the 4 big subidivded triangles and collects indices of triangle subdivisoins
      for (int triIdx = 0; triIdx < 4; ++triIdx) {
        if (triIdx % 2 == 0) {
          for (int i = 1; i <= rowInv; ++i) {
            int vIdx = triIdx * subVCount + vIdxOffset + i;
            rowVIdxs[row][col] = subVIndices.get(vIdx);
            ++col;
          }
        } else {
          for (int i = 1; i <= row; ++i) {
            int vIdx = triIdx * subVCount + vIdxOffsetInv + i;
            rowVIdxs[row][col] = subVIndices.get(vIdx);
            ++col;
          }
        }
      }
    }
    return triangulateSubVRows(rowVIdxs, subdivs);
  }
  
  //creates subdivision vertices of 4 triangles and returns indices concatenated to one list
  //@param v0 - v5, vertices that form a triangle strip with 4 (big) triangles
  List<Integer> getTrisSubdivided(PVector v0, PVector v1, PVector v2, PVector v3, PVector v4, PVector v5, int subdivs) {
    List<Integer> subVIndices = new ArrayList<>();
    subVIndices.addAll(subdivide(v0, v1, v2, subdivs));
    subVIndices.addAll(subdivide(v1, v2, v3, subdivs));
    subVIndices.addAll(subdivide(v2, v3, v4, subdivs));
    subVIndices.addAll(subdivide(v3, v4, v5, subdivs));
    return subVIndices;
  }
  
  //creates lists with indices for triangle strips triangulating vertices given by rowVIdxs
  List<List<Integer>> triangulateSubVRows(int[][] rowVIdxs, int subdivs) {
    List<List<Integer>> strips = new ArrayList<>();
    
    for (int stripIdx = 0; stripIdx < subdivs; ++stripIdx) {
      List<Integer> stripVIdxs = new ArrayList<>();
      
      for (int i = 0; i <= 2 * subdivs; ++i) {
        stripVIdxs.add(rowVIdxs[stripIdx][i]);
        stripVIdxs.add(rowVIdxs[stripIdx + 1][i]);
      }
      strips.add(stripVIdxs);
    }
    return strips;
  }
  
  //creates subdivision vertices for a big triangle
  //returns list with indices of subdiv vertices in... a specific order
  List<Integer> subdivide(PVector v0, PVector v1, PVector v2, int steps) {
    List<Integer> subVIndices = new ArrayList<>();

    PVector d1 = v1.copy().sub(v0).mult(1f / steps);
    PVector d2 = v2.copy().sub(v0).mult(1f / steps);

    for (int i = 0; i <= steps; ++i) {
      for (int j = 0; j <= steps - i; ++j) {
        PVector v = v0.copy();
        v.add(d1.copy().mult(i));
        v.add(d2.copy().mult(j));
        subVIndices.add(addVertex(v));
      }
    }
    return subVIndices;
  }

  //lists vertex if not existent yet
  //returns index of new or existing vertex with these coordinates
  int addVertex(PVector v) {
    for (int i = 0; i < vs.size(); ++i) {
      PVector d = v.copy().sub(vs.get(i));
      
      if (d.mag() < EPSILON) {
         return i;
      }
    }
    vs.add(v);
    vNormals.add(v.copy().normalize());
    return vs.size() - 1;
  }
}
