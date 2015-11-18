TestSerialValidateAndAdjustDesiredPosition :

    ldi temp1, 32
    mov testIndex, temp1

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    clr temp2               ; error on out of range
    st X, temp2

    ldi temp1, 10           
    mov targetPos, temp1    ; the required position

    ldi temp1, 1            ; parameter index of the value we're validating
    clr resh                ; return value, adjusted position before centre adjust

    ; X needs to be pointing to the first byte of the servo's control data
    
    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)


    call SerialValidateAndAdjustDesiredPosition

    cpi temp1, 1                    ; if temp1 is zero on return from function then we failed and the posn is illegal, otherwise it should be unchanged
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 10
    cp targetPos, temp1             ; target pos should be unchanged as it's within min and max
    breq PC+2
    rjmp TestsFailed
    
    cp resh, temp1                  ; resh is same as input target pos
    breq PC+2
    rjmp TestsFailed

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 0            ; there should have been 0 calls
    breq PC+2
    rjmp TestsFailed
    
    inc testResult
    ret

TestSerialValidateAndAdjustDesiredPositionTooLowErrorOnFailure :

    ldi temp1, 33
    mov testIndex, temp1

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    clr temp2               ; error on out of range
    st X, temp2

    ; X needs to be pointing to the first byte of the servo's control data
    
    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 20           ; set the min position for this servo to 20...
    st X, temp1


    ldi temp1, 10           
    mov targetPos, temp1    ; the required position

    ldi temp1, 1            ; parameter index of the value we're validating
    clr resh                ; return value, adjusted position before centre adjust


    call SerialValidateAndAdjustDesiredPosition

    tst temp1                       ; temp1 is zero on return to indicate that the posn is illegal
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 10
    cp targetPos, temp1             ; target pos should be unchanged as the function has returned failure
    breq PC+2
    rjmp TestsFailed
    
    cp resh, temp1                  ; resh is same as input target pos
    breq PC+2
    rjmp TestsFailed

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 2            ; there should have been 1 call with 1 byte of data...
    breq PC+2
    rjmp TestsFailed
    
    ld temp1, X+
    cpi temp1, 0xF1         ; param out of range function 
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 1            ; the parameter index
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret

TestSerialValidateAndAdjustDesiredPositionTooLowAdjustOnFailure :

    ldi temp1, 34
    mov testIndex, temp1

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    ldi temp2, 1            ; adjust on out of range
    st X, temp2

    ; X needs to be pointing to the first byte of the servo's control data
    
    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 20           ; set the min position for this servo to 20...
    st X, temp1


    ldi temp1, 10           
    mov targetPos, temp1    ; the required position

    ldi temp1, 1            ; parameter index of the value we're validating
    clr resh                ; return value, adjusted position before centre adjust


    call SerialValidateAndAdjustDesiredPosition

    cpi temp1, 1                    ; if temp1 is zero on return from function then we failed and the posn is illegal, otherwise it should be unchanged
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 20
    cp targetPos, temp1             ; target pos should be set to min 
    breq PC+2
    rjmp TestsFailed
    
    cp resh, temp1                  ; resh is same as output target pos
    breq PC+2
    rjmp TestsFailed

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 0            ; there should have been 0 calls
    breq PC+2
    rjmp TestsFailed
    
    inc testResult
    ret

TestSerialValidateAndAdjustDesiredPositionTooHighErrorOnFailure :

    ldi temp1, 35
    mov testIndex, temp1

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    clr temp2               ; error on out of range
    st X, temp2

    ; Set the max value for this servo
    
    ldi XL, LOW(POSITION_DATA_START + MAX_POS_OFFSET)
    ldi XH, HIGH(POSITION_DATA_START + MAX_POS_OFFSET)

    ldi temp1, 20           ; set the max position for this servo to 20...
    st X, temp1

    ; X needs to be pointing to the first byte of the servo's control data   

    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 30           
    mov targetPos, temp1    ; the required position

    ldi temp1, 1            ; parameter index of the value we're validating
    clr resh                ; return value, adjusted position before centre adjust


    call SerialValidateAndAdjustDesiredPosition

    tst temp1                       ; temp1 is zero on return to indicate that the posn is illegal
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 30
    cp targetPos, temp1             ; target pos should be unchanged as the function has returned failure
    breq PC+2
    rjmp TestsFailed
    
    cp resh, temp1                  ; resh is same as input target pos
    breq PC+2
    rjmp TestsFailed

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 2            ; there should have been 1 call with 1 byte of data...
    breq PC+2
    rjmp TestsFailed
    
    ld temp1, X+
    cpi temp1, 0xF1         ; param out of range function 
    breq PC+2
    rjmp TestsFailed

    ld temp1, X+
    cpi temp1, 1            ; the parameter index
    breq PC+2
    rjmp TestsFailed

    inc testResult
    ret

TestSerialValidateAndAdjustDesiredPositionTooHighAdjustOnFailure :

    ldi temp1, 36
    mov testIndex, temp1

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    ldi temp2, 1            ; adjust on out of range
    st X, temp2


    ; Set the max value for this servo
    
    ldi XL, LOW(POSITION_DATA_START + MAX_POS_OFFSET)
    ldi XH, HIGH(POSITION_DATA_START + MAX_POS_OFFSET)

    ldi temp1, 20           ; set the max position for this servo to 20...
    st X, temp1

    ; X needs to be pointing to the first byte of the servo's control data   

    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 30           
    mov targetPos, temp1    ; the required position

    ldi temp1, 1            ; parameter index of the value we're validating
    clr resh                ; return value, adjusted position before centre adjust


    call SerialValidateAndAdjustDesiredPosition

    cpi temp1, 1                    ; if temp1 is zero on return from function then we failed and the posn is illegal, otherwise it should be unchanged
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 20
    cp targetPos, temp1             ; target pos should be set to max
    breq PC+2
    rjmp TestsFailed
    
    cp resh, temp1                  ; resh is same as output target pos
    breq PC+2
    rjmp TestsFailed

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 0            ; there should have been 0 calls
    breq PC+2
    rjmp TestsFailed
    
    inc testResult
    ret

TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustUp :

    ldi temp1, 37
    mov testIndex, temp1

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    clr temp2               ; error on out of range
    st X, temp2

    ; Set the centre adjust for this servo
    
    ldi XL, LOW(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)
    ldi XH, HIGH(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)

    ldi temp1, 0x81           ; set the centre position for this servo to 0x81 rather than 0x7F
    st X, temp1

    ; X needs to be pointing to the first byte of the servo's control data   

    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 10           
    mov targetPos, temp1    ; the required position

    ldi temp1, 1            ; parameter index of the value we're validating
    clr resh                ; return value, adjusted position before centre adjust

    ; X needs to be pointing to the first byte of the servo's control data
    
    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    call SerialValidateAndAdjustDesiredPosition

    cpi temp1, 1                    ; if temp1 is zero on return from function then we failed and the posn is illegal, otherwise it should be unchanged
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 12
    cp targetPos, temp1             ; target pos should be 2 more than the input, as our centre is 2 greater.
    breq PC+2
    rjmp TestsFailed
    
    ldi temp1, 10
    cp resh, temp1                  ; resh is same as input target pos
    breq PC+2
    rjmp TestsFailed

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 0            ; there should have been 0 calls
    breq PC+2
    rjmp TestsFailed
    
    inc testResult
    ret

TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustDown :

    ldi temp1, 38
    mov testIndex, temp1

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    clr temp2               ; error on out of range
    st X, temp2

    ; Set the centre adjust for this servo
    
    ldi XL, LOW(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)
    ldi XH, HIGH(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)

    ldi temp1, 0x7D           ; set the centre position for this servo to 0x7D rather than 0x7F
    st X, temp1

    ; X needs to be pointing to the first byte of the servo's control data   

    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 10           
    mov targetPos, temp1    ; the required position

    ldi temp1, 1            ; parameter index of the value we're validating
    clr resh                ; return value, adjusted position before centre adjust

    ; X needs to be pointing to the first byte of the servo's control data
    
    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    call SerialValidateAndAdjustDesiredPosition

    cpi temp1, 1                    ; if temp1 is zero on return from function then we failed and the posn is illegal, otherwise it should be unchanged
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 8
    cp targetPos, temp1             ; target pos should be 2 less than the input, as our centre is 2 less than normal
    breq PC+2
    rjmp TestsFailed
    
    ldi temp1, 10
    cp resh, temp1                  ; resh is same as input target pos
    breq PC+2
    rjmp TestsFailed

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 0            ; there should have been 0 calls
    breq PC+2
    rjmp TestsFailed
    
    inc testResult
    ret


TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustToMoreThanFF :

    ldi temp1, 39
    mov testIndex, temp1

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    clr temp2               ; error on out of range
    st X, temp2

    ; Set the centre adjust for this servo
    
    ldi XL, LOW(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)
    ldi XH, HIGH(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)

    ldi temp1, 0x82           ; set the centre position for this servo to 0x82 rather than 0x7F
    st X, temp1

    ; X needs to be pointing to the first byte of the servo's control data   

    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 0xFD           
    mov targetPos, temp1    ; the required position

    ldi temp1, 1            ; parameter index of the value we're validating
    clr resh                ; return value, adjusted position before centre adjust

    ; X needs to be pointing to the first byte of the servo's control data
    
    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    call SerialValidateAndAdjustDesiredPosition

    cpi temp1, 1                    ; if temp1 is zero on return from function then we failed and the posn is illegal, otherwise it should be unchanged
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 0xFE
    cp targetPos, temp1             ; target pos should be 3 more than the input, as our centre is 3 greater but we limit to 0xFE...
    breq PC+2
    rjmp TestsFailed
    
    ldi temp1, 0xFD
    cp resh, temp1                  ; resh is same as input target pos
    breq PC+2
    rjmp TestsFailed

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 0            ; there should have been 0 calls
    breq PC+2
    rjmp TestsFailed
    
    inc testResult
    ret

TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustToExactlyFF :

    ldi temp1, 40
    mov testIndex, temp1

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    clr temp2               ; error on out of range
    st X, temp2

    ; Set the centre adjust for this servo
    
    ldi XL, LOW(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)
    ldi XH, HIGH(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)

    ldi temp1, 0x81           ; set the centre position for this servo to 0x81 rather than 0x7F
    st X, temp1

    ; X needs to be pointing to the first byte of the servo's control data   

    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 0xFD           
    mov targetPos, temp1    ; the required position

    ldi temp1, 1            ; parameter index of the value we're validating
    clr resh                ; return value, adjusted position before centre adjust

    ; X needs to be pointing to the first byte of the servo's control data
    
    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    call SerialValidateAndAdjustDesiredPosition

    cpi temp1, 1                    ; if temp1 is zero on return from function then we failed and the posn is illegal, otherwise it should be unchanged
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 0xFE
    cp targetPos, temp1             ; target pos should be 2 more than the input, as our centre is 2 greater but we limit to 0xFE...
    breq PC+2
    rjmp TestsFailed
    
    ldi temp1, 0xFD
    cp resh, temp1                  ; resh is same as input target pos
    breq PC+2
    rjmp TestsFailed

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 0            ; there should have been 0 calls
    breq PC+2
    rjmp TestsFailed
    
    inc testResult
    ret

TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustToLessThanZero :

    ldi temp1, 41
    mov testIndex, temp1

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    clr temp2               ; error on out of range
    st X, temp2

    ; Set the centre adjust for this servo
    
    ldi XL, LOW(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)
    ldi XH, HIGH(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)

    ldi temp1, 0x7D           ; set the centre position for this servo to 0x7D rather than 0x7F
    st X, temp1

    ; X needs to be pointing to the first byte of the servo's control data   

    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 1           
    mov targetPos, temp1    ; the required position

    ldi temp1, 1            ; parameter index of the value we're validating
    clr resh                ; return value, adjusted position before centre adjust

    ; X needs to be pointing to the first byte of the servo's control data
    
    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    call SerialValidateAndAdjustDesiredPosition

    cpi temp1, 1                    ; if temp1 is zero on return from function then we failed and the posn is illegal, otherwise it should be unchanged
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 0x00
    cp targetPos, temp1             ; target pos should be 2 less than the input, as our centre is 2 smaller but we limit to 0...
    breq PC+2
    rjmp TestsFailed
    
    ldi temp1, 1
    cp resh, temp1                  ; resh is same as input target pos
    breq PC+2
    rjmp TestsFailed

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 0            ; there should have been 0 calls
    breq PC+2
    rjmp TestsFailed
    
    inc testResult
    ret


TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustUpAndMinAdjust :

    ldi temp1, 42
    mov testIndex, temp1

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    ldi temp2, 1                ; adust on out of range
    st X, temp2

    ; Set the min value for this servo
    
    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 20           ; set the min position for this servo to 20...
    st X, temp1

    ; Set the centre adjust for this servo

    ldi XL, LOW(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)
    ldi XH, HIGH(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)

    ldi temp1, 0x81           ; set the centre position for this servo to 0x81 rather than 0x7F
    st X, temp1

    ; X needs to be pointing to the first byte of the servo's control data   

    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 10           
    mov targetPos, temp1    ; the required position

    ldi temp1, 1            ; parameter index of the value we're validating
    clr resh                ; return value, adjusted position before centre adjust

    ; X needs to be pointing to the first byte of the servo's control data
    
    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    call SerialValidateAndAdjustDesiredPosition

    cpi temp1, 1                    ; if temp1 is zero on return from function then we failed and the posn is illegal, otherwise it should be unchanged
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 22
    cp targetPos, temp1             ; target pos should be 2 more than the adjusted input, as our centre is 2 greater.
    breq PC+2
    rjmp TestsFailed
    
    ldi temp1, 20
    cp resh, temp1                  ; resh is the input target pos adjusted for the min limit
    breq PC+2
    rjmp TestsFailed

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 0            ; there should have been 0 calls
    breq PC+2
    rjmp TestsFailed
    
    inc testResult
    ret

TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustUpAndMaxAdjust :

    ldi temp1, 43
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

    ldi temp1, 0x81           ; set the centre position for this servo to 0x81 rather than 0x7F
    st X, temp1

    ; X needs to be pointing to the first byte of the servo's control data   

    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 30           
    mov targetPos, temp1    ; the required position

    ldi temp1, 1            ; parameter index of the value we're validating
    clr resh                ; return value, adjusted position before centre adjust

    ; X needs to be pointing to the first byte of the servo's control data
    
    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    call SerialValidateAndAdjustDesiredPosition

    cpi temp1, 1                    ; if temp1 is zero on return from function then we failed and the posn is illegal, otherwise it should be unchanged
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 22
    cp targetPos, temp1             ; target pos should be 2 more than the adjusted input, as our centre is 2 greater.
    breq PC+2
    rjmp TestsFailed
    
    ldi temp1, 20
    cp resh, temp1                  ; resh is the input target pos adjusted for the max limit
    breq PC+2
    rjmp TestsFailed

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 0            ; there should have been 0 calls
    breq PC+2
    rjmp TestsFailed
    
    inc testResult
    ret

TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustDownAndMinAdjust :

    ldi temp1, 44
    mov testIndex, temp1

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    ldi temp2, 1                ; adust on out of range
    st X, temp2

    ; Set the min value for this servo
    
    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 20           ; set the min position for this servo to 20...
    st X, temp1

    ; Set the centre adjust for this servo

    ldi XL, LOW(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)
    ldi XH, HIGH(POSITION_DATA_START + CENTRE_ADJUST_OFFSET)

    ldi temp1, 0x7D           ; set the centre position for this servo to 0x7D rather than 0x7F
    st X, temp1

    ; X needs to be pointing to the first byte of the servo's control data   

    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 10           
    mov targetPos, temp1    ; the required position

    ldi temp1, 1            ; parameter index of the value we're validating
    clr resh                ; return value, adjusted position before centre adjust

    ; X needs to be pointing to the first byte of the servo's control data
    
    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    call SerialValidateAndAdjustDesiredPosition

    cpi temp1, 1                    ; if temp1 is zero on return from function then we failed and the posn is illegal, otherwise it should be unchanged
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 18
    cp targetPos, temp1             ; target pos should be 2 less than the adjusted input, as our centre is 2 less
    breq PC+2
    rjmp TestsFailed
    
    ldi temp1, 20
    cp resh, temp1                  ; resh is the input target pos adjusted for the min limit
    breq PC+2
    rjmp TestsFailed

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 0            ; there should have been 0 calls
    breq PC+2
    rjmp TestsFailed
    
    inc testResult
    ret

TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustDownAndMaxAdjust :

    ldi temp1, 45
    mov testIndex, temp1

    ; set up what happens if the position is out of range

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)

    ldi temp2, 1                ; adjust on out of range
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

    ; X needs to be pointing to the first byte of the servo's control data   

    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    ldi temp1, 30           
    mov targetPos, temp1    ; the required position

    ldi temp1, 1            ; parameter index of the value we're validating
    clr resh                ; return value, adjusted position before centre adjust

    ; X needs to be pointing to the first byte of the servo's control data
    
    ldi XL, LOW(POSITION_DATA_START)
    ldi XH, HIGH(POSITION_DATA_START)

    call SerialValidateAndAdjustDesiredPosition

    cpi temp1, 1                    ; if temp1 is zero on return from function then we failed and the posn is illegal, otherwise it should be unchanged
    breq PC+2
    rjmp TestsFailed

    ldi temp1, 18
    cp targetPos, temp1             ; target pos should be 2 less than the adjusted input, as our centre is 2 less
    breq PC+2
    rjmp TestsFailed
    
    ldi temp1, 20
    cp resh, temp1                  ; resh is the input target pos adjusted for the max limit
    breq PC+2
    rjmp TestsFailed

    ; now validate that the correct mock functions were called...

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    ld temp1, X+
    cpi temp1, 0            ; there should have been 0 calls
    breq PC+2
    rjmp TestsFailed
    
    inc testResult
    ret


