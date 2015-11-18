TestSerialProcessCommandStopServo :

    ldi temp1, 61
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0
    st X, temp1                            ; servo index to stop

    jmp SerialProcessCommandStopServo

    jmp TestsFailed


TestSerialProcessCommandStopServoCheckResults :

    ; The call should leave X pointing into the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)
    breq PC+3
    jmp TestsFailed

    ; The servo that we stopped wasn't moving anyway, so no change 

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 7            ; there should have been 7 calls
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFD         ; stop servo response
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; servo index
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x7F         ; current posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step every - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; target pos - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step size - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed


    inc testResult
    ret

TestSerialProcessCommandStopServoDuringDelayMove :

    ldi temp1, 62
    mov testIndex, temp1

    ldi XL, LOW(POSITION_DATA_START + CURRENT_POS_OFFSET)     
    ldi XH, HIGH(POSITION_DATA_START + CURRENT_POS_OFFSET)

    ldi temp1, 0x80         ; current posn
    st X+, temp1

    ldi temp1, 0x05         ; step every
    st X+, temp1
    
    ldi temp1, 0x02         ; target posn
    st X+, temp1

    ldi temp1, 0x0A         ; step size
    st X, temp1

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0
    st X, temp1                            ; servo index to stop

    jmp SerialProcessCommandStopServo

    jmp TestsFailed


TestSerialProcessCommandStopServoDuringDelayMoveCheckResults :

    ; The call should leave X pointing into the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)
    breq PC+3
    jmp TestsFailed

    ; The servo that we stopped was moving, so check the change 

    ldi XL, LOW(POSITION_DATA_START + CURRENT_POS_OFFSET)     
    ldi XH, HIGH(POSITION_DATA_START + CURRENT_POS_OFFSET)

    ld temp1, X
    cpi temp1, 0x80         ; current posn - not changed
    breq PC+3
    jmp TestsFailed

    ldi temp1, 0x7F         ; reset to original value
    st X+, temp1

    ld temp1, X+
    cpi temp1, 0x00         ; step every - changed to zero
    breq PC+3
    jmp TestsFailed

    ; this is the original value for step every so nothing to do

    ld temp1, X
    cpi temp1, 0x02         ; target posn - not changed
    breq PC+3
    jmp TestsFailed

    clr temp1               ; reset to original value
    st X+, temp1

    ld temp1, X
    cpi temp1, 0x0A         ; step size - not changed
    breq PC+3
    jmp TestsFailed

    clr temp1               ; reset to original value          
    st X, temp1

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 7            ; there should have been 7 calls
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFD         ; stop servo response
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; servo index
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x80         ; current posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x05         ; step every 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x02         ; target pos 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x0A         ; step size 
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret

TestSerialProcessCommandStopServoInvalidServo :

    ldi temp1, 63
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, NUM_SERVOS + 1
    st X, temp1                            ; servo index to stop

    jmp SerialProcessCommandStopServo

    jmp TestsFailed


TestSerialProcessCommandStopServoInvalidServoCheckResults :

    ; The call should leave X pointing into the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)
    breq PC+3
    jmp TestsFailed

    ; The servo that we stopped wasn't moving anyway, so no change 

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should have been 1 call
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xF6         ; servo out of range
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret

TestSerialProcessCommandStopServosSetsRealCommandLength :

    ldi temp1, 64
    mov testIndex, temp1
    
    ldi temp1, 2                            ; When called with a command length of 2  
    mov sCommandLength, temp1               ; we need to read the number of servos and 
                                            ; calculate the real command length

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 5                             
    st X, temp1                             ; Number of servos in a complete command

    jmp SerialProcessCommandStopServos

    jmp TestsFailed


TestSerialProcessCommandStopServosSetsRealCommandLengthCheckResults :

    ; The call should leave X pointing into the serial input buffer at the 
    ; space where the next byte should arrive into...

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+3
    jmp TestsFailed

    ; No change, we didn't do anything but calculate the command length

    call ValidatePositionDataIsUnchanged

    ; check that we calculated the correct command length for a command that will 
    ; stop 5 servos...

    ldi temp1, 7
    cp sCommandLength, temp1
    breq PC+3
    jmp TestsFailed
    
    inc testResult
    ret

TestSerialProcessCommandStopServosTwoServosNeitherMoving :

    ldi temp1, 65
    mov testIndex, temp1

    ldi temp1, 4                            ; Two servos to stop, 2 bytes of additional command info
    mov sCommandLength, temp1               
                                            
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 2                             
    st X+, temp1                            ; Number of servos in a complete command

    ldi temp1, 0                             
    st X+, temp1                            ; Servo to stop

    ldi temp1, 5                             
    st X, temp1                             ; Servo to stop

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandStopServos

    jmp TestsFailed


TestSerialProcessCommandStopServosTwoServosNeitherMovingCheckResults :

    ; The call should leave X pointing at the end of the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 3)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 3)
    breq PC+3
    jmp TestsFailed

    ; The servo that we stopped wasn't moving anyway, so no change 

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 14            ; there should have been 14 bytes of data
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 4            ; echo command includes non zero sCommandLength
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFD         ; stop servo response
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; servo index
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x7F         ; current posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step every - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; target pos - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step size - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFD         ; stop servo response
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x05         ; servo index
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x7F         ; current posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step every - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; target pos - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step size - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret

TestSerialProcessCommandStopServosTwoServosFirstMoving :

    ldi temp1, 66
    mov testIndex, temp1
    
    ldi XL, LOW(POSITION_DATA_START + CURRENT_POS_OFFSET)     
    ldi XH, HIGH(POSITION_DATA_START + CURRENT_POS_OFFSET)

    ldi temp1, 0x80         ; current posn for servo 0
    st X+, temp1

    ldi temp1, 0x05         ; step every
    st X+, temp1
    
    ldi temp1, 0x02         ; target posn
    st X+, temp1

    ldi temp1, 0x0A         ; step size
    st X, temp1

    ldi temp1, 4                            ; Two servos to stop, 2 bytes of additional command info
    mov sCommandLength, temp1               
                                            
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 2                             
    st X+, temp1                            ; Number of servos in a complete command

    ldi temp1, 0                             
    st X+, temp1                            ; Servo to stop

    ldi temp1, 5                             
    st X, temp1                             ; Servo to stop

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandStopServos

    jmp TestsFailed


TestSerialProcessCommandStopServosTwoServosFirstMovingCheckResults :

    ; The call should leave X pointing at the end of the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 3)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 3)
    breq PC+3
    jmp TestsFailed


    ; The servo that we stopped was moving, so check the change 

    ldi XL, LOW(POSITION_DATA_START + CURRENT_POS_OFFSET)     
    ldi XH, HIGH(POSITION_DATA_START + CURRENT_POS_OFFSET)

    ld temp1, X
    cpi temp1, 0x80         ; current posn - not changed
    breq PC+3
    jmp TestsFailed

    ldi temp1, 0x7F         ; reset to original value
    st X+, temp1

    ld temp1, X+
    cpi temp1, 0x00         ; step every - changed to zero
    breq PC+3
    jmp TestsFailed

    ; this is the original value for step every so nothing to do

    ld temp1, X
    cpi temp1, 0x02         ; target posn - not changed
    breq PC+3
    jmp TestsFailed

    clr temp1               ; reset to original value
    st X+, temp1

    ld temp1, X
    cpi temp1, 0x0A         ; step size - not changed
    breq PC+3
    jmp TestsFailed

    clr temp1               ; reset to original value          
    st X, temp1

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 14            ; there should have been 14 bytes of data
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 4            ; echo command includes non zero sCommandLength
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFD         ; stop servo response
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; servo index
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x80         ; current posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x05         ; step every 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x02         ; target pos 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x0A         ; step size 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFD         ; stop servo response
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x05         ; servo index
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x7F         ; current posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step every - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; target pos - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step size - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandStopServosTwoServosFirstInvalidServo :

    ldi temp1, 67
    mov testIndex, temp1
    
    ldi temp1, 4                            ; Two servos to stop, 2 bytes of additional command info
    mov sCommandLength, temp1               
                                            
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 2                             
    st X+, temp1                            ; Number of servos in a complete command

    ldi temp1, NUM_SERVOS + 1                             
    st X+, temp1                            ; Servo to stop

    ldi temp1, 5                             
    st X, temp1                             ; Servo to stop

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandStopServos

    jmp TestsFailed


TestSerialProcessCommandStopServosTwoServosFirstInvalidServoCheckResults :

    ; The call should leave X pointing at the invalid servo in the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 2)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 2)
    breq PC+3
    jmp TestsFailed

    ; We had an invalid servo index, so no change 

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 2            ; there should have been 1 call with 1 byte of data
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFA         ; serial param out of range
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 2            ; the index of the parameter that was incorrect
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret

TestSerialProcessCommandStopServosTwoServosSecondInvalidServo :

    ldi temp1, 68
    mov testIndex, temp1

    ldi temp1, 4                            ; Two servos to stop, 2 bytes of additional command info
    mov sCommandLength, temp1               
                                            
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 2                             
    st X+, temp1                            ; Number of servos in a complete command

    ldi temp1, 0                             
    st X+, temp1                            ; Servo to stop

    ldi temp1, NUM_SERVOS + 1
    st X, temp1                             ; Servo to stop

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandStopServos

    jmp TestsFailed


TestSerialProcessCommandStopServosTwoServosSecondInvalidServoCheckResults :

    ; The call should leave X pointing at the invalid servo in the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 3)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 3)
    breq PC+3
    jmp TestsFailed

    ; We had an invalid servo index, so no change 

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 2            ; there should have been 1 call with 1 byte of data
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFA         ; serial param out of range
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 3            ; the index of the parameter that was incorrect
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandStopServosTooManyServosToStop :

    ldi temp1, 69
    mov testIndex, temp1
    
    ldi temp1, 2                            ; Initial 'calculate command length' call
    mov sCommandLength, temp1               
                                            
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, NUM_SERVOS + 1               ; Too many servos
    st X, temp1                            
    
    jmp SerialProcessCommandStopServos

    jmp TestsFailed


TestSerialProcessCommandStopServosTooManyServosToStopCheckResults :

    ; The call should leave X pointing into the serial input buffer at the 
    ; space where the next byte should arrive into...

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+3
    jmp TestsFailed

    ; No change, we didn't do anything but calculate the command length

    call ValidatePositionDataIsUnchanged

    ; check that we didn't change the command length 

    ldi temp1, 2
    cp sCommandLength, temp1
    breq PC+3
    jmp TestsFailed
    
    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should have been 1 call 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xF8         ; serial param 1 out of range
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandStopAllNoneMoving :

    ldi temp1, 70
    mov testIndex, temp1
    

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandStopAll

    jmp TestsFailed


TestSerialProcessCommandStopAllNoneMovingCheckResults :

    ; The call should leave X pointing at the end of the position data

    cpi XL, LOW(POSITION_DATA_END)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_END)
    breq PC+3
    jmp TestsFailed

    ; None of the servos were moving anyway, so no change 

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ldi temp1, 42
    cpi temp1, NUM_SERVOS               ; due to how our serial output buffer works this test wont work with
    brge PC+3                           ; a NUM_SERVOS value of more than 42...
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, (1 + (6 * NUM_SERVOS))   ; there should have been 1 call for the echo plus 6 calls per servo
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command 
    breq PC+3
    jmp TestsFailed

    clr temp2
    
TestSerialProcessCommandStopAllNoneMovingCheckResultsLoop :

    ld temp1, X+
    cpi temp1, 0xFD         ; stop servo response
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cp temp1, temp2         ; servo index
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x7F         ; current posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step every - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; target pos - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step size - 0 if it wasn't moving
    breq PC+3
    jmp TestsFailed

    inc temp2
    cpi temp2, NUM_SERVOS
    brne TestSerialProcessCommandStopAllNoneMovingCheckResultsLoop

    inc testResult
    ret

