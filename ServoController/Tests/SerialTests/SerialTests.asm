TestSerialProcessCommandGetInfo : 

    ldi temp1, 1
    mov testIndex, temp1
    

    call InitialiseSerialOutputBuffer

    call InitialiseConfigDataToKnownValues

    jmp SerialProcessCommandGetInfo

    jmp TestsFailed

TestSerialProcessCommandGetInfoCheckResults :

    ; Now we need to compare the data that was stored with what we expected to have stored...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 8            ; should send 8 bytes of data out of the serial port....
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x00         ; command code
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x06         ; version major
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x07         ; version minor
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, NUM_SERVOS   ; number of servos supported
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x11         ; CONFIG_DATA_PWM_ACTIVE_ON_RESET
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x22         ; CONFIG_DATA_SEND_CONTROLLER_ACTIVE
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x33         ; CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0x44         ; CONFIG_DATA_PWM_CURRENTLY_ACTIVE
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret

TestSerialProcessCommandEnablePWMWhenNotCurrentlyEnabled : 

    ldi temp1, 2
    mov testIndex, temp1
    
    call InitialiseSerialOutputBuffer

    call InitialiseConfigDataToKnownValues

    ldi XL, LOW(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)     
    ldi XH, HIGH(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)

    clr temp1
    st X, temp1

    jmp SerialProcessCommandEnablePWM

    jmp TestsFailed


TestSerialProcessCommandEnablePWMWhenNotCurrentlyEnabledCheckResults : 

    ; our mock functions simply store well known values to the serial output buffer...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 2            ; there should have been 2 calls...
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFE         ; enable pwm
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret

TestSerialProcessCommandEnablePWMWhenAlreadyEnabled : 

    ldi temp1, 3
    mov testIndex, temp1
    
    call InitialiseSerialOutputBuffer

    call InitialiseConfigDataToKnownValues

    ldi XL, LOW(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)     
    ldi XH, HIGH(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)

    ldi temp1, 1
    st X, temp1

    jmp SerialProcessCommandEnablePWM

    jmp TestsFailed


TestSerialProcessCommandEnablePWMWhenAlreadyEnabledCheckResults : 

    ; our mock functions simply store well known values to the serial output buffer...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should have been 1 call...
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandDisablePWMWhenNotCurrentlyEnabled : 

    ldi temp1, 4
    mov testIndex, temp1
    
    call InitialiseSerialOutputBuffer

    call InitialiseConfigDataToKnownValues

    ldi XL, LOW(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)     
    ldi XH, HIGH(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)

    clr temp1
    st X, temp1

    jmp SerialProcessCommandDisablePWM

    jmp TestsFailed


TestSerialProcessCommandDisablePWMWhenNotCurrentlyEnabledCheckResults : 

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 1            ; there should have been 1 call...
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandDisablePWMWhenEnabled : 

    ldi temp1, 5
    mov testIndex, temp1
    
    call InitialiseSerialOutputBuffer

    call InitialiseConfigDataToKnownValues

    ldi XL, LOW(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)     
    ldi XH, HIGH(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)

    ldi temp1, 1
    st X, temp1

    jmp SerialProcessCommandDisablePWM

    rjmp TestsFailed


TestSerialProcessCommandDisablePWMWhenEnabledCheckResults : 

    ; our mock functions simply store well known values to the serial output buffer...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 2            ; there should have been 2 calls...
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFD         ; disable pwm
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret

TestSerialProcessCommandReset :

    ldi temp1, 6
    mov testIndex, temp1
    
    call InitialiseSerialOutputBuffer

    call InitialiseConfigDataToKnownValues

    ldi XL, LOW(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)     
    ldi XH, HIGH(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)

    ldi temp1, 1
    st X, temp1

    jmp SerialProcessCommandReset

    jmp TestsFailed


TestSerialProcessCommandResetCheckResults :

    ; our mock functions simply store well known values to the serial output buffer...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 4            ; there should have been 4 calls...
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFC         ; wait for send complete
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFD         ; disable pwm
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFB         ; Init
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret

TestSerialProcessCommandResetWhenPWMNotActive :

    ; there's no difference at present, we dont check to see if it's active or not 
    ; before calling DisablePWMOutput

    ldi temp1, 7
    mov testIndex, temp1
    
    call InitialiseSerialOutputBuffer

    call InitialiseConfigDataToKnownValues

    ldi XL, LOW(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)     
    ldi XH, HIGH(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)

    ldi temp1, 1
    st X, temp1

    jmp SerialProcessCommandReset

    rjmp TestsFailed


TestSerialProcessCommandResetWhenPWMNotActiveCheckResults :

    ; our mock functions simply store well known values to the serial output buffer...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 4            ; there should have been 4 calls...
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFC         ; wait for send complete
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFD         ; disable pwm
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFB         ; Init
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandSaveSettingsWithPWMActive : 

    ldi temp1, 8
    mov testIndex, temp1
    
    call InitialiseSerialOutputBuffer

    call InitialiseConfigDataToKnownValues

    ldi XL, LOW(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)     
    ldi XH, HIGH(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)

    ldi temp1, 1
    st X, temp1

    jmp SerialProcessCommandSaveSettings

    jmp TestsFailed

TestSerialProcessCommandSaveSettingsWithPWMActiveCheckResults :

    ; our mock functions simply store well known values to the serial output buffer...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 2            ; there should be 2 bytes of data...
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFA         ; serial param out of range
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; the parameter, 0xFF for command not valid at this time...
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret


TestSerialProcessCommandSaveSettingsWithPWMInactive : 

    ldi temp1, 9
    mov testIndex, temp1
    
    call InitialiseSerialOutputBuffer

    call InitialiseConfigDataToKnownValues

    ldi XL, LOW(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)     
    ldi XH, HIGH(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)

    ldi temp1, 0
    st X, temp1

    jmp SerialProcessCommandSaveSettings

    jmp TestsFailed

TestSerialProcessCommandSaveSettingsWithPWMInactiveCheckResults :

    ; our mock functions simply store well known values to the serial output buffer...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 2            ; there should have been 4 calls...
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xFF         ; echo command
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 0xF9         ; save data
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret
