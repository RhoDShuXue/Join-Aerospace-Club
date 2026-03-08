void keyPressed() {
  //Rogue Reset
  if (key == 'r' || key == 'R') {
    //Planet Reset
    if (bodies.size() > 1) {
      bodies.remove(bodies.size() - 1);
      //rogueTrail.clear();
      createRoguePlanet();
      
      //Tracking Reset
      maxTiltChange = 0;
      for (int i = 0; i < wasDisturbed.length; i++) {
        wasDisturbed[i] = false;
        resonanceStates[i] = 0;
      }
      objectsInResonance = 0;
      objectsDetached = 0;
      objectsDisturbed = 0;
    }
  }
  
  //Increase rogue mass
  if (key == 'm' || key == 'M') {
    rogueMass = min(rogueMass + 5, 60);
    rogueMassSolar = rogueMass * 3.0e-6;
    if (bodies.size() > 1) {
      bodies.get(bodies.size() - 1).mass = rogueMassSolar;
    }
    println("Rogue mass increased to: " + rogueMass + " Earth masses");
  }
  
  //Tilt vectors
  if (key == 't' || key == 'T') {
    showTiltVectors = !showTiltVectors;
  }
  
  //Enabling debug mode
  if (key == 'd' || key == 'D') {
    debugResonance = !debugResonance;
    println("Debug mode: " + debugResonance);
    
    if (debugResonance && bodies.size() > 2) {
      // Print debug info
      Body rogue = bodies.get(bodies.size() - 1);
      
      // Show first 5 disturbed objects
      int count = 0;
      for (int i = 2; i < bodies.size() - 1 && count < 5; i++) {
        int idx = i - 2;
        if (wasDisturbed[idx]) {
          Body b = bodies.get(i);
          println("  Object " + idx + ": e=" + eccentricity[idx] + 
                  ", peri=" + perihelion[idx] +
                  ", state=" + resonanceStates[idx]);
          count++;
        }
      }
    }
  }
  
  //Speeds up the simulation
  if (key == '+' || key == '=') {
    timeScale = min(timeScale + 20, 400);
  }
  
  //Slows down the simulation
  if (key == '-' || key == '_') {
    timeScale = max(timeScale - 20, 50);
  }
  
  //Highlighting the rogue planet
  if (key == 'h' || key == 'H') {
    // Toggle rogue highlight
    highlightRogue = !highlightRogue;
  }
  
  // Increasing interaction distance
  if (key == 'i' || key == 'I') {
    interactionDistance = min(interactionDistance + 25, 500);
    println("Interaction distance: " + interactionDistance);
  }
}
