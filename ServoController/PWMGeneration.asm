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

.def pwmMode = r2               ; PWM timer interrupts

.def bankMask = r14             ; Initialise and PWM setup
.def index = r19
.def bankIndex = r20            ; Initialise and PWM setup
.def muxAddress = r21           ; Initialise and PWM setup

InitialisePWMOutput :

    push XL
    push XH

    ldi XL, LOW(CONFIG_DATA_PWM_CURRENTLY_ACTIVE) 
    ldi XH, HIGH(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)

    ldi temp1, 0x01

    st X, temp1                         ; Indicate that we're turned on

    pop XH
    pop XL

    ; Initialise Timer1 in CTC mode

    clr temp1                           ; Controlword A    0x0000
    sts TCCR1A, temp1

    ldi temp1, (1<<WGM12) | (1<<CS11)   ; CTC mode (WGM12) with the timer running at clock/8
    sts TCCR1B, temp1

    ldi temp1, 1 << OCIE1A              ; Enable Timer1 interrupt
    sts TIMSK1, temp1

    ; Kick off the PWM code...

    clr temp1                   ; Reset Timer 1...
    sts TCNT1H, temp1          
    sts TCNT1L, temp1          


    ldi temp1, HIGH(10)         ; CTC-value - something low to kick us off... 
    sts OCR1AH, temp1          
    ldi temp1, LOW(10)          ; Note that the 16-bit timer control registers MUST be written
    sts OCR1AL, temp1           ; high byte first then low byte as the low write triggers the
                                ; 16-bit atomic write.

    clr muxAddress              ; address channel 0 on the mux's
    out PORTD, muxAddress

    clr temp1                   ; initialise PWM output to a stable 'off' state
    out PORTB, temp1
    out PORTC, temp1

    clr bankIndex               ; start from bank 0

    ldi temp1, 1                ; set the bank mask to bit 1
    mov bankMask, temp1 

    ; We have two different states for our timer interrupt handling, a setup mode and a 
    ; 'pulse switch off' mode. We use the pwmMode register to determine which mode we're in.
    ; The interrupt handler jumps to the appropriate code depending on how pwmMode is set. 
    ; if it's zero then we're in setup mode if it's non zero then we're in switch off mode.
    
    clr pwmMode    

    sei                         ; enable interrupts    

    ret


DisablePWMOutput :

    cli                             ; disable interrupts

    clr temp1                       ; turn off all PWM output
    out PORTB, temp1
    out PORTC, temp1

    clr muxAddress                  ; address channel 0 on the mux's
    out PORTD, muxAddress

    push XL
    push XH

    ldi XL, LOW(CONFIG_DATA_PWM_CURRENTLY_ACTIVE) 
    ldi XH, HIGH(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)

    st X, temp1                     ; indicate that we're turned off

    pop XH
    pop XL

    ret


TC1CmpA:

    push temp1

    in temp1, SREG                  ; save status register
    push temp1

    tst pwmMode
    brne  PWMPulseStop

    rcall PWMSetup                  ; if pwmMode is 0 then we're doing setup tasks

    pop temp1                       ; restore the state prior to the interrupt
    out SREG, temp1
    pop temp1

    reti    
    

.def pulseStopTemp1 = r10       ; PWM switch off ONLY
.def pulseStopTemp2 = r11       ; PWM switch off ONLY

; PWM pulse stop - timer interrupt handler for phase 2 of the PWM generation cycle
;
; PWM pulse stop phase. This timer interrupt handler turns off some pins on PORTB and then sets the
; next stop time and returns, once all pins are off the final timeout uses up the remaining part
; of the 2.5ms slot and sets the Z pointer to call the PWMSetup code to start the next batch of servos


PWMPulseStop :

    ld pulseStopTemp1, Y+

    ; load the next time...

    ld pulseStopTemp2, Y+
    sts OCR1AH, pulseStopTemp2
    ld pulseStopTemp2, Y+           ; Note that the 16-bit timer control registers MUST be written
    sts OCR1AL, pulseStopTemp2      ; high byte first then low byte as the low write triggers the
                                    ; 16-bit atomic write.

    ; this needs tuning...

    nop                
    nop



    mov pulseStopTemp2, pulseStopTemp1
    tst pulseStopTemp1                          ; If all the pins are now off then the next timeout is our last
    brne PC+2                                   ; and we switch back to setup phase when it expires...
    clr pwmMode                                 ; set mode to zero so we're now in setup mode for the next 
                                                ; timer interrupt


    ldi temp1, 0x0F
    and pulseStopTemp1, temp1                   ; we need the low nibble for port b
    swap pulseStopTemp2
    and pulseStopTemp2, temp1                   ; we need the high nibble for port c

    out PORTB, pulseStopTemp1                   ; Turn off servo pins...
    out PORTC, pulseStopTemp2                   ; Turn off servo pins...

    pop temp1                                   ; restore the state prior to the interrupt
    out SREG, temp1
    pop temp1

    reti



.undef pulseStopTemp1
.undef pulseStopTemp2


; PWM Setup - timer interrupt handler for phase 1 of the PWM generation cycle


PWMSetup : 

    push temp2
    push resl
    push resh
    push currentPos         ; save the state of these as they are used by the serial protocol code
    push stepEvery
    push targetPos
    push stepCount
    push stepSize
    push thisValue
    push nextValue
    push changed
    push ZL
    push ZH


    ; Set the timer to 400ms which is much longer than the PWM setup phase takes to run. We 
    ; will adjust this to the correct value when we complete the setup phase.

    ldi temp1,HIGH(400) 
    sts OCR1AH,temp1
    ldi temp1, LOW(400)        ; Note that the 16-bit timer control registers MUST be written
    sts OCR1AL, temp1          ; high byte first then low byte as the low write triggers the
                               ; 16-bit atomic write.


    ; set the port d bits to control the mux address selection...

    out PORTD, muxAddress     ; mux address is 4 * bank index


    ; Start the PWM signal generation for this bank. All pwm pins on port b and c are on...

    ldi temp1, $0F     
    out PORTB, temp1
    out PORTC, temp1

    ; We generate at most 8 PWM signals at a time (PWM_SERVOS_PER_CYCLE) and repeat these 
    ; signals every 20ms, since we can support at most 64 servos in total this means we 
    ; need to generate 8 batches of 8 signals and each batch can take at most 2.5ms to 
    ; generate the signals for all of the servos in that batch. The signals should be between 
    ; 600us and 2.4ms long. 

    ; The data we use to generate the PWM signals is based on the data that the serial I/O
    ; code stores at POSITION_DATA_START. The serial code stores 5 bytes per servo. These bytes
    ; are as follows:
    ; 0 - current position
    ; 1 - step every
    ; 2 - target position
    ; 3 - step size
    ; 4 - step counter
    ; The current and target position values are control values of between 0 and 254 with 127 
    ; being in the centre with a pulse length of 1.5ms
    ; If 'step every' is not zero and the current position is not equal to the target position
    ; then the PWM setup code will decrement the step counter by one. When the step counter 
    ; reaches zero we step the current position towards the target position by the step size.
    ; If the current position goes past the target position during this move then the current
    ; position is set to the target position. When a step means that the current position
    ; becomes the target position we set a bit in the movesComplete register that represents
    ; the bank in which the servo that has completed is present. The serial I/O code can check,
    ; but not change, this register and send a 'incremental move complete' message back to 
    ; the controlling computer.
    ; Note that PWM code has read access to control bytes 1, 2 and 3 and read/write access
    ; to control bytes 0 and 4. The serial code has the opposite access. 

    ; The PWM generation code uses two byte servo control values that represent the actual
    ; timeout values required to turn off the servo pin, we can have up to 8 off times, as
    ; we merge duplicate off times together. The final off time (which could be number 9 if
    ; we have 8 unique servo control values) is the time remaining between the last servo 
    ; pin being turned off and the start of the next PWM generation cycle. I.e. it is the 
    ; time remaining until the 2.5ms time period has passed.

    ; First we copy our position data from the source buffers that the serial I/O code
    ; can alter into the working buffers that we'll use during PWM generation.
    ; The soruce data is arranged in 8 banks of 8 bytes, we use the eex to index
    ; into the start of the bank that we're working on.

    ; To make it easier to create a board for versions of this controller that don't provide
    ; all 64 channels we reorder the servo data during the copy so that the servo channels 
    ; appear sequentially on the pins of the MUX chips. That is servo 0 is pin 0 on mux 1, 
    ; servo 1 is pin 1 on mux 1, servo 9 is pin 0 on mux 2, etc.

    ; To achieve this we need to step the source pointer of our copy by 8 servo control data 
    ; structures each time, starting at the bankIndex offset address. So for the first cycle 
    ; we copy starting from our position data start address plus an offset of 0, for the next 
    ; we start at an offset of 1 * the number of bytes of control data per servo (currently 5), 
    ; for the next at an offset of 2 * the number of bytes of control data per servo, etc.
    

    ldi ZL, LOW(POSITION_DATA_START)   ; Load memory location to copy from
    ldi ZH, HIGH(POSITION_DATA_START)

    ; Multiply the bank index by the number of bytes per servo to get the offset from the 
    ; start of the data

    ldi temp1, BYTES_PER_SERVO

    mul bankIndex, temp1

    add ZL, r0
    adc ZH, r1

    ; Clear the 'moves are complete' bit for this bank

    mov temp1, bankMask
    com temp1
    and movesComplete, temp1

PWMSetupSetDestination:

    ldi YL, LOW(PWM_DATA_START)
    ldi YH, HIGH(PWM_DATA_START)

    ; The position data consists of a 1 byte value for each servo. The PWM code needs to 
    ; also have the bit that corresponds to the pin that controls this servo. As we copy
    ; from source to destination we expand the data per servo from a 1 byte position value 
    ; to a two byte position and bit combination.

    ldi index,1                         ; the first pin is at position 1


PWMSetupCopy:

    ld temp1, Z+                            ; Skip min position, we're not interested
    ld temp1, Z+                            ; Skip max position, we're not interested
    ld temp1, Z+                            ; Skip centre adjust, we're not interested

    ; We can be configured to support fewer than 64 servos, in that case the servos that we 
    ; don't support are hardcoded to an 0x7F value in case the hardware is such that someone
    ; can connect a servo to the pin! We still generate the signals correctly for all 64 
    ; servos, you just cant configure more than the maximum specified in NUM_SERVOS.


    cpi ZH, HIGH(POSITION_DATA_END - 1)
    brne PWMSetupCopyFromSource

    cpi ZL, LOW(POSITION_DATA_END - 1)          ; then check low byte....
    brne PWMSetupCopyFromSource


PWMSetupUnsupportedServo:

    ; Z is out of range. We are attempting to access a servo index that we don't support.
    ; Hard code the value to 0x7F...

    ldi temp1, 0x7F
    mov currentPos, temp1                    
    
    ldi temp1, (PWM_SERVOS_PER_CYCLE * BYTES_PER_SERVO)
    clr temp2

    add ZL, temp1
    adc ZH, temp2

    rjmp PWMSetupCopyToDest

PWMSetupCopyFromSource:

    ; Servo index is valid for control.

    ld currentPos, Z+                       ; load current position from the position data

    ld stepEvery, Z+                        ; load 'step every' from the position data

    ld targetPos, Z+                        ; load the target position

    ld stepSize, Z+                         ; load step size

    ld stepCount, Z+                        ; load the step count position

    sbiw ZL, BYTES_PER_SERVO                ; move Z back to the start of this structure

    tst stepEvery                           ; if we're not stepping...
    breq PWMSetupIncrementSource

    ; We only ever refer to the target position and the step size when step every is non zero.

    cp currentPos, targetPos                ; if current position != target position
    brne PWMSetupStep1                          

    ; Although we signal the serial code when a move actually completes we also signal it here to say that this
    ; move has completed and the serial code hasn't processed it yet. 

    or movesComplete, bankMask              ; add this bank of servos to the servos with moves completed register

    rjmp PWMSetupIncrementSource

PWMSetupStep1:

    ; current position is not equal to target position and step every is not equal to zero...

    tst stepCount                           ; if count is not zero
    brne PWMSetupStep2

    mov stepCount, stepEvery

PWMSetupStep2:    

    dec stepCount                           ; reduce our counter...
 
                                            ; save the counted back to the control data...
                                              
    adiw ZL, STEP_COUNT_OFFSET              ; increment Z to point to the step count

    st Z, stepCount                         ; save the value

    sbiw ZL, STEP_COUNT_OFFSET              ; move Z back to the start of this structure

   
    tst stepCount                           ; if count is not at zero...
    brne PWMSetupIncrementSource

    cp currentPos, targetPos                ; if we're incrementing towards the target position
    brlo PWMSetupIncrementCurrentPos

                                            ; else we're decrementing towards the target position...

    cp currentPos, stepSize                 ; check for underflow in the currentPos - stepSize calc
    brlo PWMSetupSetCurrentToTarget

    sub currentPos, stepSize                ; decrement towards the target...

    cp targetPos, currentPos                ; if the target position is still less than the current position
    brlo PWMSetupUpdateCurrentPos

    rjmp PWMSetupSetCurrentToTarget         ; else set the current position to the target position

PWMSetupIncrementCurrentPos:

    ldi temp1, 0xFF                         ; check for overflow in the currentPos + stepSize calc
    sub temp1, stepSize
    
    cp temp1, currentPos
    brlo PWMSetupSetCurrentToTarget

    add currentPos, stepSize                ; increment towards target position

    cp currentPos, targetPos                ; if the target position is still larger than the current position
    brlo PWMSetupUpdateCurrentPos

                                            ; else set the current position to the target position

PWMSetupSetCurrentToTarget:

    mov currentPos,  targetPos              ; set to the target position

    or movesComplete, bankMask              ; add this bank of servos to the servos with moves completed register

PWMSetupUpdateCurrentPos:
    
    adiw ZL, CURRENT_POS_OFFSET

    st Z, currentPos                        ; update the current position

PWMSetupIncrementSource:

    ldi temp1, (PWM_SERVOS_PER_CYCLE * BYTES_PER_SERVO)
    clr temp2

    add ZL, temp1
    adc ZH, temp2
    
    rjmp PWMSetupCopyToDest

PWMSetupCopyToDest:

    ; Copy the current position value (which has possibly been moved closer to the target position value)
    ; to the PWM working data.

    st Y+,currentPos        ; store to the pwm data

    ldi temp1, 0xFF
    eor temp1, index        ; servos are ON when the pin is set, we need to know the unset, OFF 
                            ; value for this pin
    st Y+, temp1            ; store the pwm OFF pin value

    lsl index               ; next pin
    tst index
    breq PC+2
    rjmp PWMSetupCopy


    ; Now that we have the servo data copied into our working space and grouped with the 
    ; related pin information we need to sort the data into order from low to high. This
    ; will allow us to set a timer for the next servo control value change, adjust the pins
    ; when the timer fires and then step to the next later servo control value.

    ; We use a simple bubble sort to compare the values of this servo control byte with the
    ; next servo control byte and if the next value is less than this value we swap both the
    ; values and the pins.

    ; During the sort we merge the pin values of servo control values that are equal as we
    ; only need to set the timer once to turn off multiple servos. This leaves us with a 
    ; servo control value that we no longer need, we set this to 0xFF so that it automatically
    ; bubbles up to the end of the list.

    ; set up before sort...

.undef temp1
.def unusedServoValue = r22


    ldi unusedServoValue, 0xFF        ; control value for 'unused pwm control value'

PWMSetupSortLoop:

    clr changed                         ; changed is a flag that we set if we need to swap
                                        ; any values this time through the loop, we keep
                                        ; looping until we manage to get through the whole
                                        ; loop without swapping anything, and then we know that
                                        ; the values are in order.

    ldi ZL, LOW(PWM_DATA_START)         ; 'this' value, start at the begining of the PWM data
    ldi ZH, HIGH(PWM_DATA_START)
    ldi YL, LOW(PWM_DATA_START + 2)     ; 'next' value, note we compare values and ignore the pins
    ldi YH, HIGH(PWM_DATA_START + 2)

PWMSetupSort1:

    ld thisValue, Z                     ; load this value
    ld nextValue, Y                     ; load next value

    cp nextValue, unusedServoValue      ; if the next value is the 'unused pwm control value' 
    breq PWMSetupSortLoopEnd            ; we can skip the rest of this loop

    cp nextValue, thisValue             ; if next < this then swap them
    brlo PWMSetupSwap

    brne PWMSetupSortIncrement1         ; if they are not the same, increment the indices and move
                                        ; on to the next value

    cp nextValue, unusedServoValue      ; if they are the same but the are not UnusedServoValue, merge them
    brne PWMSetupMerge

PWMSetupSortIncrement1:

    adiw ZL, 1                          ; step on to this pin
    adiw YL, 1                          ; step on to next pin

PWMSetupSortIncrement2:

    cpi YL, LOW(PWM_DATA_START + 0x0F)  ; check to see if we're at the last value...        
    breq PWMSetupSortLoopEnd            ; if so see if we need to restart the loop

    adiw ZL, 1                          ; step on to this pin
    adiw YL, 1                          ; step on to next pin

    rjmp PWMSetupSort1                  ; sort the next two values...
    
PWMSetupSwap:

    st Z+, nextValue                    ; store the 'next' value in the 'this' position
    st Y+, thisValue                    ; store the 'this' value in the 'next' position
    ld thisValue, Z                     ; load the 'this' pin data
    ld nextValue, Y                     ; load the 'next' pin data         
    st Z, nextValue                     ; and swap those two
    st Y, thisValue 

    inc changed                         ; note that we changed something so that we run the whole 
                                        ; sort loop again

    rjmp PWMSetupSortIncrement2         ; since we swapped the values the indices are at the pin
                                        ; positions (value + 1) therefore we jump to the second 
                                        ; stage of our index increment code...

PWMSetupMerge:

    ; If the servo values are equal then we merge the pin values together and set the later servo
    ; value to UnusedServoValue which is 0xFF and will automatically bubble up to the end of the 
    ; list...

    st Y+, unusedServoValue             ; store UnusedServoValue to the 'next' value, we don't use that 
                                        ; value anymore

    adiw ZL, 1                          ; step on to this pin

    ld thisValue, Z                     ; load 'this' pin
    ld nextValue, Y                     ; load 'next' pin
    and thisValue, nextValue            ; and the pin values together to merge the bits set in into temp1
    st Z, thisValue                     ; and store it as the 'this' pin value

    inc changed                         ; note that we changed something so that we run the whole 
                                        ; sort loop again

    rjmp PWMSetupSortIncrement2         ; since we merged the values the indices are at the pin
                                        ; positions (value + 1) therefore we jump to the second 
                                        ; stage of our index increment code...

PWMSetupSortLoopEnd :

    tst changed                         ; did we change anything this time through the loop?
    brne PWMSetupSortLoop               ; if so we run the whole sort again...

    ; Now that the servo control data has been sorted into ascending pulse length order and the 
    ; duplicates have been merged we need to run through the pin control values and merge the later ones
    ; with the earlier ones so that each ascending pulse turn off value includes all of the earlier turn
    ; off signals... That is, if we have a sequence of 0x01 0xFE, 0x02 0xEF then we should and the first 
    ; off signal with the second to give a sequence of 0x01 0xFE, 0x02 0xEE. This means that as we work
    ; our way through the sequences we turn off progressively more pulses.

PWMSetupBitMergeSetup:

    ldi ZL, LOW(PWM_DATA_START + 1)     ; 'this' pin data, start at the first pin data element in the PWM
    ldi ZH, HIGH(PWM_DATA_START + 1)    ; data area.
    ldi YL, LOW(PWM_DATA_START + 3)     ; 'next' pin data
    ldi YH, HIGH(PWM_DATA_START + 3)

PWMSetupBitMerge:

    ld thisValue, Z+                    ; load 'this' value
    ld nextValue, Y                     ; load 'next' value

    and nextValue, thisValue            ; merge the two values so that pins that were off for 'this' are
                                        ; also off for 'next'
    st Y, nextValue                     ; store the new 'next' value.

    tst nextValue                       ; check to see if all pins are now off, if so, we're done
    breq PWMSetupBitMergeDone

    cpi ZL, LOW(PWM_DATA_START + 0x0E)  ; check for last value...        
    breq PWMSetupBitMergeDone

    adiw ZL, 1                          ; increment our indices, we already incremented Z once during our load
    adiw YL, 2

    rjmp PWMSetupBitMerge

PWMSetupBitMergeDone:


    ; We now have a seqence of servo control values and pin control values sorted in ascending time order and
    ; our pin control values are such that as we step through them we progressively turn off more pins.

    ; Now we need to make the servo control values relative to each other so that the sequential values are 
    ; incremental rather than absolute; for example, 120 127 129 130 becomes 120 7 2 1


    ldi ZL,     LOW(PWM_DATA_START)    ; first servo control value
    ldi ZH,    HIGH(PWM_DATA_START)

    ld thisValue, Z+

    adiw ZL, 1

PWMSetupSequentialLoop :

    ld nextValue, Z

    cp nextValue, unusedServoValue      ; if we are at the end of the valid data...
    breq PWMSetupSequentialLoopEnd

    sub nextValue, thisValue
    st Z+, nextValue
    add thisValue, nextValue

    adiw ZL, 1

    rjmp PWMSetupSequentialLoop

PWMSetupSequentialLoopEnd :


    ; Now we need to convert the single byte servo control values into values suitable for our timer control.
    ; This requires us to multiply by 7 to give us a range of 0-1778 with the centre position as 889 for
    ; a servo control value of 127


    ; This changes the shape of the data from a list of two byte structures (servo control byte, pin control byte)
    ; to a list of three byte structres (servo high, servo low, pin control).

    ; At this point we zero out the entries that were merged and are now extra, i.e. the 0xFFs


    ldi ZL, LOW(PWM_DATA_START + 0x0E)      ; source data, we're working backwards along our list so that we can 
    ldi ZH, HIGH(PWM_DATA_START + 0x0E)     ; overwrite the data in place...
    ldi YL, LOW(PWM_DATA_START + 0x15)      ; our list is now 8 bytes longer than it was before as all the elements
    ldi YH, HIGH(PWM_DATA_START + 0x15)     ; are a byte bigger...

    ldi temp2, 7                            ; we multiply by 7 to get a range of 0-1778

PWMSetupMultiplyLoop:

    ld thisValue, Z+                        ; load the source data into temp1 ready for the multiply
    cp thisValue, unusedServoValue          ; if it's 0xFF (our invalid pwm data marker) we skip it
    breq PWMSetupSkipMultiply                   

    mul thisValue, temp2                       

    rjmp PWMSetupAfterMultiply

PWMSetupSkipMultiply:

    clr resl                                ; we need these to be zero so that we can write zeroes for the skipped
    clr resh                                ; elements...

PWMSetupAfterMultiply:

    ld thisValue, Z                         ; load the pin control data
    st Y+, resh                             ; store the new servo control value; low byte
    st Y+, resl                             ; and high byte
    st Y, thisValue                         ; store the pin control data


    cpi ZL, LOW(PWM_DATA_START + 1)         ; check for last value...        
    breq PWMSetupMultplyDone

    sbiw ZL, 3                              ; step our source index back 3 (we'd stepped forward 1 to get to the pin data)

    sbiw YL, 5                              ; step our destination index back 5 (we'd stepped forward two whilst writing this data)

    rjmp PWMSetupMultiplyLoop               ; multiply the next value...

PWMSetupMultplyDone:

.undef unusedServoValue
.def temp1 = r22


    ; Now that we have the expanded relative timeout values in order we need to add our base time to the first
    ; timeout

    ; To get from the new control values to the absolute time in us we need to add 493, which gives a
    ; value of 1500 for 127, and a range of 611us - 2389us (493-2271 clock ticks)

.equ timerBase = 493                        ; if you're running with a 7.3728mhz clock - wider range

    ; Since the AVR doesn't have an add adci we subtract a negative number; see the examples with AVR202 application note
    ; adiw can only add a max of 63...

    mov temp1, resl
    mov temp2, resh

    subi temp1, low(-timerBase)
    sbci temp2, high(-timerBase)    

    sbiw YL, 2                              ; step our destination index back to allow us to overwrite the value

    st Y+, temp2
    st Y+, temp1

    ; Now that we have our timeouts in order as relative times we need to work out the absolute time for
    ; the final timeout. Once we have this we can work out how much time we have left in our timeslot and 
    ; set a timeout for that time which brings us to the end of this batch of PWM signals and starts us on
    ; the next batch...

    clr resl
    clr resh

    ldi ZL, LOW(PWM_DATA_START)             ; source
    ldi ZH, HIGH(PWM_DATA_START)

PWMSetupAccumulateTotalTimeLoop:

    ld temp1, Z+        ; high
    ld temp2, Z+        ; low

    add resl, temp2
    adc resh, temp1
 
    ld temp1, Z+
    tst temp1
    brne PWMSetupAccumulateTotalTimeLoop

.equ maxTime = 2304                         ; if you're running with a 7.3728mhz clock 

    ldi temp1, low(maxTime)
    ldi temp2, high(maxTime)

    sub temp1, resl
    sbc temp2, resh

    st Z+, temp2                            ; store the final timer value that takes us to the end of our 2.5ms timeslot...
    st Z+, temp1

    ldi temp1, 0xFF                         ; final sentinel pin control value for the next loop...
    st Z+, temp1

    ; And finally.... Our interrupt processing from the point where the timer goes off to the point where we
    ; have turned off the PWM generation for the pins concerned takes up 1us, so we need to subtract that from the 
    ; times...

    ldi ZL, LOW(PWM_DATA_START)             ; source 
    ldi ZH, HIGH(PWM_DATA_START)
    ldi YL, LOW(PWM_DATA_START)             ; destination 
    ldi YH, HIGH(PWM_DATA_START)

PWMSetupIntTimeAdjustLoop:

    ld temp1, Z+
    ld temp2, Z+

    subi temp2, LOW(1)
    sbci temp1, HIGH(1)

    st Y+, temp1
    st Y+, temp2
    adiw YL, 1

    ld temp1, Z+
    cpi temp1, 0xFF
    brne PWMSetupIntTimeAdjustLoop


    ; Now we set things up for the next time that the PWMSetup code is called, we increment the
    ; mux address by 4, and increment the bank address and rotate the bank mask...

    ldi temp1, 4
    add muxAddress, temp1

    lsl bankMask                ; adjust the bank mask for this bank 

    inc bankIndex               ; select next bank of servos, wrap to 0 at 8..

    cpi bankIndex, 8
    brne PWMSetupComplete

    clr bankIndex               ; reset the bank address
    clr muxAddress              ; reset the mux address

    ldi temp1, 1                ; reset the bank mask to bit 1 
    mov bankMask, temp1 

PWMSetupComplete:

    ; Now set up our Y pointer for use by the PWM pulse stop code and 
    ; adjust the timer that we set so that it goes off at the first PWM stop time

    ldi YL, LOW(PWM_DATA_START)        ; source 
    ldi YH, HIGH(PWM_DATA_START)

    ld temp1, Y+
    sts OCR1AH,temp1
    ld temp1,Y+
    sts OCR1AL,temp1

    ; Finally switch into pulse switch off mode so that the next timer interrupt will
    ; go to the code that switches off the pulses!

    inc pwmMode

    ; Setup is complete

    pop ZH
    pop ZL
    pop changed
    pop nextValue
    pop thisValue
    pop stepSize
    pop stepCount
    pop targetPos
    pop stepEvery
    pop currentPos
    pop resh
    pop resl
    pop temp2

    ret






