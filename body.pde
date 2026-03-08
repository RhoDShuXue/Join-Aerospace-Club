class Body {
  PVector pos;
  PVector vel;
  PVector acc;
  float mass;
  color bodyColor;
  boolean isRogue;
  
  Body(PVector pos, PVector vel, float mass, boolean rogue) {
    this.pos = pos.copy();
    this.vel = vel.copy();
    this.acc = new PVector(0, 0);
    this.mass = mass;
    this.isRogue = rogue;
    
    if (mass > 0.9) {                 //The Sun
      bodyColor = color(60, 100, 100);
    }
    else if (rogue) {                 //Rogue Planet
      bodyColor = color(0, 100, 100);
    }
    else {                            //Kuiper Belt and Oort Cloud Bodies
      bodyColor = color(180, 255, 100);
    }
  }
  
  void display() {
    pushMatrix();
    translate(pos.x, pos.y);
    
    //The Sun
    if (mass > 0.9) {
      for (int i = 5; i > 0; i--) {
        fill(60, 100, 100, 15/i);
        noStroke();
        circle(0, 0, sunSize + i*15);
      }

      fill(bodyColor, 250);
      noStroke();
      circle(0, 0, sunSize);
    }
    
    //Rogue Planet
    else if (isRogue) {
      for (int i = 4; i > 0; i--) {
        fill(0, 100, 100, 20/i);
        noStroke();
        circle(0, 0, rogueSize + i*12);
      }
      
      fill(bodyColor, 250);
      noStroke();
      circle(0, 0, rogueSize);
      
      fill(255, 150);
      circle(-rogueSize/5, -rogueSize/5, rogueSize/4);
    }
    
    //Kuiper Belt and Oort Cloud Bodies
    else {
      fill(bodyColor, 230);
      noStroke();
      circle(0, 0, objectSize);
      
      fill(255, 100);
      circle(-objectSize/4, -objectSize/4, objectSize/3);
    }
    
    popMatrix();
  }
  
  //Checks if near rogue
  boolean isNearRogue(Body rogue, float interactionDist) {
    if (this.isRogue || this.mass > 0.9) {
      return false;
    }
    
    float dist = PVector.dist(this.pos, rogue.pos);
    return dist < interactionDist;
  }
}
