// An array of objects
Mover[] moversRed = new Mover[5];
Mover[] moversBlue = new Mover[5];
// Try making 100 or even 1000 robots!
Attractor mouseAttractor, ellipseAttractor;
void setup() {
  size(640, 360);
  background(255);

  mouseAttractor = new Attractor(new PVector(mouseX, mouseY));
  ellipseAttractor = new Attractor(new PVector(random(width) - 100, random(height) - 100));

  for (int i = 1; i <= moversRed.length; i++) {
    // Initialize each object in the array.
    moversRed[i-1] = new Mover(mouseAttractor, color(255, 0, 0), i*.05);
    moversBlue[i-1] = new Mover(ellipseAttractor, color(0, 0, 255), i*.07);
  }
}

void draw() {
  background(255);

  ellipseAttractor.display();
  mouseAttractor.update(new PVector(mouseX, mouseY));
  
  for (int i = 0; i < moversRed.length; i++) {
    //[full] Calling functions on all the objects in the array
    moversRed[i].update();
    moversRed[i].checkEdges();
    moversRed[i].display();
    //[end]
  }

  for (int i = 0; i < moversBlue.length; i++) {
    moversBlue[i].update();
    moversBlue[i].checkEdges();
    moversBlue[i].display();
  }
  
  for(int i = 0; i < moversRed.length; i++){
    Mover r = moversRed[i];
    for(int j = 0; j < moversBlue.length; j++){
      Mover b = moversBlue[j];
      
      if(dist(r.location.x, r.location.y, b.location.x, b.location.y) < 15) {
        r.velocity.mult(-1);
        b.velocity.mult(-1);
      }
    }
  }
}

class Attractor {
  PVector location;
  Attractor(PVector loc) {
    location = loc;
  }

  void update(PVector currentLocation) {
    location = currentLocation;
  }

  void display() {
    fill(0);
    ellipse(location.x, location.y, 60, 60);
  }
}
class Mover {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float topspeed;
  float hunger;
  float lifespan;

  color moverColor;
  Attractor attractor;

  Mover(Attractor att, color mC, float _hunger) {
    location = new PVector(random(width), random(height));
    velocity = new PVector(0, 0);
    topspeed = 6;
    hunger = _hunger;
    lifespan = 1000.0;
    moverColor = mC;
    attractor = att;
  }

  void update() {

    // <b><u>Our algorithm for calculating acceleration</b></u>:

    //[full] Find the vector pointing towards the mouse.
    PVector mouse = new PVector(attractor.location.x, attractor.location.y);
    PVector dir = PVector.sub(mouse, location);

    //[end]
    // Normalize.
    dir.normalize();
    // Scale.
    dir.mult(hunger);
    // Set to acceleration.
    acceleration = dir;

    //[full] Motion 101! Velocity changes by acceleration.  Location changes by velocity.
    velocity.add(acceleration);
    velocity.limit(topspeed);
    location.add(velocity);
    float d = dist(location.x, location.y, attractor.location.x, attractor.location.y);
    //println(d);
    if (d <= 50) {
      lifespan += 2.0;
    } else {
      lifespan -= 2.0;
    }
    //[end]
  }

  // Display the Mover
  void display() {
    stroke(0, lifespan);
    fill(moverColor, lifespan);
    ellipse(location.x, location.y, 8, 8);
  }

  void checkEdges() {
    if (location.x > width) {
      location.x = width;
      velocity.x *= -1;
    } else if (location.x < 0) {
      location.x = 0;
      velocity.x *= -1;
    }

    if (location.y > height) {
      location.y = height;
      velocity.y *= -1;
    } else if (location.y < 0) {
      location.y = 0;
      velocity.y *= -1;
    }
  }
}
