    #include <stdio.h>   /* Standard input/output definitions */
    #include <string.h>  /* String function definitions */
    #include <unistd.h>  /* UNIX standard function definitions */
    #include <fcntl.h>   /* File control definitions */
    #include <errno.h>   /* Error number definitions */
    #include <termios.h> /* POSIX terminal control definitions */

    /*
     * 'open_port()' - Open serial port 1.
     *
     * Returns the file descriptor on success or -1 on error.
     */

    int
    open_port(void)
    {
      int fd; /* File descriptor for the port */


      fd = open("/dev/ttyAMA0", O_RDWR | O_NOCTTY | O_NDELAY);
      if (fd == -1)
      {
       /*
        * Could not open the port.
        */

        perror("open_port: Unable to open /dev/ttyS0 - ");
      }
      else
        fcntl(fd, F_SETFL, 0);

      return (fd);
    }

void change_bps(int fd, int bps)
{
    struct termios options;

    /*
     * Get the current options for the port...
     */

    tcgetattr(fd, &options);


    /*
     * Set the baud rates to ...
     */

    switch(bps)
    {
      case 0:
        cfsetispeed(&options, B9600);
        cfsetospeed(&options, B9600);
        break;
      case 1:
        cfsetispeed(&options, B19200);
        cfsetospeed(&options, B19200);
        break;
    }

    /*
     * Enable the receiver and set local mode...
     */

    options.c_cflag |= (CLOCAL | CREAD);

    /*
     * Set the new options for the port...
     */

   //TCSADRAIN important, otherwise data on it's way
   //out to card is lost!

    tcsetattr(fd, TCSADRAIN, &options);


}


void main(void)
{
    int fd = open_port();

    change_bps(fd, 0);   // Set serial port to 9600 bps
    write(fd, "st\r", 3);  // Start servo test
    sleep(5);

    write(fd, "sbr 1\r", 6);  // Tell servo board to change to 19200 bps (still on 9600)
    // An ACK is received at 9600 bps, but we don't care for it :)
    change_bps(fd ,1);   // Change serial port settings to 19200 bps

    write(fd, "serr\r", 5);  // Stop servo test, sent at 19200 bps

    // Without the below line, we will not be able to talk to the board
    // next time we start since the servo board will still think we are at 19600.
    write(fd, "sbr 0\r", 6);  // Tell servo board to go back to 9600

}

