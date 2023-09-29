import java.util.Set;
import java.util.HashSet;

import java.util.List;
import java.util.Collections;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;

class Ui {
 
  OrbitCamera cam;
  Body body;
  String savesFolder;
  
  Set<UiCard> allCards;
  List<UiCard> cardOrder;
  Map<UiCard, Pose> poses;
  
  int cardSize;
  UiCard plusCard;
  UiCard selectedCard;
  int lastCardIndex;
  
  long animationStart;
  boolean isAnimating;
  int startPose;
  //long poseInterval = 190;
   long poseInterval = 225;

  Ui(OrbitCamera cam, Body body, String savesFolder) {
    this.cam = cam;
    this.body = body;
    this.savesFolder = savesFolder;
    
    allCards = new HashSet<UiCard>();
    cardOrder = new ArrayList<UiCard>();
    poses = new HashMap<UiCard, Pose>();
    cardSize = 40;
    
    plusCard = new UiCard(0, cardSize, "+");
    allCards.add(plusCard);
    
    loadPoses();
    //selectCard(cardOrder.get(4), false);
    //interpolatePoses(14);
    
    if (poses.isEmpty()) {
        addPose(new Pose(body));  
    }
  }
  
  Pose getPose() {
    return poses.get(selectedCard);  
  }

  Pose getPose(int index) {
    return poses.get(cardOrder.get(index));  
  }
   
  void playAnimation() {
    animationStart = System.currentTimeMillis();
    isAnimating = true;
    startPose = selectedCard.index;
  }
  
  void stopAnimation() {
    isAnimating = false;  
    poses.get(selectedCard).apply(body);
  }
  
  void display() {
    translate(-width/2f, -height/2f, cam.viewPlaneDist);
      
    for (UiCard card : allCards) {
      card.display();
    }
    
    if (isAnimating) {
      long dTime = System.currentTimeMillis() - animationStart;
      int index0 = (int) (startPose + dTime / poseInterval) % poses.size();
      int index1 = (index0 + 1) % poses.size();
      float scale = 1f * (dTime % poseInterval) / poseInterval;
      
      Pose pose0 = getPose(index0);
      Pose pose1 = getPose(index1);
      selectCard(cardOrder.get(index1), false);
      
      PVector offset0 = pose0.offset.copy();
      PVector offset1 = pose1.offset.copy();
      body.pos = offset0.mult(1 - scale).add(offset1.mult(scale));

      for (BodyPart part : body.parts) {
        PVector rot0 = pose0.rotations.get(part.name).copy();
        PVector rot1 = pose1.rotations.get(part.name).copy();
        part.rot = rot0.mult(1 - scale).add(rot1.mult(scale));
      }
      //body.pos.add(new PVector(0, 0, -(dTime % 8000 - 4000) / 1000f * 80));
    }
  }
    
  void addPose(Pose pose) {
    int index = plusCard.index;
    plusCard.index += 1;
    ++lastCardIndex;

    UiCard card = new UiCard(index, cardSize, "" + lastCardIndex);
    cardOrder.add(index, card);
    allCards.add(card);
    poses.put(card, pose);
    selectCard(card, true);
  }
  
  void repeatCycleMirrored() {
    int poseCount = poses.size();
    
    for (int i = 0; i < poseCount; ++i) {
      UiCard card = cardOrder.get(i);
      selectCard(card, true);
      addPose(new Pose(body));
      mirrorBody(body);
    }
    updateCurrentPose();
  }
  
  void interpolatePoses(int steps) {
    int startIndex = selectedCard.index;

    if (poses.size() < 2 || startIndex >= poses.size() - 1) {
      return;
    }
    Pose pose0 = getPose(startIndex);
    Pose pose1 = getPose(startIndex + 1);
    UiCard card1 = cardOrder.get(startIndex + 1);
    
    for(int i = 0; i < steps; ++i) {
      addPose(mergePoses(pose0, pose1, 1f / (steps+1) * (i+1)));
      swapRight(card1);
    }
  }
  
  Pose mergePoses(Pose pose0, Pose pose1, float percent) {
    Pose merged = new Pose();
    
    for (String part : pose0.rotations.keySet()) {
      PVector mergedRot = mergeVecs(pose0.rotations.get(part), pose1.rotations.get(part), percent);
      merged.rotations.put(part, mergedRot);
    }
    merged.offset = mergeVecs(pose0.offset, pose1.offset, percent);
    return merged;
  }
  
  PVector mergeVecs(PVector v0, PVector v1, float percent) {
    return v0.copy().mult(1 - percent).add(v1.copy().mult(percent));  
  }
  
  boolean handleClick(int x, int y, int button) {
    if (isAnimating) {
      return false;
    }
    for (UiCard card : allCards) {
      if (card.contains(x, y)) {
        clickCard(card, button);
        return true;
      }
    }
    return false;
  }
  
  void clickCard(UiCard card, int button) {
    if (plusCard == card) {
      addPose(new Pose(body));
      return;
    }
    
    if (button == LEFT) {
      selectCard(card, true);
    }else if (button == RIGHT) {
      swapRight(card);
    }else if (button == CENTER) {
      deleteCard(card);
    }
  }
  
  //highlights the clicked UiCard and displays it's pose
  void selectCard(UiCard card, boolean updatePose) {
    if (selectedCard != null) {
      selectedCard.isSelected = false;
      
      if (updatePose) {
        poses.put(selectedCard, new Pose(body));
      }
    }
    selectedCard = card;
    card.isSelected = true;
    poses.get(card).apply(body); 
  }
  
  //swaps the clicked UiCard with it's right neighbor
  void swapRight(UiCard card) {
    int index = card.index;
    
    if (index < cardOrder.size()-1) {
      card.index = card.index + 1;
      cardOrder.get(index + 1).index -= 1;
      Collections.swap(cardOrder, index, index+1);
    }
  }
  
  //deletes the given card. Card order will be updated and possibly another card selected.
  void deleteCard(UiCard card) {
    if (cardOrder.size() < 2) {
      return; 
    }
    int index = card.index;
    allCards.remove(card);
    cardOrder.remove(index);
    poses.remove(card);
    
    for (int i = index; i < cardOrder.size(); ++i) {
      cardOrder.get(i).index -= 1;
    }
    plusCard.index -= 1;
    
    if (card == selectedCard) {
      selectCard(cardOrder.get(max(0, selectedCard.index-1)), false);
    }
  }
  
  void loadPoses() {
    File[] folderContents = new File(savesFolder).listFiles();
    
    if (null == folderContents) {
      return;  
    }
    for (File file : folderContents) { 
      if (file.isFile()) {
        addPose(new Pose().read(savesFolder + "/" + file.getName()));
      }
    }
    println("Loaded", savesFolder);
  }
  
  //updates the pose of the selected UiCard by copying the current body
  void updateCurrentPose() {
    if (selectedCard != null) {
      poses.put(selectedCard, new Pose(enemy));
    }
  }
    
  void savePoses() {
    if (isAnimating) {
      return;  
    }
    File[] folderContent = new File(savesFolder).listFiles();
    
    if (null != folderContent) {
      for(File file : folderContent) {
        if (!file.isDirectory()) { 
          file.delete();
        }
      }
    }
    for (int i = 0; i < cardOrder.size(); ++i) {
        poses.get(cardOrder.get(i)).write(savesFolder + "/pose" + String.format("%02d", i+1) + ".txt");
    }
    println("Saved ", savesFolder);
  }
}

class UiCard {
  int index;
  int size;
  String text;
  boolean isSelected;
  
  UiCard(int index, int size, String text) {
    this.index = index;
    this.size = size;
    this.text = text;
  }
  
  void display() {
    pushStyle();
    fill(isSelected ? 255 : 196);
    stroke(0);
    
    beginShape();
    vertex(index * size, 0);
    vertex((index + 1) * size, 0);
    vertex((index + 1) * size, size);
    vertex(index * size, size);
    endShape();

    fill(0);
    //textSize(24);
    textAlign(CENTER, CENTER);
    text(text, index*size + size/2, size/2);
    popStyle();
  }
  
  boolean contains(int x, int y) {
    return x >= index * size && x < (index+1) *size &&
           y >= 0 && y < size;
  }
}
