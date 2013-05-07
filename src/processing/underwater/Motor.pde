

public class Motor implements ControlListener {
  int motorId;
  int minPosition;
  int maxPosition;
  int currentPosition;
  int targetPosition;
  ArrayList<MotorListener> listeners;

  public Motor(int motorId) {
    this.motorId = motorId;
    this.currentPosition = 0;
    this.targetPosition = 0;
    this.minPosition = -1200;
    this.maxPosition = 1200;
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
    }
  }

  public void query() {
    sendCommand(String.format("m%ss", motorId));
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
      /*
      if (listeners != null) {
        for (MotorListener l : listeners) {
          // pass current as a new integer instead.
          l.position(this, this.targetPosition);
        }
      }
      */

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
}

public interface MotorListener {
  public void position(Motor motor, int position);
}

