
public ViewFrustum createFrustum(PVector viewPoint, AxisAlignedRect portalRect, int frustumLength) {
    
    boolean isPlayerBehindPortal = isPlayerBehindPortal(viewPoint, portalRect);
    
    PVector portalNormal = portalRect.getPlane().getNormal();
    PVector playerFacingToPortal = portalNormal.mult(isPlayerBehindPortal ? 1 : -1);
    
    //this will become near plane of the viewing frustum. It will be cropped to fit the actual player view through the portal
    AxisAlignedRect totalViewingRect = portalRect.clone().translate(playerFacingToPortal.copy().mult(0.5f));
    Plane portalPlane = totalViewingRect.getPlane();
    
    PVector viewingRectMin = totalViewingRect.getMin();
    PVector viewingRectMax = totalViewingRect.getMax();
    
    //addTolerance(viewingRectMin, viewingRectMax, portalRect, 0.15f);
    
    //depending on which portal frame blocks will block the view, the viewing rect bounds are contracted by casting rays along the block edges
    //here for the height of the rect...
    if (viewPoint.y < viewingRectMin.y) {
      
      PVector closeRectMin = viewingRectMin.copy().sub(playerFacingToPortal);
      PVector newRectMin = portalPlane.getIntersection(new Line(viewPoint, closeRectMin));
      viewingRectMin.y = newRectMin.y;
      
    } else if (viewPoint.y > viewingRectMax.y) {
      
      PVector closeRectMax = viewingRectMax.copy().sub(playerFacingToPortal);
      PVector newRectMax = portalPlane.getIntersection(new Line(viewPoint, closeRectMax));
      viewingRectMax.y = newRectMax.y;
    }
    
    Axis portalAxis = portalRect.getAxis();
    
    //... also for the width
    if (portalAxis == Axis.X) {
      
      if (viewPoint.x < viewingRectMin.x) {
        
        PVector closeRectMin = viewingRectMin.copy().sub(playerFacingToPortal);
        PVector newRectMin = portalPlane.getIntersection(new Line(viewPoint, closeRectMin));
        viewingRectMin.x = newRectMin.x;
        
      } else if (viewPoint.x > viewingRectMax.x) {
        
        PVector closeRectMax = viewingRectMax.copy().sub(playerFacingToPortal);
        PVector newRectMax = portalPlane.getIntersection(new Line(viewPoint, closeRectMax));
        viewingRectMax.x = newRectMax.x;
      }
      
    } else {
      
      if (viewPoint.z < viewingRectMin.z) {
        
        PVector closeRectMin = viewingRectMin.copy().sub(playerFacingToPortal);
        PVector newRectMin = portalPlane.getIntersection(new Line(viewPoint, closeRectMin));
        viewingRectMin.z = newRectMin.z;
        
      } else if (viewPoint.z > viewingRectMax.z) {
        
        PVector closeRectMax = viewingRectMax.copy().sub(playerFacingToPortal);
        PVector newRectMax = portalPlane.getIntersection(new Line(viewPoint, closeRectMax));
        viewingRectMax.z = newRectMax.z;
      }
    }
    
    PVector viewingRectSize = viewingRectMax.copy().sub(viewingRectMin);
    float rectWidth = portalAxis == Axis.X ? viewingRectSize.x : viewingRectSize.z;
    float rectHeight = viewingRectSize.y;
    
    if (rectWidth < 0 || rectHeight < 0) {
      return null;
    }
    
    AxisAlignedRect actualViewingRect = new AxisAlignedRect(totalViewingRect.getAxis(), viewingRectMin, rectWidth, rectHeight);
    return new ViewFrustum(viewPoint, actualViewingRect, frustumLength);
  }
  
  public static boolean isPlayerBehindPortal(PVector viewPoint, AxisAlignedRect portalRect) {
    
    PVector portalPos = portalRect.getMin();
    
    return portalRect.getAxis() == Axis.X ?
        viewPoint.z < portalPos.z :
        viewPoint.x < portalPos.x;
  }
  
  //widen the rectangle bounds a bit so the projection becomes smoother/more consistent when moving quickly
  //side effects are blocks slightly sticking out at the sides when standing further away
  private static void addTolerance(PVector rectMin, PVector rectMax, AxisAlignedRect portalRect, float tolerance) {
    
    PVector toleranceVec = portalRect.getCrossNormal();
    toleranceVec.y = 1;
    toleranceVec.mult(tolerance);
    
    rectMin.sub(toleranceVec);
    rectMax.add(toleranceVec);
  }
