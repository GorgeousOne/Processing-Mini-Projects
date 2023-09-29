

class DepthFirst {

  int w;
  int h;
  boolean[][] visited;

  DepthFirst(int w, int h) {
    this.w = w;
    this.h = h;
  }

  PathTree generateMaze(int x0, int y0, float pathSize) {
    Random random = new Random(seed);
    PathTree tree = new PathTree();

    visited = new boolean[w][h];
    Stack<Point> stack = new Stack<>(); // To keep track of visited cells

    // Mark the starting cell as visited
    visited[x0][y0] = true;
    stack.push(new Point(x0, y0));

    // Possible movement directions: up, right, down, left
    Point[] directions = {
      new Point(-1, 0), // up
      new Point(0, 1),  // right
      new Point(1, 0),  // down
      new Point(0, -1)  // left
    };

    PathAnimation path = new PathAnimation(pathSize);
    tree.paths.add(path);

    while (!stack.isEmpty()) {
      Point cell = stack.peek();

      if (path.cells.size() == 0) {
        path.addCell(maze.getCellPos(cell.x, cell.y));
      }

      // Check for unvisited neighbors
      ArrayList<Integer> unvisitedNeighbors = new ArrayList<>();
      for (int i = 0; i < 4; i++) {
        Point newCell = cell.add(directions[i]);

        if (newCell.x >= 0 && newCell.x < w && 
            newCell.y >= 0 && newCell.y < h && 
            !visited[newCell.x][newCell.y]) {
          unvisitedNeighbors.add(i);
        }
      }

      if (!unvisitedNeighbors.isEmpty()) {
        // Choose a random unvisited neighbor
        int randomDirection = unvisitedNeighbors.get(random.nextInt(unvisitedNeighbors.size()));
        Point newCell = cell.add(directions[randomDirection]);

        // Carve a passage to the neighbor
        visited[newCell.x][newCell.y] = true;
        path.addCell(maze.getCellPos(newCell.x, newCell.y));
        stack.push(newCell);

      } else {
        path = new PathAnimation(pathSize);
        tree.paths.add(path);
        // No unvisited neighbors, backtrack
        stack.pop();
      }
    }
    return tree;
  }
}
