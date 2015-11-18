TestSerialProcessCommandSetPosn :

    ldi temp1, 30
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0
    st X+, temp1                            ; servo index to change

    ldi temp1, 20
    st X, temp1                             ; new position 

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetPosn

    rjmp TestsFailed

TestSerialProcessCommandSetPosnCheckResults :

    ; The call should leave X pointing to the step size value in the first set of servo position data

    cpi XL, LOW(POSITION_DATA_START + STEP_SIZE_OFFSET)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + STEP_SIZE_OFFSET)
    breq PC+2
    rjmp TestsFailed

    sbiw XL, STEP_SIZE_OFFSET
    adiw XL, CURRENT_POS_OFFSET

    ld temp2, X                         ; load the new current position value
    cpi temp2, 20
    breq PC+2
    rjmp TestsFailed

    ldi temp2, 0x7F                     ; reset the value back to its initial value
    st X+, temp2

    ld temp2, X+                        ; load the step every value
    cpi temp2, 0x00
    breq PC+2
    rjmp TestsFailed

    ld temp2, X+                        ; load the target position value
    cpi temp2, 0x00
    breq PC+2
    rjmp TestsFailed

    ld temp2, X+                        ; load the step size value
    cpi temp2, 0x00
    breq PC+2
    rjmp TestsFailed

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should have been 1 call
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret

TestSerialProcessCommandSetPosnInvalidServo :

    ldi temp1, 31
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, NUM_SERVOS + 1
    st X+, temp1                            ; servo index to change

    ldi temp1, 20
    st X, temp1                             ; new position 

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetPosn

    rjmp TestsFailed

TestSerialProcessCommandSetPosnInvalidServoCheckResults :

    ; The call should leave X pointing to the position value in the serial buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+2
    rjmp TestsFailed

    ; Nothing was changed because the call failed

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should have been 1 call
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xF6         ; servo out of range
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret

TestSerialProcessCommandSetPosnClearsAllExceptCurrentPos :

    ldi temp1, 46
    mov testIndex, temp1
    
    ; set the servo data to something so that we can make sure that a SetPosn resets all to zero except
    ; for current pos

    ldi XL, LOW(POSITION_DATA_START + CURRENT_POS_OFFSET)     
    ldi XH, HIGH(POSITION_DATA_START + CURRENT_POS_OFFSET)

    ldi temp1, 0xFF                         ; not a likely real value, but good enough
    st X+, temp1                            ; current pos
    st X+, temp1                            ; step every
    st X+, temp1                            ; target pos
    st X+, temp1                            ; step size
    st X+, temp1                            ; step count - this is left alone

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0
    st X+, temp1                            ; servo index to change

    ldi temp1, 20
    st X, temp1                             ; new position 

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetPosn

    rjmp TestsFailed


TestSerialProcessCommandSetPosnClearsAllExceptCurrentPosCheckResults :

    ; The call should leave X pointing to the step size value in the first set of servo position data

    cpi XL, LOW(POSITION_DATA_START + STEP_SIZE_OFFSET)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + STEP_SIZE_OFFSET)
    breq PC+2
    rjmp TestsFailed

    sbiw XL, STEP_SIZE_OFFSET
    adiw XL, CURRENT_POS_OFFSET

    ld temp2, X                         ; load the new current position value
    cpi temp2, 20
    breq PC+2
    rjmp TestsFailed

    ldi temp2, 0x7F                     ; reset the value back to its initial value
    st X+, temp2

    ld temp2, X+                        ; load the step every value
    cpi temp2, 0x00
    breq PC+2
    rjmp TestsFailed

    ld temp2, X+                        ; load the target position value
    cpi temp2, 0x00
    breq PC+2
    rjmp TestsFailed

    ld temp2, X+                        ; load the step size value
    cpi temp2, 0x00
    breq PC+2
    rjmp TestsFailed

    ld temp2, X                         ; load the step count value - this hasn't been touched
    cpi temp2, 0xFF
    breq PC+2
    rjmp TestsFailed

    clr temp2                           ; reset the value back to its initial value
    st X+, temp2

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should have been 1 call
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandSetPosnWithCentreAdjustDownAndMaxAdjust :

    ldi temp1, 47
    mov testIndex, temp1
   
      ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    ldi temp2, 1                ; adust on out of range
    st X, temp2

    ; Set the max value for this servo
    
    ldi XL, LOW(POSITION_DATA_START + MAX_POS_OFFSET)
    ldi XH, HIGH(POSITION_DATA_START + MAX_POS_OFFSET)

    ldi temp1, 20           ; set the max position for this servo to 20...
    st X, temp1

    ; Set the centre adjust for this servo

    ldi XL, LOW(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)
    ldi XH, HIGH(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)

    ldi temp1, 0x7D           ; set the centre position for this servo to 0x7D rather than 0x7F
    st X, temp1


    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0
    st X+, temp1                            ; servo index to change

    ldi temp1, 30
    st X, temp1                             ; new position 

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetPosn

    rjmp TestsFailed


TestSerialProcessCommandSetPosnWithCentreAdjustDownAndMaxAdjustCheckResults :

    ; The call should leave X pointing to the step size value in the first set of servo position data

    cpi XL, LOW(POSITION_DATA_START + STEP_SIZE_OFFSET)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + STEP_SIZE_OFFSET)
    breq PC+2
    rjmp TestsFailed

    sbiw XL, STEP_SIZE_OFFSET
    adiw XL, MAX_POS_OFFSET

    ld temp2, X                         ; load the max value
    cpi temp2, 20                       
    breq PC+2
    rjmp TestsFailed

    ldi temp2, 0xFE                     ; reset to default value
    st X+, temp2

    ld temp2, X                         ; load the centre adjust
    cpi temp2, 0x7D                       
    breq PC+2
    rjmp TestsFailed

    ldi temp2, 0x7F                     ; reset to default value
    st X+, temp2

    ld temp2, X                         ; load the new current position value
    cpi temp2, 18                       ; max is 20, centre adjust is -2
    breq PC+2
    rjmp TestsFailed

    ldi temp2, 0x7F                     ; reset the value back to its initial value
    st X+, temp2

    ld temp2, X+                        ; load the step every value
    cpi temp2, 0x00
    breq PC+2
    rjmp TestsFailed

    ld temp2, X+                        ; load the target position value
    cpi temp2, 0x00
    breq PC+2
    rjmp TestsFailed

    ld temp2, X+                        ; load the step size value
    cpi temp2, 0x00
    breq PC+2
    rjmp TestsFailed

    ld temp2, X                         ; load the step count value - this hasn't been touched
    cpi temp2, 0x00
    breq PC+2
    rjmp TestsFailed

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should have been 1 call
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+2
    rjmp TestsFailed

    ; now validate that the adjusted position value was echoed back

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ld temp1, X+                            ; servo index to change
    cpi temp1, 0
    breq PC+2
    rjmp TestsFailed
            
    ld temp1, X+                            ; adjusted posn value
    cpi temp1, 20
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret
