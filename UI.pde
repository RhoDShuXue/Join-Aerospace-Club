void drawUI() {
  scale(1, -1);
  scale(1/calculateViewScale(), 1/calculateViewScale());
  translate(-width/2, -height/2);
  
  //Simulation Info
  fill(255);
  textAlign(LEFT);  
  textSize(14);
  text("Elapsed: " + nf(currentStep * dt, 0, 0) + " years", 20, 65);
  
  if (bodies.size() > 2) {
    Body rogue = bodies.get(bodies.size() - 1);
    float rogueDist = rogue.pos.mag();
    text("Rogue Distance: " + nf(rogueDist, 0, 0) + " AU", 20, 90);
    
    float rogueSpeed = rogue.vel.mag();
    text("Rogue Speed: " + nf(rogueSpeed, 0, 2) + " AU/yr", 20, 115);
    
    text("Rogue Mass: " + (int)rogueMass + " Earth", 20, 140);
    
    //Disruption Metrics
    text("DISRUPTION METRICS:", 20, 170);
    text("Objects disturbed: " + objectsDisturbed, 20, 195);
    text("In resonance (R): " + objectsInResonance, 20, 220);
    text("Detached (D): " + objectsDetached, 20, 245);
    
    if (objectsDisturbed > 0) {
      float resonancePercent = (objectsInResonance * 100.0 / max(objectsDisturbed, 1));
      float detachedPercent = (objectsDetached * 100.0 / max(objectsDisturbed, 1));
      text("Resonance %: " + nf(resonancePercent, 0, 1) + "%", 20, 270);
      text("Detached %: " + nf(detachedPercent, 0, 1) + "%", 20, 295);
    }
    
    //Interaction Indicators
    int objectsNear = 0;
    for (int i = 2; i < bodies.size() - 1; i++) {
      Body obj = bodies.get(i);
      if (obj.isNearRogue(rogue, interactionDistance)) {
        objectsNear++;
      }
    }
    
    if (objectsNear > 0) {
      fill(0, 100, 100);
      text("⚡ " + objectsNear + " objects near rogue", 20, 325);
      fill(255);
    }
    
    if (rogueDist < 200) {
      fill(0, 100, 100);
      text("⚡ ROGUE IN INNER SYSTEM", 20, 350);
      fill(255);
    }
  }
  
  //Controls - REMOVED THE BLACK BACKGROUND BOX
  int instY = height - 260;
  
  fill(255);
  text("CONTROLS:", 20, instY + 15);
  text("'r' - Reset rogue", 20, instY + 40);
  text("'m' - Increase mass (+5 Earth)", 20, instY + 65);
  text("'t' - Toggle tilt vectors", 20, instY + 90);
  text("'s' - Save data", 20, instY + 115);
  text("'+' - Speed up", 20, instY + 140);
  text("'-' - Slow down", 20, instY + 165);
  text("'d' - Debug resonance", 20, instY + 190);
  
  text("MASS: " + (int)rogueMass + " Earth", 20, instY + 220);
}
