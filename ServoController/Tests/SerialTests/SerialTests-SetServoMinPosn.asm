TestSerialProcessCommandSetServoMinPosn :

    ldi temp1, 15
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0                            
    st X+, temp1                            ; servo index to change

    ldi temp1, 20                            
    st X, temp1                             ; new min value

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetServoMinPosn

    rjmp TestsFailed


TestSerialProcessCommandSetServoMinPosnCheckResults : 

    ; The call should leave X pointing at the config value that we have changed...

    cpi XL, LOW(POSITION_DATA_START + MIN_POS_OFFSET)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + MIN_POS_OFFSET)
    breq PC+2
    rjmp TestsFailed

    ld temp1, X                     ; validate that we changed the value we wanted to change
    cpi temp1, 20                   ; to the correct value
    breq PC+2
    rjmp TestsFailed        

    clr temp1                       ; reset the value to its starting value 
    st X, temp1

    call ValidatePositionDataIsUnchanged   ; and then make sure nothing else was changed

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

TestSerialProcessCommandSetServoMinPosnInvalidServo :

    ldi temp1, 16
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, NUM_SERVOS + 1                            
    st X+, temp1                            ; servo index to change

    ldi temp1, 20                            
    st X, temp1                             ; new min value

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetServoMinPosn

    rjmp TestsFailed


TestSerialProcessCommandSetServoMinPosnInvalidServoCheckResults : 

    ; The call should leave X pointing into the serial input buffer

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

TestSerialProcessCommandSetServoMinPosnMinLargerThanMax :

    ldi temp1, 17
    mov testIndex, temp1
    
    ldi XL, LOW(POSITION_DATA_START)     
    ldi XH, HIGH(POSITION_DATA_START)

    adiw X, MAX_POS_OFFSET                      ; update the max pos for servo 0

    ldi temp1, 20
    st X, temp1

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0
    st X+, temp1                            ; servo index to change

    ldi temp1, 21                            
    st X, temp1                             ; new min value

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetServoMinPosn

    rjmp TestsFailed


TestSerialProcessCommandSetServoMinPosnMinLargerThanMaxCheckResults : 

    ; The call should leave X pointing to the max value of the first set of servo data

    cpi XL, LOW(POSITION_DATA_START + MAX_POS_OFFSET)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + MAX_POS_OFFSET)
    breq PC+2
    rjmp TestsFailed

    ; Nothing was changed because the call failed

    ld temp1, X                             ; check that the max pos wasnt changed
    cpi temp1, 20
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 0xFE
    st X, temp1                             ; reset the max pos for servo 0

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should have been 1 call
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xF5         ; posn out of range
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandSetServoMinPosnMinEqualToMax :

    ldi temp1, 18
    mov testIndex, temp1
    
    ldi XL, LOW(POSITION_DATA_START)     
    ldi XH, HIGH(POSITION_DATA_START)

    adiw X, MAX_POS_OFFSET                      ; update the max pos for servo 0

    ldi temp1, 20
    st X, temp1

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0
    st X+, temp1                            ; servo index to change

    ldi temp1, 20                            
    st X, temp1                             ; new min value

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetServoMinPosn

    rjmp TestsFailed


TestSerialProcessCommandSetServoMinPosnMinEqualToMaxCheckResults : 

    ; The call should leave X pointing at the config value that we have changed...

    cpi XL, LOW(POSITION_DATA_START + MIN_POS_OFFSET)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + MIN_POS_OFFSET)
    breq PC+2
    rjmp TestsFailed

    ld temp1, X                     ; validate that we changed the value we wanted to change
    cpi temp1, 20                   ; to the correct value
    breq PC+2
    rjmp TestsFailed        

    clr temp1                       ; reset the value to its starting value 
    st X+, temp1                    ; and step to max pos

    ldi temp1, 0xFE                 ; set max back to its original value
    st X, temp1

    call ValidatePositionDataIsUnchanged   ; and then make sure nothing else was changed

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
