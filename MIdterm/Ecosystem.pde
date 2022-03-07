import java.util.*;

// An array of objects
ArrayList<Mover> moversRed = new ArrayList<Mover>();
ArrayList<Mover> moversBlue = new ArrayList<Mover>();

Attractor ellipseAttractor;
Predator predator;

int time = millis();
void setup() {
  size(640, 360);
  background(255);

  //mouseAttractor = new Attractor(new PVector(mouseX, mouseY));
  ellipseAttractor = new Attractor(new PVector(abs(random(width) - 260), abs(random(height) - 260)));
  predator = new Predator();
  for (int i = 1; i <= 5; i++) {
    // Initialize each object in the array.
    moversRed.add(new Mover(ellipseAttractor, color(255, 0, 0), i*.05));
    moversBlue.add(new Mover(ellipseAttractor, color(0, 0, 255), i*.07));
  }
}

void draw() {
  background(255);

  ellipseAttractor.display();
  predator.display();
  //mouseAttractor.update(new PVector(mouseX, mouseY));

  for (int i = 0; i < moversRed.size(); i++) {
    //[full] Calling functions on all the objects in the array
    moversRed.get(i).update();
    moversRed.get(i).checkEdges();
    moversRed.get(i).display();
    //[end]
  }

  for (int i = 0; i < moversBlue.size(); i++) {
    moversBlue.get(i).update();
    moversBlue.get(i).checkEdges();
    moversBlue.get(i).display();
  }

  boolean removed = false;
  for (int i = 0; i < moversRed.size(); i++) {
    Mover r = moversRed.get(i);
    for (int j = 0; j < moversBlue.size(); j++) {
      Mover b = moversBlue.get(j);

      if (dist(r.location.x, r.location.y, b.location.x, b.location.y) < 15) {
        if (moversRed.get(i).radius > moversBlue.get(j).radius) {
          moversBlue.get(j).lifespan -= 10;
        } else {
          moversRed.get(i).lifespan -= 10;
        }

        if (moversBlue.get(j).lifespan < 50) {
          moversBlue.remove(j);
          removed = true;
        }
        if (moversRed.get(i).lifespan < 50) {
          moversRed.remove(i);
          removed = true;
        }
        if (removed) {
          break;
        }
        //r.velocity.mult(-1);
        //b.velocity.mult(-1);
      }
    }

    if (removed) {
      break;
    }
  }

  if (moversRed.size() == 2) {
    moversRed.add(new Mover(ellipseAttractor, color(255, 0, 0), random(1, 5)*.05));
  }

  if (moversBlue.size() == 2) {
    moversBlue.add(new Mover(ellipseAttractor, color(0, 0, 255), random(1, 5)*.05));
  }
}

class Predator {
  PVector location;
  float angle;
  PVector velocity = new PVector(random(1, 1.5), random(1, 1.5));

  Predator() {
    location = new PVector(width / 2, height / 2);
    angle = radians(.001);
  }

  void display() {
    fill(color(0, 255, 0));
    rectMode(CENTER);
    rect(location.x, location.y, 30, 30);
    location.add(velocity);

    angle += 0.01;

    checkEdges();
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
class DNA {
  PVector velocity;
  PVector acceleration;
  float topspeed;
  float hunger;
  float lifespan;

  DNA(float _hunger) {
    velocity = new PVector(0, 0);
    topspeed = random(3, 8);
    hunger = _hunger;
    lifespan = random(1000, 1500);
  }
}

class Attractor {
  int radius = 60;
  PVector location;
  Attractor(PVector loc) {
    location = loc;
  }

  void update(PVector currentLocation) {
    location = currentLocation;
  }

  void display() {
    println(location);
    if (radius <= 10) {
      ellipseAttractor = new Attractor(new PVector(abs(random(width)), abs(random(height) - 260)));
      for (int i = 0; i < moversRed.size(); i++) {
        moversRed.get(i).attractor = ellipseAttractor;
        moversBlue.get(i).attractor = ellipseAttractor;
      }
    }
    fill(0);
    ellipse(location.x, location.y, radius, radius);
  }
}
class Mover extends DNA {

  PVector location;
  float radius = 8.0;
  color moverColor;
  Attractor attractor;

  Mover(Attractor att, color mC, float _hunger) {
    super(_hunger);
    location = new PVector(random(width), random(height));
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

    if (d<10) {
      attractor.radius -= 0.01;

      for (int i = 0; i < moversRed.size(); i++) {
        Mover red = moversRed.get(i);
        red.radius += 0.02;
        if (red.topspeed > 1.5) {
          red.topspeed -= 0.009;
        }

        Mover blue = moversBlue.get(i);
        blue.radius += 0.02;
        if (blue.topspeed > 1.5) {
          blue.topspeed -= 0.009;
        }
      }
    }

    if (dist(location.x, location.y, predator.location.x, predator.location.y) < 30) {
      lifespan = 0;
    }
    if (dist(location.x, location.y, predator.location.x, predator.location.y) < 60) {
      predator.location.add(new PVector((2.2),(2.2)));
    }
    

    //[end]
  }

  // Display the Mover
  void display() {
    stroke(0, lifespan);
    fill(moverColor, lifespan);
    ellipse(location.x, location.y, radius, radius);
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

