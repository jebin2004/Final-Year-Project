; ******************************************* 
; ** 64 Channel Serial Servo Controller    **
; **           For ATMega168               **
; **            Version 7.0                **
; **                                       **
; **     Copyright (c) November 2009       **
; **             Len Holgate               **
; **                                       **
; ** See http://www.lhexapod.com           **
; **                                       **
; ** Note that this controller assumes     **
; ** that we have CD74HCT238E or equivalent**
; ** demultiplexor chips connected to pins **
; ** 0-4 of Ports B and C and that the     **
; ** required address lines for these MUXs **
; ** are run from pins 2-4 of PortD.       **
; ** See website for a schematic.          **
; *******************************************
;


; Eeprom access code...

.def zero = r10             ; Note that these two registers are also used by the PWM
.def servoData = r11        ; pulse switch off interrupt handler BUT that can't be called
                            ; whilst we're doing EEPROM stuff because it MUST be turned
                            ; off...

LoadServoData : 

    ; first load the controller config data...

    ldi XL, LOW(EEPROM_CONFIG_DATA_START)               ; set up source address in eeprom
    ldi XH, HIGH(EEPROM_CONFIG_DATA_START)

    ldi YL, LOW(CONFIG_DATA_START)                      ; set up destination address
    ldi YH, HIGH(CONFIG_DATA_START)

    clr temp2

LoadServoDataConfigDataLoop : 

    rcall EEPROM_read
    
    st Y+, temp1

    adiw XL, 1

    inc temp2

    cpi temp2, EEPROM_CONFIG_DATA_SIZE
    brne LoadServoDataConfigDataLoop        

    ; now load the servo data itself

    ldi YL, LOW(POSITION_DATA_START)                    ; set up destination address
    ldi YH, HIGH(POSITION_DATA_START)

    ldi temp2, CONFIG_DATA_TABLE_SIZE

    clr zero

    ldi servoIndex, 0x00

LoadServoDataLoop:

    ldi XL, LOW(EEPROM_MIN_POSITION_TABLE_START)        ; set up source address in eeprom
    ldi XH, HIGH(EEPROM_MIN_POSITION_TABLE_START)

    add XL, servoIndex
    adc XH, zero

    rcall EEPROM_read

    st Y+, temp1        ; min position

    add XL, temp2
    adc XH, zero

    rcall EEPROM_read

    st Y+, temp1        ; max position

    add XL, temp2
    adc XH, zero

    rcall EEPROM_read

    st Y+, temp1        ; centre adjust

    add XL, temp2
    adc XH, zero

    rcall EEPROM_read

    st Y+, temp1        ; current position

    ; now initialise the rest of the servo data structure to zero    

    st Y+, zero         ; step every
    st Y+, zero         ; target position
    st Y+, zero         ; step size
    st Y+, zero         ; step counter

    ; also save initial servo position to a table in ram so we can compare before saving changes...

    ldi XL, LOW(SRAM_DEFAULT_POSITION_TABLE_START)        ; set up destination table address 
    ldi XH, HIGH(SRAM_DEFAULT_POSITION_TABLE_START)

    add XL, servoIndex
    adc XH, zero

    st X, temp1

    ; next servo

    inc servoIndex

    cpi servoIndex, NUM_SERVOS
    brne LoadServoDataLoop

    ret

SaveServoDataSaveIfChanged :

    ld servoData, Y                         ; load current servo data

    rcall EEPROM_read                       ; read eeprom config data 

    cp servoData, temp1
    brne PC+2                               ; Do not save if data is the same
    ret

    mov temp1, servoData
    rcall EEPROM_write                      ; Data has changed, save to Eeprom..

    ret

SaveServoData :

    push temp1    

    ; first save the controller config data

    ldi YL, LOW(CONFIG_DATA_START)                      ; set up source address
    ldi YH, HIGH(CONFIG_DATA_START)

    ldi XL, LOW(EEPROM_CONFIG_DATA_START)               ; set up destination address in eeprom
    ldi XH, HIGH(EEPROM_CONFIG_DATA_START)

    clr temp2

SaveServoDataConfigDataLoop : 

    rcall SaveServoDataSaveIfChanged        
    
    adiw YL, 1

    adiw XL, 1

    inc temp2

    cpi temp2, EEPROM_CONFIG_DATA_SIZE
    brne SaveServoDataConfigDataLoop


    ; now save the servo data itself...

    ldi YL, LOW(POSITION_DATA_START)                    ; set up source address
    ldi YH, HIGH(POSITION_DATA_START)

    ldi temp2, CONFIG_DATA_TABLE_SIZE

    clr zero

    ldi servoIndex, 0x00

SaveServoDataLoop :

    ldi XL, LOW(EEPROM_MIN_POSITION_TABLE_START)        ; set up destination address in eeprom
    ldi XH, HIGH(EEPROM_MIN_POSITION_TABLE_START)

    add XL, servoIndex
    adc XH, zero

    rcall SaveServoDataSaveIfChanged        ; Save servo min position

    adiw YL, 1                              ; step to next servo data location

    add XL, temp2                           ; step to next eeprom location
    adc XH, zero

    rcall SaveServoDataSaveIfChanged        ; Save servo max position

    adiw YL, 1                              ; step to next servo data location

    add XL, temp2                           ; step to next eeprom location
    adc XH, zero

    rcall SaveServoDataSaveIfChanged        ; Save servo centre position

    adiw YL, BYTES_PER_SERVO - 2            ; next servo data structure

    inc servoIndex                          ; next servo

    cpi servoIndex, NUM_SERVOS
    brne SaveServoDataLoop

    ; now need to save the default position table
    
    ldi YL, LOW(SRAM_DEFAULT_POSITION_TABLE_START)      ; set up source address
    ldi YH, HIGH(SRAM_DEFAULT_POSITION_TABLE_START)

    ldi XL, LOW(EEPROM_DEFAULT_POSITION_TABLE_START)    ; set up destination address in eeprom
    ldi XH, HIGH(EEPROM_DEFAULT_POSITION_TABLE_START)

    ldi servoIndex, 0x00

SaveServoDataLoop2 : 

    rcall SaveServoDataSaveIfChanged        ; Save data

    adiw YL, 1                              ; step to next servo data location

    adiw XL, 1                              ; step to next eeprom data location
    
    inc servoIndex                          ; next servo

    cpi servoIndex, NUM_SERVOS
    brne SaveServoDataLoop2

    pop temp1

    ret

EEPROM_read:
    
    sbic EECR,EEPE
    rjmp EEPROM_read                    ; Wait for completion of previous write

    out EEARH, XH                       ; Set up read address in address register
    out EEARL, XL
    
    sbi EECR,EERE                       ; Start eeprom read 

    in temp1,EEDR                       ; Read data from Data Register

    ret

EEPROM_write:

    sbic EECR,EEPE
    rjmp EEPROM_write                   ; Wait for completion of previous write

    out EEARH, XH                       ; Set up write address in address register
    out EEARL, XL
    
    out EEDR, temp1                     ; data to write
    
    ; Write logical one to EEMPE        - not sure why we do this!!
    sbi EECR,EEMPE

    sbi EECR,EEPE                       ; Start eeprom write
    
    ret


.undef zero
.undef servoData
