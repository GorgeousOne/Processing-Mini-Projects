import java.util.HashMap;
import java.util.Map;
import java.util.AbstractMap;

/**
 * A viewing frustum for detecting the blocks of a projection cache that can be seen through a portal frame.
 * It is a frustum with the specific condition that near and far plane are rectangles either aligned to the x or z axis.
 */
public class ViewFrustum {
  
  private PVector viewPoint;
  private AxisAlignedRect nearPlaneRect;
  private AxisAlignedRect farPlaneRect;
  
  private int frustumLength;
  private PVector frustumFacing;
  
  public ViewFrustum(PVector viewPoint, AxisAlignedRect nearPlane, int frustumLength) {
    
    this.viewPoint = viewPoint;
    this.nearPlaneRect = nearPlane;
    this.frustumLength = frustumLength;
    
    createFrustumFacing();
    createFarPlaneRect();
  }
  
  public AxisAlignedRect getNearPlaneRect() {
    return nearPlaneRect;
  }
  
  public AxisAlignedRect getFarPlaneRect() {
    return farPlaneRect;
  }
  
  public boolean contains(PVector point) {
    
    DefinedLine lineOfView = new DefinedLine(viewPoint, point);
    PVector pointInNearPlane = nearPlaneRect.getPlane().getIntersection(lineOfView);
    
    return pointInNearPlane != null && nearPlaneRect.contains(pointInNearPlane);
  }
  
  /**
   * Returns true if any vertex of the block at the given position intersects the frustum
   */
  public boolean containsBlock(PVector blockPos) {
    
    for (int dx = 0; dx <= 1; dx++) {
      for (int dy = 0; dy <= 1; dy++) {
        for (int dz = 0; dz <= 1; dz++) {
          
          if (contains(blockPos.copy().add(new PVector(dy, dy, dz)))) {
            return true;
          }
        }
      }
    }
    
    return false;
  }
  
  public int getLength() {
    return frustumLength;
  }
  
  private void createFrustumFacing() {
    
    //take the near plane's normal as the facing of the frustum
    this.frustumFacing = nearPlaneRect.getNormal();
    
    //but make it face in the opposite direction of where the view point
    PVector relViewPoint = viewPoint.copy().sub(nearPlaneRect.getMin());
    frustumFacing.mult(-Math.signum(frustumFacing.dot(relViewPoint)));
  }
  
  private void createFarPlaneRect() {
    
    PVector nearPlaneOrigin = nearPlaneRect.getMin();
    PVector nearPlaneNormal = nearPlaneRect.getNormal();
    
    //calculate a vector representing the distance between near plane and far plane
    PVector farPlaneOffset = frustumFacing.copy().mult(frustumLength);
    
    //calculate a far plane parallel to the near plane with the correct offset
    PVector farPlaneOrigin = nearPlaneOrigin.copy().add(farPlaneOffset);
    Plane farPlane = new Plane(farPlaneOrigin, nearPlaneNormal);
    
    //create two lines for mapping the vertices of the near rect onto the far plane
    Line farRectMinLine = new Line(viewPoint, nearPlaneOrigin);
    Line farRectMaxLine = new Line(viewPoint, nearPlaneRect.getMax());
    
    PVector farRectMin = farPlane.getIntersection(farRectMinLine);
    PVector farRectMax = farPlane.getIntersection(farRectMaxLine);
    
    PVector rectDiameter = farRectMax.copy().sub(farRectMin);
    float rectHeight = rectDiameter.y;
    rectDiameter.y = 0;
    float rectWidth = rectDiameter.mag();
    
    farPlaneRect = new AxisAlignedRect(nearPlaneRect.getAxis(), farRectMin, rectWidth, rectHeight);
  }
  
  /**
   * Returns a map of all blocks from a projection cache visible with this frustum.
   */
  public Map<BlockVec, Block> getContainedBlocks(BlockCache projection) {
    
    AxisAlignedRect startLayer;
    AxisAlignedRect endLayer;
    
    if (frustumFacing.x == -1 || frustumFacing.z == -1) {
      startLayer = farPlaneRect;
      endLayer = nearPlaneRect;
      
    } else {
      startLayer = nearPlaneRect;
      endLayer = farPlaneRect;
    }
    
    if (nearPlaneRect.getAxis() == Axis.X) {
      return getBlocksInXAlignedFrustum(projection, startLayer, endLayer);
    } else {
      return getBlocksInZAlignedFrustum(projection, startLayer, endLayer);
    }
  }
  
  void display() {
    
    PVector p3 = farPlaneRect.getMin();
    PVector p4 = farPlaneRect.getMax();
    
    PVector p1;
    PVector p2;
    
    if (nearPlaneRect.getAxis() == Axis.X) {
      p1 = new PVector(p4.x, p3.y, p3.z);
      p2 = new PVector(p3.x, p4.y, p3.z);
      
    }else {
      p1 = new PVector(p3.x, p3.y, p4.z);
      p2 = new PVector(p3.x, p4.y, p3.z);
    }
    
    pushStyle();
    stroke(255, 0, 0);
    
    line(viewPoint.x, viewPoint.y, viewPoint.z, p3.x, p3.y, p3.z);
    line(viewPoint.x, viewPoint.y, viewPoint.z, p4.x, p4.y, p4.z);
    line(viewPoint.x, viewPoint.y, viewPoint.z, p1.x, p1.y, p1.z);
    line(viewPoint.x, viewPoint.y, viewPoint.z, p2.x, p2.y, p2.z);
    
    stroke(0, 128, 255);
    line(viewPoint.x, 0, viewPoint.z, p1.x, 0, p1.z);
    line(viewPoint.x, 0, viewPoint.z, p2.x, 0, p2.z);
    
    popStyle();
  }
  
  private Map<BlockVec, Block> getBlocksInXAlignedFrustum(BlockCache projection,
                                                              AxisAlignedRect startLayer,
                                                              AxisAlignedRect endLayer) {
    
    PVector iterationMaxPoint = endLayer.getMax();
    PVector currentLayerMinPoint = startLayer.getMin();
    PVector currentLayerMaxPoint = startLayer.getMax();
    
    PVector layerMinPointStep = endLayer.getMin().sub(startLayer.getMin()).mult(1f / frustumLength);
    PVector layerMaxPointStep = endLayer.getMax().sub(startLayer.getMax()).mult(1f / frustumLength);
    
    Map<BlockVec, Block> blocksInFrustum = new HashMap<BlockVec, Block>();
    
    for (int layerZ = (int) (currentLayerMinPoint.z); layerZ <= iterationMaxPoint.z; layerZ++) {
      
      int layerMax = (int) currentLayerMaxPoint.x;
      boolean isFirstColumn = true;
      boolean isLastColumn = false;
      
      for (int columnX = (int) Math.ceil(currentLayerMinPoint.x); isFirstColumn || columnX <= layerMax; columnX++) {
        
        int columnMax = (int) currentLayerMaxPoint.y;
        boolean isFirstRow = true;
        boolean isLastRow = false;
        
        if (columnX == layerMax) {
          isLastColumn = true;
        }
        
        for (int rowY = (int) Math.ceil(currentLayerMinPoint.y); isFirstRow || rowY <= columnMax; rowY++) {
          
          if (rowY == columnMax) {
            isLastRow = true;
          }
          
          //since the iteration only passes every block at one point, the surrounding blocks have to be added on edges for accurately determining all blocks
          if (isFirstColumn || isLastColumn || isFirstRow || isLastRow) {
            addSurroundingBlocks(columnX, rowY, layerZ, projection, blocksInFrustum);
          } else {
            addBlock(columnX, rowY, layerZ, projection, blocksInFrustum);
          }
          
          isFirstRow = false;
        }
        isFirstColumn = false;
      }
      
      currentLayerMinPoint.add(layerMinPointStep);
      currentLayerMaxPoint.add(layerMaxPointStep);
    }
    
    return blocksInFrustum;
  }
  
  private Map<BlockVec, Block> getBlocksInZAlignedFrustum(BlockCache projection,
                                                              AxisAlignedRect startLayer,
                                                              AxisAlignedRect endLayer) {
    
    PVector iterationMaxPoint = endLayer.getMax();
    PVector currentLayerMinPoint = startLayer.getMin();
    PVector currentLayerMaxPoint = startLayer.getMax();
    
    Map.Entry<PVector, PVector> unitVecs = getSmallestUnitVecs(
        endLayer.getMin().sub(startLayer.getMin()),
        endLayer.getMax().sub(startLayer.getMax()));
        
    PVector layerMinPointStep = unitVecs.getKey();
    PVector layerMaxPointStep = unitVecs.getValue();
    
    println(layerMinPointStep + " aha " + layerMaxPointStep);
    
    Map<BlockVec, Block> blocksInFrustum = new HashMap<BlockVec, Block>();
    
    for (float layerX = currentLayerMinPoint.x; layerX <= iterationMaxPoint.x; layerX += layerMinPointStep.x) {
      

      int layerMax = (int) currentLayerMaxPoint.z;
      boolean isFirstColumn = true;
      boolean isLastColumn = false;
      
      for (float columnZ = currentLayerMinPoint.z; isFirstColumn || columnZ <= layerMax; columnZ++) {
        
        int columnMax = (int) currentLayerMaxPoint.y;
        boolean isFirstRow = true;
        boolean isLastRow = false;
        
        if (columnZ == layerMax) {
          isLastColumn = true;
        }
        
        for (float rowY = currentLayerMinPoint.y; isFirstRow || rowY <= columnMax; rowY++) {
          
          if (rowY == columnMax) {
            isLastRow = true;
          }
          
          if (isFirstColumn || isLastColumn || isFirstRow || isLastRow) {
            
            addSurroundingBlocks(
                (int) (layerX), 
                (int) (rowY), 
                (int) (columnZ), 
                projection, blocksInFrustum);
                
          } else {
            
            addBlock(
                (int) (layerX), 
                (int) (rowY), 
                (int) (columnZ),
                projection, blocksInFrustum);
          }
          
          isFirstRow = false;
        }
        isFirstColumn = false;
      }
      
      currentLayerMinPoint.add(layerMinPointStep);
      currentLayerMaxPoint.add(layerMaxPointStep);
    }
    
    return blocksInFrustum;
  }
  
  float SQRT_TWO = sqrt(0.5);
  
  private Map.Entry<PVector, PVector> getSmallestUnitVecs(PVector dir1, PVector dir2) {
    
    makeVecBlocky(dir1);
    makeVecBlocky(dir2);
    
        println(dir1 + " oho " + dir1);

    //println(greatestX + " : " + greatestY + " : " + greatestZ);
    
    if (roundOn(abs(dir1.y), 1) >= 1 && roundOn(abs(dir2.y), 1) >= 1) {
      
      println("y is big");
      return new AbstractMap.SimpleEntry<PVector, PVector>(
          dir1.copy().mult(1 / abs(dir1.y)),
          dir2.copy().mult(1 / abs(dir2.y)));
          
    }else if (roundOn(abs(dir1.z), 1) >= 1 && roundOn(abs(dir2.z), 1) >= 1) {

      println("z is big");
    
      return new AbstractMap.SimpleEntry<PVector, PVector>(
          dir1.copy().mult(1 / abs(dir1.z)),
          dir2.copy().mult(1 / abs(dir2.z)));
    
    }else {
      
      return new AbstractMap.SimpleEntry<PVector, PVector>(
          dir1.copy().mult(1 / abs(dir1.x)),
          dir2.copy().mult(1 / abs(dir2.x)));

    }
  }
  
  private PVector makeVecBlocky(PVector vec) {
    
    float absX = abs(vec.x);  
    float absY = abs(vec.y);
    float absZ = abs(vec.z);

    if (absX > absY && absX > absZ) {
      vec.mult(1 / absX);
      
    }else if (absY > absZ) {
      vec.mult(1 / absY); 
      
    }else {
      vec.mult(1 / absZ); 
    }
    
    return vec;
  }
  
  float roundOn(float f, int decimals) {
    return round(f * pow(10, decimals)) / pow(10, decimals);  
  }
  /**
   * Adds a blocks from the projection cache to the visible blocks in the frustum.
   */
  private void addBlock(int x,
                        int y,
                        int z,
                        BlockCache projection,
                        Map<BlockVec, Block> blocksInFrustum) {
    
    Block block = projection.getBlockAt(x, y, z);
    
    if (block != null) {
      block.setMaterial(color(128, 128));
      blocksInFrustum.put(new BlockVec(x, y, z), block);
    }
  }
  
  /**
   * Adds the 8 blocks from the projection cache around a block location to the map of visible blocks in the frustum.
   */
  private void addSurroundingBlocks(int x,
                                    int y,
                                    int z,
                                    BlockCache projection,
                                    Map<BlockVec, Block> blocksInFrustum) {
    
    for (int dx = -1; dx <= 0; dx++) {
      for (int dy = -1; dy <= 0; dy++) {
        for (int dz = -1; dz <= 0; dz++) {
          
          Block block = projection.getBlockAt(x + dx, y + dy, z + dz);
          
          if (block != null) {
            
            BlockVec vec = new BlockVec(x + dx, y + dy, z + dz);
            
            if (blocksInFrustum.containsKey(vec))
              continue;
            
            if (dx != 0 && dy != 0 && dz != 0)
              block.setMaterial(color(255, 196, 128, 128));
            else
              block.setMaterial(color(128, 128));

            //trying to reduce the object creation (the BlockVec)
            blocksInFrustum.put(vec, block);
          }
        }
      }
    }
  }
}
