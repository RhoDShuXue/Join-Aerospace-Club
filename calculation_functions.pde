//Converting to cartesian coordinates for Processing
PVector orbitToCartesian(float a, float e, float inc, float argP, float lonNode, float trueAnomaly) {
  float r = a * (1 - e*e) / (1 + e * cos(trueAnomaly));
  float xOrbit = r * cos(trueAnomaly + argP);
  float yOrbit = r * sin(trueAnomaly + argP);
  
  float incRad = radians(inc);
  PVector pos = new PVector(
    xOrbit * cos(lonNode) - yOrbit * sin(lonNode) * cos(incRad),
    xOrbit * sin(lonNode) + yOrbit * cos(lonNode) * cos(incRad)
  );  
  return pos;
}

PVector calculateOrbitalVelocity(PVector pos, float centralMass) {
  PVector r = pos.copy();
  float rMag = r.mag();
  
  //Centripedal Motion Mr. Vrolyk reference no wayy!!!
  float vCirc = sqrt(G * centralMass / rMag);
  
  PVector vDir = new PVector(-r.y, r.x);
  vDir.normalize();
  
  return PVector.mult(vDir, vCirc);
}

float calculateTilt(Body b) {
  float h = b.pos.x * b.vel.y - b.pos.y * b.vel.x;
  float tilt = abs(h / (b.pos.mag() * b.vel.mag()));
  return degrees(asin(tilt));
}

float calculateEccentricity(Body b) {
  float r = b.pos.mag();
  float v = b.vel.mag();
  float mu = G;
  float energy = v*v/2 - mu/r;
  float h = abs(b.pos.x * b.vel.y - b.pos.y * b.vel.x);
  float eSq = 1 + (2 * energy * h * h) / (mu * mu);
  return sqrt(max(0, eSq));
}

float calculatePerihelion(Body b) {
  float a = calculateSemiMajorAxis(b);
  float e = calculateEccentricity(b);
  
  if (a > 0) {
    return a * (1 - e);
  }
  else {
    return abs(a) * (e - 1);
  }
}

float calculateSemiMajorAxis(Body b) {
  float r = b.pos.mag();
  float v = b.vel.mag();
  float mu = G;
  float a = 1.0 / (2.0/r - v*v/mu);
  return abs(a);
}

//Resonance Detection
void checkResonances() {
  if (bodies.size() < 3) return;
  
  Body rogue = bodies.get(bodies.size() - 1);
  float a_rogue = rogue.pos.mag();
  float n_rogue = 0;
  
  if (a_rogue > 0 && a_rogue < 10000) {
    n_rogue = sqrt(G * rogue.mass / (a_rogue * a_rogue * a_rogue));
  }
  
  objectsInResonance = 0;
  objectsDetached = 0;
  objectsDisturbed = 0;
  
  for (int i = 2; i < bodies.size() - 1; i++) {
    int idx = i - 2;
    Body b = bodies.get(i);
    
    if (wasDisturbed[idx]) {
      objectsDisturbed++;
      
      float newE = calculateEccentricity(b);
      float newPeri = calculatePerihelion(b);
      
      eccentricity[idx] = newE;
      perihelion[idx] = newPeri;
      
      //Detach
      if (newPeri > detachmentThreshold && initialPerihelion[idx] < detachmentThreshold) {
        resonanceStates[idx] = 2;  // 2 = detached
        objectsDetached++;
        
        if (frameCount % 30 == 0) {
          println("Object " + idx + " became DETACHED! Perihelion: " + newPeri + " AU");
        }
      }
      else if (n_rogue > 0) {
        float newA = calculateSemiMajorAxis(b);
        if (newA > 0 && newA < 10000) {
          float n_obj = sqrt(G / (newA * newA * newA));
          float ratio = n_obj / n_rogue;
          
          float[] resonanceRatios = {2.0, 1.5, 1.333, 1.25, 1.0, 0.75, 0.667, 0.5};
          String[] resonanceNames = {"2:1", "3:2", "4:3", "5:4", "1:1", "3:4", "2:3", "1:2"};
          boolean inResonance = false;
          
          for (int r = 0; r < resonanceRatios.length; r++) {
            if (abs(ratio - resonanceRatios[r]) < resonanceTolerance) {
              inResonance = true;
              if (resonanceStates[idx] != 1) {
                resonanceStates[idx] = 1;
                println("Object " + idx + " entered " + resonanceNames[r] + 
                        " resonance! Ratio: " + ratio + ", a: " + newA + 
                        ", rogue a: " + a_rogue);
              }
              objectsInResonance++;
              break;
            }
          }
          if (!inResonance && resonanceStates[idx] == 1) {
            resonanceStates[idx] = 0;
          }
        }
      }
      
      //Update Tilt
      float newTilt = calculateTilt(b);
      float change = abs(newTilt - currentTilts[idx]);
      if (change > maxTiltChange) {
        maxTiltChange = change;  // Track maximum tilt change ever seen
      }
      tiltChange[idx] = change;
      currentTilts[idx] = newTilt;
    }
  }
}

//Resonance Indicators
void drawResonanceIndicators() {
  for (int i = 2; i < bodies.size() - 1; i++) {
    int idx = i - 2;
    if (resonanceStates[idx] > 0 && wasDisturbed[idx]) {
      Body b = bodies.get(i);
      
      pushMatrix();
      translate(b.pos.x, b.pos.y);
      
      if (resonanceStates[idx] == 1) {
        float pulse = sin(frameCount * 0.2 + i) * 5 + 25;
        strokeWeight(2);
        stroke(60, 100, 100, 80 + sin(frameCount * 0.3) * 20);
        noFill();
        circle(0, 0, objectSize + pulse);
        
        fill(60, 100, 100);
        noStroke();
        textSize(12);
        text("R", objectSize/2 + 10, -objectSize/2 - 10);
      }
      
      else if (resonanceStates[idx] == 2) {
        // DETACHED INDICATOR - Purple pulsing ring
        float pulse = sin(frameCount * 0.15 + i) * 8 + 30;
        strokeWeight(3);
        stroke(280, 100, 100, 70 + sin(frameCount * 0.2) * 30);
        noFill();
        circle(0, 0, objectSize + pulse);
        
        fill(280, 100, 100);
        noStroke();
        textSize(12);
        text("D", objectSize/2 + 12, -objectSize/2 - 12);
      }
      
      popMatrix();
    }
  }
}
