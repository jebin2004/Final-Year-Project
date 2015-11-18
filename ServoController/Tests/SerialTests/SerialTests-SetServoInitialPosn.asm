TestSerialProcessCommandSetServoInitialPosn :

    ldi temp1, 27
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 10
    st X+, temp1                            ; servo index to change

    ldi temp1, 20
    st X, temp1                             ; new position 

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetServoInitialPosn

    rjmp TestsFailed

TestSerialProcessCommandSetServoInitialPosnCheckResults :

    ; The call should leave X pointing to the initial position value for servo 10

    cpi XL, LOW(SRAM_DEFAULT_POSITION_TABLE_START + 10)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(SRAM_DEFAULT_POSITION_TABLE_START + 10)
    breq PC+2
    rjmp TestsFailed

    ld temp1, X                     ; validate that we changed the value we wanted to change
    cpi temp1, 20                   ; to the correct value
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 0x7F                 ; reset the value to its starting value 
    st X, temp1

    call ValidateDefaultPositionDataIsUnchanged   ; and then make sure nothing else was changed

    ; This call should not have touched the actual position data at all

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



TestSerialProcessCommandSetServoInitialPosnInvalidServo :

    ldi temp1, 28
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, NUM_SERVOS + 1
    st X+, temp1                            ; servo index to change

    ldi temp1, 20
    st X, temp1                             ; new position 

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetServoInitialPosn

    rjmp TestsFailed

TestSerialProcessCommandSetServoInitialPosnInvalidServoCheckResults :

    ; The call should leave X pointing to the initial position value in the serial buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+2
    rjmp TestsFailed

    ; Nothing was changed because the call failed

    call ValidateDefaultPositionDataIsUnchanged   

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


TestSerialProcessCommandSetServoInitialPosnToFF :

    ldi temp1, 29
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0
    st X+, temp1                            ; servo index to change

    ldi temp1, 0xFF
    st X, temp1                             ; new position 

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetServoInitialPosn

    rjmp TestsFailed

TestSerialProcessCommandSetServoInitialPosnToFFCheckResults :

    ; The call should leave X pointing to the initial position value in the serial buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+2
    rjmp TestsFailed

    ; Nothing was changed because the call failed

    call ValidateDefaultPositionDataIsUnchanged   

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
