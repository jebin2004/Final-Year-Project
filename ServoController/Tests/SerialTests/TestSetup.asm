.nolist
.include "m168def.inc"
.list

.def testResult = r2
.def testIndex = r21

.include "..\..\PWMAndSerialDefinitions.asm"
.include "..\..\SerialDefinitions.asm"

.equ NUM_SERVOS = 28        ; limit to make it easier to test the 'stop all' and 'query all' commands...



.equ CONFIG_DATA_START                     = SRAM_START
.equ CONFIG_DATA_PWM_ACTIVE_ON_RESET       = CONFIG_DATA_START
.equ CONFIG_DATA_SEND_CONTROLLER_ACTIVE    = CONFIG_DATA_START + 1
.equ CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION = CONFIG_DATA_START + 2
.equ CONFIG_DATA_PWM_CURRENTLY_ACTIVE      = CONFIG_DATA_START + 3
.equ CONFIG_DATA_SIZE                      = 4

.equ POSITION_DATA_START = CONFIG_DATA_START + CONFIG_DATA_SIZE
.equ POSITION_DATA_END    = POSITION_DATA_START + (NUM_SERVOS * BYTES_PER_SERVO)


.equ TEST_SERIAL_OUTPUT_BUFFER = POSITION_DATA_END
.equ TEST_SERIAL_OUTPUT_BUFFER_SIZE = 255

.equ TEST_SERIAL_INPUT_BUFFER = TEST_SERIAL_OUTPUT_BUFFER + TEST_SERIAL_OUTPUT_BUFFER_SIZE
.equ TEST_SERIAL_INPUT_BUFFER_SIZE = 100
.equ SERIAL_DATA_START = TEST_SERIAL_INPUT_BUFFER - 1

.equ SRAM_DEFAULT_POSITION_TABLE_START = TEST_SERIAL_INPUT_BUFFER + TEST_SERIAL_INPUT_BUFFER_SIZE
.equ SRAM_DEFAULT_POSITION_TABLE_SIZE = NUM_SERVOS * 1

.equ MULTI_MOVE_WORKSPACE_START = SRAM_DEFAULT_POSITION_TABLE_START + SRAM_DEFAULT_POSITION_TABLE_SIZE
.equ MULTI_MOVE_WORKSPACE_SIZE = MULTI_MOVE_WORKSPACE_BYTES_PER_SERVO * MULTI_MOVE_MAX_SERVOS


.equ STACK_START          = RAMEND


.macro RunTest

    call InitialiseDataToKnownValues
    clr testResult
    call @0
    tst testResult
    brne PC+2
    rjmp TestsFailed
    rcall CheckStack

.endmacro



.ORG $0000
    rjmp TestInit       ; Reset


.org INT_VECTORS_SIZE

TestInit : 

    ; Set stack pointer - we use the stack for the return address of the interrupt handler...

    ldi temp1, LOW(STACK_START)
    out SPL, temp1
    ldi temp1, HIGH(STACK_START)
    out SPH, temp1

    RunTest TestSerialProcessCommandGetInfo
    RunTest TestSerialProcessCommandEnablePWMWhenNotCurrentlyEnabled
    RunTest TestSerialProcessCommandEnablePWMWhenAlreadyEnabled
    RunTest TestSerialProcessCommandDisablePWMWhenNotCurrentlyEnabled
    RunTest TestSerialProcessCommandDisablePWMWhenEnabled
    RunTest TestSerialProcessCommandReset
    RunTest TestSerialProcessCommandResetWhenPWMNotActive
    RunTest TestSerialProcessCommandSaveSettingsWithPWMActive
    RunTest TestSerialProcessCommandSaveSettingsWithPWMInactive
    RunTest TestSerialProcessCommandSetConfigValueWithInvalidConfigItem
    RunTest TestSerialProcessCommandSetConfigValueWithInvalidConfigValue
    RunTest TestSerialProcessCommandSetConfigValueSetConfig0To1
    RunTest TestSerialProcessCommandSetConfigValueSetConfig0To0
    RunTest TestSerialProcessCommandSetConfigValueSetConfig2To1
    RunTest TestSerialProcessCommandSetServoMinPosn
    RunTest TestSerialProcessCommandSetServoMinPosnInvalidServo
    RunTest TestSerialProcessCommandSetServoMinPosnMinLargerThanMax
    RunTest TestSerialProcessCommandSetServoMinPosnMinEqualToMax
    RunTest TestSerialProcessCommandSetServoMaxPosn
    RunTest TestSerialProcessCommandSetServoMaxPosnInvalidServo
    RunTest TestSerialProcessCommandSetServoMaxPosnMaxSmallerThanMin
    RunTest TestSerialProcessCommandSetServoMaxPosnMaxEqualToMin
    RunTest TestSerialProcessCommandSetServoMaxPosnMaxEqualToFF
    RunTest TestSerialProcessCommandSetServoCentrePosn
    RunTest TestSerialProcessCommandSetServoCentrePosnInvalidServo
    RunTest TestSerialProcessCommandSetServoCentrePosnToFF
    RunTest TestSerialProcessCommandSetServoInitialPosn
    RunTest TestSerialProcessCommandSetServoInitialPosnInvalidServo
    RunTest TestSerialProcessCommandSetServoInitialPosnToFF
    RunTest TestSerialProcessCommandSetPosn
    RunTest TestSerialProcessCommandSetPosnInvalidServo
    RunTest TestSerialValidateAndAdjustDesiredPosition
    RunTest TestSerialValidateAndAdjustDesiredPositionTooLowErrorOnFailure
    RunTest TestSerialValidateAndAdjustDesiredPositionTooLowAdjustOnFailure
    RunTest TestSerialValidateAndAdjustDesiredPositionTooHighErrorOnFailure
    RunTest TestSerialValidateAndAdjustDesiredPositionTooHighAdjustOnFailure
    RunTest TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustUp
    RunTest TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustDown
    RunTest TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustToMoreThanFF
    RunTest TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustToExactlyFF
    RunTest TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustToLessThanZero
    RunTest TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustUpAndMinAdjust
    RunTest TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustUpAndMaxAdjust
    RunTest TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustDownAndMinAdjust
    RunTest TestSerialValidateAndAdjustDesiredPositionWithCentreAdjustDownAndMaxAdjust
    RunTest TestSerialProcessCommandSetPosnClearsAllExceptCurrentPos
    RunTest TestSerialProcessCommandSetPosnWithCentreAdjustDownAndMaxAdjust
    RunTest TestSerialProcessCommandSetDelayPosn
    RunTest TestSerialProcessCommandSetDelayPosnInvalidServo
    RunTest TestSerialProcessCommandSetDelayPosnInvalidPosn
    RunTest TestSerialProcessCommandSetDelayPosnInvalidStepSize
    RunTest TestSerialProcessCommandSetDelayPosnPosnTooSmallWithError
    RunTest TestSerialProcessCommandSetDelayPosnPosnTooSmallWithAdjust
    RunTest TestSerialProcessCommandSetDelayPosn2
    RunTest TestSerialProcessCommandSetDelayPosn2InvalidServo
    RunTest TestSerialProcessCommandSetDelayPosn2InvalidPosn
    RunTest TestSerialProcessCommandSetDelayPosn2InvalidStepSize
    RunTest TestSerialProcessCommandSetDelayPosn2InvalidFrequency
    RunTest TestSerialProcessCommandSetDelayPosn2PosnTooSmallWithError
    RunTest TestSerialProcessCommandSetDelayPosn2PosnTooSmallWithAdjust
    RunTest TestSerialProcessCommandStopServo
    RunTest TestSerialProcessCommandStopServoDuringDelayMove
    RunTest TestSerialProcessCommandStopServoInvalidServo
    RunTest TestSerialProcessCommandStopServosSetsRealCommandLength
    RunTest TestSerialProcessCommandStopServosTwoServosNeitherMoving
    RunTest TestSerialProcessCommandStopServosTwoServosFirstMoving
    RunTest TestSerialProcessCommandStopServosTwoServosFirstInvalidServo
    RunTest TestSerialProcessCommandStopServosTwoServosSecondInvalidServo
    RunTest TestSerialProcessCommandStopServosTooManyServosToStop
    RunTest TestSerialProcessCommandStopAllNoneMoving
    RunTest TestSerialProcessCommandQueryServo
    RunTest TestSerialProcessCommandQueryServoDuringDelayMove
    RunTest TestSerialProcessCommandQueryServoInvalidServo
    RunTest TestSerialProcessCommandQueryServosSetsRealCommandLength
    RunTest TestSerialProcessCommandQueryServosTwoServosNeitherMoving
    RunTest TestSerialProcessCommandQueryServosTwoServosFirstMoving
    RunTest TestSerialProcessCommandQueryServosTwoServosFirstInvalidServo
    RunTest TestSerialProcessCommandQueryServosTwoServosSecondInvalidServo
    RunTest TestSerialProcessCommandQueryServosTooManyServosToQuery
    RunTest TestSerialProcessCommandQueryAllNoneMoving


TestsSucceeded : 

rjmp TestsSucceeded 

TestsFailed : 

    ; Note that testIndex contains the index of the test that failed

rjmp TestsFailed

CheckStack : 

    ; The only item on the stack should be our return address...

    in temp1, SPL
    cpi temp1, LOW(STACK_START - 2)
    breq PC+2
    rjmp TestsFailed

    in temp1, SPH
    cpi temp1, HIGH(STACK_START - 2)
    breq PC+2
    rjmp TestsFailed

    ret

.include "SerialTests.asm"
.include "SerialTests-SetConfigValue.asm"
.include "SerialTests-SetServoMinPosn.asm"
.include "SerialTests-SetServoMaxPosn.asm"
.include "SerialTests-SetServoCentrePosn.asm"
.include "SerialTests-SetServoInitialPosn.asm"
.include "SerialTests-SetPosn.asm"
.include "SerialTests-ValidateAndAdjust.asm"
.include "SerialTests-SetDelayPosn.asm"
.include "SerialTests-SetDelayPosn2.asm"
.include "SerialTests-StopServo.asm"
.include "SerialTests-QueryServo.asm"
.include "Mocks.asm"
.include "..\..\SerialProtocolHandling.asm"

InitialiseDataToKnownValues :

    rcall InitialiseSerialInputBuffer
    rcall InitialiseSerialOutputBuffer
    rcall InitialisePositionDataToKnownValues
    rcall InitialiseConfigDataToKnownValues
    rcall InitialiseDefaultPositionDataToKnownValues
    rcall InitialiseMultiMoveWorkspaceData

    clr sCommandLength

    ret


InitialiseSerialOutputBuffer :

    ldi XL, LOW(TEST_SERIAL_OUTPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_OUTPUT_BUFFER)

    clr temp1

    ldi temp2, TEST_SERIAL_OUTPUT_BUFFER_SIZE

InitialiseSerialOutputBufferLoop :
    
    tst temp2
    brne PC+2
    ret

    st X+, temp1

    dec temp2

    rjmp InitialiseSerialOutputBufferLoop
   
InitialiseSerialInputBuffer :

    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    clr temp1

    ldi temp2, TEST_SERIAL_INPUT_BUFFER_SIZE

InitialiseSerialInputBufferLoop :
    
    tst temp2
    brne PC+2
    ret

    st X+, temp1

    dec temp2

    rjmp InitialiseSerialOutputBufferLoop

ValidateSerialInputBufferIsUnchanged : 


    ldi XL, LOW(TEST_SERIAL_INPUT_BUFFER)     
    ldi XH, HIGH(TEST_SERIAL_INPUT_BUFFER)

    clr temp1

    ldi temp2, TEST_SERIAL_INPUT_BUFFER_SIZE

ValidateSerialInputBufferIsUnchangedLoop :

    tst temp2
    brne PC+2
    ret

    ld temp1, X+
    tst temp1
    breq PC+3
    jmp TestsFailed

    dec temp2

    rjmp InitialiseSerialOutputBufferLoop

InitialiseConfigDataToKnownValues : 

    ldi XL, LOW(CONFIG_DATA_PWM_ACTIVE_ON_RESET)     
    ldi XH, HIGH(CONFIG_DATA_PWM_ACTIVE_ON_RESET)
 
    ldi temp1, 0x11
    st X, temp1

    ldi XL, LOW(CONFIG_DATA_SEND_CONTROLLER_ACTIVE)     
    ldi XH, HIGH(CONFIG_DATA_SEND_CONTROLLER_ACTIVE)
 
    ldi temp1, 0x22
    st X, temp1

    ldi XL, LOW(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)     
    ldi XH, HIGH(CONFIG_DATA_SERVO_OUT_OF_RANGE_ACTION)
 
    ldi temp1, 0x33
    st X, temp1

    ldi XL, LOW(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)     
    ldi XH, HIGH(CONFIG_DATA_PWM_CURRENTLY_ACTIVE)
 
    ldi temp1, 0x44
    st X, temp1

    ret


InitialisePositionDataToKnownValues : 

    push count

    ldi XL, LOW(POSITION_DATA_START)     
    ldi XH, HIGH(POSITION_DATA_START)

    ldi count, NUM_SERVOS

InitialisePositionDataToKnownValuesLoop : 

    ldi temp2, 0x00
    st X+, temp2                ; min pos

    ldi temp2, 0xFE
    st X+, temp2                ; max pos

    ldi temp2, 0x7F
    st X+, temp2                ; centre adjust

    ldi temp2, 0x7F
    st X+, temp2                ; current pos

    ldi temp2, 0x00
    st X+, temp2                ; step every

    ldi temp2, 0x00
    st X+, temp2                ; target pos

    ldi temp2, 0x00
    st X+, temp2                ; step size

    ldi temp2, 0x00
    st X+, temp2                ; step counter

    dec count
    tst count
    brne InitialisePositionDataToKnownValuesLoop

    pop count

    ret

ValidatePositionDataIsUnchanged : 

    push temp1
    push temp2
    push count

    ldi XL, LOW(POSITION_DATA_START)     
    ldi XH, HIGH(POSITION_DATA_START)

    ldi count, NUM_SERVOS

ValidatePositionDataIsUnchangedLoop : 

    ldi temp2, 0x00
    ld temp1, X+                ; min pos
    cp temp2, temp1
    brne ValidatePositionDataIsUnchangedLoopError

    ldi temp2, 0xFE
    ld temp1, X+                ; max pos
    cp temp2, temp1
    brne ValidatePositionDataIsUnchangedLoopError

    ldi temp2, 0x7F
    ld temp1, X+                ; centre adjust
    cp temp2, temp1
    brne ValidatePositionDataIsUnchangedLoopError

    ldi temp2, 0x7F
    ld temp1, X+                ; current pos
    cp temp2, temp1
    brne ValidatePositionDataIsUnchangedLoopError

    ldi temp2, 0x00
    ld temp1, X+                ; step every
    cp temp2, temp1
    brne ValidatePositionDataIsUnchangedLoopError

    ldi temp2, 0x00
    ld temp1, X+                ; target pos
    cp temp2, temp1
    brne ValidatePositionDataIsUnchangedLoopError

    ldi temp2, 0x00
    ld temp1, X+                ; step size
    cp temp2, temp1
    brne ValidatePositionDataIsUnchangedLoopError

    ldi temp2, 0x00
    ld temp1, X+                ; step counter
    cp temp2, temp1
    brne ValidatePositionDataIsUnchangedLoopError

    dec count
    tst count
    brne ValidatePositionDataIsUnchangedLoop

    pop count
    pop temp2
    pop temp1

    ret

ValidatePositionDataIsUnchangedLoopError :

    pop count
    pop temp2
    pop temp1

    jmp TestsFailed


InitialiseDefaultPositionDataToKnownValues : 

    push count

    ldi XL, LOW(SRAM_DEFAULT_POSITION_TABLE_START)     
    ldi XH, HIGH(SRAM_DEFAULT_POSITION_TABLE_START)

    ldi count, NUM_SERVOS

InitialiseDefaultPositionDataToKnownValuesLoop : 

    ldi temp2, 0x7F
    st X+, temp2                ; initial pos

    dec count
    tst count
    brne InitialiseDefaultPositionDataToKnownValuesLoop

    pop count

    ret

ValidateDefaultPositionDataIsUnchanged : 

    push temp1
    push temp2
    push count

    ldi XL, LOW(SRAM_DEFAULT_POSITION_TABLE_START)     
    ldi XH, HIGH(SRAM_DEFAULT_POSITION_TABLE_START)

    ldi count, NUM_SERVOS

ValidateDefaultPositionDataIsUnchangedLoop : 

    ldi temp2, 0x7F
    ld temp1, X+                ; initial pos
    cp temp2, temp1
    brne ValidateDefaultPositionDataIsUnchangedLoopError

    dec count
    tst count
    brne ValidateDefaultPositionDataIsUnchangedLoop

    pop count
    pop temp2
    pop temp1

    ret

ValidateDefaultPositionDataIsUnchangedLoopError :

    pop count
    pop temp2
    pop temp1

    jmp TestsFailed


InitialiseMultiMoveWorkspaceData : 

    push XL
    push XH
    push count
    push temp1

    ldi XL,  LOW(MULTI_MOVE_WORKSPACE_START)                        ; 1st entry
    ldi XH,  HIGH(MULTI_MOVE_WORKSPACE_START)

    ldi temp1, MULTI_MOVE_MAX_SERVOS
    mov count, temp1

    clr temp1

InitialiseMultiMoveWorkspaceDataLoop : 

    st X+, temp1        ; servo index
    st X+, temp1        ; target
    st X+, temp1        ; current
    st X+, temp1        ; steps
    st X+, temp1        ; step when
    st X+, temp1        ; step size

    dec count
    brne InitialiseMultiMoveWorkspaceDataLoop

    pop temp1
    pop count
    pop XH
    pop XL

    ret


ValidateMultiMoveWorkspaceIsUnchanged :

    push XL
    push XH
    push count
    push temp2
    push temp1

    ldi XL,  LOW(MULTI_MOVE_WORKSPACE_START)                        ; 1st entry
    ldi XH,  HIGH(MULTI_MOVE_WORKSPACE_START)

    ldi temp1, MULTI_MOVE_MAX_SERVOS
    mov count, temp1

ValidateMultiMoveWorkspaceIsUnchangedLoop :    

    ldi temp2, MULTI_MOVE_WORKSPACE_BYTES_PER_SERVO

ValidateMultiMoveWorkspaceIsUnchangedLoop2 :    

    ld temp1, X+
    tst temp1
    breq PC+3
    jmp TestsFailed

    dec temp2
    brne ValidateMultiMoveWorkspaceIsUnchangedLoop2

    dec count
    brne ValidateMultiMoveWorkspaceIsUnchangedLoop

    pop temp1
    pop temp2
    pop count
    pop XH
    pop XL

    ret
