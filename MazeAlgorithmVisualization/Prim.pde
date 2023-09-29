
class Prim {
  int w;
  int h;
  boolean[][] visited;

  Prim(int w, int h) {
    this.w = w;
    this.h = h;
    visited = new boolean[w][h];
  }

  PathTree generateMaze(int x0, int y0, float pathSize) {
    PathTree tree = new PathTree();
    Random random = new Random(seed);

    ArrayList<Point> unvisited = new ArrayList<>();
    Map<Point, Point> parents = new HashMap<>();

    unvisited.add(new Point(x0, y0));

    Point[] directions = {
      new Point(-1, 0), // up
      new Point(0, 1),  // right
      new Point(1, 0),  // down
      new Point(0, -1)  // left
    };
    
    while (!unvisited.isEmpty()) {
      Point cell = unvisited.remove(random.nextInt(unvisited.size()));
      visited[cell.x][cell.y] = true; // Mark cell as part of the maze

      if (parents.containsKey(cell)) {
        Point parent = parents.get(cell);
        PathAnimation path = new PathAnimation(pathSize);
        path.addCell(maze.getCellPos(cell.x, cell.y));
        path.addCell(maze.getCellPos(parent.x, parent.y));
        tree.paths.add(path);
      }

      for (int i = 0; i < 4; i++) {
        Point newCell = cell.add(directions[i]);

        if (newCell.y >= 0 && newCell.y < h && 
            newCell.x >= 0 && newCell.x < w && 
            !visited[newCell.x][newCell.y]) {
          unvisited.add(newCell);
          parents.put(newCell, cell);
        }
      }
    }
    return tree;
  }
}
