#define INPUT_BUFFER_LENGTH 32

#define SERIAL_SPEED 9600

char inputBuffer[INPUT_BUFFER_LENGTH+1]; //ad on character to keep the trainling 0
unsigned char inputBufferPosition;

void startSerial() {
  Serial.begin(SERIAL_SPEED);
  Serial.println(F("============================"));
  Serial.println(F("Underwater"));
  Serial.println(F("============================"));  

  //empty the input buffer
  for (unsigned char i=0; i< INPUT_BUFFER_LENGTH+1; i++) {
    inputBuffer[i]=0;
  }
  inputBufferPosition=0;
}

void loopSerial() {
  if (Serial.available() > 0 && inputBufferPosition < INPUT_BUFFER_LENGTH) {
    char c = Serial.read();
    //Read the char
    inputBuffer[inputBufferPosition] = c;
    inputBufferPosition++;
    //always terminate the string
    inputBuffer[inputBufferPosition] = 0;
    //and if the line ended we execute the command
    if (c=='\n') {
      executeSerialCommand();   
    }
  }
  
  // Write stepper status.
  // c = current position
  // t = target position
  for (int i = 0; i < STEPPER_COUNT; i++) {
    if (steppers[i].currentPosition() == steppers[i].targetPosition()) {
      if (statusReported[i] != true) {
        executeQuery(i);
        // Update status reported to avoid sending the same command multiple times.
        statusReported[i] = true;
      }
    } else {
      statusReported[i] = false;
    }
  }
}

// Execture a command sent over serial.
// Contract;
//   m[motor_index][command][value]
// Commands
//   t = set new target position for the motor.
//   r = reset the current position of the motor.
//   q = query the status of current and target position.
// m0m600
void executeSerialCommand() {
  Serial.print("Executing ");
  Serial.println(inputBuffer);

  switch(inputBuffer[0]) {
    case 'm':
      //int motorIndex = int(inputBuffer[1]);
      int motorIndex = decode(1);
      switch(inputBuffer[2]) {
        case 't':
          {
            int value = decode(3);
            steppers[motorIndex].moveTo(value);
          }
          break;
        case 'r':
          {
            int value = decode(3);
            steppers[motorIndex].setCurrentPosition(value);
            // TODO: Might need to set speed again.
          }
          break;
        case 'q':
          executeQuery(motorIndex);
          break;
      }
      break;
  }

  // Clear the buffer.
  inputBufferPosition=0;
  inputBuffer[0]=0;
}

int decode(unsigned char startPosition) {
  int result=0;
  boolean negative = false;
  if (inputBuffer[startPosition]=='-') {
    negative=true;
    startPosition++;
  }
  for (unsigned char i=startPosition; i< (INPUT_BUFFER_LENGTH+1) && inputBuffer[i]!=0; i++) {
    char number = inputBuffer[i];
    if (number <= '9' && number >='0') {
      result *= 10;
      result += number - '0';
    } else {
      break;
    }
  }
  if (negative) {
    return -result;
  } 
  else {
    return result;
  }
}

void executeQuery(int motorIndex) {
  Serial.print('m');
  Serial.print(motorIndex, DEC);
  Serial.print('q');
  Serial.print('c');
  Serial.print(steppers[motorIndex].currentPosition());
  Serial.print(',');
  Serial.print('t');
  Serial.print(steppers[motorIndex].targetPosition());
  Serial.print(',');
  Serial.println();
}

