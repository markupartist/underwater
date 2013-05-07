

boolean arduinoConnected = false;
StringBuilder serialStringBuilder = new StringBuilder();

void setupSerialConfig() {
  try {
    String portName = Serial.list()[6]; // TODO: Make configurable.
    println(portName);
    arduinoPort = new Serial(this, portName, 9600);
    arduinoConnected = true;
  } catch (Exception e) {
    println("Failed to init serial. Check serial port.");
    println(Serial.list());
  }  
}

void sendCommand(String command) {
  println("command: " + command);
  if (arduinoConnected) {
    arduinoPort.write(command + "\n");
  }
}

void decodeSerial() {
  if (arduinoConnected) {
    while (arduinoPort.available ()>0) {
      char c = arduinoPort.readChar();
      serialStringBuilder.append(c);
      if (c=='\n') {
        decodeSerial(serialStringBuilder.toString());
        serialStringBuilder = new StringBuilder();
      }
    }
  }
}

void decodeSerial(String line) {
  if (line.startsWith("m")) {
    int motorId = Character.getNumericValue(line.charAt(1));
    Motor motor = motors.get(motorId);
    String command = line.substring(2);
    if (command.startsWith("s")) {
      String status = line.substring(3);
      StringTokenizer statusTokenizer = new StringTokenizer(status, ",");
      while (statusTokenizer.hasMoreTokens ()) {
        String statusToken = statusTokenizer.nextToken();
        //println("statusToken: " + statusToken);
        if (statusToken.startsWith("c")) {
          // TODO: Swap current and target, probably makes more sense.
          motor.setCurrentPosition(getValueOfToken(statusToken, 1));
        } else if (statusToken.startsWith("t")) {
          // TODO: Should we set this?
          int targetPosition = getValueOfToken(statusToken, 1);
          motor.setTargetPosition(targetPosition);
        }
      }
    }
  }
}

int getValueOfToken(String token, int position) {
  String value = token.substring(position);
  try {
    return Integer.valueOf(value);
  } catch (NumberFormatException e) {
    println("Unable to decode '"+value+"'of '"+token+"' !");
    return 0;
  }
}
