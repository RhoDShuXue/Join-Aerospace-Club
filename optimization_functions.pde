void drawInteractionRadius() {
  if (bodies.size() < 2) {
    return;
  }
  
  Body rogue = bodies.get(bodies.size() - 1);
  
  pushMatrix();
  translate(rogue.pos.x, rogue.pos.y);
  
  noFill();
  strokeWeight(1);
  stroke(0, 100, 100, 30);
  circle(0, 0, interactionDistance * 2);
  
  popMatrix();
}

void drawRogueHighlight() {
  Body rogue = bodies.get(bodies.size() - 1);
  float pulse = sin(frameCount * 0.4) * 20 + 30;
  
  pushMatrix();
  translate(rogue.pos.x, rogue.pos.y);
  
  noFill();
  strokeWeight(4);
  stroke(0, 100, 100, 100 - frameCount % 50);
  circle(0, 0, rogueSize + pulse);
  
  if (rogue.vel.mag() > 0.1) {
    PVector velDir = rogue.vel.copy();
    float speed = velDir.mag();
    velDir.normalize();
    velDir.mult(rogueSize + 40 + speed * 15);
    
    stroke(0, 100, 100, 200);
    line(0, 0, velDir.x, velDir.y);
    
    pushMatrix();
    translate(velDir.x, velDir.y);
    rotate(atan2(velDir.y, velDir.x));
    fill(0, 100, 100);
    noStroke();
    triangle(0, 0, -18, -10, -18, 10);
    popMatrix();
  }
  
  popMatrix();
}

float calculateViewScale() {
  if (bodies.size() > 1) {
    Body rogue = bodies.get(bodies.size() - 1);
    float rogueDist = rogue.pos.mag();
    
    if (rogueDist < 200) {
      return 1.1;
    } else if (rogueDist < 300) {
      return 1.0;
    } else if (rogueDist < 500) {
      return 0.9;
    } else if (rogueDist < 700) {
      return 0.7;
    } else {
      return 0.5;
    }
  }
  return 0.9;
}
