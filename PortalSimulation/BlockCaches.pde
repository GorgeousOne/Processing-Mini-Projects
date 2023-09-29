
public class ProjectionCache extends BlockCache {
  
  private Transform linkTransform;
  private int cacheLength;
  
  public ProjectionCache(Portal portal,
                         BlockVec offset,
                         BlockVec size,
                         BlockVec facing,
                         color borderType,
                         Transform linkTransform) {
    
    super(portal, offset, size, facing, borderType);
    
    this.linkTransform = linkTransform;
    this.cacheLength = portal.getAxis() == Axis.X ? size.getZ() : size.getX();
  }
  
  public Transform getLinkTransform() {
    return linkTransform;
  }
  
  /**
   * Returns the length of the projection cache measured from portal to back wall.
   * The value is important for the length of viewing frustums.
   */
  public int getCacheLength() {
    return cacheLength;
  }
}

public class BlockCache {
  
  private Portal portal;
  private Block[][][] blockCopies;
  private BlockVec min;
  private BlockVec max;
  
  private BlockVec facing;
  private color borderType;
  
  public BlockCache(Portal portal,
                    BlockVec offset,
                    BlockVec size,
                    BlockVec facing,
                    color borderType) {
    
    this.portal = portal;
    this.blockCopies = new Block[size.getX()][size.getY()][size.getZ()];
    this.min = offset.clone();
    this.max = offset.clone().add(size);
    
    this.facing = facing;
    this.borderType = borderType;
  }
  
  void display() {
    
    pushStyle();
    stroke(borderType);
    
    PVector p1 = min.toVector();
    PVector p2 = new PVector(max.x, min.y, min.z);
    PVector p3 = new PVector(min.x, min.y, max.z);
    PVector p4 = new PVector(max.x, min.y, max.z);
    PVector p5 = new PVector(min.x, max.y, min.z);
    PVector p6 = new PVector(max.x, max.y, min.z);
    PVector p7 = new PVector(min.x, max.y, max.z);
    PVector p8 = max.toVector();
    
    line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
    line(p1.x, p1.y, p1.z, p3.x, p3.y, p3.z);
    line(p2.x, p2.y, p2.z, p4.x, p4.y, p4.z);
    line(p3.x, p3.y, p3.z, p4.x, p4.y, p4.z);
    
    line(p1.x, p1.y, p1.z, p5.x, p5.y, p5.z);
    line(p2.x, p2.y, p2.z, p6.x, p6.y, p6.z);
    line(p3.x, p3.y, p3.z, p7.x, p7.y, p7.z);
    line(p4.x, p4.y, p4.z, p8.x, p8.y, p8.z);
    
    line(p5.x, p5.y, p5.z, p6.x, p6.y, p6.z);
    line(p5.x, p5.y, p5.z, p7.x, p7.y, p7.z);
    line(p6.x, p6.y, p6.z, p8.x, p8.y, p8.z);
    line(p7.x, p7.y, p7.z, p8.x, p8.y, p8.z);
    
    popStyle();
  }
  
  //private BlockVec size() {
  //  return new BlockVec(blockCopies.length, blockCopies[0].length, blockCopies[0][0].length);
  //}
  
  public Portal getPortal() {
    return portal;
  }
  
  public BlockVec getMin() {
    return min.clone();
  }
  
  public BlockVec getMax() {
    return max.clone();
  }
  
  public BlockVec getFacing() {
    return facing.clone();
  }
  
  public boolean contains(BlockVec loc) {
    return contains(loc.getX(), loc.getY(), loc.getZ());
  }
  
  public boolean contains(int x, int y, int z) {
    return x >= min.getX() && x < max.getX() &&
           y >= min.getY() && y < max.getY() &&
           z >= min.getZ() && z < max.getZ();
  }
  
  public boolean isBorder(BlockVec loc) {
    return isBorder(loc.getX(), loc.getY(), loc.getZ());
  }
  
  /**
   * Returns true if the block is at any position bordering the cuboid except the side facing the portal.
   */
  public boolean isBorder(int x, int y, int z) {
    
    if (y == min.getY() || y == max.getY() - 1) {
      return true;
    }
    
    int minX = min.getX();
    int minZ = min.getZ();
    int maxX = max.getX() - 1;
    int maxZ = max.getZ() - 1;
    
    if (facing.getZ() != 0) {
      if (x == minX || x == maxX) {
        return true;
      }
    } else if (z == minZ || z == maxZ) {
      return true;
    }
    
    if (facing.getX() == 1) {
      return x == maxX;
    }
    if (facing.getX() == -1) {
      return x == minX;
    }
    if (facing.getZ() == 1) {
      return z == maxZ;
    } else {
      return z == minZ;
    }
  }
  
  public Block getBlockAt(BlockVec blockPos) {
    return getBlockAt(blockPos.getX(),
                          blockPos.getY(),
                          blockPos.getZ());
  }
  
  public Block getBlockAt(int x, int y, int z) {
    
    if (!contains(x, y, z)) {
      return null;
    }
    
    return blockCopies
        [x - min.getX()]
        [y - min.getY()]
        [z - min.getZ()];
  }
  
  public void setBlockAt(BlockVec blockPos, Block Block) {
    setBlockAt(
        blockPos.getX(),
        blockPos.getY(),
        blockPos.getZ(),
        Block);
  }
  
  public void setBlockAt(int x, int y, int z, Block Block) {
    blockCopies
        [x - min.getX()]
        [y - min.getY()]
        [z - min.getZ()] = Block;
  }
  
  public void removeBlockDataAt(BlockVec blockPos) {
    blockCopies
        [blockPos.getX() - min.getX()]
        [blockPos.getY() - min.getY()]
        [blockPos.getZ() - min.getZ()] = null;
  }
  
  /**
   * Returns true if the block copy at the given position is listed as visible (when it's not null)
   */
  public boolean isBlockListedVisible(BlockVec blockPos) {
    return getBlockAt(blockPos) != null;
  }
}
