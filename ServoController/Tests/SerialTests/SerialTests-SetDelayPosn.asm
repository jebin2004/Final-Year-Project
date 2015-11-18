TestSerialProcessCommandSetDelayPosn :

    ldi temp1, 48
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0
    st X+, temp1                            ; servo index to change

    ldi temp1, 20
    st X+, temp1                            ; new position 

    ldi temp1, 2
    st X, temp1                             ; step size

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetDelayPosn

    jmp TestsFailed

TestSerialProcessCommandSetDelayPosnCheckResults :

    ; The call should leave X pointing to the step every value in the first set of servo position data

    cpi XL, LOW(POSITION_DATA_START + STEP_EVERY_OFFSET)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + STEP_EVERY_OFFSET)
    breq PC+3
    jmp TestsFailed

    sbiw XL, STEP_EVERY_OFFSET
    adiw XL, CURRENT_POS_OFFSET

    ld temp2, X+                        ; load the existing current position value
    cpi temp2, 0x7F
    breq PC+3
    jmp TestsFailed

    ld temp2, X                         ; load the step every value
    cpi temp2, 1
    breq PC+3
    jmp TestsFailed

    clr temp2                           ; reset the value back to its initial value
    st X+, temp2

    ld temp2, X                         ; load the target position value
    cpi temp2, 20
    breq PC+3
    jmp TestsFailed

    clr temp2                           ; reset the value back to its initial value
    st X+, temp2

    ld temp2, X                         ; load the step size value
    cpi temp2, 2
    breq PC+3
    jmp TestsFailed

    clr temp2                           ; reset the value back to its initial value
    st X+, temp2

    ld temp2, X                         ; load the step count value - this hasn't been touched
    cpi temp2, 0
    breq PC+3
    jmp TestsFailed

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should have been 1 call
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandSetDelayPosnInvalidServo :

    ldi temp1, 49
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, NUM_SERVOS + 1
    st X+, temp1                            ; servo index to change

    ldi temp1, 20
    st X+, temp1                            ; new position 

    ldi temp1, 2
    st X, temp1                             ; step size

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetDelayPosn

    jmp TestsFailed

TestSerialProcessCommandSetDelayPosnInvalidServoCheckResults :

    ; The call should leave X pointing into the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+3
    jmp TestsFailed

    ; Nothing was changed because the call failed

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

TestSerialProcessCommandSetDelayPosnInvalidPosn :

    ldi temp1, 50
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0
    st X+, temp1                            ; servo index to change

    ldi temp1, 0xFF
    st X+, temp1                            ; new position 

    ldi temp1, 2
    st X, temp1                             ; step size

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetDelayPosn

    jmp TestsFailed

TestSerialProcessCommandSetDelayPosnInvalidPosnCheckResults :

    ; The call should leave X pointing into the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 2)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 2)
    breq PC+3
    jmp TestsFailed

    ; Nothing was changed because the call failed

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should have been 1 call
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xF5         ; posn out of range
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret

TestSerialProcessCommandSetDelayPosnInvalidStepSize :

    ldi temp1, 51
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0
    st X+, temp1                            ; servo index to change

    ldi temp1, 20
    st X+, temp1                            ; new position 

    ldi temp1, 0
    st X, temp1                             ; step size

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetDelayPosn

    jmp TestsFailed

TestSerialProcessCommandSetDelayPosnInvalidStepSizeCheckResults :

    ; The call should leave X pointing into the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 3)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 3)
    breq PC+3
    jmp TestsFailed

    ; Nothing was changed because the call failed

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should have been 1 call
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xF4         ; step size out of range
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret

// These next two tests simply prove that we're going through SerialValidateAndAdjustDesiredPosition which
// is tested elsewhere. We don't test all the combinations of adjustment that can be done there.

TestSerialProcessCommandSetDelayPosnPosnTooSmallWithError :

    ldi temp1, 52
    mov testIndex, temp1
    

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    ldi temp2, 0                ; error on out of range
    st X, temp2

    ; Set the max value for this servo
    
    ldi XL, LOW(POSITION_DATA_START + MIN_POS_OFFSET)
    ldi XH, HIGH(POSITION_DATA_START + MIN_POS_OFFSET)

    ldi temp1, 20           ; set the min position for this servo to 20...
    st X, temp1

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0
    st X+, temp1                            ; servo index to change

    ldi temp1, 10
    st X+, temp1                            ; new position 

    ldi temp1, 1
    st X, temp1                             ; step size

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetDelayPosn

    jmp TestsFailed


TestSerialProcessCommandSetDelayPosnPosnTooSmallWithErrorCheckResults :

    ; The call should leave X pointing to the max posn offset of the first set of servo position data

    cpi XL, LOW(POSITION_DATA_START + MAX_POS_OFFSET)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + MAX_POS_OFFSET)
    breq PC+3
    jmp TestsFailed

    sbiw X, 1               ; move back to the min posn 

    ldi temp1, 0             ; reset it to its original value
    st X, temp1

    ; Nothing was changed because the call failed

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 2            ; there should have been 1 call with 1 byte of data...
    breq PC+3
    jmp TestsFailed
    
    ld temp1, X+
    cpi temp1, 0xF1         ; param out of range function 
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 2            ; the parameter index
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandSetDelayPosnPosnTooSmallWithAdjust :

    ldi temp1, 53
    mov testIndex, temp1
    

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    ldi temp2, 1                ; adjust on out of range
    st X, temp2

    ; Set the max value for this servo
    
    ldi XL, LOW(POSITION_DATA_START + MIN_POS_OFFSET)
    ldi XH, HIGH(POSITION_DATA_START + MIN_POS_OFFSET)

    ldi temp1, 20           ; set the min position for this servo to 20...
    st X, temp1

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0
    st X+, temp1                            ; servo index to change

    ldi temp1, 10
    st X+, temp1                            ; new position 

    ldi temp1, 1
    st X, temp1                             ; step size

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetDelayPosn

    jmp TestsFailed

TestSerialProcessCommandSetDelayPosnPosnTooSmallWithAdjustCheckResults :

    ; The call should leave X pointing to the step every value in the first set of servo position data

    cpi XL, LOW(POSITION_DATA_START + STEP_EVERY_OFFSET)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + STEP_EVERY_OFFSET)
    breq PC+3
    jmp TestsFailed

    sbiw XL, STEP_EVERY_OFFSET

    ld temp2, X                         ; load and validate the minimum value that we set
    cpi temp2, 20
    breq PC+3
    jmp TestsFailed

    clr temp2                           ; reset the minimum value...
    st X, temp2

    adiw XL, CURRENT_POS_OFFSET

    ld temp2, X+                        ; load the existing current position value
    cpi temp2, 0x7F
    breq PC+3
    jmp TestsFailed

    ld temp2, X                         ; load the step every value
    cpi temp2, 1
    breq PC+3
    jmp TestsFailed

    clr temp2                           ; reset the value back to its initial value
    st X+, temp2

    ld temp2, X                         ; load the target position value
    cpi temp2, 20                       ; although we tried to set it as 10 it was limited to 20...
    breq PC+3
    jmp TestsFailed

    clr temp2                           ; reset the value back to its initial value
    st X+, temp2

    ld temp2, X                         ; load the step size value
    cpi temp2, 1
    breq PC+3
    jmp TestsFailed

    clr temp2                           ; reset the value back to its initial value
    st X+, temp2

    ld temp2, X                         ; load the step count value - this hasn't been touched
    cpi temp2, 0
    breq PC+3
    jmp TestsFailed

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should have been 1 call
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command (which echoed the modified command)
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret

