import java.util.AbstractMap;

public Map.Entry<BlockCache, BlockCache> createBlockCaches(Portal portal, int viewDist) {
  
  viewDist += 1;
  
  AxisAlignedRect portalRect = portal.getPortalRect();
  PVector portalFacing = portalRect.getNormal();
  PVector widthFacing = portalRect.getCrossNormal();
  
  PVector cacheCorner1 = portalRect.getMin();
  cacheCorner1.sub(new PVector(0, 5, 0));
  cacheCorner1.sub(widthFacing.copy().mult(viewDist));
  
  PVector cacheCorner2 = portalRect.getMax();
  cacheCorner2.add(new PVector(0, 5, 0));
  cacheCorner2.add(widthFacing.copy().mult(viewDist));
  
  int frontViewDist = 10;
  
  BlockCache front = copyBlocksInBounds(
      portal,
      cacheCorner1.copy().add(portalFacing),
      cacheCorner2.copy().add(portalFacing.copy().mult(frontViewDist+1)),
      portalFacing,
      color(0, 200, 0));
  
  //BlockCache back = copyBlocksInBounds(
  //    portal,
  //    cacheCorner1.copy().sub(portalFacing.copy().mult(frontViewDist - 1)),
  //    cacheCorner2,
  //    portalFacing.copy().mult(-1),
  //    color(0, 0, 250));
  
  //return new AbstractMap.SimpleEntry<BlockCache, BlockCache>(front, back);
  return new AbstractMap.SimpleEntry<BlockCache, BlockCache>(front, null);

}

private BlockCache copyBlocksInBounds(Portal portal,
                                             PVector cacheCorner1,
                                             PVector cacheCorner2,
                                             PVector cacheFacing,
                                             color borderColor) {
  
  PVector cacheMin = getMinimum(cacheCorner1, cacheCorner2);
  PVector cacheMax = getMaximum(cacheCorner1, cacheCorner2);
  
  int minX = (int) Math.floor(cacheMin.x);
  int minY = (int) Math.floor(cacheMin.y);
  int minZ = (int) Math.floor(cacheMin.z);
  int maxX = (int) Math.floor(cacheMax.x);
  int maxY = (int) Math.floor(cacheMax.y);
  int maxZ = (int) Math.floor(cacheMax.z);
    
  if (maxX < minX || maxY < minY || maxZ < minZ) {
    throw new IllegalArgumentException("Cannot create a BlockCache smaller than 1 block.");
  }
  
  BlockVec cacheSize = new BlockVec(cacheMax.copy().sub(cacheMin));
  
  BlockCache blockCache = new BlockCache(
      portal,
      new BlockVec(cacheMin),
      cacheSize,
      new BlockVec(cacheFacing),
      borderColor);
  
  for (int x = minX; x < maxX; x++) {
    for (int y = minY; y < maxY; y++) {
      for (int z = minZ; z < maxZ; z++) {
        
        Block block = world.getBlockAt(x, y, z);       
        blockCache.setBlockAt(x, y, z, block);
      }
    }
  }
  
  return blockCache;
}

public Map.Entry<ProjectionCache, ProjectionCache> createProjectionCaches(BlockCache frontCache,
                                                                                 BlockCache backCache,
                                                                                 Transform portalLinkTransform) {
  
  return new AbstractMap.SimpleEntry<ProjectionCache, ProjectionCache>(
      null,//createProjection(backCache, portalLinkTransform),
      createProjection(frontCache, portalLinkTransform));
}

public ProjectionCache createProjection(BlockCache sourceCache, Transform blockTransform) {
  
  
  BlockVec sourceMin = sourceCache.getMin();
  BlockVec sourceMax = sourceCache.getMax();
    
  BlockVec corner1 = blockTransform.transformVec(sourceMin.clone());
  BlockVec corner2 = blockTransform.transformVec(sourceMax.clone().add(-1, -1, -1));

  BlockVec projectionMin = corner1.getMinimum(corner1, corner2);//.sub(blockMid);
  BlockVec projectionMax = corner1.getMaximum(corner1, corner2).clone().add(1, 1, 1);//.add(blockMid);
  BlockVec projectionSize = projectionMax.clone().subtract(projectionMin);
  
  color c = sourceCache.borderType;
  
  ProjectionCache projectionCache = new ProjectionCache(
      sourceCache.getPortal(),
      projectionMin,
      projectionSize,
      blockTransform.transformVec(sourceCache.getFacing()),
      color(255 - red(c), 255 - green(c), 255 - blue(c)),
      blockTransform);
  
  for (int x = sourceMin.getX(); x < sourceMax.getX(); x++) {
    for (int y = sourceMin.getY(); y < sourceMax.getY(); y++) {
      for (int z = sourceMin.getZ(); z < sourceMax.getZ(); z++) {
        
        BlockVec blockPos = new BlockVec(x, y, z);
        Block block = sourceCache.getBlockAt(blockPos);
        
        if (block == null) {
          continue;
        }
        
        BlockVec newBlockPos = blockTransform.transformVec(blockPos);
        projectionCache.setBlockAt(newBlockPos, block);
      }
    }
  }
  
  return projectionCache;
}

public PVector getMinimum(PVector v1, PVector v2) {
  return new PVector(
      Math.min(v1.x, v2.x),
      Math.min(v1.y, v2.y),
      Math.min(v1.z, v2.z));
}

public PVector getMaximum(PVector v1, PVector v2) {
  return new PVector(
      Math.max(v1.x, v2.x),
      Math.max(v1.y, v2.y),
      Math.max(v1.z, v2.z));
}
