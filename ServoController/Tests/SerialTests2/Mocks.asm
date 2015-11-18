SerialStart : 

    cpi testIndex, 81
    brne PC+3
    jmp TestSerialProcessCommandSetMultipleServoPosnSetsRealCommandLengthCheckResults

    cpi testIndex, 82
    brne PC+3
    jmp TestSerialProcessCommandSetMultipleServoPosnTooManyServosToSetCheckResults

    cpi testIndex, 83
    brne PC+3
    jmp TestSerialProcessCommandSetMultipleServoPosnTwoServosFirstInvalidCheckResults

    cpi testIndex, 84
    brne PC+3
    jmp TestSerialProcessCommandSetMultipleServoPosnTwoServosSecondInvalidCheckResults

    cpi testIndex, 85
    brne PC+3
    jmp TestSerialProcessCommandSetMultipleServoPosnTwoServosFirstPosnInvalidCheckResults

    cpi testIndex, 86
    brne PC+3
    jmp TestSerialProcessCommandSetMultipleServoPosnTwoServosSecondPosnInvalidCheckResults

    cpi testIndex, 90
    brne PC+3
    jmp TestSerialProcessCommandSetMultipleServoPosnCalculateFactorsLoopCompleteCheckResults

    cpi testIndex, 91
    brne PC+2
    rjmp TestSerialProcessCommandSetMultipleServoPosnCalculateFactorsCheckResults

    cpi testIndex, 92
    brne PC+2
    rjmp TestSerialProcessCommandSetMultipleServoPosnSortStartCheckResults

    cpi testIndex, 93
    brne PC+2
    rjmp TestSerialProcessCommandSetMultipleServoPosnAfterValidationCheckResults

    cpi testIndex, 94
    brne PC+2
    rjmp TestSerialProcessCommandSetMultipleServoPosnThreeServos100x50x25CheckResults

    cpi testIndex, 95
    brne PC+2
    rjmp TestSerialProcessCommandSetMultipleServoPosnThreeServosOneWithZeroStepsCheckResults

    cpi testIndex, 96
    brne PC+2
    rjmp TestSerialProcessCommandSetMultipleServoPosnTwoServos100x77CheckResults


    cpi testIndex, 110
    brne PC+2
    rjmp TestSerialProcessCommandSetMultipleServoPosn2SetsRealCommandLengthCheckResults

    cpi testIndex, 111
    brne PC+3
    jmp TestSerialProcessCommandSetMultipleServoPosn2ThreeServos100x50x25MinStep10CheckResults

    cpi testIndex, 112
    brne PC+3
    jmp TestSerialProcessCommandSetMultipleServoPosn2ThreeServos249x0x0MinStep6CheckResults

    cpi testIndex, 130
    brne PC+2
    rjmp TestSerialProcessCommandSetMultipleServoPosn3SetsRealCommandLengthCheckResults

    cpi testIndex, 131
    brne PC+3
    jmp TestSerialProcessCommandSetMultipleServoPosn3ThreeServos100x50x25MinStep10MinFreq20CheckResults

    jmp TestsFailed


SendSerial :

    push XL                                     ; save the registers that we use
    push XH
    push temp1
    push temp2

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X                                 ; load the number of bytes currently stored in the serial
    clr temp2                                   ; output buffer.
                                    
    inc temp1                                   ; increment the number of bytes as the offset from the
                                                ; start of the buffer is one greater than the number of bytes
                                                ; as the buffer also holds the count itself at offset 0
    add XL, temp1
    adc XH, temp2

    st X, serialChar                            ; store the data that would be written to the serial port in
                                                ; out buffer for later analysis in the test

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER) 
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    st X, temp1                                 ; save the number of bytes stored, note that we incremented
                                                ; this value above

    pop temp2                                   ; clean up the stack
    pop temp1
    pop XH
    pop XL

    ret


SerialEchoCommand : 

    ldi serialChar, 0xFF

    rcall SendSerial

    tst sCommandLength
    brne PC+2
    ret

    mov serialChar, sCommandLength

    rcall SendSerial
    
    ret

InitialisePWMOutput : 


    ldi serialChar, 0xFE

    rcall SendSerial
    
    ret

DisablePWMOutput : 

    ldi serialChar, 0xFD

    rcall SendSerial
    
    ret

WaitForSerialSendComplete :

    ldi serialChar, 0xFC

    rcall SendSerial
    
    ret

Init : 

    ldi serialChar, 0xFB

    rcall SendSerial
    
    rjmp SerialStart                ; not strictly true but this throws us back to our results checking dispatcher...


SerialParamOutOfRange : 

    ldi serialChar, 0xFA

    rcall SendSerial

    mov serialChar, temp2

    rcall SendSerial

    rjmp SerialStart

SaveServoData : 

    ldi serialChar, 0xF9

    rcall SendSerial
    
    ret

SerialParam1OutOfRange : 

    ldi serialChar, 0xF8

    rcall SendSerial
    
    rjmp SerialStart

SerialParam2OutOfRange : 

    ldi serialChar, 0xF7

    rcall SendSerial
    
    rjmp SerialStart

SerialServoOutOfRange : 

    ldi serialChar, 0xF6

    rcall SendSerial
    
    rjmp SerialStart

SerialPosnOutOfRange : 

    ldi serialChar, 0xF5

    rcall SendSerial
    
    rjmp SerialStart

SerialStepSizeOutOfRange : 

    ldi serialChar, 0xF4

    rcall SendSerial
    
    rjmp SerialStart

SerialStepEveryOutOfRange : 

    ldi serialChar, 0xF3

    rcall SendSerial
    
    rjmp SerialStart

SerialLoop : 

    ldi serialChar, 0xF2

    rcall SendSerial
    
    rjmp SerialStart

SerialParamOutOfRangeFnc : 

    ldi serialChar, 0xF1

    rcall SendSerial

    mov serialChar, temp2

    rcall SendSerial

    ret
