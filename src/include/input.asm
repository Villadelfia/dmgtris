IF !DEF(INPUT_ASM)
DEF INPUT_ASM EQU 1


SECTION "Input Variables", HRAM
hUpState::     ds 1
hDownState::   ds 1
hLeftState::   ds 1
hRightState::  ds 1
hAState::      ds 1
hBState::      ds 1
hStartState::  ds 1
hSelectState:: ds 1



SECTION "Input Functions", ROM0
InputInit::
    xor a, a
    ldh [hUpState], a
    ldh [hDownState], a
    ldh [hLeftState], a
    ldh [hRightState], a
    ldh [hAState], a
    ldh [hBState], a
    ldh [hStartState], a
    ldh [hSelectState], a
    ret


GetInput::
    ; Get the button state.
.btns
    ld a, P1F_GET_BTN
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ld b, a

.readA
    bit 0, b ; A
    jr nz, .clearA
.setA
    ldh a, [hAState]
    cp $FF
    jr z, .readB
    inc a
    ldh [hAState], a
    jr .readB
.clearA
    xor a, a
    ldh [hAState], a

.readB
    bit 1, b ; B
    jr nz, .clearB
.setB
    ldh a, [hBState]
    cp $FF
    jr z, .readSelect
    inc a
    ldh [hBState], a
    jr .readSelect
.clearB
    xor a, a
    ldh [hBState], a

.readSelect
    bit 2, b ; Select
    jr nz, .clearSelect
.setSelect
    ldh a, [hSelectState]
    cp $FF
    jr z, .readStart
    inc a
    ldh [hSelectState], a
    jr .readStart
.clearSelect
    xor a, a
    ldh [hSelectState], a

.readStart
    bit 3, b ; Start
    jr nz, .clearStart
.setStart
    ldh a, [hStartState]
    cp $FF
    jr z, .dpad
    inc a
    ldh [hStartState], a
    jr .dpad
.clearStart
    xor a, a
    ldh [hStartState], a


    ; Get the dpad state.
.dpad
    ld a, P1F_GET_DPAD
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ld b, a

.readUp
    bit 2, b ; Up
    jr nz, .clearUp
.setUp
    ldh a, [hUpState]
    cp $FF
    jr z, .readDown
    inc a
    ldh [hUpState], a
    jr .readDown
.clearUp
    xor a, a
    ldh [hUpState], a

.readDown
    bit 3, b ; Down
    jr nz, .clearDown
.setDown
    ldh a, [hDownState]
    cp $FF
    jr z, .readLeft
    inc a
    ldh [hDownState], a
    jr .readLeft
.clearDown
    xor a, a
    ldh [hDownState], a

.readLeft
    bit 1, b ; Left
    jr nz, .clearLeft
.setLeft
    ldh a, [hLeftState]
    cp $FF
    jr z, .readRight
    inc a
    ldh [hLeftState], a
    jr .readRight
.clearLeft
    xor a, a
    ldh [hLeftState], a

.readRight
    bit 0, b ; Right
    jr nz, .clearRight
.setRight
    ldh a, [hRightState]
    cp $FF
    ret z
    inc a
    ldh [hRightState], a
    ret
.clearRight
    xor a, a
    ldh [hRightState], a
    ret


ENDC
