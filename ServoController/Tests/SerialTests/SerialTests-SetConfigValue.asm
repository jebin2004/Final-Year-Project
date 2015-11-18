TestSerialProcessCommandSetConfigValueWithInvalidConfigItem :

    ldi temp1, 10
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 5                            ; valid values are 0-2
    st X, temp1

    jmp SerialProcessCommandSetConfigValue

    jmp TestsFailed


TestSerialProcessCommandSetConfigValueWithInvalidConfigItemCheckResults :

    ; The call should leave X 1 place further on than where it started...

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+2
    rjmp TestsFailed

    ; our mock functions simply store well known values to the serial output buffer...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should be 1 bytes of data...
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xF8         ; serial param 1 out of range
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandSetConfigValueWithInvalidConfigValue :

    ldi temp1, 11
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0                            ; valid values are 0-2
    st X+, temp1

    ldi temp1, 5                            ; valid values are 0-1
    st X, temp1

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetConfigValue

    jmp TestsFailed


TestSerialProcessCommandSetConfigValueWithInvalidConfigValueCheckResults :

    ; The call should leave X 1 place further on than where it started...

    cpi XL, LOW(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(TEST_SERIAL_INPUT_BUFFER + 1)
    breq PC+2
    rjmp TestsFailed

    ; our mock functions simply store well known values to the serial output buffer...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should be 1 bytes of data...
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xF7         ; serial param 2 out of range
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandSetConfigValueSetConfig0To1 :

    ldi temp1, 12
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0                            
    st X+, temp1

    ldi temp1, 1                            
    st X, temp1

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetConfigValue

    jmp TestsFailed


TestSerialProcessCommandSetConfigValueSetConfig0To1ValueCheckResults :

    ; The call should leave X pointing at the config value that we have changed...

    cpi XL, LOW(CONFIG_DATA_START + 0)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(CONFIG_DATA_START + 0)
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+                ; check that we've changed the 1 value that we wanted to change
    cpi temp1, 1
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+                ; and left the others as expected...
    cpi temp1, 0x22
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x33
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x44
    breq PC+2
    rjmp TestsFailed

    ; our mock functions simply store well known values to the serial output buffer...

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

TestSerialProcessCommandSetConfigValueSetConfig0To0 :

    ldi temp1, 13
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 0                            
    st X+, temp1

    ldi temp1, 0                            
    st X, temp1

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetConfigValue

    jmp TestsFailed


TestSerialProcessCommandSetConfigValueSetConfig0To0ValueCheckResults :

    ; The call should leave X pointing at the config value that we have changed...

    cpi XL, LOW(CONFIG_DATA_START + 0)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(CONFIG_DATA_START + 0)
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+                ; check that we've changed the 1 value that we wanted to change
    cpi temp1, 0
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+                ; and left the others as expected...
    cpi temp1, 0x22
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x33
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x44
    breq PC+2
    rjmp TestsFailed

    ; our mock functions simply store well known values to the serial output buffer...

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

TestSerialProcessCommandSetConfigValueSetConfig2To1 :

    ldi temp1, 14
    mov testIndex, temp1
    
    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    ldi temp1, 2                            
    st X+, temp1

    ldi temp1, 1                            
    st X, temp1

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)   ; reset X   
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    jmp SerialProcessCommandSetConfigValue

    rjmp TestsFailed


TestSerialProcessCommandSetConfigValueSetConfig2To1ValueCheckResults :

    ; The call should leave X pointing at the config value that we have changed...

    cpi XL, LOW(CONFIG_DATA_START + 2)
    breq PC+2
    rjmp TestsFailed

    cpi XH, HIGH(CONFIG_DATA_START + 2)
    breq PC+2
    rjmp TestsFailed

    ldi XL, LOW(CONFIG_DATA_START)     
    ldi XH, HIGH(CONFIG_DATA_START)

    ld temp1, X+                
    cpi temp1, 0x11
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+                ; and left the others as expected...
    cpi temp1, 0x22
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+                ; check that we've changed the 1 value that we wanted to change
    cpi temp1, 1
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x44
    breq PC+2
    rjmp TestsFailed

    ; our mock functions simply store well known values to the serial output buffer...

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
