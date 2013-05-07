#include <Wire.h>
#include <Adafruit_MCP23017.h>
#include <AccelStepper.h>
#include <MCP3017AccelStepper.h>

#define STEPPER_COUNT 4

Adafruit_MCP23017 mcp1;
Adafruit_MCP23017 mcp2;

MCP3017AccelStepper steppers[STEPPER_COUNT] = {
  MCP3017AccelStepper(AccelStepper::DRIVER, 15, 14, 8),   // CH1 interface, step, dir, en
  MCP3017AccelStepper(AccelStepper::DRIVER, 4, 5, 6),     // CH2 interface, step, dir, en
  MCP3017AccelStepper(AccelStepper::DRIVER, 12, 11, 10),  // CH3 interface, step, dir, en
  MCP3017AccelStepper(AccelStepper::DRIVER, 3, 1, 2),     // CH4 interface, step, dir, en
};
// TODO: Can we autofill this in setup.
// Need to match steppers.
boolean statusReported[STEPPER_COUNT] = {false, false, false, false};

void setup() {
  startSerial();

  mcp1.begin();
  mcp2.begin(1);

  // Configure MS for mcp1
  mcp1.pinMode(0, OUTPUT);   // MS2
  mcp1.pinMode(7, OUTPUT);   // MS3
  mcp1.pinMode(9, OUTPUT);   // MS1
  mcp1.digitalWrite(0, LOW); //MS2
  mcp1.digitalWrite(7, LOW); // MS3
  mcp1.digitalWrite(9, LOW); // MS1

  for (int i = 0; i < STEPPER_COUNT; i++) {
    steppers[i].setMcp(mcp1);
    steppers[i].setMinPulseWidth(1350);
    steppers[i].setPinsInverted(false, false, true);
    steppers[i].enableOutputs();
    steppers[i].setMaxSpeed(150.0);
    steppers[i].setAcceleration(150.0);
  }

  /*
  for (int i = 0; i < STEPPER_COUNT; i++) {
    steppers[i].moveTo(200);
  }
  */
}

void loop() {
  loopSerial();
  for (int i = 0; i < STEPPER_COUNT; i++) {
    steppers[i].run();
  }
}

