; ******************************************* 
; ** 64 Channel Serial Servo Controller    **
; **           For ATMega168               **
; **            Version 7.0                **
; **                                       **
; **     Copyright (c) November 2009       **
; **             Len Holgate               **
; **                                       **
; ** See http://www.lhexapod.com           **
; **                                       **
; ** Note that this controller assumes     **
; ** that we have CD74HCT238E or equivalent**
; ** demultiplexor chips connected to pins **
; ** 0-4 of Ports B and C and that the     **
; ** required address lines for these MUXs **
; ** are run from pins 2-4 of PortD.       **
; ** See website for a schematic.          **
; *******************************************
;



; Serial protocol handling..

; The serial handling code can be interrupted at any time by the PWM generation code.
; We never turn off interrupts, so any two instructions in the serial handling code 
; could be separated by the PWM code running. Because of this we need to be careful
; about how we update the PWM configuration data. The PWM code will ONLY act on the 
; PWM configuration data for a servo if the stepEvery value is non zero. If the
; stepEvery value IS zero then only the currentPos will be used - and the PWM code
; will generate a signal for the specified current position. The servo is stationary.
; Before changing anything else the serial code should always set the stepEvery
; value to 0. This means that it can safely change the currentPos, targetPos and 
; stepSize and then change the stepEvery value to a non zero value for these other
; values to take affect. Immediate moves only involve changing the currentPos and
; these take effect immediately, delayed moves require the currentPos, targetPos, 
; stepSize and stepEvery to be changed and by observing the protocol detailed above
; these four values can be changed atomically with respect to what the PWM generation
; code will see.

; The serial code loops and accumulates a number of bytes into a complete command.
; Once a command is complete we process it, send any results and loop back to 
; accumulate another command. Each time through the byte accumulation loop that
; begins at SerialLoop we check the movesComplete register which is set by the PWM
; code. If this is non-zero then we send any delayed move completion notifications
; that need sending.

; Each command starts with a known byte. Most commands are of a fixed length though
; some can be variable length. Even variable length commands are treated like fixed
; length commands to start with; the fixed portion of their length being the part up
; to the length indicator embedded in the command. All commands consist of an initial,
; unique, command byte. Once we have this byte we can determine the length of the
; fixed part of the command. If we don't recognise the command code then we return
; an error.

; Note that all successful commands are echoed back to the caller. Invalid parameters
; are indicated by an error in the form 0xFF <bad param index> <command echo> where
; bad param index is a 1 based index into the parameters in the echoed command and
; indicates the first parameter that failed validation.

; Some commands, Stop and Query commands for example, also cause a notification to be
; returned once the command has been executed, these should be treated as asynchronous
; messages, though, in fact, they are guarenteed to occur immediately after the command
; echo completes.

SerialStart :

    ; we start with a zero command length, we're waiting for a command byte to work
    ; out how long the command will be...

    clr sCommandLength
    clr sExpectedBytes

SerialLoop :

    tst movesComplete                           ; check to see if we have any incremental
    breq SerialLoop1                            ; move completion notifications to send

    rcall SerialSendMoveCompleteNotification    ; send them...

SerialLoop1 : 

    lds temp1, UCSR0A
    sbrs temp1, RXC0
    rjmp SerialLoop

    sbrc temp1, DOR0
    rjmp SerialDataOverrunDetected 

    lds serialChar, UDR0                        ; read the character

    tst sExpectedBytes                          ; are we already accumulating a command?
    breq PC+2
    rjmp SerialDataCharacter

    ; new command to accumulate?

    ldi XL, LOW(SERIAL_DATA_START)              ; new command, set pointer to buffer start
    ldi XH, HIGH(SERIAL_DATA_START)

    ; is the command byte valid??

    ; calculate the length of data required for valid commands...

    cpi serialChar, 0x00
    brne PC+2
    rjmp SerialSetCommandLengthGetInfo

    cpi serialChar, 0x01
    brne PC+2
    rjmp SerialSetCommandLengthEnablePWM

    cpi serialChar, 0x02
    brne PC+2
    rjmp SerialSetCommandLengthDisablePWM

    cpi serialChar, 0x03
    brne PC+2
    rjmp SerialSetCommandLengthReset

    cpi serialChar, 0x04
    brne PC+2
    rjmp SerialSetCommandLengthSaveSettings

    cpi serialChar, 0x05
    brne PC+2
    rjmp SerialSetCommandLengthSetConfigValue

    cpi serialChar, 0x06
    brne PC+2
    rjmp SerialSetCommandLengthSetServoMinPosn

    cpi serialChar, 0x07
    brne PC+2
    rjmp SerialSetCommandLengthSetServoMaxPosn

    cpi serialChar, 0x08
    brne PC+2
    rjmp SerialSetCommandLengthSetServoCentrePosn

    cpi serialChar, 0x09
    brne PC+2
    rjmp SerialSetCommandLengthSetServoInitialPosn

    cpi serialChar, 0x41
    brne PC+2
    rjmp SerialSetCommandLengthSetPosn

    cpi serialChar, 0x42
    brne PC+2
    rjmp SerialSetCommandLengthSetDelayPosn

    cpi serialChar, 0x43
    brne PC+2
    rjmp SerialSetCommandLengthSetDelayPosn2

    cpi serialChar, 0x44
    brne PC+2
    rjmp SerialSetCommandLengthStopServo

    cpi serialChar, 0x45
    brne PC+2
    rjmp SerialSetCommandLengthStopServos

    cpi serialChar, 0x46
    brne PC+2
    rjmp SerialSetCommandLengthStopAll

    cpi serialChar, 0x47
    brne PC+2
    rjmp SerialSetCommandLengthQueryServo

    cpi serialChar, 0x48
    brne PC+2
    rjmp SerialSetCommandLengthQueryServos

    cpi serialChar, 0x49
    brne PC+2
    rjmp SerialSetCommandLengthQueryAll

    cpi serialChar, 0x50
    brne PC+2
    rjmp SerialSetCommandLengthSetMultipleServoPosn

    cpi serialChar, 0x51
    brne PC+2
    rjmp SerialSetCommandLengthSetMultipleServoPosn2

    cpi serialChar, 0x52
    brne PC+2
    rjmp SerialSetCommandLengthSetMultipleServoPosn3

    ; return an error for unrecognised commands...

    rjmp SerialError

SerialDataOverrunDetected :

    lds serialChar, UDR0            ; read and discard the character

    cbr temp1,  DOR0 
    sts UCSR0A, temp1

    clr sExpectedBytes

    ldi serialChar, 0xF0            ; overrun detected. All data discarded...
    rcall SendSerial

    rjmp SerialLoop

SerialDataCharacter :

    ldi temp1, HIGH(SERIAL_DATA_END)            ; check for buffer overruns...
    cp temp1, XH
    brge PC+2
    rjmp SerialError

    cpi XL, LOW(SERIAL_DATA_END)                ; if we have already filled our buffer space 
    brne PC+2
    rjmp SerialError                            ; that's an error

    st X+, serialChar

    dec sExpectedBytes
    
    tst sExpectedBytes                          ; if we have accumulated the expected number of bytes
    breq SerialProcessCommand                   ; process the command

    rjmp SerialLoop


; Determine the length of the fixed portion of the commands.

SerialSetCommandLengthSetDelayPosn2 :

    ldi temp1, 5
    mov sExpectedBytes, temp1
    mov sCommandLength, temp1

    rjmp SerialDataCharacter

SerialSetCommandLengthSetDelayPosn :

    ldi temp1, 4
    mov sExpectedBytes, temp1
    mov sCommandLength, temp1

    rjmp SerialDataCharacter

SerialSetCommandLengthSetPosn :
SerialSetCommandLengthSetConfigValue : 
SerialSetCommandLengthSetServoMinPosn :
SerialSetCommandLengthSetServoMaxPosn : 
SerialSetCommandLengthSetServoCentrePosn : 
SerialSetCommandLengthSetServoInitialPosn : 

    ldi temp1, 3
    mov sExpectedBytes, temp1
    mov sCommandLength, temp1

    rjmp SerialDataCharacter

SerialSetCommandLengthStopServo :
SerialSetCommandLengthQueryServo :
SerialSetCommandLengthStopServos :              ; This is a variable length command with a two byte header
SerialSetCommandLengthQueryServos :             ; This is a variable length command with a two byte header  
SerialSetCommandLengthSetMultipleServoPosn :    ; This is a variable length command with a two byte header       
SerialSetCommandLengthSetMultipleServoPosn2 :   ; This is a variable length command with a two byte header  
SerialSetCommandLengthSetMultipleServoPosn3 :   ; This is a variable length command with a two byte header  

    ldi temp1, 2
    mov sExpectedBytes, temp1
    mov sCommandLength, temp1

    rjmp SerialDataCharacter

SerialSetCommandLengthGetInfo :
SerialSetCommandLengthEnablePWM :
SerialSetCommandLengthDisablePWM :  
SerialSetCommandLengthSaveSettings : 
SerialSetCommandLengthReset :
SerialSetCommandLengthStopAll :
SerialSetCommandLengthQueryAll :

    ldi temp1, 1
    mov sExpectedBytes, temp1
    mov sCommandLength, temp1

    rjmp SerialDataCharacter


; process the command...

SerialProcessCommand :

    ; we have an 'x' byte serial command...

    ldi XL, LOW(SERIAL_DATA_START)       
    ldi XH, HIGH(SERIAL_DATA_START)

    ld temp1, X+                                ; get the command byte...

    cpi temp1, 0x00
    brne PC+2
    rjmp SerialProcessCommandGetInfo

    cpi temp1, 0x01
    brne PC+2
    rjmp SerialProcessCommandEnablePWM

    cpi temp1, 0x02
    brne PC+2
    rjmp SerialProcessCommandDisablePWM

    cpi temp1, 0x03
    brne PC+2
    rjmp SerialProcessCommandReset

    cpi temp1, 0x04
    brne PC+2
    rjmp SerialProcessCommandSaveSettings

    cpi temp1, 0x05
    brne PC+2
    rjmp SerialProcessCommandSetConfigValue

    cpi temp1, 0x06
    brne PC+2
    rjmp SerialProcessCommandSetServoMinPosn

    cpi temp1, 0x07
    brne PC+2
    rjmp SerialProcessCommandSetServoMaxPosn

    cpi temp1, 0x08
    brne PC+2
    rjmp SerialProcessCommandSetServoCentrePosn

    cpi temp1, 0x09
    brne PC+2
    rjmp SerialProcessCommandSetServoInitialPosn

    cpi temp1, 0x41
    brne PC+2
    rjmp SerialProcessCommandSetPosn   

    cpi temp1, 0x42
    brne PC+2
    rjmp SerialProcessCommandSetDelayPosn

    cpi temp1, 0x43
    brne PC+2
    rjmp SerialProcessCommandSetDelayPosn2

    cpi temp1, 0x44
    brne PC+2
    rjmp SerialProcessCommandStopServo

    cpi temp1, 0x45
    brne PC+2
    rjmp SerialProcessCommandStopServos

    cpi temp1, 0x46
    brne PC+2
    rjmp SerialProcessCommandStopAll

    cpi temp1, 0x47
    brne PC+2
    rjmp SerialProcessCommandQueryServo

    cpi temp1, 0x48
    brne PC+2
    rjmp SerialProcessCommandQueryServos

    cpi temp1, 0x49
    brne PC+2
    rjmp SerialProcessCommandQueryAll

    cpi temp1, 0x50
    brne PC+2
    rjmp SerialProcessCommandSetMultipleServoPosn

    cpi temp1, 0x51
    brne PC+2
    rjmp SerialProcessCommandSetMultipleServoPosn2

    cpi temp1, 0x52
    brne PC+2
    rjmp SerialProcessCommandSetMultipleServoPosn3

    rjmp SerialError


SerialSendDebug : 

    push serialChar

    ldi serialChar, 0x99
    rcall SendSerial

    pop serialChar
    rcall SendSerial

    ret

; Echoes the command in the serial command accumulation buffer
; back to the client.

SerialEchoCommand :

    ; echo the command back to the sender...

    mov sExpectedBytes, sCommandLength

    ldi XL, LOW(SERIAL_DATA_START)        
    ldi XH, HIGH(SERIAL_DATA_START)

SerialEchoCommandSendNextByte :

    ld serialChar, X+ 
    rcall SendSerial

    dec sExpectedBytes

    tst sExpectedBytes
    brne SerialEchoCommandSendNextByte

    ret

; Sets up temp2 for parameter out of range errors.

SerialServoListElementOutOfRange : 

    ldi temp2, 1                    ; add one for the command length...
    add temp2, temp1 

    rjmp SerialParamOutOfRange 

SerialParam1OutOfRange : 
SerialServoOutOfRange :   

    ldi temp2, 1                    ; index of the bad parameter

    rjmp SerialParamOutOfRange 

SerialParam2OutOfRange : 
SerialPosnOutOfRange:   

    ldi temp2, 2                    ; index of the bad parameter

    rjmp SerialParamOutOfRange 

SerialStepSizeOutOfRange : 

    ldi temp2, 3                    ; index of the bad parameter

    rjmp SerialParamOutOfRange 

SerialStepEveryOutOfRange : 

    ldi temp2, 4                    ; index of the bad parameter

    rjmp SerialParamOutOfRange 


; Sends a parameter out of range error; 0xFF <param> <command echo>
; where <param> is a 1 based index into the parameters in the command
; that indicates which parameter is invalid.

SerialParamOutOfRange : 

    ; send the error message back to the sender...

    ldi serialChar, 0xFF            ; command error response
    rcall SendSerial

    mov serialChar, temp2           ; index of parameter that is out of range
    rcall SendSerial

    rcall SerialEchoCommand         ; the command...

    rjmp SerialStart

; same as above, but returns to caller rather than jumping back to command accumulation

SerialParamOutOfRangeFnc :

    ; send the error message back to the sender...

    ldi serialChar, 0xFF            ; command error response
    rcall SendSerial

    mov serialChar, temp2           ; index of parameter that is out of range
    rcall SendSerial

    rcall SerialEchoCommand         ; the command...

    ret

; Sends a serial error, which is simply a parameter out of range error
; with a parameter index of 0. 

SerialError :

    ; we could light a led and only unlight it on valid data...


    ldi temp2, 1                    ; 1 byte of command data to echo...
    mov sCommandLength, temp2

    ldi temp2, 0                    ; index of the bad parameter


    rjmp SerialParamOutOfRange 
