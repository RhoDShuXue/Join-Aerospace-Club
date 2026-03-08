//Creating a Varied Body
void createBody(int index) {
  float a;
  
  if (index < numObjects/3) {
    a = random(150, 250);
  }
  else if (index < 2*numObjects/3) {
    a = random(300, 450);
  }
  else {
    a = random(500, 700);
  }
  
  float e = random(0.05, 0.2);
  float inc = random(-10, 10);
  float argP = random(TWO_PI);
  float lonNode = random(TWO_PI);
  float trueAnomaly = random(TWO_PI);
  
  PVector pos = orbitToCartesian(a, e, inc, argP, lonNode, trueAnomaly);  
  PVector vel = calculateOrbitalVelocity(pos, 1.0);
  float mass = random(0.8, 2.5) * 1e-6;
  bodies.add(new Body(pos, vel, mass, false));
}

//Creating a Rogue Planet
void createRoguePlanet() {
  float startDistance = 900;
  float angle = random(TWO_PI);
  float inc = random(-3, 3);
  
  PVector pos = new PVector(
    startDistance * cos(angle) * cos(radians(inc)),
    startDistance * sin(angle)
  );
  
  PVector toSun = PVector.mult(pos, -1);
  toSun.normalize();
  PVector radialDir = toSun.copy();
  PVector tangDir = new PVector(-toSun.y, toSun.x);
  
  PVector velDir = PVector.mult(radialDir, 0.9);
  velDir.add(PVector.mult(tangDir, 0.1));
  velDir.normalize();
  
  float r = pos.mag();
  float mu = G;
  float vMag = sqrt(mu / r) * 5;            //Side note this is not mathematically accurate in the slightest, just looks better
  
  PVector vel = PVector.mult(velDir, vMag);
  
  rogueInitialPos = pos.copy();
  rogueInitialVel = vel.copy();
  
  bodies.add(new Body(pos, vel, rogueMassSolar, true));
  println("Rogue planet created at distance: " + startDistance + " AU");
}

void drawTiltVectors() {
  if (bodies.size() < 2) {
    return;
  }
  
  Body rogue = bodies.get(bodies.size() - 1);
  
  for (int i = 2; i < bodies.size() - 1; i++) {
    int idx = i - 2;
    Body b = bodies.get(i);
    
    if (wasDisturbed[idx] || b.isNearRogue(rogue, interactionDistance)) {
      float tilt = currentTilts[idx];
      float initial = initialTilts[idx];
      float change = abs(tilt - initial);

      if (change > 8) {
        stroke(0, 100, 100, 90);
        strokeWeight(3);
      }
      else if (change > 4) {
        stroke(15, 100, 100, 80);
        strokeWeight(2.5);
      }
      else if (change > 2) {
        stroke(30, 100, 100, 70);
        strokeWeight(2);
      }
      else {
        stroke(180, 100, 100, 60);
        strokeWeight(1.5);
      }
      
      line(b.pos.x, b.pos.y, b.pos.x, b.pos.y + tilt * 3);
    }
  }
}
