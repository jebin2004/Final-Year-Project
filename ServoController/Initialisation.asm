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


; Program start

Init:

    ; Set stack pointer 

    ldi temp1, LOW(STACK_START)
    out SPL, temp1
    ldi temp1, HIGH(STACK_START)
    out SPH, temp1

    ; Set up the serial port

    ldi temp1, HIGH(baudconstant)               ; Set the baud rate
    sts UBRR0H, temp1
    ldi temp1, LOW(baudconstant)
    sts UBRR0L, temp1

    ldi temp1, (1 << RXEN0) | (1 << TXEN0)      ; enable rx and tx
    sts UCSR0B, temp1

    ldi temp1, (3 << UCSZ00)                    ; 8N1 
    sts UCSR0C, temp1

    ; Initialise our PWM output pins    

    ldi temp1, $0F                  ; set pins 0-4 on port B as output 
    out DDRB, temp1

    ldi temp1, $0F                  ; set pins 0-4 on port C as output 
    out DDRC, temp1

    ; Initialise our MUX address select output pins         

    ldi temp1, $1C                  ; Init MUX address line outputs; we use pins 2-4 on port D
    out DDRD, temp1

    rcall LoadServoData

    ; Initialisation is done...

    ldi XL, LOW(CONFIG_DATA_START)              ; set up source address
    ldi XH, HIGH(CONFIG_DATA_START)
    
    ld temp1, X+                                ; load 'PWM active' flag

    tst temp1               
    breq PC+2   
    rcall InitialisePWMOutput        

    ld temp1, X+                                ; load 'send controller active' flag
    
    tst temp1
    breq PC+2
    rjmp SerialProcessCommandGetInfo
    
    rjmp SerialStart
