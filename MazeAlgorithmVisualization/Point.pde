import java.util.Objects;

class Point {
  public final int x;
  public final int y;
  
  Point(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  Point add(Point other) {
    return new Point(
      x + other.x,
      y + other.y);
  }
  
  @Override
  public int hashCode() {
    // Using the hash code of x and y to generate a unique hash code for the Point
    return Objects.hash(x, y);
  }

  @Override
  public boolean equals(Object obj) {
    // Checking if two Points have the same x and y values
    if (this == obj) {
      return true;
    }
    if (obj == null || getClass() != obj.getClass()) {
      return false;
    }
    Point other = (Point) obj;
    return x == other.x && y == other.y;
  }
}
