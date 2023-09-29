class D4 extends Polyhedron {

  D4(float radius) {
    super(radius);
  }

  @Override
    PVector[] calcVertices(float radius) {
    float diehdralAngle = acos(1/3f);
    float vertexMidSlope = HALF_PI - diehdralAngle;

    float vertexFaceCenterDist = cos(vertexMidSlope) * radius;
    float faceMidCenterDist = asin(vertexMidSlope) * radius;
    float halfSideLength = cos(0.5 * THIRD_PI) * vertexFaceCenterDist;
    float haflSideFaceMidDist = sin(0.5 * THIRD_PI) * vertexFaceCenterDist;

    return new PVector[] {
      new PVector(0, -faceMidCenterDist, vertexFaceCenterDist),
      new PVector(-halfSideLength, -faceMidCenterDist, -haflSideFaceMidDist),
      new PVector( halfSideLength, -faceMidCenterDist, -haflSideFaceMidDist),
      new PVector(0, radius, 0)
    };
  }

  @Override
    Integer[][] listFaces() {
    return new Integer[][] {
      new Integer[] {0, 1, 2},
      new Integer[] {0, 1, 3},
      new Integer[] {1, 2, 3},
      new Integer[] {2, 0, 3},
    };
  }
}

class D8 extends Polyhedron {

  D8(float radius) {
    super(radius);
  }

  @Override
  PVector[] calcVertices(float radius) {
    return new PVector[] {
      new PVector(-radius, 0, 0),
      new PVector( radius, 0, 0),
      new PVector(0, -radius, 0),
      new PVector(0, radius, 0),
      new PVector(0, 0, -radius),
      new PVector(0, 0, radius)
    };
  }

  @Override
  Integer[][] listFaces() {
    return new Integer[][] {
      new Integer[] {0, 2, 4},
      new Integer[] {0, 2, 5},
      new Integer[] {0, 3, 4},
      new Integer[] {0, 3, 5},
      new Integer[] {1, 2, 4},
      new Integer[] {1, 2, 5},
      new Integer[] {1, 3, 4},
      new Integer[] {1, 3, 5},
    };
  }
}

class D10 extends Polyhedron {

  D10(float radius) {
    super(radius);
  }

  @Override
  PVector[] calcVertices(float radius) {
    int faceCount = 10;

    PVector[] verts = new PVector[faceCount + 2];
    verts[faceCount] = new PVector(0, -radius, 0);
    verts[faceCount + 1] = new PVector(0, radius, 0);

    float pitch = radians(5); //atan(sin(TWO_PI / (0.5 * faceCount)));
    println(degrees(pitch));

    float h = (1 - cos(TWO_PI / faceCount)) / (1 + cos(TWO_PI / faceCount));
    
    for (int i = 0; i < faceCount; ++i) {
      verts[i] = new PVector(
        sqrt(1 - h * h) * cos(i * TWO_PI / faceCount),
        (i % 2 == 0 ? -1 : 1) * h,
        sqrt(1 - h * h) * sin(i * TWO_PI / faceCount)
      ).mult(radius);
    }
    return verts;
  }

  @Override
  Integer[][] listFaces() {
    int faceCount = 10;
    Integer[][] faces = new Integer[faceCount][4];

    for (int i = 0; i < faceCount; ++i) {
      faces[i] = new Integer[] {
        faceCount + i % 2,
        i,
        (i + 1) % faceCount,
        (i + 2) % faceCount};
    }
    return faces;
  }
}

class D12 extends Polyhedron {

  D12(float radius) {
    super(radius);
  }

  @Override
  PVector[] calcVertices(float radius) {
    float phi = (1 + sqrt(5)) / 2;
    float rPhi = radius * phi;
    float rInv = radius / phi;

    return new PVector[] {
      new PVector(-radius, -radius, -radius),
      new PVector(-radius, -radius, radius),
      new PVector(-radius, radius, -radius),
      new PVector(-radius, radius, radius),
      new PVector( radius, -radius, -radius),
      new PVector( radius, -radius, radius),
      new PVector( radius, radius, -radius),
      new PVector( radius, radius, radius),
      new PVector( 0, -rInv, -rPhi),
      new PVector( 0, -rInv, rPhi),
      new PVector( 0, rInv, -rPhi),
      new PVector( 0, rInv, rPhi),
      new PVector(-rInv, -rPhi, 0),
      new PVector(-rInv, rPhi, 0),
      new PVector( rInv, -rPhi, 0),
      new PVector( rInv, rPhi, 0),
      new PVector(-rPhi, 0, -rInv),
      new PVector(-rPhi, 0, rInv),
      new PVector( rPhi, 0, -rInv),
      new PVector( rPhi, 0, rInv)
    };
  }

  @Override
  Integer[][] listFaces() {
    return new Integer[][] {
      new Integer[] {12, 14, 4, 8, 0},
      new Integer[] {12, 14, 5, 9, 1},
      new Integer[] {12, 1, 17, 16, 0},
      new Integer[] {14, 4, 18, 19, 5},
      new Integer[] {0, 16, 2, 10, 8},
      new Integer[] {1, 9, 11, 3, 17},
      new Integer[] {4, 8, 10, 6, 18},
      new Integer[] {5, 19, 7, 11, 9},
      new Integer[] {16, 17, 3, 13, 2},
      new Integer[] {19, 18, 6, 15, 7},
      new Integer[] {10, 2, 13, 15, 6},
      new Integer[] {11, 7, 15, 13, 3},
    };
  }
}
