#include <Servo.h>                                         // include the servo library 
Servo sv[24];                                              // declare your servo variable as an array

void setup()
{
  pinMode(12,OUTPUT);                                      // pin 12 used to turn on/off servo power
  digitalWrite(12,1);                                      // power up servos - servos remain dead until they are initialized and receive a signal
  
  for (int i=0;i<24;i++)                               
  {
    sv[i].attach(i+26);                                    // initialize 24 servos on digital pins 26 to 49
    sv[i].writeMicroseconds(1500);                         // set servos to center position
    delay(50);                                             // delay limits power surge by initializing the servos one at a time.
  }
}

void loop()
{
  
}
