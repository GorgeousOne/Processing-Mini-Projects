
import java.util.Objects;

public class BlockVec {
  
  private int x;
  private int y;
  private int z;
  
  public BlockVec() {
  }
  
  public BlockVec(PVector vector) {
    this((int) Math.floor(vector.x), 
         (int) Math.floor(vector.y), 
         (int) Math.floor(vector.z));
  }
  
  public BlockVec(int x, int y, int z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  public int getX() {
    return x;
  }
  
  public void setX(int x) {
    this.x = x;
  }
  
  public int getZ() {
    return z;
  }
  
  public void setZ(int z) {
    this.z = z;
  }
  
  public int getY() {
    return y;
  }
  
  public void setY(int y) {
    this.y = y;
  }
  
  public BlockVec add(BlockVec other) {
    return add(other.x, other.y, other.z);
  }
  
  public BlockVec add(int dx, int dy, int dz) {
    x += dx;
    y += dy;
    z += dz;
    return this;
  }
  
  public BlockVec subtract(BlockVec other) {
    x -= other.getX();
    y -= other.getY();
    z -= other.getZ();
    return this;
  }
  
  public BlockVec multiply(int multiplier) {
    x *= multiplier;
    y *= multiplier;
    z *= multiplier;
    return this;
  }
  
  public BlockVec getMinimum(BlockVec v1, BlockVec v2) {
    return new BlockVec(
        Math.min(v1.x, v2.x),
        Math.min(v1.y, v2.y),
        Math.min(v1.z, v2.z));
  }
  
  public BlockVec getMaximum(BlockVec v1, BlockVec v2) {
    return new BlockVec(
        Math.max(v1.x, v2.x),
        Math.max(v1.y, v2.y),
        Math.max(v1.z, v2.z));
  }
  
  public PVector toVector() {
    return new PVector(x, y, z);
  }
  
  @Override
  public BlockVec clone() {
    return new BlockVec(x, y, z);
  }
  
  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof BlockVec)) {
      return false;
    }
    BlockVec otherVec = (BlockVec) o;
    return x == otherVec.x &&
           y == otherVec.y &&
           z == otherVec.z;
  }
  
  @Override
  public int hashCode() {
    return Objects.hash(x, y, z);
  }
  
  @Override
  public String toString() {
    return "x=" + x + ",y=" + y + ",z=" + z;
  }

}
