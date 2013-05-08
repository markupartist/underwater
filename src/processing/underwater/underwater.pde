import java.util.*;
import processing.serial.*;
import controlP5.*;

static int STEPPER_COUNT = 5;
ControlP5 cp5;
Serial arduinoPort;
ArrayList<Motor> motors = new ArrayList<Motor>();
EventEmitter eventEmitter = new EventEmitter();

void setup() {
  size(800, 600);
  noStroke();
  
  cp5 = new ControlP5(this);
  //cp5.setColor(new CColor(0xffaa0000, 0xff330000, 0xffff0000, 0xffffffff, 0xffffffff));  

  Group emitterGroup = cp5.addGroup("emitter")
    .setPosition(10, 20)
    .setBackgroundHeight(50)
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

      int groupWidth = 180;
      int groupHeight = 180;

      int groupX = (x * (groupWidth + 10)) + 10;
      int groupY = (y * (groupHeight + 20)) + 100;
      Group g = cp5.addGroup("motor " + motorId)
        .setPosition(groupX, groupY)
        .setBackgroundHeight(groupHeight)
        .setWidth(groupWidth)
        .setBackgroundColor(color(255,50));
        //.addListener(m);
      cp5.addSlider("targetpos" + motorId)
        .setCaptionLabel("Target")
        .setPosition(10,10).setSize(10,60)
        .setRange(-1200, 1200)
        .setGroup(g)
        .addListener(m);
      cp5.addSlider("currentpos" + motorId)
        .setCaptionLabel("Current")
        .setPosition(50,10).setSize(10,60)
        .setRange(-1200, 1200)
        .setGroup(g)
        .setColor(new CColor(0xffaa0000, 0xff330000, 0xffff0000, 0xffffffff, 0xffffffff))
        .lock()
        .addListener(m);
      cp5.addBang("up" + motorId)
        .setCaptionLabel("Up")
        .setPosition(90,10)
        .setSize(20,20)
        .setGroup(g)
        .addListener(m);
      cp5.addBang("down" + motorId)
        .setCaptionLabel("Down")
        .setPosition(120,10)
        .setSize(20,20)
        .setGroup(g)
        .addListener(m);
      cp5.addBang("stop" + motorId)
        .setCaptionLabel("Stop")
        .setPosition(150,10)
        .setSize(20,20)
        .setGroup(g)
        .addListener(m);
      cp5.addBang("reset" + motorId)
        .setCaptionLabel("Reset")
        .setPosition(90,50)
        .setSize(20,20)
        .setGroup(g)
        .addListener(m);
      cp5.addBang("status" + motorId)
        .setCaptionLabel("Status")
        .setPosition(120,50)
        .setSize(20,20)
        .setGroup(g)
        .addListener(m);
      cp5.addBang("home" + motorId)
        .setCaptionLabel("Home")
        .setPosition(150,50)
        .setSize(20,20)
        .setGroup(g)
        .addListener(m);
      cp5.addSlider("speed" + motorId)
        .setCaptionLabel("Speed")
        .setPosition(10, 90)
        .setSize(60, 20)
        .setRange(0, 700)
        .setGroup(g)
        .setValue(300) // Need to match default conf in the Arduino.
        .addListener(m);
      cp5.addSlider("acceleration" + motorId)
        .setCaptionLabel("Acceleration")
        .setPosition(10, 120)
        .setSize(60, 20)
        .setRange(0, 700)
        .setGroup(g)
        .setValue(150) // Need to match default conf in the Arduino.
        .addListener(m);
      cp5.addToggle("toggle" + motorId)
        .setCaptionLabel("Enable")
        .setPosition(10, 150).setSize(10,10)
        .setGroup(g)
        .setValue(1.0)
        .addListener(eventEmitter);
      cp5.addTextlabel("querylabel" + motorId)
        .setText(m.print())
        .setPosition(50, 150)
        .setGroup(g);
      motorId++;
    }
  }

  setupSerialConfig();
}

void draw() {
  background(20);
  decodeSerial();
}

public class FakeMover {
  public void update() {
    
  }
}

