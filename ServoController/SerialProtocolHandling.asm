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



SerialProcessCommandGetInfo : 

    ; send back version major/minor then number of servos supported

    ldi serialChar, 0x00
    rcall SendSerial

    ldi serialChar, 0x07
    rcall SendSerial

    ldi serialChar, 0x00
    rcall SendSerial

    ldi serialChar, NUM_SERVOS
    rcall SendSerial

    ldi XL, LOW(CONFIG_DATA_START) 
    ldi XH, HIGH(CONFIG_DATA_START)

    ld serialChar, X+                  ; pwm on after reset              
    rcall SendSerial

    ld serialChar, X+                  ; send controller active 
    rcall SendSerial

    ld serialChar, X+                  ; servo out of range active
    rcall SendSerial

    ld serialChar, X+                  ; pwm currently active
    rcall SendSerial

    rjmp SerialStart


SerialProcessCommandEnablePWM : 

    ldi XL, LOW(CONFIG_DATA_PWM_CURRENTLY_ACTIVE) 
    ldi XH, HIGH(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)

    ld temp1, X

    rcall SerialEchoCommand

    tst temp1                   ; skip if already enabled
    brne PC+2
    rcall InitialisePWMOutput

    rjmp SerialStart


SerialProcessCommandDisablePWM : 

    ldi XL, LOW(CONFIG_DATA_PWM_CURRENTLY_ACTIVE) 
    ldi XH, HIGH(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)

    ld temp1, X

    rcall SerialEchoCommand

    tst temp1                   ; skip if already disabled
    breq PC+2
    rcall DisablePWMOutput

    rjmp SerialStart


SerialProcessCommandReset : 

    rcall SerialEchoCommand

    rcall WaitForSerialSendComplete

    rcall DisablePWMOutput

    rjmp Init


SerialProcessCommandSaveSettings : 

    ldi XL, LOW(CONFIG_DATA_PWM_CURRENTLY_ACTIVE) 
    ldi XH, HIGH(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)

    ld temp1, X

    tst temp1                       ; if PWM enabled, error
    breq SerialProcessCommandSaveSettingsSave

    ldi temp2, 0xFF                 ; index of the bad parameter

    rjmp SerialParamOutOfRange 

SerialProcessCommandSaveSettingsSave :

    rcall SerialEchoCommand

    rcall SaveServoData
    
    rjmp SerialStart



SerialProcessCommandSetConfigValue : 

    ld temp1, X+           ; setting to change

    cpi temp1, 0x03
    brlo SerialProcessCommandSetConfigValueValidateValue

    rjmp SerialParam1OutOfRange 

SerialProcessCommandSetConfigValueValidateValue : 

    ld temp2, X             ; value of setting

    cpi temp2, 0x02
    brlo SerialProcessCommandSetConfigValueExecute

    rjmp SerialParam2OutOfRange 

SerialProcessCommandSetConfigValueExecute : 

    ldi XL, LOW(CONFIG_DATA_START) 
    ldi XH, HIGH(CONFIG_DATA_START)

    add XL, temp1
    clr temp1
    adc XH, temp1

    st X, temp2

    rcall SerialEchoCommand
    
    rjmp SerialStart


SerialProcessCommandSetServoMinPosn : 

    ld servoIndex, X+

    cpi servoIndex, NUM_SERVOS                  ; check the servo index is valid
    brlt PC+2
    rjmp SerialServoOutOfRange

    ld temp1, X                                 ; load new min posn

    rcall SerialSelectServoData

    adiw XL, MAX_POS_OFFSET

    ld temp2, X                                 ; read existing max position

    cp temp2, temp1                             ; new min must be less than 
    brsh PC+2                                   ; or equal to exisiting max
    rjmp SerialPosnOutOfRange 

    sbiw XL, MAX_POS_OFFSET
    adiw XL, MIN_POS_OFFSET

    st X, temp1
        
    rcall SerialEchoCommand
    
    rjmp SerialStart


SerialProcessCommandSetServoMaxPosn : 

    ld servoIndex, X+

    cpi servoIndex, NUM_SERVOS                  ; check the servo index is valid
    brlt PC+2
    rjmp SerialServoOutOfRange

    ld temp1, X                                 ; load new max posn

    cpi temp1, 0xFF                             ; max can't be 0xFF as that's illegal....
    brne PC+2
    rjmp SerialPosnOutOfRange 

    rcall SerialSelectServoData

    adiw XL, MIN_POS_OFFSET

    ld temp2, X                                 ; read existing min position

    cp temp1, temp2                             ; new max must be same or higher than exisiting min
    brsh PC+2
    rjmp SerialPosnOutOfRange 

    sbiw XL, MIN_POS_OFFSET
    adiw XL, MAX_POS_OFFSET

    st X, temp1
        
    rcall SerialEchoCommand
    
    rjmp SerialStart


SerialProcessCommandSetServoCentrePosn : 

    ld servoIndex, X+

    cpi servoIndex, NUM_SERVOS                  ; check the servo index is valid
    brlt PC+2
    rjmp SerialServoOutOfRange

    ld temp1, X                                 ; load new centre posn

    cpi temp1, 0xFF                             ; posn can't be 0xFF as that's illegal....
    brne PC+2
    rjmp SerialPosnOutOfRange 

    rcall SerialSelectServoData

    adiw XL, CENTRE_ADJUST_OFFSET

    st X, temp1

    rcall SerialEchoCommand
    
    rjmp SerialStart


SerialProcessCommandSetServoInitialPosn :

    ld servoIndex, X+

    cpi servoIndex, NUM_SERVOS                  ; check the servo index is valid
    brlt PC+2
    rjmp SerialServoOutOfRange

    ld temp1, X                                 ; load new initial posn

    cpi temp1, 0xFF                             ; posn can't be 0xFF as that's illegal....
    brne PC+2
    rjmp SerialPosnOutOfRange 

    ldi XL, LOW(SRAM_DEFAULT_POSITION_TABLE_START)      ; set up destination address
    ldi XH, HIGH(SRAM_DEFAULT_POSITION_TABLE_START)

    clr temp2
    
    add XL, servoIndex
    adc XH, temp2

    st X, temp1                                 ; save the new initial position
    
    rcall SerialEchoCommand
    
    rjmp SerialStart

; Set Servo Position.
; 0x41 <servo> <posn>
; This command is the same as the SSC 0xFF <servo> <posn> command. We set the
; specified servo to the specified position. The servo must be in the range 
; 0 - NUM_SERVOS and the position must be in the range 0 - 0xFE. We validate
; the parameters and send an error message if any are out of bounds.
; Since we could be setting a position when a delayed move is in progress we
; MUST set stepEvery to 0 before updating currentPos. Once stepEvery is 0
; we can update currentPos to the new desired servo position and then set 
; the other delayed move parameters to zero.

SerialProcessCommandSetPosn :

    ld servoIndex, X+

    cpi servoIndex, NUM_SERVOS                  ; check the servo index is valid
    brlt PC+2
    rjmp SerialServoOutOfRange

    ld targetPos, X

    ; we have a servo index 0-NUM_SERVOS in servoIndex
    ; we have a control value that needs validating in targetPos

    rcall SerialSelectServoData

    ldi temp1, 2                                    ; validating parameter 2
    rcall SerialValidateAndAdjustDesiredPosition
    tst temp1                                       ; if temp1 is non zero then we validated OK
    brne PC+2                                       ; else we've already sent the error report
    rjmp SerialStart                                ; so jump back to accumulate a new command


    // COULD ONLY DO THIS IF resh != original target pos...
    // to do that we'd need to store the original target pos as we may have adjusted it...
    
    push XL
    push XH

    ldi XL, LOW(SERIAL_DATA_START)        
    ldi XH, HIGH(SERIAL_DATA_START)

    adiw XL, 2          ; select the target pos in the serial input buffer...

    st X, resh          ; if the value was adjusted, store back the pre 'centre adjust' value for 
                        ; command echo

    pop XH
    pop XL   

    // end of only if !original

    adiw XL, 1          ; we must update the 'step every' value to 0 before changing anything else
                        ; or the PWM generation may get confused and use this data as part of a 
                        ; delayed move...
    clr temp2           

    st X, temp2        ; step every...

    sbiw XL, 1

    ; now update the whole data structure, we reset unused values to zero, we need only really set
    ; current position and step every...

    st X+, targetPos    ; current position
    st X+, temp2        ; step every...
    st X+, temp2        ; target position
    st X,  temp2        ; step size

    rcall SerialEchoCommand

    rjmp SerialStart


; Delayed Set Servo Position
; 0x42 <servo> <posn> <stepSize>
; Sets the servo to move from the current position to the specified position with the specified
; step size which increments each refresh of the PWM signal (that is, 20 times per second). 
; The servo must be in the range 0 - NUM_SERVOS and the position must be in the range 0 - 0xFE,
; the step size must be non zero. We validate the parameters and send an error message if any are 
; out of bounds.
; Since we're updating the multiple byte part of the servo control data we MUST set the stepEvery
; value to zero before we update anything else. Once that's done we update the targetPos and the
; stepSize. We then set the stepEvery value to 1 so that we step each cycle.

SerialProcessCommandSetDelayPosn :

    ld servoIndex, X+

    cpi servoIndex, NUM_SERVOS                  ; check the servo index is valid
    brlt PC+2
    rjmp SerialServoOutOfRange

    ld temp2, X+
    cpi temp2, 0xFF                             ; check the servo position is valid
    brne PC+2
    rjmp SerialPosnOutOfRange

    mov targetPos, temp2

    ld temp1, X+
    tst temp1                                   ; check the step size is valid
    brne PC+2
    rjmp SerialStepSizeOutOfRange

    ; we have a servo index 0-NUM_SERVOS in servoIndex
    ; we have a control value 0-254 in targetPos
    ; we have a step size in temp1

    rcall SerialSelectServoData

    push temp1
    ldi temp1, 2                                    ; validating parameter 2

    rcall SerialValidateAndAdjustDesiredPosition
    mov temp2, temp1                                ; save return value
    pop temp1                                       ; clean stack...
    tst temp2                                       ; if return value is non zero then we validated OK
    brne PC+2                                       ; else we've already sent the error report
    rjmp SerialStart                                ; so jump back to accumulate a new command

    // COULD ONLY DO THIS IF resh != original target pos...
    
    push XL
    push XH

    ldi XL, LOW(SERIAL_DATA_START)        
    ldi XH, HIGH(SERIAL_DATA_START)

    adiw XL, 2          ; select the target pos in the serial input buffer...

    st X, resh          ; if the value was adjusted, store back the pre 'centre adjust' value for 
                        ; command echo

    pop XH
    pop XL   

    // end of only if !original



    adiw XL, 1          ; we must update the 'step every' value to 0 before changing anything else
                        ; or the PWM generation may get confused and use this data as part of a 
                        ; delayed move...
    clr temp2           

    st X+, temp2         ; step every...

    ; now update the rest of the data structure for a delayed move
    
    st X+, targetPos    ; target position (where we want to move to)
    st X, temp1         ; step size

    sbiw XL, 2          ; move back to the 'step every' part of the data structure

    ldi temp2, 1

    st X, temp2         ; step every cycle...

    rcall SerialEchoCommand

    rjmp SerialStart


; Delayed Set Servo Position with step frequency
; 0x42 <servo> <posn> <stepSize> <stepEvery>
; Sets the servo to move from the current position to the specified position with the specified
; step size which increments at the specified frequency of the PWM signal (that is a value of 1
; steps 20 times per second, a value of 2 steps 10 times per second, a value of 20 once per second, 
; etc). The servo must be in the range 0 - NUM_SERVOS and the position must be in the range 
; 0 - 0xFE, the step size and the step frequency must be non zero. We validate the parameters and 
; send an error message if any are out of bounds.
; Since we're updating the multiple byte part of the servo control data we MUST set the stepEvery
; value to zero before we update anything else. Once that's done we update the targetPos and the
; stepSize. We then set the stepEvery value to the desired step frequency.

SerialProcessCommandSetDelayPosn2 :

    ld servoIndex, X+

    cpi servoIndex, NUM_SERVOS                  ; check the servo index is valid
    brlt PC+2
    rjmp SerialServoOutOfRange

    ld temp2, X+
    cpi temp2, 0xFF                             ; check the servo position is valid
    brne PC+2
    rjmp SerialPosnOutOfRange

    mov targetPos, temp2

    ld temp1, X+
    tst temp1                                   ; check the step size is valid
    brne PC+2
    rjmp SerialStepSizeOutOfRange

    ld stepEvery, X+
    tst stepEvery                              ; check the step frequency is valid
    brne PC+2
    rjmp SerialStepEveryOutOfRange

    ; we have a servo index 0-NUM_SERVOS in servoIndex
    ; we have a control value 0-254 in targetPos
    ; we have a step size in temp1
    ; we have a step frequency in stepEvery

    rcall SerialSelectServoData

    push temp1
    ldi temp1, 2                                    ; validating parameter 2
    rcall SerialValidateAndAdjustDesiredPosition
    mov temp2, temp1                                ; save return value
    pop temp1                                       ; clean stack...
    tst temp2                                       ; if return value is non zero then we validated OK
    brne PC+2                                       ; else we've already sent the error report
    rjmp SerialStart                                ; so jump back to accumulate a new command



    // COULD ONLY DO THIS IF resh != original target pos...
    
    push XL
    push XH

    ldi XL, LOW(SERIAL_DATA_START)        
    ldi XH, HIGH(SERIAL_DATA_START)

    adiw XL, 2          ; select the target pos in the serial input buffer...

    st X, resh          ; if the value was adjusted, store back the pre 'centre adjust' value for 
                        ; command echo

    pop XH
    pop XL   

    // end of only if !original


    adiw XL, 1          ; we must update the 'step every' value to 0 before changing anything else
                        ; or the PWM generation may get confused and use this data as part of a 
                        ; delayed move...
    clr temp2           

    st X+, temp2         ; step every...

    ; now update the rest of the data structure for a delayed move
    
    st X+, targetPos    ; target position (where we want to move to)
    st X, temp1         ; step size

    sbiw XL, 2          ; move back to the 'step every' part of the data structure

    st X, stepEvery     ; step every cycle...

    rcall SerialEchoCommand

    rjmp SerialStart


; Servo Stop functions

; Stop Servo
; 0x43 <servo>
; Stops the specific servo and causes a servo stopped response to be returned (after the command echo). 
; The servo must be in the range 0 - NUM_SERVOS. We validate the parameters and send an error message 
; if any are out of bounds. Note that in addition to the command echo this command also generates a
; single stop notificiation message in the form: 
; 0xFD <servo> <currentPos> <stepEvery> <targetPos> <stepSize> 
; If the servo was not moving when the stop command was sent then the <stepEvery> value in the 
; notification will be 0.

SerialProcessCommandStopServo :

    ld servoIndex, X

    cpi servoIndex, NUM_SERVOS                  ; check the servo index is valid
    brlt PC+2
    rjmp SerialServoOutOfRange

    rcall SerialEchoCommand

    rcall SerialStopServo

    rjmp SerialStart

; Stop Servos
; 0x44 <numservos> <servo1> <servo2> ... <servoN>
; Stops all of the specified servos. This is a variable length command.
; The first thing we do is check to see if we've been called once already. The initial
; command accumulation code works with a fixed length of 2 bytes, enough for us to
; accumulate the length of the actual command. If the command length is currently 2 then
; we go off to calculate the real length and continue to accumulate more data until we
; have a complete command.
; Once we have a complete command we loop over all of the servos and validate them. 
; this allows us to send the command echo, or error before we start to send 
; servo stop notifications.
; Finally we loop over the servos again and stop each one and send the appropriate
; notification

SerialProcessCommandStopServos :

    ; sCommandLength == 2 then our command length is actually
    ; 2 + value of length byte, else we're complete...

    ldi temp1, 2

    cp sCommandLength, temp1
    breq SerialProcessCommandStopServosSetRealLength

    ld temp1, X+                                            ; number of servos to process...

SerialProcessCommandStopServosValidationLoop :

    tst temp1                                               ; it's valid, though unusual, to have 0 servos...
    breq SerialProcessCommandStopServosValidationLoopEnd

    ld servoIndex, X+

    cpi servoIndex, NUM_SERVOS                              ; check the servo index is valid
    brlt SerialProcessCommandStopServosValidationLoopNext
    
    ; temp2 needs to hold the index of the servo parameter that's out of range...
    
    mov temp2, sCommandLength

    sub temp2, temp1            ; calculate the param position of this servo index

    rjmp SerialParamOutOfRange


SerialProcessCommandStopServosValidationLoopNext :

    dec temp1

    rjmp SerialProcessCommandStopServosValidationLoop

SerialProcessCommandStopServosValidationLoopEnd :

    rcall SerialEchoCommand

    ; now process the command... 

    ldi XL, LOW(SERIAL_DATA_START)                          ; back to the start of the buffer
    ldi XH, HIGH(SERIAL_DATA_START)

    ld temp1, X+                                            ; throw away the command code...

    ld temp2, X+                                            ; number of servos to process...
    
SerialProcessCommandStopServosActionLoop :

    tst temp2                                               ; it's valid, though unusual, to have 0 servos...
    breq SerialProcessCommandStopServosActionLoopEnd

    ld servoIndex, X+

    rcall SerialStopServo

    dec temp2

    rjmp SerialProcessCommandStopServosActionLoop

SerialProcessCommandStopServosActionLoopEnd :

    rjmp SerialStart

SerialProcessCommandStopServosSetRealLength : 

    ; the stop servos command is in the form <cmd><length><servo><servo><servo>....
    ; where there are 'length' servo indexes after the length...
    ; the initial command length is set to 2, once we have 2 bytes we can work out
    ; the complete length...

    ld temp1, X+

    tst temp1                                           ; 0 is valid, though pointless!
    breq SerialProcessCommandStopServosValidationLoop

    ; a max number of servos we can process? 64 at a time?

    ldi temp2, NUM_SERVOS 
    cp temp1, temp2
    brlo PC+2
    rjmp SerialParam1OutOfRange

    mov sExpectedBytes, temp1

    ldi temp2, 2
    add temp1, temp2

    mov sCommandLength, temp1

    rjmp SerialLoop                                     ; back to the command accumulation loop!



; This function does the actual work of stopping a servo, also called from serial stop servos....
; Note that we first read the stepEvery value, then set it to zero to stop any further movement
; of the servo, we must then (and only then) read the currentPos of the servo as the PWM code
; will not change it once stepEvery is zero. 

SerialStopServo : 

    push XL
    push XH

    ; servo to stop is in servoIndex

    rcall SerialSelectServoData

    adiw XL, CURRENT_POS_OFFSET

    ld currentPos, X+
    ld stepEvery, X

    tst stepEvery
    breq SerialStopServoAlreadyStopped

    clr temp1                               ; zero the step every value to stop the servo
    st X, temp1

SerialStopServoAlreadyStopped : 

    sbiw XL, 1                              ; move back to the current pos as this is used
                                            ; in SerialSendStopResponse

    rcall SerialSendStopResponse

    pop XH
    pop XL

    ret

SerialStopServoNoNotificationIfAlreadyStopped : 

    push XL
    push XH

    ; servo to stop is in servoIndex

    rcall SerialSelectServoData

    adiw XL, CURRENT_POS_OFFSET

    ld currentPos, X+
    ld stepEvery, X

    tst stepEvery
    breq SerialStopServoNoNotificationIfAlreadyStoppedAlreadyStopped

    clr temp1                               ; zero the step every value to stop the servo
    st X, temp1

    sbiw XL, 1                              ; move back to the current pos as this is used
                                            ; in SerialSendStopResponse

    rcall SerialSendStopResponse

SerialStopServoNoNotificationIfAlreadyStoppedAlreadyStopped : 

    pop XH
    pop XL

    ret


; Stop All Servos
; 0x46 
; Stops all of the servos that the controller controls.

SerialProcessCommandStopAll :

    rcall SerialEchoCommand

    ldi XL, LOW(POSITION_DATA_START)       
    ldi XH, HIGH(POSITION_DATA_START)

    clr servoIndex

SerialStopAllServosLoop :

    adiw XL, CURRENT_POS_OFFSET

    ld currentPos, X+
    ld stepEvery, X

    tst stepEvery
    breq SerialStopAllServosLoopServoAlreadyStopped

    clr temp1                   ; zero the step every value to stop the servo
    st X, temp1

SerialStopAllServosLoopServoAlreadyStopped : 

    sbiw XL, 1                  ; move back to the current pos...

    rcall SerialSendStopResponse      

    adiw XL, 1                  ; step over the final member of the structure 
                                ; to the next record       

    inc servoIndex

    cpi servoIndex, NUM_SERVOS
    brne SerialStopAllServosLoop

    rjmp SerialStart


; Sends a servo stopped notification

SerialSendStopResponse :

    ld currentPos, X+              ; load current pos after we've set 'step every' to 0

    ldi serialChar, 0xFD
    rcall SendSerial
    
    mov serialChar, servoIndex      ; servo we stopped
    rcall SendSerial
    
    mov serialChar, currentPos      ; position it was in
    rcall SendSerial
    
    
    adiw XL, 1                      ; step the pointer over the 'step every' value

    mov serialChar, stepEvery       ; how often it steped before we stopped it
    rcall SendSerial

    ld temp1, X+                    ; target position

    mov serialChar, temp1           ; where it's moving too
    rcall SendSerial

    ld temp1, X+                    ; step size

    mov serialChar, temp1           ; the size of the step
    rcall SendSerial

    ret


; Query Servo Position
; 0x47 <servo>
; Queries the position of the specific servo and causes a servo query response to be returned 
; (after the command echo). 
; The servo must be in the range 0 - NUM_SERVOS. We validate the parameters and send an error message 
; if any are out of bounds. Note that in addition to the command echo this command also generates a
; single query notificiation message in the form: 
; 0xFC <servo> <currentPos> <stepEvery> <targetPos> <stepSize> 
; If the servo was not moving when the query command was sent then the <stepEvery> value in the 
; notification will be 0. If the <currentPos> and the <targetPos> are not equal and the <stepEvery> value
; is non-zero then the servo is moving.

SerialProcessCommandQueryServo :

    ld servoIndex, X

    cpi servoIndex, NUM_SERVOS                  ; check the servo index is valid
    brlt PC+2
    rjmp SerialServoOutOfRange

    rcall SerialEchoCommand

    rcall SerialQueryServo

    rjmp SerialStart


; Query Servos
; 0x48 <numservos> <servo1> <servo2> ... <servoN>
; Queries all of the specified servos. This is a variable length command.
; The first thing we do is check to see if we've been called once already. The initial
; command accumulation code works with a fixed length of 2 bytes, enough for us to
; accumulate the length of the actual command. If the command length is currently 2 then
; we go off to calculate the real length and continue to accumulate more data until we
; have a complete command.
; Once we have a complete command we loop over all of the servos and validate them. 
; this allows us to send the command echo, or error before we start to send 
; servo query notifications.
; Finally we loop over the servos again and query each one and send the appropriate
; notification

SerialProcessCommandQueryServos :

    ; sCommandLength == 2 then our command length is actually
    ; 2 + value of length byte, else we're complete...

    ldi temp1, 2

    cp sCommandLength, temp1
    breq SerialProcessCommandQueryServosSetRealLength

    ld temp1, X+                                            ; number of servos to process...

SerialProcessCommandQueryServosValidationLoop :

    tst temp1                                               ; it's valid, though unusual, to have 0 servos...
    breq SerialProcessCommandQueryServosValidationLoopEnd

    ld servoIndex, X+

    cpi servoIndex, NUM_SERVOS                              ; check the servo index is valid
    brlt SerialProcessCommandQueryServosValidationLoopNext

    ; temp2 needs to hold the index of the servo parameter that's out of range...
    
    mov temp2, sCommandLength

    sub temp2, temp1            ; calculate the param position of this servo index

    rjmp SerialParamOutOfRange

SerialProcessCommandQueryServosValidationLoopNext :

    dec temp1

    rjmp SerialProcessCommandQueryServosValidationLoop

SerialProcessCommandQueryServosValidationLoopEnd :

    rcall SerialEchoCommand

    ; now process the command... 

    ldi XL, LOW(SERIAL_DATA_START)                          ; back to the start of the buffer
    ldi XH, HIGH(SERIAL_DATA_START)

    ld temp1, X+                                            ; throw away the command code...

    ld temp2, X+                                            ; number of servos to process...
    
SerialProcessCommandQueryServosActionLoop :

    tst temp2                                               ; it's valid, though unusual, to have 0 servos...
    breq SerialProcessCommandQueryServosActionLoopEnd

    ld servoIndex, X+

    rcall SerialQueryServo

    dec temp2

    rjmp SerialProcessCommandQueryServosActionLoop

SerialProcessCommandQueryServosActionLoopEnd :

    rjmp SerialStart

SerialProcessCommandQueryServosSetRealLength : 

    ; the query servos command is in the form <cmd><length><servo><servo><servo>....
    ; where there are 'length' servo indexes after the length...
    ; the initial command length is set to 2, once we have 2 bytes we can work out
    ; the complete length...

    ld temp1, X+

    tst temp1                                           ; 0 is valid, though pointless!
    breq SerialProcessCommandQueryServosValidationLoop

    ; a max number of servos we can process? 64 at a time?

    ldi temp2, NUM_SERVOS 
    cp temp1, temp2
    brlo PC+2
    rjmp SerialParam1OutOfRange

    mov sExpectedBytes, temp1

    ldi temp2, 2
    add temp1, temp2

    mov sCommandLength, temp1

    rjmp SerialLoop                                     ; back to the command accumulation loop!


; This function does the actual work of querying a servo, also called from serial query servos....

SerialQueryServo :

    ; servo to query is in servoIndex

    push XL
    push XH

    rcall SerialSelectServoData

    rcall SendQueryResponse

    pop XH
    pop XL

    ret

; Query All Servos
; 0x49
; Queries all of the servos that the controller controls.

SerialProcessCommandQueryAll :

    rcall SerialEchoCommand

    ldi XL, LOW(POSITION_DATA_START)       
    ldi XH, HIGH(POSITION_DATA_START)

    clr servoIndex

SerialQueryAllServosLoop :

    rcall SendQueryResponse      

    adiw XL, BYTES_PER_SERVO        ; next servo...

    inc servoIndex

    cpi servoIndex, NUM_SERVOS
    brne SerialQueryAllServosLoop

    rjmp SerialStart


; Sends a query response

SendQueryResponse : 

    ldi serialChar, 0xFC
    rcall SendSerial

    mov serialChar, servoIndex      ; servo we queried
    rcall SendSerial

    ld temp1, X+                    ; min position
    mov serialChar, temp1           
    rcall SendSerial

    ld temp1, X+                    ; max position
    mov serialChar, temp1           
    rcall SendSerial

    ld temp1, X+                    ; centre position
    mov serialChar, temp1           
    rcall SendSerial

    ld currentPos, X+              ; current position
    mov serialChar, currentPos     
    rcall SendSerial
    
    ld temp1, X+                    ; step every
    mov serialChar, temp1           
    rcall SendSerial

    ld temp1, X+                    ; target position
    mov serialChar, temp1           
    rcall SendSerial

    ld temp1, X+                    ; step size
    mov serialChar, temp1           
    rcall SendSerial

    sbiw XL, 7                   ; move X back to where we started

    ret


; Set Multiple Servos
; <0x50> <numServos> <servo> <posn> <servo> <posn> ... <servoN> <posnN>


SerialProcessCommandSetMultipleServoPosn : 

    clr temp2

    ; sCommandLength == 2 then our command length is actually
    ; 2 + value of length byte, else we're complete...

    ldi temp1, 2

    cp sCommandLength, temp1
    brne PC+2
    rjmp SerialProcessCommandSetMultipleServoPosnSetLength

    push XL
    push XH

    mov temp1, sCommandLength
    dec temp1

    add XL, temp1               ; move to the end of the command
    adc XH, temp2

    ldi temp1, 1                
    st X+, temp1                ; set the min step size
    st X, temp1                 ; set the min step frequency

    pop XH                      ; move back to where we were
    pop XL

    rjmp SerialProcessCommandSetMultipleServoPosnStart


SerialProcessCommandSetMultipleServoPosnSetLength : 

    ; the set multiple servos command is in the form <cmd><length><servo><posn><servo><posn><servo><posn>....
    ; where there are 'length' servo indexes and posns after the length...
    ; the initial command length is set to 2, once we have 2 bytes we can work out
    ; the complete length...

    ld temp1, X+

    ; a max number of servos we can process? 64 at a time?

    cpi temp1, MULTI_MOVE_MAX_SERVOS
    brlo PC+2
    rjmp SerialParam1OutOfRange

    lsl temp1                                           ; each servo needs two bytes of command data...

    mov sExpectedBytes, temp1                           
    add sExpectedBytes, temp2

    add sCommandLength, temp1                           ; 
    add sCommandLength, temp2           

                                                        ; if we have 0 servos expected it's valid, though 
                                                        ; pointless and if we aren't setting the min step
                                                        ; size then we should execute the command now...
    tst sExpectedBytes                                  
    brne PC+2
    rjmp SerialProcessCommandSetMultipleServoPosnValidationLoop

    rjmp SerialLoop                                     ; back to the command accumulation loop!



; Set Multiple Servos2
; <0x51> <numServos> <servo> <posn> <servo> <posn> ... <servoN> <posnN> <min step size>

SerialProcessCommandSetMultipleServoPosn2 : 

    ; SerialProcessCommandSetMultipleServoPosn2 also has an additional command byte
    ; for the min step size value

    ldi temp2, 1


    ; sCommandLength == 2 then our command length is actually
    ; 2 + value of length byte, else we're complete...

    ldi temp1, 2

    cp sCommandLength, temp1
    brne PC+2
    rjmp SerialProcessCommandSetMultipleServoPosnSetLength

    push XL
    push XH

    mov temp1, sCommandLength
    dec temp1

    clr temp2
    add XL, temp1               ; move to the end of the command
    adc XH, temp2

    ldi temp1, 1                
    st X, temp1                 ; set the min step frequency

    pop XH                      ; move back to where we were
    pop XL

    rjmp SerialProcessCommandSetMultipleServoPosnStart


; Set Multiple Servos3
; <0x52> <numServos> <servo> <posn> <servo> <posn> ... <servoN> <posnN> <min step size> <min frequency>

SerialProcessCommandSetMultipleServoPosn3 : 

    ; SerialProcessCommandSetMultipleServoPosn2 also has an additional command byte
    ; for the min step size value

    ldi temp2, 2

    ; sCommandLength == 2 then our command length is actually
    ; 2 + value of length byte, else we're complete...

    ldi temp1, 2

    cp sCommandLength, temp1
    brne PC+2
    rjmp SerialProcessCommandSetMultipleServoPosnSetLength

    rjmp SerialProcessCommandSetMultipleServoPosnStart


SerialProcessCommandSetMultipleServoPosnStart :

    ld temp1, X+                                            ; number of servos to process...

SerialProcessCommandSetMultipleServoPosnValidationLoop :    

    tst temp1                                               ; it's valid, though unusual, to have 0 servos...
    breq SerialProcessCommandSetMultipleServoPosnValidationLoopEnd

    ld servoIndex, X+

    cpi servoIndex, NUM_SERVOS                              ; check the servo index is valid
    brlt SerialProcessCommandSetMultipleServoPosnValidationLoopValidateAndAdjust

    ; temp2 needs to hold the index of the servo parameter that's out of range...
    
    mov temp2, sCommandLength

    lsl temp1                   ; double the value of our counter as each servo has two bytes of data and
                                ; the servo index is the first...

    sub temp2, temp1            ; calculate the param position of this servo index

    rjmp SerialParamOutOfRange

SerialProcessCommandSetMultipleServoPosnValidationLoopValidateAndAdjust :     

    ld targetPos, X

    push XL
    push XH

    rcall SerialSelectServoData

    push temp1                  ; calculate the parameter index so we can report on bad params...
                
    mov temp2, sCommandLength
    lsl temp1                   ; double the value of our counter as each servo has two bytes of data and
                                ; the servo index is the first...

    sub temp2, temp1            ; calculate the param position of this servo index
    inc temp2                   ; the position is the next position

    mov temp1, temp2            ; needs to be in temp1 for the call

    rcall SerialValidateAndAdjustDesiredPosition
    mov temp2, temp1                                ; save return value
    pop temp1                                       ; clean stack...
    pop XH
    pop XL
    tst temp2                                       ; if return value is non zero then we validated OK
    brne PC+2                                       ; else we've already sent the error report
    rjmp SerialStart                                ; so jump back to accumulate a new command


    st X+, resh         ; if the value was adjusted, store back the pre 'centre adjust' value for 
                        ; command echo

    dec temp1

    rjmp SerialProcessCommandSetMultipleServoPosnValidationLoop

SerialProcessCommandSetMultipleServoPosnValidationLoopEnd : 

/// now validate the min step and frequency values, cannot be 0
/// probably can't be more than around 10 or so
/// don't echo here???

// store the multipliers on the stack


//

    ldi XL, LOW(SERIAL_DATA_START)                          ; back to the start of the buffer
    ldi XH, HIGH(SERIAL_DATA_START)

    ld temp1, X                                             ; command code

    clr temp2

    add XL, sCommandLength                                  ; move to end of command
    adc XH, temp2

    cpi temp1, 0x52
    brne PC+2
    sbiw X, 2                                               ; step back over frequency and size

    cpi temp1, 0x51
    brne PC+2
    sbiw X, 1                                               ; step back over size

    ld temp1, X+                                            ; load minimum step size           

    push temp1

    ld temp1, X                                             ; load minimum step frequency

    push temp1

//

    

    rcall SerialEchoCommand

    ; now process the command... 

    ldi XL, LOW(SERIAL_DATA_START)                          ; back to the start of the buffer
    ldi XH, HIGH(SERIAL_DATA_START)

    ld temp1, X+                                            ; throw away the command code...

    ld numServos, X+                                        ; number of servos to process...

    mov count, numServos

SerialProcessCommandSetMultipleServoPosnStopServosLoop : 

    tst count
    breq SerialProcessCommandSetMultipleServoPosnStopServosLoopEnd

    ld servoIndex, X+                                       ; load the servo index

    rcall SerialStopServoNoNotificationIfAlreadyStopped     ; stop the servo

    ld temp1, X+                                            ; throw away the target pos

    dec count

    rjmp SerialProcessCommandSetMultipleServoPosnStopServosLoop    

SerialProcessCommandSetMultipleServoPosnStopServosLoopEnd :

    ldi XL, LOW(SERIAL_DATA_START)                          ; back to the start of the buffer
    ldi XH, HIGH(SERIAL_DATA_START)

    ld temp1, X+                                            ; throw away the command code...

    ld numServos, X+                                        ; number of servos to process...

    mov count, numServos

SerialProcessCommandSetMultipleServoPosnSetupDataLoop : 

    tst count
    breq SerialProcessCommandSetMultipleServoPosnSetupDataLoopEnd

    dec count

    ld servoIndex, X+

    ld targetPos, X+

    push XL
    push XH
    
    rcall SerialSelectServoData

    rcall SerialAdjustDesiredPosition

    ld currentPos, X+                                      ; validate and adjust leaves X at current pos...

    ldi XL,  LOW(MULTI_MOVE_WORKSPACE_START)                ; destination
    ldi XH,  HIGH(MULTI_MOVE_WORKSPACE_START)

    ldi temp1, MULTI_MOVE_WORKSPACE_BYTES_PER_SERVO

    mul temp1, count

    add XL, resl
    adc XH, resh

    st X+, servoIndex
    st X+, targetPos
    st X+, currentPos

    cp targetPos, currentPos
    brlo SerialProcessCommandSetMultipleServoPosnSetupDataTargetLower

    ; target is greater than current

    sub targetPos, currentPos
    st X+, targetPos                                       ; save number of steps required from current to target

    rjmp SerialProcessCommandSetMultipleServoPosnSetupDataEndOfLoop

SerialProcessCommandSetMultipleServoPosnSetupDataTargetLower : 

    ; target is less than current

    sub currentPos, targetPos
    st X+, currentPos                                      ; save number of steps required from current to target


SerialProcessCommandSetMultipleServoPosnSetupDataEndOfLoop : 

    pop XH
    pop XL
    
    rjmp SerialProcessCommandSetMultipleServoPosnSetupDataLoop    

SerialProcessCommandSetMultipleServoPosnSetupDataLoopEnd : 

; Now we have each servo with each target and current position and the number of steps required to 
; get from current to target. We now sort them into descending order of 'number of steps'.

; Uses
; numServos     - the number of servos to process
; count         - loop counter
; changed       - set to indicate that the bubble sort isn't done yet
; X             - pointer to 1st entry to compare
; Z             - pointer to 2nd entry to compare

; thisValue     - the 1st entry's number of steps value
; nextValue     - the 2nd entry's number of steps value

SerialProcessCommandSetMultipleServoPosnSortStart : 

    clr count
    clr changed

    ldi XL,  LOW(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET)                             ; 1st entry
    ldi XH,  HIGH(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET)

    ldi ZL,  LOW(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_BYTES_PER_SERVO + MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET) ; 2nd entry
    ldi ZH,  HIGH(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_BYTES_PER_SERVO + MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET)

SerialProcessCommandSetMultipleServoPosnSortLoop : 

    inc count
    cp count, numServos
    breq SerialProcessCommandSetMultipleServoPosnSortLoopEnd
        
    ld thisValue, X
    ld nextValue, Z

    cp thisValue, nextValue
    brsh SerialProcessCommandSetMultipleServoPosnSortIncrementToNext
    
SerialProcessCommandSetMultipleServoPosnSortSwap : 

    inc changed

    st X, nextValue                                             ; swap number of steps required
    st Z, thisValue

    sbiw XL, MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET         ; step back to the start of the structure
    sbiw ZL, MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET 
    
    ld thisValue, X                                             ; swap servo index
    ld nextValue, Z

    st X+, nextValue
    st Z+, thisValue

    ld thisValue, X                                             ; swap target posn
    ld nextValue, Z

    st X+, nextValue
    st Z+, thisValue

    ld thisValue, X                                             ; swap current posn
    ld nextValue, Z

    st X+, nextValue
    st Z+, thisValue

    ; pointers are back at the steps required offset in the structures....

SerialProcessCommandSetMultipleServoPosnSortIncrementToNext : 

    adiw XL, MULTI_MOVE_WORKSPACE_BYTES_PER_SERVO 
    adiw ZL, MULTI_MOVE_WORKSPACE_BYTES_PER_SERVO

    rjmp SerialProcessCommandSetMultipleServoPosnSortLoop

SerialProcessCommandSetMultipleServoPosnSortLoopEnd : 

    tst changed
    brne SerialProcessCommandSetMultipleServoPosnSortStart

; Now we have the servo data sorted into descending order of number of steps.
; We now calculate the step size and step frequency (when) values for but the first
; (highest number of steps) servo. This will result in all servos arriving at their
; end positions at the same time.

; Uses
; numServos     - the number of servos to process
; count         - loop counter
; X             - pointer to 1st entry to compare
; Z             - pointer to 2nd entry to compare
; thisFactor    - the number of times we've multiplied the this value (also the step size)
; nextFactor    - the number of times we've multiplied the next value (also the step frequency) 
; thisValue     - the low byte of the 16-bit multiplied 'this value'
; thisValueH    - the high byte of the 16-bit multiplied 'this value'
; nextValue     - the low byte of the 16-bit multiplied 'next value'
; nextValueH    - the high byte of the 16-bit multiplied 'next value'
; workingValue  - the low byte of the 16-bit result of subtracting 'next value' from 'this value'
; workingValueH - the high byte of the 16-bit result of subtracting 'next value' from 'this value'
; temp2         - temp

SerialProcessCommandSetMultipleServoPosnPrepareToCalculateFactors :

.undef stepCount
.undef stepSize
.undef changed
.undef servoIndex
.undef sCommandLength
.undef sExpectedBytes
.undef serialChar

.def thisFactor = r12
.def nextFactor = r13
.def thisValueH = r17
.def nextValueH = r7             
.def workingValue = r8
.def workingValueH = r9
.def div8Divisor = r16          

SerialProcessCommandSetMultipleServoPosnCalculateFactors : 

    ldi XL,  LOW(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_STEP_WHEN_OFFSET)              ; 1st entry
    ldi XH,  HIGH(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_STEP_WHEN_OFFSET)

    clr thisFactor
    inc thisFactor

    clr nextFactor
    inc nextFactor

    st X+, thisFactor                                                        ; save first entry's step when
    st X, nextFactor                                                         ; save first entry's step size

    clr count
    inc count       ; because we dont calculate for the first servo value...

    ldi XL,  LOW(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET)                        ; 1st entry
    ldi XH,  HIGH(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET)

    ldi ZL,  LOW(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_BYTES_PER_SERVO + MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET) ; 2nd entry
    ldi ZH,  HIGH(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_BYTES_PER_SERVO + MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET)


SerialProcessCommandSetMultipleServoPosnCalculateFactorsStart : 

    clr thisFactor
    inc thisFactor

    clr nextFactor
    inc nextFactor

    ld thisValue, X
    clr thisValueH

    ld nextValue, Z
    clr nextValueH

    tst nextValue
    brne PC+2
    rjmp SerialProcessCommandSetMultipleServoPosnCalculateFactorsNoMoveRequired

SerialProcessCommandSetMultipleServoPosnCalculateFactorsLoop : 

    mov workingValue, thisValue
    mov workingValueH, thisValueH
    
    sub workingValue, nextValue
    sbc workingValueH, nextValueH
    brne SerialProcessCommandSetMultipleServoPosnCalculateFactorsValuesNotEqual
    
    rjmp SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateData

SerialProcessCommandSetMultipleServoPosnCalculateFactorsValuesNotEqual : 

    clr temp2

    cp workingValue, temp2
    cpc workingValueH, temp2
    brlt SerialProcessCommandSetMultipleServoPosnCalculateFactorsNextLargerThanThis  ; working value is negative (so next was larger than this)

SerialProcessCommandSetMultipleServoPosnCalculateFactorsThisLargerThanNext : 

    ; the accumulated 'this' value is larger than the accumulate 'next' value. Add the original 'next' value
    ; and increment the factor to track it.

    inc nextFactor                      ; track how many times we've added the steps required to itself.

    ld temp1, Z                         ; load the original value 
    clr temp2

    add nextValue, temp1                ; add it to the accumulated value
    adc nextValueH, temp2
        
    rjmp SerialProcessCommandSetMultipleServoPosnCalculateFactorsLoop


SerialProcessCommandSetMultipleServoPosnCalculateFactorsNextLargerThanThis : 

    ; when next > this we apply a fudge factor to keep the minimum common factors smaller...

    ; first make the value positive...
    
    com workingValueH
    com workingValue

    mov temp1, thisFactor
    cpi temp1, 1                            ; no point in doing the division if we'd be dividing by 1...
    breq SerialProcessCommandSetMultipleServoPosnCalculateFactorsNextLargerThanThisFactorIs1

    ;need to take this value and divide by thisfactor then compare with nextfactor

    mov temp1, workingValue
    mov temp2, workingValueH
    mov div8Divisor, thisFactor
    
    rcall div8

    clr temp2

    cp nextFactor, resl
    cpc temp2, resh
    brge SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateCurrentPosByStepSize     
                                        ; if the result of the division is less than the nextFactor
                                        ; then that's good enough a match, we can fudge the currentPosn 
                                        ; of the servo by one 'step size' to make the movement work correctly

    rjmp SerialProcessCommandSetMultipleServoPosnCalculateFactorsNextLargerThanThisNotInRange

SerialProcessCommandSetMultipleServoPosnCalculateFactorsNextLargerThanThisFactorIs1 : 

    clr temp2
    cp nextFactor, workingValue
    cpc temp2, workingValueH
    brge SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateCurrentPosByStepSize     
                                        ; if the result of the division (by 1) is less than the nextFactor
                                        ; then that's good enough a match, we can fudge the currentPos 
                                        ; of the servo by one 'step size' to make the movement work correctly


SerialProcessCommandSetMultipleServoPosnCalculateFactorsNextLargerThanThisNotInRange :

    ; the accumulated 'next' value is now larger than the 'this' value, add the original number of steps
    ; to 'this' again and increment the factor to keep track of it

    inc thisFactor                      ; track how many times we've added the steps required to itself.

    ld temp1, X                         ; load the original value 
    clr temp2

    add thisValue, temp1                ; add it to the accumulated value
    adc thisValueH, temp2   
        
    rjmp SerialProcessCommandSetMultipleServoPosnCalculateFactorsLoop
    

SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateCurrentPosByStepSize : 

    ; update current pos by moving it one step value closer to the target pos

    sbiw ZL:ZH, 2               ; move from steps required offset back to target Pos offset

    ld targetPos, Z+           ; load target Pos
    ld currentPos, Z           ; load current and leave Z ready for updated value


    cp targetPos, currentPos
    brlo SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateCurrentPosTargetIsLessThanCurrent

    ; target is larger than current

    ldi temp2, 0xFE
    sub temp2, nextFactor

    cp temp2, currentPos 
    brlo SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateCurrentPosSetCurrentToMaxPos

    add currentPos, nextFactor ; add the step value to the current Pos    

    rjmp SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateCurrentPosWriteCurrentPos

SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateCurrentPosSetCurrentToMaxPos : 

    ldi temp2, 0xFE
    mov currentPos, temp2

    rjmp SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateCurrentPosWriteCurrentPos

SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateCurrentPosTargetIsLessThanCurrent : 

    ; target is smaller than current

    sub currentPos, nextFactor ; add the step value to the current Pos    
    brcs SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateCurrentPosSetCurrentToZero

    rjmp SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateCurrentPosWriteCurrentPos


SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateCurrentPosSetCurrentToZero :

    clr currentPos

    rjmp SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateCurrentPosWriteCurrentPos

SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateCurrentPosWriteCurrentPos : 

    st Z+, currentPos          ; save current Pos and move to steps required offset

SerialProcessCommandSetMultipleServoPosnCalculateFactorsUpdateData : 

    adiw Z, 1                   ; move from steps required offset to step when offset
    st Z+, nextFactor           ; save step when
    st Z+, thisFactor           ; save step size

SerialProcessCommandSetMultipleServoPosnCalculateFactorsStepToNextValue : 

    inc count
    cp count, numServos
    breq SerialProcessCommandSetMultipleServoPosnCalculateFactorsLoopComplete

    adiw ZL, MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET     ; select next steps required value

    rjmp SerialProcessCommandSetMultipleServoPosnCalculateFactorsStart

SerialProcessCommandSetMultipleServoPosnCalculateFactorsNoMoveRequired : 

    clr thisFactor          ; steps required is zero so the step size and step frequency
    clr nextFactor          ; are zero

    adiw Z, 3              ; move from steps required offset to end of record
    

    rjmp SerialProcessCommandSetMultipleServoPosnCalculateFactorsStepToNextValue

SerialProcessCommandSetMultipleServoPosnCalculateFactorsLoopComplete : 

; now we need to set up the moves...

.undef thisFactor
.undef nextFactor
.undef thisValueH
.undef nextValueH
.undef workingValue
.undef workingValueH
.undef div8Divisor

.def stepCount = r7             
.def stepSize = r8
.def changed = r9               ; serial + PWM setup
.def servoIndex = r16           ; serial + EEPROM code (serial)
.def serialChar = r17           ; serial ONLY
       
                 
.def sCommandLength = r12       ; serial ONLY
.def sExpectedBytes = r13       ; serial ONLY

; Apply minimum step frequency

    pop temp1                   ; retrieve the minimum step frequency
    
    cpi temp1, 1                ; skip this if the multiply value is 1
    breq SerialProcessCommandSetMultipleServoPosnApplyMinStepFrequencyLoopEnd
    
    ldi ZL,  LOW(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_STEP_WHEN_OFFSET)
    ldi ZH,  HIGH(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_STEP_WHEN_OFFSET)

    mov count, numServos

SerialProcessCommandSetMultipleServoPosnApplyMinStepFrequencyLoop : 

    tst count
    breq SerialProcessCommandSetMultipleServoPosnApplyMinStepFrequencyLoopEnd
    
    ld temp2, Z
    mul temp2, temp1

    ;tst r1
    // if r1 isn't 0 then we've multipled to too big a value. invalid parameter
    // need to set up temp2 to point to the param index (which we need to have stored?)
    // and pop the remaining values from the stack before returning via the invalid param
    // routine
    
    st Z, r0                          ; save the new value


    adiw Z, MULTI_MOVE_WORKSPACE_BYTES_PER_SERVO            ; step to the next one
        
    dec count

    rjmp SerialProcessCommandSetMultipleServoPosnApplyMinStepFrequencyLoop 

SerialProcessCommandSetMultipleServoPosnApplyMinStepFrequencyLoopEnd :


; Apply minimum step size

    pop temp1                   ; retrieve the minimum step frequency
    
    cpi temp1, 1                ; skip this if the multiply value is 1
    breq SerialProcessCommandSetMultipleServoPosnApplyMinStepSizeLoopEnd
    
    ldi ZL,  LOW(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_STEP_SIZE_OFFSET)
    ldi ZH,  HIGH(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_STEP_SIZE_OFFSET)

    mov count, numServos

SerialProcessCommandSetMultipleServoPosnApplyMinStepSizeLoop : 

    tst count
    breq SerialProcessCommandSetMultipleServoPosnApplyMinStepSizeLoopEnd
    
    ld temp2, Z
    mul temp2, temp1

    ;tst r1
    // if r1 isn't 0 then we've multipled to too big a value. invalid parameter
    // need to set up temp2 to point to the param index (which we need to have stored?)
    // and pop the remaining values from the stack before returning via the invalid param
    // routine
    
    st Z, r0                          ; save the new value


    adiw Z, MULTI_MOVE_WORKSPACE_BYTES_PER_SERVO            ; step to the next one
        
    dec count

    rjmp SerialProcessCommandSetMultipleServoPosnApplyMinStepSizeLoop
    
SerialProcessCommandSetMultipleServoPosnApplyMinStepSizeLoopEnd :  

   

// now multiply the factors by the min values, skip if min values are 1

// validate that the multiplied factors arent more than 255, fail with param error if they are

// if configured to, echo the delay moves we're setting up

// echo the command

; loop over each servo and set them as delay moves

; finally loop over all of them again and set the step every values
    
    ldi ZL,  LOW(MULTI_MOVE_WORKSPACE_START)                             ; 1st entry
    ldi ZH,  HIGH(MULTI_MOVE_WORKSPACE_START)

    mov count, numServos

SerialProcessCommandSetMultipleServoPosnSetPosnLoop : 

    tst count
    breq SerialProcessCommandSetMultipleServoPosnSetPosnLoopEnd

    ld servoIndex, Z+
    ld targetPos, Z+
    ld currentPos, Z+               
    ld temp1, Z+                    ; throw away the steps required
    ld stepEvery, Z+
    ld stepSize, Z+


    rcall SerialSelectServoData

    adiw X, CURRENT_POS_OFFSET

    st X+, currentPos               ; we may have adjusted the current pos slightly...

    adiw X, 1                       ; step over the step every value

    st X+, targetPos
    st X, stepSize

    sbiw XL, 2                      ; move back to the step every value

    st X, stepEvery

    dec count

    rjmp SerialProcessCommandSetMultipleServoPosnSetPosnLoop 

SerialProcessCommandSetMultipleServoPosnSetPosnLoopEnd : 


    rjmp SerialStart                                ; back to the command accumulation loop!



; When the PWM code completes some delayed servo moves, that is, when
; the servo reaches the target position, it signals the serial code to
; send notifications. The siginally is based on the PWM code setting the
; movesComplete register (it sets the bit for the bank in which the 
; servo that has completed its move). Right now we ignore the bits and
; always check all servos if the movesComplete register is non zero.

; Note that to ensure that we don't miss any move completions we MUST 
; set the movesComplete register to 0 before we begin to process the
; servo data and send notifications. This is because the PWM code can
; interrupt us at any point and may complete more servo moves.

; Completion messages are in the form: 0xFE <servo> <posn>.

SerialSendMoveCompleteNotification :

    ; we could optimise this so that we only check the bank that is
    ; set in movesComplete...

    ; note that we've processed these completions...

    clr  movesComplete

    ; loop over all the config data...

    push XL
    push XH

    ldi XL, LOW(POSITION_DATA_START)       
    ldi XH, HIGH(POSITION_DATA_START)

    clr servoIndex

SerialSendMoveCompleteNotificationLoop :

    adiw XL, CURRENT_POS_OFFSET

    ld currentPos, X+
    ld stepEvery, X+
    ld targetPos, X

    cp currentPos, targetPos
    brne SerialSendMoveCompleteNotificationLoopIncrement

    tst stepEvery
    breq SerialSendMoveCompleteNotificationLoopIncrement    

    sbiw XL, 1

    clr stepEvery
    st X+, stepEvery

    ldi serialChar, 0xFE
    rcall SendSerial
    
    mov serialChar, servoIndex 
    rcall SendSerial

    mov serialChar, currentPos
    rcall SendSerial

SerialSendMoveCompleteNotificationLoopIncrement :

    adiw XL, BYTES_PER_SERVO - 5

    inc servoIndex

    cpi servoIndex, NUM_SERVOS
    breq SerialSendMoveCompleteNotificationLoopEnd

    rjmp SerialSendMoveCompleteNotificationLoop          

SerialSendMoveCompleteNotificationLoopEnd :

    pop XH
    pop XL



    rjmp SerialStart


; Function!

; passed temp1 - the parameter index of the position we're validating...
; uses temp2, resl, updates targetPos, moves X to the currentPos...

SerialValidateAndAdjustDesiredPosition : 

    mov resh, targetPos                     ; resh returns the adjusted position if we're
                                            ; outside the min and max limits and we're allowed
                                            ; to adjust and continue. 

    push XL
    push XH

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)                      
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    ld resl, X                              ; load the servo out of range action flag 
                                            ; 1 == allow out of range and set to range limit
                                            ; 0 == return error on out of range

    pop XH
    pop XL

    ; check the minimum position

    ld temp2, X+                            ; load the min position
    cp targetPos, temp2                     ; check the servo position is valid
    brlo SerialValidateAndAdjustDesiredPositionOutOfRangeLow


SerialValidateAndAdjustDesiredPositionCheckMax : 

    ; now check the maximum position

    ldi temp2, 0xFF
    cp targetPos, temp2                                             ; if we're actually illegal and out of range
    breq SerialValidateAndAdjustDesiredPositionPosnOutOfRange       ; we must always flag as an error!


    ld temp2, X+                            ; load the max position
    cp temp2, targetPos                     ; check the servo position is valid
    brsh SerialAdjustDesiredPositionAdjustCentre

    ; we're out of range and too high...

    tst resl                                                        ; controller configurable if we treat this 
    breq SerialValidateAndAdjustDesiredPositionPosnOutOfRange       ; as an error or simply adjust the desired posn 
                                                                    ; to the limit

    ; fix up the target posn to the max posn

    mov targetPos, temp2                ; limit the max posn
    mov resh, temp2                     ; return the limited value without centre adjust

    rjmp SerialAdjustDesiredPositionAdjustCentre

SerialValidateAndAdjustDesiredPositionOutOfRangeLow : 

    ; were out of range and too low...

    tst resl
    breq SerialValidateAndAdjustDesiredPositionPosnOutOfRange

    ; fix up the target posn to the min posn

    mov targetPos, temp2                ; limit the min posn
    mov resh, temp2                     ; return the limited value without centre adjust

    rjmp SerialValidateAndAdjustDesiredPositionCheckMax


SerialValidateAndAdjustDesiredPositionPosnOutOfRange : 

    mov temp2, temp1                        ; set up the parameter index for the invalid parameter response

    rcall SerialParamOutOfRangeFnc 

    clr temp1                               ; indicate failure by clearing temp1 before return...

    ret


; uses temp2, resl, updates targetPos, moves X to the currentPos...

SerialAdjustDesiredPosition : 

    adiw XL, CENTRE_ADJUST_OFFSET           ; select the centre adjust value...

SerialAdjustDesiredPositionAdjustCentre : 

    ld temp2, X+                            ; load servo centre position

    cpi temp2, 0x7F                         ; if the centre position of this servo is 
    brne PC+2                               ; the standard 127 position then there's
    ret                                     ; nothing more to do...

    cpi temp2, 0x7F                         ; if the centre adjust is less than 127...
    brlo SerialAdjustDesiredPositionAdjustCentreLessThanNormal

    mov resl, temp2

    ldi temp2, 0x7F

    sub resl, temp2                         ; calculate difference between real centre and ideal centre

    add targetPos, resl                     ; add the centre adjust value to the desired position
    brcc PC+2                               ; if the result has wrapped then that's illegal...
    rjmp SerialAdjustDesiredPositionAdjustTooBig

    ldi temp2, 0xFF                         ; the resulting value can't be larger than 0xFE....
    cp targetPos, temp2
    breq SerialAdjustDesiredPositionAdjustTooBig

    ret

SerialAdjustDesiredPositionAdjustTooBig : 

    ; value has wrapped past the maximum possible position...
    ; set to the max position
    ; this shouldnt be able to happen!!!

    ldi temp2, 0xFE
    mov targetPos, temp2

    ret 

SerialAdjustDesiredPositionAdjustCentreLessThanNormal : 

    mov resl, temp2

    ldi temp2, 0x7F

    sub temp2, resl                         ; calculate difference between real centre and ideal centre

    sub targetPos, temp2                   ; subtract the centre adjust value from the desired position
    brcs PC+2
    ret

    ; value has wrapped past the minimum position...
    ; set to the mim position
    ; this shouldnt be able to happen!!!

    ldi temp2, 0x00
    mov targetPos, temp2

    ret


; Function
; Adjusts X to point to the servo position data for the servo in servoIndex
; destroys resl, resh

SerialSelectServoData :

    push resl
    push resh
    push temp2

    ldi XL, LOW(POSITION_DATA_START)       
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp2, BYTES_PER_SERVO
    
    mul servoIndex, temp2

    add XL, resl
    adc XH, resh

    pop temp2
    pop resh
    pop resl

    ret


; Div8 divides a 16-bit-number by a 8-bit-number
; From http://www.avr-asm-tutorial.net/avr_en/calc/DIV8E.html
;
; Registers
;
;temp1 - LSB 16-bit-number to be divided
;temp2 - MSB 16-bit-number to be divided
;div8Divisor - 8-bit-number to divide with


.undef servoIndex
.def div8Divisor = r16


.undef serialChar
.def divTemp = r17           ; interim register



;
; Divide temp2:temp1 by div8Divisor
;
div8:

    push divTemp
    lds divTemp, SREG
    push divTemp


	clr divTemp         ; clear interim register
	clr resh            ; clear result (the result registers
	clr resl            ; are also used to count to 16 for the
	inc resl            ; division steps, is set to 1 at start)

;
; Here the division loop starts
;

div8a:
	clc                 ; clear carry-bit
	rol temp1           ; rotate the next-upper bit of the number
	rol temp2           ; to the interim register (multiply by 2)
	rol divTemp
	brcs div8b          ; a one has rolled left, so subtract
	cp divTemp,div8Divisor    ; Division result 1 or 0?
	brcs div8c          ; jump over subtraction, if smaller
div8b:
	sub divTemp,div8Divisor   ; subtract number to divide with
	sec                 ; set carry-bit, result is a 1
	rjmp div8d          ; jump to shift of the result bit
div8c:
	clc                 ; clear carry-bit, resulting bit is a 0
div8d:
	rol resl            ; rotate carry-bit into result registers
	rol resh
	brcc div8a          ; as long as zero rotate out of the result
	                    ; registers: go on with the division loop

    
    pop divTemp
    sts SREG, divTemp
    pop divTemp

    ret


.undef div8Divisor
.def servoIndex = r16           ; serial + EEPROM code (serial)


