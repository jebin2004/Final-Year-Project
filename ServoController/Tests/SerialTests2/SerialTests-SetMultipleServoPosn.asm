TestSerialProcessCommandSetMultipleServoPosnSetsRealCommandLength :

    ldi temp1, 81
    mov testIndex, temp1
    
    ldi temp1, 2                            ; When called with a command length of 2  
    mov sCommandLength, temp1               ; we need to read the number of servos and 
                                            ; calculate the real command length

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 5                             
    st X, temp1                             ; Number of servos in a complete command

    jmp SerialProcessCommandSetMultipleServoPosn

    jmp TestsFailed


TestSerialProcessCommandSetMultipleServoPosnSetsRealCommandLengthCheckResults :

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
    ; Query 5 servos, 1 byte command code, 1 byte length, 2 bytes per servo...

    ldi temp1, 12
    cp sCommandLength, temp1
    breq PC+3
    jmp TestsFailed

    ldi temp1, 10
    cp sExpectedBytes, temp1
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret

TestSerialProcessCommandSetMultipleServoPosnTooManyServosToSet :

    ldi temp1, 82
    mov testIndex, temp1
    
    ldi temp1, 2                            ; Initial 'calculate command length' call
    mov sCommandLength, temp1               
                                            
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, MULTI_MOVE_MAX_SERVOS + 1               ; Too many servos
    st X, temp1                            
    
    jmp SerialProcessCommandSetMultipleServoPosn

    jmp TestsFailed


TestSerialProcessCommandSetMultipleServoPosnTooManyServosToSetCheckResults :

    ; The call should leave X pointing into the serial input buffer

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

TestSerialProcessCommandSetMultipleServoPosnTwoServosFirstInvalid :

    ldi temp1, 83
    mov testIndex, temp1
    
    ldi temp1, 6                            ; command length is 4, 1 for the command code, 1 for 
    mov sCommandLength, temp1               ; the length (of 2) and 2 * 2 bytes of servo data

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 2                             
    st X+, temp1                            ; Number of servos in the command

    ldi temp1, NUM_SERVOS + 1                             
    st X+, temp1                            ; Servo index

    ldi temp1, 0                             
    st X+, temp1                            ; Servo position

    ldi temp1, 0                             
    st X+, temp1                            ; Servo index

    ldi temp1, 0                             
    st X, temp1                             ; Servo position

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetMultipleServoPosn

    jmp TestsFailed

TestSerialProcessCommandSetMultipleServoPosnTwoServosFirstInvalidCheckResults : 

    ; The call should leave X pointing into the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 2)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 2)
    breq PC+3
    jmp TestsFailed

    ; No change, we didn't do anything but calculate the command length

    call ValidatePositionDataIsUnchanged

    ; check that we didn't change the command length 

    ldi temp1, 6
    cp sCommandLength, temp1
    breq PC+3
    jmp TestsFailed
    
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

TestSerialProcessCommandSetMultipleServoPosnTwoServosSecondInvalid :

    ldi temp1, 84
    mov testIndex, temp1
    
    ldi temp1, 6                            ; command length is 4, 1 for the command code, 1 for 
    mov sCommandLength, temp1               ; the length (of 2) and 2 * 2 bytes of servo data

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 2                             
    st X+, temp1                            ; Number of servos in the command

    ldi temp1, 0                             
    st X+, temp1                            ; Servo index

    ldi temp1, 0                             
    st X+, temp1                            ; Servo position

    ldi temp1, NUM_SERVOS + 1                             
    st X+, temp1                            ; Servo index

    ldi temp1, 0                             
    st X, temp1                             ; Servo position

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetMultipleServoPosn

    jmp TestsFailed

TestSerialProcessCommandSetMultipleServoPosnTwoServosSecondInvalidCheckResults : 

    ; The call should leave X pointing into the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 4)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 4)
    breq PC+3
    jmp TestsFailed

    ; No change, we didn't do anything but calculate the command length

    call ValidatePositionDataIsUnchanged

    ; check that we didn't change the command length 

    ldi temp1, 6
    cp sCommandLength, temp1
    breq PC+3
    jmp TestsFailed
    
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
    cpi temp1, 4            ; the index of the parameter that was incorrect
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret

TestSerialProcessCommandSetMultipleServoPosnTwoServosFirstPosnInvalid :

    ldi temp1, 85
    mov testIndex, temp1
    
    ldi temp1, 6                            ; command length is 4, 1 for the command code, 1 for 
    mov sCommandLength, temp1               ; the length (of 2) and 2 * 2 bytes of servo data

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 2                             
    st X+, temp1                            ; Number of servos in the command

    ldi temp1, 0                             
    st X+, temp1                            ; Servo index

    ldi temp1, 0xFF                             
    st X+, temp1                            ; Servo position

    ldi temp1, 0                             
    st X+, temp1                            ; Servo index

    ldi temp1, 0                             
    st X, temp1                             ; Servo position

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetMultipleServoPosn

    jmp TestsFailed

TestSerialProcessCommandSetMultipleServoPosnTwoServosFirstPosnInvalidCheckResults : 

    ; The call should leave X pointing into the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 2)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 2)
    breq PC+3
    jmp TestsFailed

    ; No change, we didn't do anything but calculate the command length

    call ValidatePositionDataIsUnchanged

    ; check that we didn't change the command length 

    ldi temp1, 6
    cp sCommandLength, temp1
    breq PC+3
    jmp TestsFailed
    
    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 2            ; there should have been 1 call with 1 byte of data
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xF1         ; serial param out of range (function version)
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 3            ; the index of the parameter that was incorrect
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandSetMultipleServoPosnTwoServosSecondPosnInvalid :

    ldi temp1, 86
    mov testIndex, temp1
    
    ldi temp1, 6                            ; command length is 4, 1 for the command code, 1 for 
    mov sCommandLength, temp1               ; the length (of 2) and 2 * 2 bytes of servo data

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 2                             
    st X+, temp1                            ; Number of servos in the command

    ldi temp1, 0                             
    st X+, temp1                            ; Servo index

    ldi temp1, 0                             
    st X+, temp1                            ; Servo position

    ldi temp1, 0                             
    st X+, temp1                            ; Servo index

    ldi temp1, 0xFF                             
    st X, temp1                             ; Servo position

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetMultipleServoPosn

    jmp TestsFailed

TestSerialProcessCommandSetMultipleServoPosnTwoServosSecondPosnInvalidCheckResults : 

    ; The call should leave X pointing into the serial input buffer

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 4)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 4)
    breq PC+3
    jmp TestsFailed

    ; No change, we didn't do anything but calculate the command length

    call ValidatePositionDataIsUnchanged

    ; check that we didn't change the command length 

    ldi temp1, 6
    cp sCommandLength, temp1
    breq PC+3
    jmp TestsFailed
    
    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 2            ; there should have been 1 call with 1 byte of data
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xF1         ; serial param out of range (function version)
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 5            ; the index of the parameter that was incorrect
    breq PC+3
    jmp TestsFailed

    inc testResult
    ret

// 87 - Invalid posn (due to min/max) error
// 88 - Invalid posn (due to min/max) adjust

// duplicate servo? we dont check in the query and stop commands
// we could check by setting bits in a byte and testing to see if the bit is set before setting the new servo bit...

; Testing the actual functionality of SerialProcessCommandSetMultipleServoPosn backwards...


TestSerialProcessCommandSetMultipleServoPosnCalculateFactorsLoopComplete : 

    ldi temp1, 90
    mov testIndex, temp1
    
    ldi ZL,  LOW(MULTI_MOVE_WORKSPACE_START)                             ; 1st entry
    ldi ZH,  HIGH(MULTI_MOVE_WORKSPACE_START)

    ; set up the entries that we'd expect after the rest of the code had completed


    ldi temp1, 3                    ; number of servos to process
    mov numServos, temp1

    ldi XL,  LOW(MULTI_MOVE_WORKSPACE_START)                        ; 1st entry
    ldi XH,  HIGH(MULTI_MOVE_WORKSPACE_START)

    ; first servo

    ldi temp1, 0                ; servo index
    st X+, temp1
    ldi temp1, 100              ; target position
    st X+, temp1
    ldi temp1, 0                ; current position
    st X+, temp1
    ldi temp1, 100              ; steps required
    st X+, temp1
    ldi temp1, 1                ; initial factor of 1st entry is always 1
    st X+, temp1
    st X+, temp1                ; for both factors

    ; second servo
    
    ldi temp1, 1                ; servo index
    st X+, temp1
    ldi temp1, 50               ; target position
    st X+, temp1
    ldi temp1, 0                ; current position
    st X+, temp1
    ldi temp1, 50               ; steps required
    st X+, temp1
    ldi temp1, 2                ; step when
    st X+, temp1                
    ldi temp1, 1                ; step size
    st X+, temp1                

    ; third servo
    
    ldi temp1, 2                ; servo index
    st X+, temp1
    ldi temp1, 25               ; target position
    st X+, temp1
    ldi temp1, 0                ; current position
    st X+, temp1
    ldi temp1, 25               ; steps required
    st X+, temp1
    ldi temp1, 4                ; step when
    st X+, temp1                
    ldi temp1, 1                ; step size
    st X+, temp1                

    ; push the min step size and min step frequency onto the stack

    ldi temp1, 1
    push temp1
    push temp1

    jmp SerialProcessCommandSetMultipleServoPosnCalculateFactorsLoopComplete

    jmp TestsFailed


TestSerialProcessCommandSetMultipleServoPosnCalculateFactorsLoopCompleteCheckResults :

    ; The call should leave X pointing to the STEP_EVERY_OFFSET value of the last
    ; servo that we moved
    
    cpi XL, LOW(POSITION_DATA_START + STEP_EVERY_OFFSET + (2 * BYTES_PER_SERVO))
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + STEP_EVERY_OFFSET + (2 * BYTES_PER_SERVO))
    breq PC+3
    jmp TestsFailed

    ; the workspace data should not have changed

    rcall ValidateWorkspaceDataIsAsExpected

    rcall ValidatePositionDataIsAsExpected

    rcall ValidateNoSerialOutputProduced

    inc testResult
    ret

ValidateNoSerialOutputProduced : 

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 0            ; there should have been zero calls
    breq PC+3
    jmp TestsFailed

    ret

ValidatePositionDataIsAsExpected :

    ldi XL, LOW(POSITION_DATA_START + CURRENT_POS_OFFSET)     
    ldi XH, HIGH(POSITION_DATA_START + CURRENT_POS_OFFSET)

    ; now validate that we changed the data that we expected to change

    ; servo 0

    ld temp1, X                         ; current pos
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
    cpi temp1, 1
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    adiw X, 4                           ; step to the current pos offset of the next 
                                        ; servo

    ; servo 1

    ld temp1, X                         ; current pos
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
    cpi temp1, 1
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    adiw X, 4                           ; step to the current pos offset of the next 
                                        ; servo

    ; servo 2

    ld temp1, X                         ; current pos
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
    cpi temp1, 1
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    call ValidatePositionDataIsUnchanged

    ret

ValidateWorkspaceDataIsAsExpected :

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
    cpi temp1, 1                ; no change
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
    cpi temp1, 1                ; updated 
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
    cpi temp1, 1                ; updated 
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    call ValidateMultiMoveWorkspaceIsUnchanged    

    ret


TestSerialProcessCommandSetMultipleServoPosnCalculateFactors :

    ldi temp1, 91
    mov testIndex, temp1

    ldi temp1, 3                        ; number of servos we're processing
    mov numServos, temp1

    ldi temp1, 1
    mov r12, temp1                      ; set the initial factors
    mov r13, temp1

    ; set up the data...

    ldi XL,  LOW(MULTI_MOVE_WORKSPACE_START)                        ; 1st entry
    ldi XH,  HIGH(MULTI_MOVE_WORKSPACE_START)

    ; first servo

    ldi temp1, 0                ; servo index
    st X+, temp1
    ldi temp1, 100              ; target position
    st X+, temp1
    ldi temp1, 0                ; current position
    st X+, temp1
    ldi temp1, 100              ; steps required
    st X+, temp1
    ldi temp1, 1                ; initial factor of 1st entry is always 1
    st X+, temp1
    st X+, temp1                ; for both factors

    ; second servo
    
    ldi temp1, 1                ; servo index
    st X+, temp1
    ldi temp1, 50               ; target position
    st X+, temp1
    ldi temp1, 0                ; current position
    st X+, temp1
    ldi temp1, 50               ; steps required
    st X+, temp1
    clr temp1
    st X+, temp1                ; initial factor of 2nd and subsequent entries is calculated,
    st X+, temp1                ; so init both to zero

    ; third servo
    
    ldi temp1, 2                ; servo index
    st X+, temp1
    ldi temp1, 25               ; target position
    st X+, temp1
    ldi temp1, 0                ; current position
    st X+, temp1
    ldi temp1, 25               ; steps required
    st X+, temp1
    clr temp1
    st X+, temp1                ; initial factor of 2nd and subsequent entries is calculated,
    st X+, temp1                ; so init both to zero

    ldi temp1, 1
    mov count, temp1

    ldi temp1, 3
    mov numServos, temp1

    ldi XL,  LOW(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET)                        ; 1st entry
    ldi XH,  HIGH(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET)

    ldi ZL,  LOW(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_BYTES_PER_SERVO + MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET) ; 2nd entry
    ldi ZH,  HIGH(MULTI_MOVE_WORKSPACE_START + MULTI_MOVE_WORKSPACE_BYTES_PER_SERVO + MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET)

    ; push the min step size and min step frequency onto the stack

    ldi temp1, 1
    push temp1
    push temp1

    jmp SerialProcessCommandSetMultipleServoPosnCalculateFactors

    jmp TestsFailed

TestSerialProcessCommandSetMultipleServoPosnCalculateFactorsCheckResults :

    ; output is the same

    rjmp TestSerialProcessCommandSetMultipleServoPosnCalculateFactorsLoopCompleteCheckResults

TestSerialProcessCommandSetMultipleServoPosnSortStart :

    ldi temp1, 92
    mov testIndex, temp1

    ; set up the data...
    
    ldi temp1, 3                        ; number of servos we're processing
    mov numServos, temp1

    ; due to the fact that we always extract the min step size and min step freq from the
    ; command buffer (even when the command itself doesn't contain them and they're added
    ; during command parsing) we need to set up a valid command buffer here

    ldi XL,  LOW(SERIAL_DATA_START)                        ; Note that we MUST set the command code
    ldi XH,  HIGH(SERIAL_DATA_START)

    clr temp1

    ldi temp2, 0x50

    st X+, temp2                ; command code    required
    st X+, temp1                ; command length  not used from the command buffer
    st X+, temp1                ; servo index     not used from the command buffer
    st X+, temp1                ; servo posn      not used from the command buffer
    st X+, temp1                ; servo index     not used from the command buffer
    st X+, temp1                ; servo posn      not used from the command buffer
    st X+, temp1                ; servo index     not used from the command buffer
    st X+, temp1                ; servo posn      not used from the command buffer
    ldi temp2, 1
    st X+, temp2                ; min step size   required, added by command parser
    st X+, temp2                ; min step freq   required, added by command parser

    ldi temp1, 8
    mov sCommandLength, temp1   ; required

    ; now set the workspace data to how the previous stage would have left it

    ldi XL,  LOW(MULTI_MOVE_WORKSPACE_START)                        ; 1st entry
    ldi XH,  HIGH(MULTI_MOVE_WORKSPACE_START)

    ; first servo

    ldi temp1, 2                ; servo index
    st X+, temp1
    ldi temp1, 25               ; target position
    st X+, temp1
    ldi temp1, 0                ; current position
    st X+, temp1
    ldi temp1, 25               ; steps required
    st X+, temp1
    ldi temp1, 0                ; the rest to be calculated
    st X+, temp1
    st X+, temp1

    ; second servo

    ldi temp1, 0                ; servo index
    st X+, temp1
    ldi temp1, 100              ; target position
    st X+, temp1
    ldi temp1, 0                ; current position
    st X+, temp1
    ldi temp1, 100              ; steps required
    st X+, temp1
    ldi temp1, 0                ; the rest to be calculated
    st X+, temp1
    st X+, temp1

    ; third servo
    
    ldi temp1, 1                ; servo index
    st X+, temp1
    ldi temp1, 50               ; target position
    st X+, temp1
    ldi temp1, 0                ; current position
    st X+, temp1
    ldi temp1, 50               ; steps required?s
    st X+, temp1
    ldi temp1, 0                ; the rest to be calculated

    st X+, temp1
    st X+, temp1

    ldi temp1, 3
    mov numServos, temp1

    ; push the min step size and min step frequency onto the stack

    ldi temp1, 1
    push temp1
    push temp1

    jmp SerialProcessCommandSetMultipleServoPosnSortStart

    jmp TestsFailed
    
    ret


TestSerialProcessCommandSetMultipleServoPosnSortStartCheckResults :

    ; the result is the same...

    rjmp TestSerialProcessCommandSetMultipleServoPosnCalculateFactorsLoopCompleteCheckResults


TestSerialProcessCommandSetMultipleServoPosnAfterValidation :

    ldi temp1, 93
    mov testIndex, temp1
    
    ; set up the data...
    
    ldi temp1, 3                        ; number of servos we're processing
    mov numServos, temp1

    ldi temp1, 8
    mov sCommandLength, temp1   ; required

    ldi XL,  LOW(SERIAL_DATA_START)                        ; Note that we MUST set the command code
    ldi XH,  HIGH(SERIAL_DATA_START)

    ldi temp1, 0x50                         ; command code
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

    ldi temp1, 1                             
    st X+, temp1                            ; min step size   required, added by command parser

    ldi temp1, 1                             
    st X+, temp1                            ; min step freq   required, added by command parser

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

    jmp SerialProcessCommandSetMultipleServoPosnValidationLoopEnd

    jmp TestsFailed
    
    ret


TestSerialProcessCommandSetMultipleServoPosnAfterValidationCheckResults :

    ; The call should leave X pointing to the STEP_EVERY_OFFSET value of the last
    ; servo that we moved
    
    cpi XL, LOW(POSITION_DATA_START + STEP_EVERY_OFFSET + (2 * BYTES_PER_SERVO))
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + STEP_EVERY_OFFSET + (2 * BYTES_PER_SERVO))
    breq PC+3
    jmp TestsFailed

    rcall ValidateWorkspaceDataIsAsExpected

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
    cpi temp1, 1
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
    cpi temp1, 1
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
    cpi temp1, 1
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value


    ; and that we didn't change anything else

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ld temp1, X+
    cpi temp1, 2            ; there should have been 1 call with 1 byte of data
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 8            ; echo command includes non zero sCommandLength
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
    cpi temp1, 1                            ; min step size 
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 1                            ; min frequency
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    call ValidateSerialInputBufferIsUnchanged

    inc testResult
    ret

TestSerialProcessCommandSetMultipleServoPosnThreeServos100x50x25 :

    ldi temp1, 94
    mov testIndex, temp1

    ; setup data

    ldi temp1, 8                            ; set command length to the correct value
    mov sCommandLength, temp1

    ldi XL,  LOW(SERIAL_DATA_START)         ; Note that we MUST set the command code
    ldi XH,  HIGH(SERIAL_DATA_START)

    ldi temp1, 0x50                         ; command code
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

    jmp SerialProcessCommandSetMultipleServoPosn

    jmp TestsFailed


TestSerialProcessCommandSetMultipleServoPosnThreeServos100x50x25CheckResults :

    rjmp TestSerialProcessCommandSetMultipleServoPosnAfterValidationCheckResults


TestSerialProcessCommandSetMultipleServoPosnThreeServosOneWithZeroSteps :

    ldi temp1, 95
    mov testIndex, temp1

    ; setup data

    ldi temp1, 8                            ; set command length to the correct value
    mov sCommandLength, temp1

    ldi XL,  LOW(SERIAL_DATA_START)         ; Note that we MUST set the command code
    ldi XH,  HIGH(SERIAL_DATA_START)

    ldi temp1, 0x50                         ; command code
    st X+, temp1

    ldi temp1, 3                             
    st X+, temp1                            ; Number of servos in the command

    ldi temp1, 2
    st X+, temp1                            ; Servo index

    ldi temp1, 0                             
    st X+, temp1                            ; Servo position

    ldi temp1, 0                             
    st X+, temp1                            ; Servo index

    ldi temp1, 100                             
    st X+, temp1                            ; Servo position

    ldi temp1, 1                             
    st X+, temp1                            ; Servo index

    ldi temp1, 50
    st X+, temp1                            ; Servo position

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

    jmp SerialProcessCommandSetMultipleServoPosn

    jmp TestsFailed


TestSerialProcessCommandSetMultipleServoPosnThreeServosOneWithZeroStepsCheckResults :

    ; The call should leave X pointing to the STEP_EVERY_OFFSET value of the last
    ; servo that we moved
    
    cpi XL, LOW(POSITION_DATA_START + STEP_EVERY_OFFSET + (2 * BYTES_PER_SERVO))
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + STEP_EVERY_OFFSET + (2 * BYTES_PER_SERVO))
    breq PC+3
    jmp TestsFailed

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
    cpi temp1, 1                ; no change
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
    cpi temp1, 1                ; updated 
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
    cpi temp1, 0                ; no change
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
    cpi temp1, 0                ; no change
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
    cpi temp1, 1
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
    cpi temp1, 1
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
    cpi temp1, 0
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; target position 
    cpi temp1, 0
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

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ld temp1, X+
    cpi temp1, 2            ; there should have been 1 call with 1 byte of data
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 8            ; echo command includes non zero sCommandLength
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
    cpi temp1, 0                            ; Servo position
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
    cpi temp1, 1                            ; min step size 
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 1                            ; min frequency
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    call ValidateSerialInputBufferIsUnchanged

    inc testResult
    ret


TestSerialProcessCommandSetMultipleServoPosnTwoServos100x77 :

    ldi temp1, 96
    mov testIndex, temp1

    ; setup data

    ldi temp1, 6                            ; set command length to the correct value
    mov sCommandLength, temp1

    ldi XL,  LOW(SERIAL_DATA_START)         ; Note that we MUST set the command code
    ldi XH,  HIGH(SERIAL_DATA_START)

    ldi temp1, 0x50                         ; command code
    st X+, temp1

    ldi temp1, 2                             
    st X+, temp1                            ; Number of servos in the command

    ldi temp1, 1
    st X+, temp1                            ; Servo index

    ldi temp1, 100                             
    st X+, temp1                            ; Servo position

    ldi temp1, 0                             
    st X+, temp1                            ; Servo index

    ldi temp1, 77                             
    st X+, temp1                            ; Servo position

    ldi XL, LOW(POSITION_DATA_START + CURRENT_POS_OFFSET)     
    ldi XH, HIGH(POSITION_DATA_START + CURRENT_POS_OFFSET)

    clr temp1
    st X, temp1                             ; set current posn for servo to 0

    adiw X, BYTES_PER_SERVO                 ; next servo

    clr temp1
    st X, temp1                             ; set current posn for servo to 0

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; set X to the correct location
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetMultipleServoPosn

    jmp TestsFailed


TestSerialProcessCommandSetMultipleServoPosnTwoServos100x77CheckResults :

    ; The call should leave X pointing to the STEP_EVERY_OFFSET value of the last
    ; servo that we moved
    
    cpi XL, LOW(POSITION_DATA_START + STEP_EVERY_OFFSET)
    breq PC+3
    jmp TestsFailed

    cpi XH, HIGH(POSITION_DATA_START + STEP_EVERY_OFFSET)
    breq PC+3
    jmp TestsFailed

    ; we can check the final calculated values...

    ldi XL,  LOW(MULTI_MOVE_WORKSPACE_START)                        ; 1st entry
    ldi XH,  HIGH(MULTI_MOVE_WORKSPACE_START)

    ; first servo

    ld temp1, X                 ; servo index
    cpi temp1, 1                ; no change
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
    cpi temp1, 1                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ; second servo
    
    ld temp1, X                 ; servo index
    cpi temp1, 0                ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; target position 
    cpi temp1, 77               ; no change
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; current position 
    cpi temp1, 4                ; initial adjust...
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    ld temp1, X                 ; steps required
    cpi temp1, 77               ; no change
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
    cpi temp1, 3                ; updated 
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                ; reset it to zero

    call ValidateMultiMoveWorkspaceIsUnchanged    

    ldi XL, LOW(POSITION_DATA_START + CURRENT_POS_OFFSET)     
    ldi XH, HIGH(POSITION_DATA_START + CURRENT_POS_OFFSET)

    ; now validate that we changed the data that we expected to change

    ; servo 0

    ld temp1, X                         ; current posn
    cpi temp1, 4                        ; initial adjust
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
    cpi temp1, 77
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    ld temp1, X                         ; step size
    cpi temp1, 3
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
    cpi temp1, 1
    breq PC+3
    jmp TestsFailed
    clr temp1
    st X+, temp1                        ; reset to original value

    adiw X, 4                           ; step to the current posn offset of the next 
                                        ; servo

    ; and that we didn't change anything else

    call ValidatePositionDataIsUnchanged

    ; now validate that the correct mock functions were called...

    ld temp1, X+
    cpi temp1, 2            ; there should have been 1 call with 1 byte of data
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+3
    jmp TestsFailed

    ld temp1, X+
    cpi temp1, 6            ; echo command includes non zero sCommandLength
    breq PC+3
    jmp TestsFailed

    ; validate the echoed data...

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    clr temp2

    ld temp1, X
    cpi temp1, 2                            ; Number of servos in the command
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 1                            ; Servo index
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 100                          ; Servo position
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 0                            ; Servo index
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 77                           ; Servo position
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 1                            ; min step size 
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    ld temp1, X
    cpi temp1, 1                            ; min frequency
    breq PC+3
    jmp TestsFailed
    st X+, temp2                            ; reset to zero

    call ValidateSerialInputBufferIsUnchanged

    inc testResult
    ret

; now the test above but with 2 servos moving when we make the call

; 0 servos
; positive and negative steps
; 100, 20, 10
; more complex factors, most complex factors?

; max servos...

; specify step size for '1'
; specify step when for '1'
