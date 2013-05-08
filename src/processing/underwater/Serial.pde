

boolean arduinoConnected = false;
StringBuilder serialStringBuilder = new StringBuilder();

void setupSerialConfig() {
  try {
    String portName = Serial.list()[4]; // TODO: Make configurable.
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
  println(line);
  if (line.startsWith("m")) {
    int motorId = Character.getNumericValue(line.charAt(1));
    if (motors.size() < motorId) {
      println(String.format("Failed to match motor id with motors conf. (id: %s, motors: %s)", motorId, motors.size()));
      return;
    }
    // TODO: Move parsing into Motor, to have the protocol in one place.
    Motor motor = motors.get(motorId);
    String command = line.substring(2);
    if (command.startsWith("q")) {
      String query = line.substring(3);
      StringTokenizer queryTokenizer = new StringTokenizer(query, ",");
      while (queryTokenizer.hasMoreTokens ()) {
        String queryToken = queryTokenizer.nextToken();
        if (queryToken.startsWith("c")) {
          motor.setCurrentPosition(int(getValueOfToken(queryToken, 1)));
        } else if (queryToken.startsWith("t")) {
          int targetPosition = int(getValueOfToken(queryToken, 1));
          motor.setTargetPosition(targetPosition);
        } else if (queryToken.startsWith("s")) {
          float currentSpeed = getValueOfToken(queryToken, 1);
          motor.setCurrentSpeed(currentSpeed);
        }
      }
    }
  }
}

float getValueOfToken(String token, int position) {
  String value = token.substring(position);
  try {
    //return Integer.valueOf(value);
    return Float.valueOf(value);
  } catch (NumberFormatException e) {
    println("Unable to decode '"+value+"'of '"+token+"' !");
    return 0;
  }
}
