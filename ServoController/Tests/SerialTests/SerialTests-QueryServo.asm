
TestSerialProcessCommandQueryServo :

    ldi temp1, 71
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0
    st X, temp1                            ; servo index to Query

    jmp SerialProcessCommandQueryServo

    jmp TestsFailed


TestSerialProcessCommandQueryServoCheckResults :

    ; The call should leave X pointing into the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)
    breq PC+3
    jmp TestsFailed

    ; A query doesn't change anything

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 10            ; there should have been 10 calls
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFC         ; Query servo response
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; servo index
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; min posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFE         ; max posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x7F         ; centre posn
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
    cpi temp1, 0x00         ; target pos
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step size
    breq PC+3
    jmp TestsFailed


    inc testResult
    ret

TestSerialProcessCommandQueryServoDuringDelayMove :

    ldi temp1, 72
    mov testIndex, temp1

    ldi XL, LOW(POSITION_DATA_START)     
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 0x20         ; min 
    st X+, temp1

    ldi temp1, 0x90         ; max
    st X+, temp1

    ldi temp1, 0x70         ; centre
    st X+, temp1

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
    st X, temp1                            ; servo index to Query

    jmp SerialProcessCommandQueryServo

    jmp TestsFailed


TestSerialProcessCommandQueryServoDuringDelayMoveCheckResults :

    ; The call should leave X pointing into the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)
    breq PC+3
    jmp TestsFailed

    ; A query doesn't change anything

    ldi XL, LOW(POSITION_DATA_START)     
    ldi XH, HIGH(POSITION_DATA_START)

    ld temp1, X
    cpi temp1, 0x20         ; min 
    breq PC+3
    jmp TestsFailed

    clr temp1               ; reset to original value
    st X+, temp1

    ld temp1, X
    cpi temp1, 0x90         ; max 
    breq PC+3
    jmp TestsFailed

    ldi temp1, 0xFE         ; reset to original value
    st X+, temp1

    ld temp1, X
    cpi temp1, 0x70         ; centre 
    breq PC+3
    jmp TestsFailed

    ldi temp1, 0x7F         ; reset to original value
    st X+, temp1

    ld temp1, X
    cpi temp1, 0x80         ; current posn
    breq PC+3
    jmp TestsFailed

    ldi temp1, 0x7F         ; reset to original value
    st X+, temp1

    ld temp1, X
    cpi temp1, 0x05         ; step every
    breq PC+3
    jmp TestsFailed

    clr temp1               ; reset to original value
    st X+, temp1

    ld temp1, X
    cpi temp1, 0x02         ; target posn
    breq PC+3
    jmp TestsFailed

    clr temp1               ; reset to original value
    st X+, temp1

    ld temp1, X
    cpi temp1, 0x0A         ; step size
    breq PC+3
    jmp TestsFailed

    clr temp1               ; reset to original value          
    st X, temp1

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 10            ; there should have been 10 calls
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFC         ; Query servo response
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; servo index
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x20         ; min posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x90         ; max posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x70         ; centre posn
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

TestSerialProcessCommandQueryServoInvalidServo :

    ldi temp1, 73
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, NUM_SERVOS + 1
    st X, temp1                            ; servo index to Query

    jmp SerialProcessCommandQueryServo

    jmp TestsFailed


TestSerialProcessCommandQueryServoInvalidServoCheckResults :

    ; The call should leave X pointing into the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)
    breq PC+3
    jmp TestsFailed

    ; A query doesn't change anything

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

TestSerialProcessCommandQueryServosSetsRealCommandLength :

    ldi temp1, 74
    mov testIndex, temp1

    ldi temp1, 2                            ; When called with a command length of 2  
    mov sCommandLength, temp1               ; we need to read the number of servos and 
                                            ; calculate the real command length

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 5                             
    st X, temp1                             ; Number of servos in a complete command

    jmp SerialProcessCommandQueryServos

    jmp TestsFailed


TestSerialProcessCommandQueryServosSetsRealCommandLengthCheckResults :

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
    ; Query 5 servos...

    ldi temp1, 7
    cp sCommandLength, temp1
    breq PC+3
    jmp TestsFailed
    
    inc testResult
    ret

TestSerialProcessCommandQueryServosTwoServosNeitherMoving :

    ldi temp1, 75
    mov testIndex, temp1
    
    ldi temp1, 4                            ; Two servos to Query, 2 bytes of additional command info
    mov sCommandLength, temp1               
                                            
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 2                             
    st X+, temp1                            ; Number of servos in a complete command

    ldi temp1, 0                             
    st X+, temp1                            ; Servo to Query

    ldi temp1, 5                             
    st X, temp1                             ; Servo to Query

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandQueryServos

    jmp TestsFailed


TestSerialProcessCommandQueryServosTwoServosNeitherMovingCheckResults :

    ; The call should leave X pointing at the end of the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 3)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 3)
    breq PC+3
    jmp TestsFailed

    ; The servo that we Queryped wasn't moving anyway, so no change 

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 20           ; there should have been 20 bytes of data
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
    cpi temp1, 0xFC         ; Query servo response
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; servo index
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; min posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFE         ; max posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x7F         ; centre posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x7F         ; current posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step every 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; target pos
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step size
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFC         ; Query servo response
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x05         ; servo index
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; min posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFE         ; max posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x7F         ; centre posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x7F         ; current posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step every 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; target pos
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step size
    breq PC+3
    jmp TestsFailed


    inc testResult
    ret

TestSerialProcessCommandQueryServosTwoServosFirstMoving :

    ldi temp1, 76
    mov testIndex, temp1

    ldi XL, LOW(POSITION_DATA_START)     
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 0x20         ; min 
    st X+, temp1

    ldi temp1, 0x90         ; max
    st X+, temp1

    ldi temp1, 0x70         ; centre
    st X+, temp1

    ldi temp1, 0x80         ; current posn
    st X+, temp1

    ldi temp1, 0x05         ; step every
    st X+, temp1
    
    ldi temp1, 0x02         ; target posn
    st X+, temp1

    ldi temp1, 0x0A         ; step size
    st X, temp1

    ldi temp1, 4                            ; Two servos to Query, 2 bytes of additional command info
    mov sCommandLength, temp1               
                                            
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 2                             
    st X+, temp1                            ; Number of servos in a complete command

    ldi temp1, 0                             
    st X+, temp1                            ; Servo to Query

    ldi temp1, 5                             
    st X, temp1                             ; Servo to Query

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandQueryServos

    jmp TestsFailed


TestSerialProcessCommandQueryServosTwoServosFirstMovingCheckResults :

    ; The call should leave X pointing at the end of the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 3)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 3)
    breq PC+3
    jmp TestsFailed

    ; A query doesn't change anything

    ldi XL, LOW(POSITION_DATA_START)     
    ldi XH, HIGH(POSITION_DATA_START)

    ld temp1, X
    cpi temp1, 0x20         ; min 
    breq PC+3
    jmp TestsFailed

    clr temp1               ; reset to original value
    st X+, temp1

    ld temp1, X
    cpi temp1, 0x90         ; max 
    breq PC+3
    jmp TestsFailed

    ldi temp1, 0xFE         ; reset to original value
    st X+, temp1

    ld temp1, X
    cpi temp1, 0x70         ; centre 
    breq PC+3
    jmp TestsFailed

    ldi temp1, 0x7F         ; reset to original value
    st X+, temp1

    ld temp1, X
    cpi temp1, 0x80         ; current posn
    breq PC+3
    jmp TestsFailed

    ldi temp1, 0x7F         ; reset to original value
    st X+, temp1

    ld temp1, X
    cpi temp1, 0x05         ; step every
    breq PC+3
    jmp TestsFailed

    clr temp1               ; reset to original value
    st X+, temp1

    ld temp1, X
    cpi temp1, 0x02         ; target posn
    breq PC+3
    jmp TestsFailed

    clr temp1               ; reset to original value
    st X+, temp1

    ld temp1, X
    cpi temp1, 0x0A         ; step size
    breq PC+3
    jmp TestsFailed

    clr temp1               ; reset to original value          
    st X, temp1

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 20           ; there should have been 20 bytes of data
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
    cpi temp1, 0xFC         ; Query servo response
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; servo index
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x20         ; min posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x90        ; max posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x70         ; centre posn
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
    cpi temp1, 0xFC         ; Query servo response
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x05         ; servo index
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; min posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFE         ; max posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x7F         ; centre posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x7F         ; current posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step every 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; target pos 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step size 
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandQueryServosTwoServosFirstInvalidServo :

    ldi temp1, 77
    mov testIndex, temp1
    
    ldi temp1, 4                            ; Two servos to Query, 2 bytes of additional command info
    mov sCommandLength, temp1               
                                            
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 2                             
    st X+, temp1                            ; Number of servos in a complete command

    ldi temp1, NUM_SERVOS + 1                             
    st X+, temp1                            ; Servo to Query

    ldi temp1, 5                             
    st X, temp1                             ; Servo to Query

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandQueryServos

    jmp TestsFailed


TestSerialProcessCommandQueryServosTwoServosFirstInvalidServoCheckResults :

    ; The call should leave X pointing at the invalid servo in the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 2)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 2)
    breq PC+3
    jmp TestsFailed

    ; A query doesn't change anything

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

TestSerialProcessCommandQueryServosTwoServosSecondInvalidServo :

    ldi temp1, 78
    mov testIndex, temp1
    
    ldi temp1, 4                            ; Two servos to Query, 2 bytes of additional command info
    mov sCommandLength, temp1               
                                            
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 2                             
    st X+, temp1                            ; Number of servos in a complete command

    ldi temp1, 0                             
    st X+, temp1                            ; Servo to Query

    ldi temp1, NUM_SERVOS + 1
    st X, temp1                             ; Servo to Query

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandQueryServos

    jmp TestsFailed


TestSerialProcessCommandQueryServosTwoServosSecondInvalidServoCheckResults :

    ; The call should leave X pointing at the invalid servo in the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 3)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 3)
    breq PC+3
    jmp TestsFailed

    ; A query doesn't change anything

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


TestSerialProcessCommandQueryServosTooManyServosToQuery :

    ldi temp1, 79
    mov testIndex, temp1
    
    ldi temp1, 2                            ; Initial 'calculate command length' call
    mov sCommandLength, temp1               
                                            
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, NUM_SERVOS + 1               ; Too many servos
    st X, temp1                            
    
    jmp SerialProcessCommandQueryServos

    jmp TestsFailed


TestSerialProcessCommandQueryServosTooManyServosToQueryCheckResults :

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


TestSerialProcessCommandQueryAllNoneMoving :

    ldi temp1, 80
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandQueryAll

    jmp TestsFailed


TestSerialProcessCommandQueryAllNoneMovingCheckResults :

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

    ldi temp1, 28
    cpi temp1, NUM_SERVOS               ; due to how our serial output buffer works this test wont work with
    brge PC+3                           ; a NUM_SERVOS value of more than 28...
    jmp TestsFailed                    

    ld temp1, X+
    cpi temp1, (1 + (9 * NUM_SERVOS))   ; there should have been 1 call for the echo plus 9 calls per servo
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command 
    breq PC+3
    jmp TestsFailed

    clr temp2
    
TestSerialProcessCommandQueryAllNoneMovingCheckResultsLoop :

    ld temp1, X+
    cpi temp1, 0xFC         ; Query servo response
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cp temp1, temp2         ; servo index
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; min posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFE         ; max posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x7F         ; centre posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x7F         ; current posn
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step every 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; target pos 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; step size 
    breq PC+3
    jmp TestsFailed

    inc temp2
    cpi temp2, NUM_SERVOS
    brne TestSerialProcessCommandQueryAllNoneMovingCheckResultsLoop

    inc testResult
    ret

