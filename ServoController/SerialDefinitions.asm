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


.def count = r18                ; serial ONLY
.def numServos = r15            ; serial ONLY

.def sCommandLength = r12       ; serial ONLY
.def sExpectedBytes = r13       ; serial ONLY
.def serialChar = r17           ; serial ONLY


.def servoIndex = r16           ; serial + EEPROM code (serial)


.equ SERIAL_DATA_LENGTH   = 140


.equ MULTI_MOVE_WORKSPACE_BYTES_PER_SERVO  = 6

.equ MULTI_MOVE_WORKSPACE_SERVO_INDEX_OFFSET    = 0
.equ MULTI_MOVE_WORKSPACE_TARGET_POSN_OFFSET    = 1
.equ MULTI_MOVE_WORKSPACE_CURRENT_POSN_OFFSET   = 2
.equ MULTI_MOVE_WORKSPACE_STEPS_REQUIRED_OFFSET = 3
.equ MULTI_MOVE_WORKSPACE_STEP_WHEN_OFFSET      = 4
.equ MULTI_MOVE_WORKSPACE_STEP_SIZE_OFFSET      = 5

.equ MULTI_MOVE_MAX_SERVOS = 32
