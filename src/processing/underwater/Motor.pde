

public class Motor implements ControlListener {
  int motorId;
  int minPosition;
  int maxPosition;
  int currentPosition;
  int targetPosition;
  float maxSpeed;
  float currentSpeed;
  int acceleration;
  ArrayList<MotorListener> listeners;

  public Motor(int motorId) {
    this.motorId = motorId;
    this.currentPosition = 0;
    this.targetPosition = 0;
    this.minPosition = -1200;
    this.maxPosition = 1200;
    this.maxSpeed = 300;
    this.acceleration = 150;
    this.currentSpeed = 0;
  }

  public void addListener(MotorListener l) {
    if (listeners == null) {
      listeners = new ArrayList<MotorListener>();
    }
    listeners.add(l);
  }

  public void controlEvent(ControlEvent event) {
    // Command
    String command = event.getController().getName();
    if (command.startsWith("status")) {
      this.query();
    } else if (command.startsWith("reset")) {
      this.reset();
    } else if (command.startsWith("up")) {
      this.stepUp();
    } else if (command.startsWith("down")) {
      this.stepDown();
    } else if (command.startsWith("targetpos")) {
      this.target(int(event.getController().getValue()));
    } else if (command.startsWith("home")) {
      this.home();
    } else if (command.startsWith("speed")) {
      this.setMaxSpeed(event.getController().getValue());
    } else if (command.startsWith("acceleration")) {
      this.setAcceleration(int(event.getController().getValue()));
    } else if (command.startsWith("stop")) {
      this.stop();
    }
  }

  /**
   * Sets the acceleration and deceleration parameter.
   * Must the greater than zero.
   */
  public void setAcceleration(int acceleration) {
    if (acceleration != this.acceleration || acceleration > 0) {
      sendCommand(String.format("m%sa%s", motorId, maxSpeed));
      this.maxSpeed = maxSpeed;
    }
  }

  /**
   * Sets the maximum permitted speed as steps per second.
   */
  public void setMaxSpeed(float maxSpeed) {
    if (maxSpeed != this.maxSpeed) {
      sendCommand(String.format("m%ss%s", motorId, maxSpeed));
      this.maxSpeed = maxSpeed;
    }
  }

  public void setCurrentSpeed(float currentSpeed) {
    this.currentSpeed = currentSpeed;

    Textlabel label = ((Textlabel)cp5.getController("querylabel" + motorId));
    label.setText(this.print());
  }

  /**
   * Move to home position, home position is 0.
   */
  public void home() {
    sendCommand(String.format("m%sh", motorId));
  }

  /**
   * Stop the motor.
   * This will deaccelerate according to the current speed and acceleration.
   */
  public void stop() {
    sendCommand(String.format("m%sb", motorId));
  }

  /**
   * Query the motor of it current position, target position and speed.
   * This call is async and an event will be fired with the result.
   */
  public void query() {
    sendCommand(String.format("m%sq", motorId));
  }

  public void reset() {
    sendCommand(String.format("m%sr", motorId));
    setCurrentPosition(0);
    setTargetPosition(0);
  }

  public void target(int position) {
    if (position != this.targetPosition) {
      sendCommand(String.format("m%st%s", motorId, position));
      setTargetPosition(position);
    }
  }

  public void stepUp() {
    int position = this.targetPosition + 1;
    target(position);
  }

  public void stepDown() {
    int position = this.targetPosition - 1;
    target(position);    
  }

  public void setTargetPosition(int position) {
    if (position != this.targetPosition) {
      this.targetPosition = position;
      // TODO: This could be moved into a motor listener, or should be supported by ControlP5?
      Slider slider = ((Slider)cp5.getController("targetpos" + motorId));
      slider.setValue(this.targetPosition);
    }
  }

  // TODO: This should be target position instead.
  public void setCurrentPosition(int currentPosition) {
    // Update the controller.
    if (currentPosition != this.currentPosition) {
      this.currentPosition = currentPosition;

      if (listeners != null) {
        for (MotorListener l : listeners) {
          // pass current as a new integer instead.
          l.position(this, this.currentPosition);
        }
      }

      // TODO: This could be moved into a motor listener, or should be supported by ControlP5?
      Slider slider = ((Slider)cp5.getController("currentpos" + motorId));
      slider.setValue(this.currentPosition);
    }
  }

  public String print() {
    return String.format("C=%s, T=%s, S=%s",
      this.currentPosition,
      this.targetPosition,
      this.currentSpeed);
  }
}

public interface MotorListener {
  public void position(Motor motor, int position);
}

