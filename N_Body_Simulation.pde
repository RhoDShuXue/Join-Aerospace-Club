ArrayList<Body> bodies;
int numObjects = 100;
float dt = 0.05;
float G = 39.478;
float AU = 1.0;
float timeScale = 150;
int currentStep = 0;
int resonanceCheckInterval = 5;

boolean debugResonance = false;

// Rogue Planet Parameters
float rogueMass = 30.0;
float rogueMassSolar = 0;
PVector rogueInitialPos;
PVector rogueInitialVel;
float interactionDistance = 200;

// The Sun
Body sun;

// Tracking Arrays
float[] initialTilts;
float[] currentTilts;
float[] tiltChange;
int[] resonanceStates;
float[] eccentricity;
float[] perihelion;
float[] initialPerihelion;
boolean[] wasDisturbed;

//Display
float sunSize = 80;
float rogueSize = 45;
float objectSize = 12;
boolean showTiltVectors = true;
float maxTiltDisplay = 30;
boolean highlightRogue = true;

//Disruption Metrics
float maxTiltChange = 0;
int objectsDisturbed = 0;
int objectsInResonance = 0;
int objectsDetached = 0;

//Performance Tracking
float lastTimeCheck = 0;
int lastStepCount = 0;
float actualYearsPerSecond = 0;

//Resonance Detection Parameters
float resonanceTolerance = 0.15;
float detachmentThreshold = 50;

void setup() {
  size(1200, 800);
  colorMode(HSB, 360, 100, 100, 100);            // HSB color mode for vibrant colors
  
  rogueMassSolar = rogueMass * 3.0e-6;
  
  bodies = new ArrayList<Body>();  
  sun = new Body(new PVector(0, 0), new PVector(0, 0), 1.0, true);
  bodies.add(sun);
  
  for (int i = 0; i < numObjects; i++) {
    createBody(i);
  }
  createRoguePlanet();
  
  //Initialize tracking arrays
  int numTrackedObjects = bodies.size() - 2;
  initialTilts = new float[numTrackedObjects];
  currentTilts = new float[numTrackedObjects];
  tiltChange = new float[numTrackedObjects];
  resonanceStates = new int[numTrackedObjects];
  eccentricity = new float[numTrackedObjects];
  perihelion = new float[numTrackedObjects];
  initialPerihelion = new float[numTrackedObjects];
  wasDisturbed = new boolean[numTrackedObjects];
  
  //Calculate initial orbital parameters
  for (int i = 2; i < bodies.size(); i++) {
    int idx = i - 2;
    Body b = bodies.get(i);
    
    //Store initial values
    initialTilts[idx] = calculateTilt(b);
    currentTilts[idx] = initialTilts[idx];
    wasDisturbed[idx] = false;
    resonanceStates[idx] = 0;
    
    //Store initial orbital parameters
    eccentricity[idx] = calculateEccentricity(b);
    perihelion[idx] = calculatePerihelion(b);
    initialPerihelion[idx] = perihelion[idx];
  }
  
  lastTimeCheck = millis() / 1000.0;
  lastStepCount = currentStep;
}

void draw() {
  background(0);
  translate(width/2, height/2);
  scale(1, -1);
  
  //Zooming
  float viewScale = calculateViewScale();
  scale(viewScale, viewScale);
  
  for (int step = 0; step < timeScale; step++) {
    updateSimulation();
    currentStep++;
    
    //Resonance Check
    if (currentStep % resonanceCheckInterval == 0) {
      checkResonances();
    }
  }
  
  //Performance Calculator
  float currentTime = millis() / 1000.0;
  float timeDiff = currentTime - lastTimeCheck;
  if (timeDiff >= 1.0) {  // Update once per second
    int stepDiff = currentStep - lastStepCount;
    actualYearsPerSecond = (stepDiff * dt) / timeDiff;
    lastTimeCheck = currentTime;
    lastStepCount = currentStep;
  }

  //Draw all bodies
  for (Body b : bodies) {
    b.display();
  }
  
  drawInteractionRadius();
  
  //Visualization
  if (showTiltVectors) {
    drawTiltVectors();
  }
  
  //Draw Resonance Indicators
  drawResonanceIndicators();
  
  if (highlightRogue && bodies.size() > 1) {
    drawRogueHighlight();
  }
  
  //Draw UI
  drawUI();
}

void updateSimulation() {
  if (bodies.size() < 2) {
    return;
  }

  //Updating Rogue Planet
  Body rogue = bodies.get(bodies.size() - 1);
  rogue.acc.set(0, 0);
  
  PVector toSun = PVector.mult(rogue.pos, -1);
  float rSun = toSun.mag();
  float forceMagSun = (G * 1.0 * rogue.mass) / (rSun * rSun);
  toSun.normalize();
  toSun.mult(forceMagSun / rogue.mass);
  rogue.acc.add(toSun);
  
  //Updating rogue position (Euler integration)
  rogue.vel.add(PVector.mult(rogue.acc, dt));
  rogue.pos.add(PVector.mult(rogue.vel, dt));
  
  //Updating Kuiper Belt and Oort Cloud Bodies
  for (int i = 2; i < bodies.size() - 1; i++) {
    Body obj = bodies.get(i);
    float distToRogue = PVector.dist(obj.pos, rogue.pos);
    
    if (distToRogue < interactionDistance) {
      PVector r = PVector.sub(rogue.pos, obj.pos);
      float magSq = r.magSq();      
      float forceMagnitude = (G * obj.mass * rogue.mass) / max(magSq, 100.0);
      
      if (distToRogue < 100) {
        forceMagnitude *= 2.0;
      }
      if (distToRogue < 50) {
        forceMagnitude *= 3.0;
      }
      
      r.normalize();
      r.mult(forceMagnitude / obj.mass);
      obj.acc = r;
      
      if (!wasDisturbed[i-2]) {
        wasDisturbed[i-2] = true;
        println("Object " + (i-2) + " disturbed at distance: " + distToRogue);
      }
      
      obj.vel.add(PVector.mult(obj.acc, dt));
      obj.pos.add(PVector.mult(obj.vel, dt));
    }
    else {
      obj.acc.set(0, 0);
      obj.pos.add(PVector.mult(obj.vel, dt));
    }
  }
}
