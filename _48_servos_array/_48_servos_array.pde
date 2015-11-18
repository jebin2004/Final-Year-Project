#include <Servo.h>



// define global variables
#define howmanyservos 48                                                                         // constant - how many servos to control from 1 to 48
int uSmin=1000;                                                                                  // minimum servo position in uS - adjust this value to suit your brand of servo.
int uSmax=2000;                                                                                  // maximum servo position in uS - adjust this value to suit your brand of servo.
int servoposition[howmanyservos];                                                                // this array stores the current position of each servo in uS (typically 1000 - 2000 uS)
int servodirection[howmanyservos];                                                               // this array stores the speed and direction of each servo

// define servos
Servo servo[howmanyservos];                                                                      // define servos as an array for easy control


void setup()
{
  for (int i=0;i<howmanyservos;i++)                                                              // loop to initialize servos and arrays                            
  {  
    servoposition[i]=1500;                                                                       // start all servos at the center position
    servodirection[i]=20-i;                                                                      // each servo will start at a different speed and or direction
    servo[i].attach(53-i,uSmin,uSmax);                                                           // initialize servos starting at D53 and counting backward (limit travel between uSmin & uSmax)
    servo[i].writeMicroseconds(1500);                                                            // set servos to center position
    delay(25);                                                                                   // delay limits power surge by initializing the servos one at a time.
  }
}

void loop()
{
  for (int i=0;i<howmanyservos;i++)                                                              // loop to update servo positions  
  {
    servoposition[i]+=servodirection[i];                                                         // calculate new servo position 
    if (servoposition[i]>uSmax || servoposition[i]<uSmin) servodirection[i]=-servodirection[i];  // reverse direction when limits are met.
    servo[i].writeMicroseconds(servoposition[i]);                                                // update servo to new position
  }
  delay(25);
}
