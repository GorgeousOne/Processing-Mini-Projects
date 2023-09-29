
class Kruskal {
  int w;
  int h;
  
  Map<Point, Set<Point>> setMap;
  Random random = new Random(seed);
  List<Point> unvisited = new ArrayList<>();

  Kruskal(int w, int h) {
    this.w = w;
    this.h = h;
    this.setMap = new HashMap<>();
    initializeMaze();
  }

  void initializeMaze() {
    for (int x = 0; x < w; ++x) {
      for (int y = 0; y < h; ++y) {
        Point cell = new Point(x, y);
        setMap.put(cell, new HashSet<>(Arrays.asList(cell)));
        unvisited.add(cell);
      }
    }
  }

  void union(Point c1, Point c2) {    
    Set<Point> mainSet = setMap.get(c1);
    Set<Point> subSet = setMap.get(c2);
    
    mainSet.addAll(subSet);
    
    for (Point c3 : subSet) {
      setMap.put(c3, mainSet);
    }
  }
  
  Point[] directions = {
    new Point(-1, 0), // up
    new Point(0, 1),  // right
    new Point(1, 0),  // down
    new Point(0, -1)  // left
  };
  
  List<Point> getWalls(Point cell) {
    List<Point> walls = new ArrayList<>();
    
    for (Point direction : directions) {
      Point newCell = cell.add(direction);

      if (newCell.x >= 0 && newCell.x < w && 
          newCell.y >= 0 && newCell.y < h) {
        walls.add(newCell);
      }
    }
    Collections.shuffle(walls, random);
    return walls;
  }

  boolean isSameSet(Point c1, Point c2) {
    return setMap.get(c1) == setMap.get(c2);
  }

  PathTree generateMaze(int x0, int y0, float pathSize) {
    PathTree tree = new PathTree();
    
    unvisited.add(new Point(x0, y0));

    while (!unvisited.isEmpty()) {
      Point cell = unvisited.remove(random.nextInt(unvisited.size()));
      List<Point> neighbors = getWalls(cell);

      for (Point neighbor : neighbors) {
        if (!isSameSet(cell, neighbor)) {
          PathAnimation path = new PathAnimation(pathSize);
          path.addCell(maze.getCellPos(cell.x, cell.y));
          path.addCell(maze.getCellPos(neighbor.x, neighbor.y));
          tree.paths.add(path);
        
          union(cell, neighbor);
          break;
        }
      }
    }
    return tree;
  }
}
