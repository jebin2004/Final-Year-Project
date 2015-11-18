SerialStart : 

    cpi testIndex, 1
    brne PC+3
    jmp TestSerialProcessCommandGetInfoCheckResults

    cpi testIndex, 2
    brne PC+3
    jmp TestSerialProcessCommandEnablePWMWhenNotCurrentlyEnabledCheckResults

    cpi testIndex, 3
    brne PC+3
    jmp TestSerialProcessCommandEnablePWMWhenAlreadyEnabledCheckResults
    
    cpi testIndex, 4
    brne PC+3
    jmp TestSerialProcessCommandDisablePWMWhenNotCurrentlyEnabledCheckResults

    cpi testIndex, 5
    brne PC+3
    jmp TestSerialProcessCommandDisablePWMWhenEnabledCheckResults

    cpi testIndex, 6
    brne PC+3
    jmp TestSerialProcessCommandResetCheckResults

    cpi testIndex, 7
    brne PC+3
    jmp TestSerialProcessCommandResetWhenPWMNotActiveCheckResults

    cpi testIndex, 8
    brne PC+3
    jmp TestSerialProcessCommandSaveSettingsWithPWMActiveCheckResults

    cpi testIndex, 9
    brne PC+3
    jmp TestSerialProcessCommandSaveSettingsWithPWMInactiveCheckResults

    cpi testIndex, 10
    brne PC+3
    jmp TestSerialProcessCommandSetConfigValueWithInvalidConfigItemCheckResults

    cpi testIndex, 11
    brne PC+3
    jmp TestSerialProcessCommandSetConfigValueWithInvalidConfigValueCheckResults

    cpi testIndex, 12
    brne PC+3
    jmp TestSerialProcessCommandSetConfigValueSetConfig0To1ValueCheckResults

    cpi testIndex, 13
    brne PC+3
    jmp TestSerialProcessCommandSetConfigValueSetConfig0To0ValueCheckResults

    cpi testIndex, 14
    brne PC+3
    jmp TestSerialProcessCommandSetConfigValueSetConfig2To1ValueCheckResults

    cpi testIndex, 15
    brne PC+3
    jmp TestSerialProcessCommandSetServoMinPosnCheckResults

    cpi testIndex, 16
    brne PC+3
    jmp TestSerialProcessCommandSetServoMinPosnInvalidServoCheckResults

    cpi testIndex, 17
    brne PC+3
    jmp TestSerialProcessCommandSetServoMinPosnMinLargerThanMaxCheckResults

    cpi testIndex, 18
    brne PC+3
    jmp TestSerialProcessCommandSetServoMinPosnMinEqualToMaxCheckResults

    cpi testIndex, 19
    brne PC+3
    jmp TestSerialProcessCommandSetServoMaxPosnCheckResults

    cpi testIndex, 20
    brne PC+3
    jmp TestSerialProcessCommandSetServoMaxPosnInvalidServoCheckResults

    cpi testIndex, 21
    brne PC+3
    jmp TestSerialProcessCommandSetServoMaxPosnMaxSmallerThanMinCheckResults

    cpi testIndex, 22
    brne PC+3
    jmp TestSerialProcessCommandSetServoMaxPosnMaxEqualToMinCheckResults

    cpi testIndex, 23
    brne PC+3
    jmp TestSerialProcessCommandSetServoMaxPosnMaxEqualToFFCheckResults

    cpi testIndex, 24
    brne PC+3
    jmp TestSerialProcessCommandSetServoCentrePosnCheckResults

    cpi testIndex, 25
    brne PC+3
    jmp TestSerialProcessCommandSetServoCentrePosnInvalidServoCheckResults

    cpi testIndex, 26
    brne PC+3
    jmp TestSerialProcessCommandSetServoCentrePosnToFFCheckResults

    cpi testIndex, 27
    brne PC+3
    jmp TestSerialProcessCommandSetServoInitialPosnCheckResults

    cpi testIndex, 28
    brne PC+3
    jmp TestSerialProcessCommandSetServoInitialPosnInvalidServoCheckResults

    cpi testIndex, 29
    brne PC+3
    jmp TestSerialProcessCommandSetServoInitialPosnToFFCheckResults

    cpi testIndex, 30
    brne PC+3
    jmp TestSerialProcessCommandSetPosnCheckResults

    cpi testIndex, 31
    brne PC+3
    jmp TestSerialProcessCommandSetPosnInvalidServoCheckResults

    cpi testIndex, 46
    brne PC+3
    jmp TestSerialProcessCommandSetPosnClearsAllExceptCurrentPosCheckResults

    cpi testIndex, 47
    brne PC+3
    jmp TestSerialProcessCommandSetPosnWithCentreAdjustDownAndMaxAdjustCheckResults

    cpi testIndex, 48
    brne PC+3
    jmp TestSerialProcessCommandSetDelayPosnCheckResults

    cpi testIndex, 49
    brne PC+3
    jmp TestSerialProcessCommandSetDelayPosnInvalidServoCheckResults

    cpi testIndex, 50
    brne PC+3
    jmp TestSerialProcessCommandSetDelayPosnInvalidPosnCheckResults

    cpi testIndex, 51
    brne PC+3
    jmp TestSerialProcessCommandSetDelayPosnInvalidStepSizeCheckResults

    cpi testIndex, 52
    brne PC+3
    jmp TestSerialProcessCommandSetDelayPosnPosnTooSmallWithErrorCheckResults

    cpi testIndex, 53
    brne PC+3
    jmp TestSerialProcessCommandSetDelayPosnPosnTooSmallWithAdjustCheckResults

    cpi testIndex, 54
    brne PC+3
    jmp TestSerialProcessCommandSetDelayPosn2CheckResults

    cpi testIndex, 55
    brne PC+3
    jmp TestSerialProcessCommandSetDelayPosn2InvalidServoCheckResults

    cpi testIndex, 56
    brne PC+3
    jmp TestSerialProcessCommandSetDelayPosnInvalidPosn2CheckResults

    cpi testIndex, 57
    brne PC+3
    jmp TestSerialProcessCommandSetDelayPosn2InvalidStepSizeCheckResults

    cpi testIndex, 58
    brne PC+3
    jmp TestSerialProcessCommandSetDelayPosn2InvalidFrequencyCheckResults

    cpi testIndex, 59
    brne PC+3
    jmp TestSerialProcessCommandSetDelayPosn2PosnTooSmallWithErrorCheckResults

    cpi testIndex, 60
    brne PC+3
    jmp TestSerialProcessCommandSetDelayPosn2PosnTooSmallWithAdjustCheckResults

    cpi testIndex, 61
    brne PC+3
    jmp TestSerialProcessCommandStopServoCheckResults

    cpi testIndex, 62
    brne PC+3
    jmp TestSerialProcessCommandStopServoDuringDelayMoveCheckResults

    cpi testIndex, 63
    brne PC+3
    jmp TestSerialProcessCommandStopServoInvalidServoCheckResults

    cpi testIndex, 64
    brne PC+3
    jmp TestSerialProcessCommandStopServosSetsRealCommandLengthCheckResults

    cpi testIndex, 65
    brne PC+3
    jmp TestSerialProcessCommandStopServosTwoServosNeitherMovingCheckResults

    cpi testIndex, 66
    brne PC+3
    jmp TestSerialProcessCommandStopServosTwoServosFirstMovingCheckResults

    cpi testIndex, 67
    brne PC+3
    jmp TestSerialProcessCommandStopServosTwoServosFirstInvalidServoCheckResults

    cpi testIndex, 68
    brne PC+3
    jmp TestSerialProcessCommandStopServosTwoServosSecondInvalidServoCheckResults

    cpi testIndex, 69
    brne PC+3
    jmp TestSerialProcessCommandStopServosTooManyServosToStopCheckResults

    cpi testIndex, 70
    brne PC+3
    jmp TestSerialProcessCommandStopAllNoneMovingCheckResults

    cpi testIndex, 71
    brne PC+3
    jmp TestSerialProcessCommandQueryServoCheckResults

    cpi testIndex, 72
    brne PC+3
    jmp TestSerialProcessCommandQueryServoDuringDelayMoveCheckResults

    cpi testIndex, 73
    brne PC+3
    jmp TestSerialProcessCommandQueryServoInvalidServoCheckResults

    cpi testIndex, 74
    brne PC+3
    jmp TestSerialProcessCommandQueryServosSetsRealCommandLengthCheckResults

    cpi testIndex, 75
    brne PC+3
    jmp TestSerialProcessCommandQueryServosTwoServosNeitherMovingCheckResults

    cpi testIndex, 76
    brne PC+3
    jmp TestSerialProcessCommandQueryServosTwoServosFirstMovingCheckResults

    cpi testIndex, 77
    brne PC+3
    jmp TestSerialProcessCommandQueryServosTwoServosFirstInvalidServoCheckResults

    cpi testIndex, 78
    brne PC+3
    jmp TestSerialProcessCommandQueryServosTwoServosSecondInvalidServoCheckResults

    cpi testIndex, 79
    brne PC+2
    rjmp TestSerialProcessCommandQueryServosTooManyServosToQueryCheckResults

    cpi testIndex, 80
    brne PC+2
    rjmp TestSerialProcessCommandQueryAllNoneMovingCheckResults

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
