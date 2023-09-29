import java.util.Map;
import java.util.Objects;
import java.util.Set;

/**
 * A class containing information about a located portal structure in a world.
 */
public class Portal {
  
  private AxisAlignedRect portalRect;
  private BlockVec min;
  private BlockVec max;
  private Set<Block> frameBlocks;
  
  private Portal counterPortal;
  private Transform tpTransform;
  
  private Map.Entry<BlockCache, BlockCache> blockCaches;
  private Map.Entry<ProjectionCache, ProjectionCache> projectionCaches;
  
  public Portal(AxisAlignedRect portalRect,
                BlockVec min,
                BlockVec max,
                Set<Block> frameBlocks,
                color fill) {
    
    this.portalRect = portalRect;
    this.min = min;
    this.max = max;
    this.frameBlocks = frameBlocks;
    
    for (Block block : frameBlocks)
      block.setMaterial(fill);

  }
  
  void display() {
    
    for (Block block : frameBlocks)
      block.display();
      
    portalRect.display();
    
    if (isLinked()) {
      //getFrontProjection().display();
      getBackProjection().display();
    }else {
      getFrontCache().display();
      //getBackCache().display();
    }
  }
  
  public BlockVec getMin() {
    return min.clone();  
  }
  
  public PVector getLocation() {
    return portalRect.getMin();
  }
  
  public AxisAlignedRect getPortalRect() {
    return portalRect.clone();
  }
  
  public Axis getAxis() {
    return portalRect.getAxis();
  }
  
  /**
   * Returns true if the given BlockVec is inside portal structure including the frame.
   */
  public boolean contains(BlockVec loc) {
    return loc.getX() >= min.getX() && loc.getX() < max.getX() &&
           loc.getY() >= min.getY() && loc.getY() < max.getY() &&
           loc.getZ() >= min.getZ() && loc.getZ() < max.getZ();
  }
  
  public boolean equalsInSize(Portal other) {
    
    AxisAlignedRect otherRect = other.getPortalRect();
    
    return portalRect.width() == otherRect.width() &&
           portalRect.height() == otherRect.height();
  }
  
  public Portal getCounterPortal() {
    return counterPortal;
  }
  
  public void setTpTransform(Transform tpTransform) {
    this.tpTransform = tpTransform;
  }
  
  public Transform getTpTransform() {
    return tpTransform;
  }
  
  public void setLinkedTo(Portal counterPortal) {
    this.counterPortal = counterPortal;
  }
  
  public boolean isLinked() {
    return counterPortal != null;
  }
  
  public void setBlockCaches(Map.Entry<BlockCache, BlockCache> blockCaches) {
    this.blockCaches = blockCaches;
  }
  
  public BlockCache getFrontCache() {
    return blockCaches.getKey();
  }
  
  public BlockCache getBackCache() {
    return blockCaches.getValue();
  }
  
  public void setProjectionCaches(Map.Entry<ProjectionCache, ProjectionCache> projectionCaches) {
    this.projectionCaches = projectionCaches;
  }
  
  public ProjectionCache getFrontProjection() {
    return projectionCaches.getKey();
  }
  
  public ProjectionCache getBackProjection() {
    return projectionCaches.getValue();
  }
   
  @Override
  public int hashCode() {
    return Objects.hash(getLocation());
  }  
}
