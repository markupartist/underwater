import java.util.*;
import processing.serial.*;
import controlP5.*;

static int STEPPER_COUNT = 4;
ControlP5 cp5;
Serial arduinoPort;
ArrayList<Motor> motors = new ArrayList<Motor>();
EventEmitter eventEmitter = new EventEmitter();

void setup() {
  size(710,500);
  noStroke();
  
  cp5 = new ControlP5(this);
  //cp5.setColor(new CColor(0xffaa0000, 0xff330000, 0xffff0000, 0xffffffff, 0xffffffff));  

  Group emitterGroup = cp5.addGroup("emitter")
    .setPosition(30, 300)
    .setBackgroundHeight(100)
    .setWidth(140)
    .setBackgroundColor(color(255,50));
  cp5.addToggle("toggleEmitter")
    .setCaptionLabel("Toggle")
    .setPosition(10,10).setSize(10,10)
    .setGroup(emitterGroup)
    .addListener(eventEmitter);

  // TODO: Move to build UI or similar.
  int cols = 4;
  int rows = ceil(float(STEPPER_COUNT) / float(cols));
  int motorId = 0;

  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      if (motorId >= STEPPER_COUNT) {
        break; // We reached max configured motors.
      }
      Motor m = new Motor(motorId);
      m.addListener(eventEmitter);
      motors.add(m);
      

      int groupX = (x * (140 + 30)) + 30;
      int groupY = (y * (100 + 30)) + 30;
      Group g = cp5.addGroup("motor " + motorId)
        .setPosition(groupX, groupY)
        .setBackgroundHeight(100)
        .setWidth(140)
        .setBackgroundColor(color(255,50));
        //.addListener(m);
      cp5.addSlider("position" + motorId)
        .setCaptionLabel("Position")
        .setPosition(10,10).setSize(10,60)
        .setRange(-1200, 1200)
        .setGroup(g)
        .addListener(m);
      cp5.addBang("up" + motorId)
        .setCaptionLabel("Up")
        .setPosition(70,10)
        .setSize(20,20)
        .setGroup(g)
        .addListener(m);
      cp5.addBang("down" + motorId)
        .setCaptionLabel("Down")
        .setPosition(100,10)
        .setSize(20,20)
        .setGroup(g)
        .addListener(m);
      cp5.addBang("reset" + motorId)
        .setCaptionLabel("Reset")
        .setPosition(70,50)
        .setSize(20,20)
        .setGroup(g)
        .addListener(m);
      cp5.addBang("status" + motorId)
        .setCaptionLabel("Status")
        .setPosition(100,50)
        .setSize(20,20)
        .setGroup(g)
        .addListener(m);

      motorId++;
    }
  }

  setupSerialConfig();
}

void draw() {
  background(20);
  decodeSerial();
}



