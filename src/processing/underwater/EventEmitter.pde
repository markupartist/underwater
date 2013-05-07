class EventEmitter implements MotorListener, ControlListener {

  TargetEvent[] targets;
  boolean started;

  EventEmitter() {
    started = false;
    targets = new TargetEvent[STEPPER_COUNT];
    for (int i = 0; i < targets.length; i++) {
      targets[i] = new TargetEvent(-600, 600);
    }
  }

  public void position(Motor motor, int position) {
    if (started) {
      println("POS: " + position);
      targets[motor.motorId].update();    
      motor.target(int(targets[motor.motorId].target));
    }
  }

  public void controlEvent(ControlEvent event) {
    if (event.getController().getName().equals("toggleEmitter")) {
      started = boolean(int(event.getController().getValue()));
    }
  }
}

class TargetEvent {
  float target = 0; 
  int min;
  int max;

  public TargetEvent(int min, int max) {
    this.min = min;
    this.max = max;
  }

  void update() {
    target = random(min, max);
  }
}
