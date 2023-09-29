
class Spectator {
 
  PVector pos;
  float yaw;
  float pitch;
  float fov;
  
  Spectator(PVector pos, float fovDegrees) {
    this.pos = pos;
    this.fov = fovDegrees / 180 * PI;
    
    perspective(fov, 1f * width / height, 0.3, 150);
  }
  
  PVector getPos() {
    return pos;
  }
  
  void setPos(PVector pos) {
    this.pos = pos;
  }
  
  float getYaw() {
    return yaw;
  }
  
  void setYaw(float yaw) {
    this.yaw = yaw;
  }
  
  float getPitch() {
    return pitch;
  }
    
  void setPitch(float pitch) {
    this.pitch = pitch;
  }

  PVector getFacing() {
    
    float cosPitch = cos(pitch);

    return new PVector(
        cosPitch * cos(yaw), 
        sin(pitch), 
        cosPitch * sin(yaw));
  }
  
  void focus() {
    
    float cosPitch = cos(pitch);
    float dx = cosPitch * cos(yaw);
    float dy = sin(pitch);
    float dz = cosPitch * sin(yaw);
    
    //camera(0, 0, 0, 
    //       0, 0, 1, 
    //       0, -1, 0);
    
    //translate(pos.x, pos.y, pos.z);
    
    //rotateX(pitch);
    //rotateY(yaw);
    
    
    camera(pos.x, pos.y, pos.z, 
           pos.x + dx, pos.y + dy, pos.z + dz, 
           0, -1, 0);
            
  }
  
  void move(float forwards, float sidewards) {
    
    float cosYaw = cos(yaw);
    float sinYaw = sin(yaw);
    
    pos.add(
        cosYaw * forwards + cos(yaw + HALF_PI) * sidewards, 0,
        sinYaw * forwards + sin(yaw + HALF_PI) * sidewards);
  }
 
  void move(float upwards) {
    pos.add(0, upwards, 0);
  }
  
  void rotate(float dYaw, float dPitch) {
    
    yaw += dYaw / 180 * PI;
    
    pitch += dPitch / 180 * PI;
    pitch = max(-HALF_PI+0.001, min(HALF_PI-0.001, pitch));
  }
}
