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

; Sends a byte out of the serial port.

SendSerial : 

    push temp1

SendSerialWaitForSend :
 
    lds temp1, UCSR0A
    sbrs temp1, UDRE0
    rjmp SendSerialWaitForSend              ; wait for transmit buffer empty

    cbr temp1, TXC0                         ; clear the transmit complete bit so we can test it
    sts UCSR0A, temp1                       ; if we need to...
    sts UDR0, serialChar

    pop temp1

    ret


WaitForSerialSendComplete :

    push temp1

WaitForSerialSendCompleteLoop2 :

    lds temp1, UCSR0A
    sbrs temp1, TXC0
    rjmp WaitForSerialSendCompleteLoop2

    pop temp1

    ret


