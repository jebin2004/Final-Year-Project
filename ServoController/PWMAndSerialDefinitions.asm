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


.def resl = r0                  ; serial + PWM setup (used by mul)           
.def resh = r1                  ; serial + PWM setup (used by mul)

.def movesComplete = r3         ; Communications register between serial + PWM setup code

.def currentPos = r4            ; serial + PWM setup 
.def stepEvery = r5             ; serial + PWM setup
.def targetPos = r6             ; serial + PWM setup
.def stepCount = r7             
.def stepSize = r8
.def changed = r9               ; serial + PWM setup
                 





.def temp1 = r22                ; serial + PWM 
.def temp2 = r23                ; serial + PWM

.def thisValue = r24        
.def nextValue = r25


.equ MAX_SERVOS = 64



; Each servo has 8 bytes of configuration/working data. These are as follows:

; 0 - min position
; 1 - max position
; 2 - centre adjust
; 3 - current position
; 4 - step every
; 5 - target position
; 6 - step size
; 7 - step counter

.equ MIN_POS_OFFSET       = 0
.equ MAX_POS_OFFSET       = 1
.equ CENTRE_ADJUST_OFFSET = 2
.equ CURRENT_POS_OFFSET   = 3
.equ STEP_EVERY_OFFSET    = 4
.equ TARGET_POS_OFFSET    = 5
.equ STEP_SIZE_OFFSET     = 6
.equ STEP_COUNT_OFFSET    = 7

.equ BYTES_PER_SERVO      = 8           

