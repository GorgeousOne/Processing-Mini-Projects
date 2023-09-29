
Portal createPortal(BlockVec pos, int width, int height, Axis axis, color fill) {

  PVector rectMin = pos.toVector()
      .add(0, 1, 0)
      .add(axis.getCrossNormal())
      .add(axis.getNormal().mult(0.5));
      
  AxisAlignedRect portalRect = new AxisAlignedRect(axis, rectMin, width-2, height-2);
  
  BlockVec portalMax = pos.clone()
      .add(new BlockVec(axis.getNormal()))
      .add(new BlockVec(axis.getCrossNormal().mult(width)))
      .add(new BlockVec(0, height, 0));
  
  Portal newPortal = new Portal(portalRect, pos, portalMax, getFrameBlocks(pos, width, height, axis), fill);
  newPortal.setBlockCaches(createBlockCaches(newPortal, 10));
  return newPortal;
}

Set<Block> getFrameBlocks(BlockVec pos, int width, int height, Axis axis) {
  
  Set<Block> frameBlocks = new HashSet<Block>();
  
  BlockVec widthVec = new BlockVec(axis.getCrossNormal());
  BlockVec iter = pos.clone();
  
  for (int i = 0; i < width-1; i++) {
    frameBlocks.add(world.getBlockAt(iter));
    iter.add(widthVec);
  }
  
  for (int i = 0; i < height-1; i++) {
    frameBlocks.add(world.getBlockAt(iter));
    iter.add(new BlockVec(0, 1, 0));
  }
  
  for (int i = 0; i < width-1; i++) {
    frameBlocks.add(world.getBlockAt(iter));
    iter.add(widthVec.clone().multiply(-1));
  }
  
  for (int i = 0; i < height-1; i++) {
    frameBlocks.add(world.getBlockAt(iter));
    iter.add(new BlockVec(0, -1, 0));
  }
  
  return frameBlocks;
}

public void loadProjectionCachesOf(Portal portal) {
    
    Portal counterPortal = portal.getCounterPortal();
    Transform linkTransform = calculateLinkTransform(portal, counterPortal);
    portal.setTpTransform(linkTransform.clone().invert());
    
    BlockCache frontCache = counterPortal.getFrontCache();
    BlockCache backCache = counterPortal.getBackCache();
    
    portal.setProjectionCaches(createProjectionCaches(frontCache, backCache, linkTransform));
}

private Transform calculateLinkTransform(Portal portal, Portal counterPortal) {
  
  Transform linkTransform;
  BlockVec loc1 = new BlockVec(portal.getLocation());
  BlockVec loc2 = new BlockVec(counterPortal.getLocation());
  
  linkTransform = new Transform();
  
  //during the rotation some weird shifts happen
  //I did not figure out where they come from, for now some extra translations are a good workaround
  if (portal.getAxis() == counterPortal.getAxis()) {
    
    int y = loc2.y;
    loc2 = new BlockVec(counterPortal.getPortalRect().getMax()
        .sub(counterPortal.getPortalRect().getCrossNormal()));
    loc2.y = y;
    
    linkTransform.setRotY180Deg();
    
  } else if (counterPortal.getAxis() == Axis.X) {
    linkTransform.setRotY90DegRight();
    
  } else {
    
    linkTransform.setRotY90DegLeft();
  }
  
  BlockVec distance = loc1.subtract(loc2);
  linkTransform.setTranslation(distance);
  linkTransform.setRotCenter(loc2);
  return linkTransform;
}
