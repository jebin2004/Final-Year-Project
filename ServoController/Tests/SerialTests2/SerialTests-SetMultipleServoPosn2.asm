TestSerialProcessCommandSetMultipleServoPosn2SetsRealCommandLength :

    ldi temp1, 110
    mov testIndex, temp1
    
    ldi temp1, 2                            ; When called with a command length of 2  
    mov sCommandLength, temp1               ; we need to read the number of servos and 
                                            ; calculate the real command length

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 5                             
    st X, temp1                             ; Number of servos in a complete command

    jmp SerialProcessCommandSetMultipleServoPosn2

    jmp TestsFailed


TestSerialProcessCommandSetMultipleServoPosn2SetsRealCommandLengthCheckResults :

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
    ; Query 5 servos, 1 byte command code, 1 byte length, 2 bytes per servo, plus 1 byte
    ; for the min step size..

    ldi temp1, 13
    cp sCommandLength, temp1
    breq PC+3
    jmp TestsFailed

    ldi temp1, 11
    cp sExpectedBytes, temp1
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandSetMultipleServoPosn2ThreeServos100x50x25MinStep10 :

    ldi temp1, 111
    mov testIndex, temp1

    ; setup data

    ldi temp1, 9                            ; set command length to the correct value
    mov sCommandLength, temp1

    ldi XL,  LOW(SERIAL_DATA_START)         ; Note that we MUST set the command code
    ldi XH,  HIGH(SERIAL_DATA_START)

    ldi temp1, 0x51                         ; command code
    st X+, temp1

    ldi temp1, 3                             
    st X+, temp1                            ; Number of servos in the command

    ldi temp1, 2
    st X+, temp1                            ; Servo index

    ldi temp1, 25                             
    st X+, temp1                            ; Servo position

    ldi temp1, 0                             
    st X+, temp1                            ; Servo index

    ldi temp1, 100                             
    st X+, temp1                            ; Servo position

    ldi temp1, 1                             
    st X+, temp1                            ; Servo index

    ldi temp1, 50
    st X+, temp1                            ; Servo position

    ldi temp1, 10                           ; min step size
    st X+, temp1

    ldi XL, LOW(POSITION_DATA_START + CURRENT_POS_OFFSET)     
    ldi XH, HIGH(POSITION_DATA_START + CURRENT_POS_OFFSET)

    clr temp1
    st X, temp1                             ; set current posn for servo to 0

    adiw X, BYTES_PER_SERVO                 ; next servo

    clr temp1
    st X, temp1                             ; set current posn for servo to 0

    adiw X, BYTES_PER_SERVO                 ; next servo

    clr temp1
    st X, temp1                             ; set current posn for servo to 0

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)           ; set X to the correct location
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetMultipleServoPosn2

    jmp TestsFailed


TestSerialProcessCommandSetMultipleServoPosn2ThreeServos100x50x25MinStep10CheckResults :

    ; The call should leave X pointing to the STEP_EVERY_OFFSET value of the last
    ; servo that we moved
    
    cpi XL, LOW(POSITION_DATA_START + STEP_EVERY_OFFSET + (2 * BYTES_PER_SERVO))
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + STEP_EVERY_OFFSET + (2 * BYTES_PER_SERVO))
    breq PC+3
    jmp TestsFailed

    rcall ValidateWorkspaceDataIsAsExpected2

    ldi XL, LOW(POSITION_DATA_START + CURRENT_POS_OFFSET)     
    ldi XH, HIGH(POSITION_DATA_START + CURRENT_POS_OFFSET)

    ; now validate that we changed the data that we expected to change

    ; servo 0

    ld temp1, X                         ; current posn
    cpi temp1, 0
    breq PC+3
    jmp TestsFailed
    ldi temp1, 0x7F
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; step every
    cpi temp1, 1
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; target position 
    cpi temp1, 100
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; step size
    cpi temp1, 10
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    adiw X, 4                           ; step to the current posn offset of the next 
                                        ; servo

    ; servo 1

    ld temp1, X                         ; current posn
    cpi temp1, 0
    breq PC+3
    jmp TestsFailed
    ldi temp1, 0x7F
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; step every
    cpi temp1, 2
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; target position 
    cpi temp1, 50
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; step size
    cpi temp1, 10
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    adiw X, 4                           ; step to the current posn offset of the next 
                                        ; servo

    ; servo 2

    ld temp1, X                         ; current posn
    cpi temp1, 0
    breq PC+3
    jmp TestsFailed
    ldi temp1, 0x7F
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; step every
    cpi temp1, 4
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; target position 
    cpi temp1, 25
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; step size
    cpi temp1, 10
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value


    ; and that we didn't change anything else

    rcall ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 2            ; there should have been 1 call with 1 byte of data
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 9            ; echo command includes non zero sCommandLength
    breq PC+3
    jmp TestsFailed

    ; validate the echoed data...

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    clr temp2

    ld temp1, X
    cpi temp1, 3                            ; Number of servos in the command
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 2                            ; Servo index
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 25                           ; Servo position
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 0                            ; Servo index
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 100                          ; Servo position
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 1                            ; Servo index
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 50                           ; Servo position
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 10                           ; min step size
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    rcall ValidateSerialInputBufferIsUnchanged

    inc testResult
    ret

ValidateWorkspaceDataIsAsExpected2 :

    ; we can check the final calculated values...

    ldi XL,  LOW(MULTI_MOVE_WORKSPACE_START)                        ; 1st entry
    ldi XH,  HIGH(MULTI_MOVE_WORKSPACE_START)

    ; first servo

    ld temp1, X                 ; servo index
    cpi temp1, 0                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; target position 
    cpi temp1, 100              ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; current position 
    cpi temp1, 0                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; steps required
    cpi temp1, 100              ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; step when 
    cpi temp1, 1                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; step size
    cpi temp1, 10               ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ; second servo
    
    ld temp1, X                 ; servo index
    cpi temp1, 1                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; target position 
    cpi temp1, 50               ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; current position 
    cpi temp1, 0                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; steps required
    cpi temp1, 50               ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; step when 
    cpi temp1, 2                ; updated
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; step size
    cpi temp1, 10               ; updated 
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ; third servo

    ld temp1, X                 ; servo index
    cpi temp1, 2                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; target position 
    cpi temp1, 25               ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; current position 
    cpi temp1, 0                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; steps required
    cpi temp1, 25               ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; step when 
    cpi temp1, 4                ; updated
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; step size
    cpi temp1, 10               ; updated 
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    call ValidateMultiMoveWorkspaceIsUnchanged    

    ret

    // bug with a move where the last servo doesnt have to move at all, for some reason
    // servo 2 moves to the last servo's position 250, 233, 130 move to 1, 233, 130
    // leaves servo 2 at 1 with a step when on 110 and a step size of 249

TestSerialProcessCommandSetMultipleServoPosn2ThreeServos249x0x0MinStep6 :

    ldi temp1, 112
    mov testIndex, temp1

    ; setup data

    ldi temp1, 9                            ; set command length to the correct value
    mov sCommandLength, temp1

    ldi XL,  LOW(SERIAL_DATA_START)         ; Note that we MUST set the command code
    ldi XH,  HIGH(SERIAL_DATA_START)

    ldi temp1, 0x51                         ; command code
    st X+, temp1

    ldi temp1, 3                             
    st X+, temp1                            ; Number of servos in the command

    ldi temp1, 0
    st X+, temp1                            ; Servo index

    ldi temp1, 1                             
    st X+, temp1                            ; Servo position

    ldi temp1, 1                             
    st X+, temp1                            ; Servo index

    ldi temp1, 233                             
    st X+, temp1                            ; Servo position

    ldi temp1, 2                             
    st X+, temp1                            ; Servo index

    ldi temp1, 130
    st X+, temp1                            ; Servo position

    ldi temp1, 6                            ; min step size
    st X+, temp1

    ldi XL, LOW(POSITION_DATA_START + CURRENT_POS_OFFSET)     
    ldi XH, HIGH(POSITION_DATA_START + CURRENT_POS_OFFSET)

    ldi temp1, 250
    st X, temp1                             ; set current posn for servo to 250

    adiw X, BYTES_PER_SERVO                 ; next servo

    ldi temp1, 233
    st X, temp1                             ; set current posn for servo to 233

    adiw X, BYTES_PER_SERVO                 ; next servo

    ldi temp1, 130
    st X, temp1                             ; set current posn for servo to 130

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)           ; set X to the correct location
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetMultipleServoPosn2

    jmp TestsFailed


TestSerialProcessCommandSetMultipleServoPosn2ThreeServos249x0x0MinStep6CheckResults :

    ; The call should leave X pointing to the STEP_EVERY_OFFSET value of the last
    ; servo that we moved (which happens to be servo 1)
    
    cpi XL, LOW(POSITION_DATA_START + STEP_EVERY_OFFSET + BYTES_PER_SERVO)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + STEP_EVERY_OFFSET + BYTES_PER_SERVO)
    breq PC+3
    jmp TestsFailed

    rcall ValidateWorkspaceDataIsAsExpected2a

    ldi XL, LOW(POSITION_DATA_START + CURRENT_POS_OFFSET)     
    ldi XH, HIGH(POSITION_DATA_START + CURRENT_POS_OFFSET)

    ; now validate that we changed the data that we expected to change

    ; servo 0

    ld temp1, X                         ; current posn
    cpi temp1, 250
    breq PC+3
    jmp TestsFailed
    ldi temp1, 0x7F
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; step every
    cpi temp1, 1
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; target position 
    cpi temp1, 1
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; step size
    cpi temp1, 6
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    adiw X, 4                           ; step to the current posn offset of the next 
                                        ; servo

    ; servo 1

    ld temp1, X                         ; current posn
    cpi temp1, 233
    breq PC+3
    jmp TestsFailed
    ldi temp1, 0x7F
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; step every
    cpi temp1, 0
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; target position 
    cpi temp1, 233
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; step size
    cpi temp1, 0
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    adiw X, 4                           ; step to the current posn offset of the next 
                                        ; servo

    ; servo 2

    ld temp1, X                         ; current posn
    cpi temp1, 130
    breq PC+3
    jmp TestsFailed
    ldi temp1, 0x7F
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; step every
    cpi temp1, 0
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; target position 
    cpi temp1, 130
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; step size
    cpi temp1, 0
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value


    ; and that we didn't change anything else

    rcall ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 2            ; there should have been 1 call with 1 byte of data
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 9            ; echo command includes non zero sCommandLength
    breq PC+3
    jmp TestsFailed

    ; validate the echoed data...

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    clr temp2

    ld temp1, X
    cpi temp1, 3                            ; Number of servos in the command
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 0                            ; Servo index
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 1                            ; Servo position
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 1                            ; Servo index
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 233                          ; Servo position
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 2                            ; Servo index
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 130                          ; Servo position
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 6                            ; min step size
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    rcall ValidateSerialInputBufferIsUnchanged

    inc testResult
    ret

ValidateWorkspaceDataIsAsExpected2a :

    ; we can check the final calculated values...

    ldi XL,  LOW(MULTI_MOVE_WORKSPACE_START)                        ; 1st entry
    ldi XH,  HIGH(MULTI_MOVE_WORKSPACE_START)

    ; first servo

    ld temp1, X                 ; servo index
    cpi temp1, 0                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; target position 
    cpi temp1, 1                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; current position 
    cpi temp1, 250
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; steps required
    cpi temp1, 249              
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; step when 
    cpi temp1, 1                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; step size
    cpi temp1, 6                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ; second servo
    
    ld temp1, X                 ; servo index
    cpi temp1, 2                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; target position 
    cpi temp1, 130
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; current position 
    cpi temp1, 130
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; steps required
    cpi temp1, 0
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; step when 
    cpi temp1, 0                ; updated
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; step size
    cpi temp1, 0                ; updated 
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ; third servo

    ld temp1, X                 ; servo index
    cpi temp1, 1                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; target position 
    cpi temp1, 233
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; current position 
    cpi temp1, 233
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; steps required
    cpi temp1, 0
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; step when 
    cpi temp1, 0                ; updated
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; step size
    cpi temp1, 0                ; updated 
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    call ValidateMultiMoveWorkspaceIsUnchanged    

    ret
