; DMGTRIS
; Copyright (C) 2023 - Randy Thiemann <randy.thiemann@gmail.com>

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.


IF !DEF(INPUT_ASM)
DEF INPUT_ASM EQU 1


INCLUDE "globals.asm"


SECTION "High Input Variables", HRAM
hUpState::         ds 1
hDownState::       ds 1
hLeftState::       ds 1
hRightState::      ds 1
hAState::          ds 1
hBState::          ds 1
hStartState::      ds 1
hSelectState::     ds 1



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

    ; Read A button.
.readA
    bit 0, b
    jr nz, .clearA
.setA
    ldh a, [hAState]
    cp a, $FF
    jr z, .readB
    inc a
    ldh [hAState], a
    jr .readB
.clearA
    xor a, a
    ldh [hAState], a

    ; Read B button.
.readB
    bit 1, b
    jr nz, .clearB
.setB
    ldh a, [hBState]
    cp a, $FF
    jr z, .readSelect
    inc a
    ldh [hBState], a
    jr .readSelect
.clearB
    xor a, a
    ldh [hBState], a

    ; Read select button.
.readSelect
    bit 2, b
    jr nz, .clearSelect
.setSelect
    ldh a, [hSelectState]
    cp a, $FF
    jr z, .readStart
    inc a
    ldh [hSelectState], a
    jr .readStart
.clearSelect
    xor a, a
    ldh [hSelectState], a

    ; Read start button.
.readStart
    bit 3, b
    jr nz, .clearStart
.setStart
    ldh a, [hStartState]
    cp a, $FF
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

    ; Read up button.
.readUp
    bit 2, b
    jr nz, .clearUp
.setUp
    ldh a, [hUpState]
    cp a, $FF
    jr z, .readDown
    inc a
    ldh [hUpState], a
    jr .readDown
.clearUp
    xor a, a
    ldh [hUpState], a

    ; Read down button.
.readDown
    bit 3, b
    jr nz, .clearDown
.setDown
    ldh a, [hDownState]
    cp a, $FF
    jr z, .readLeft
    inc a
    ldh [hDownState], a
    jr .readLeft
.clearDown
    xor a, a
    ldh [hDownState], a

    ; Read left button.
.readLeft
    bit 1, b
    jr nz, .clearLeft
.setLeft
    ldh a, [hLeftState]
    cp a, $FF
    jr z, .readRight
    inc a
    ldh [hLeftState], a
    jr .readRight
.clearLeft
    xor a, a
    ldh [hLeftState], a

    ; Read right button.
.readRight
    bit 0, b
    jr nz, .clearRight
.setRight
    ldh a, [hRightState]
    cp a, $FF
    jr z, .priorities
    inc a
    ldh [hRightState], a
    jr .priorities
.clearRight
    xor a, a
    ldh [hRightState], a

    ; If left or right are pressed, zero out up and down.
.priorities
    ldh a, [hRightState]
    cp a, 0
    jr nz, .zero
    ldh a, [hLeftState]
    cp a, 0
    ret z

.zero
    xor a, a
    ldh [hUpState], a
    ldh [hDownState], a
    ret


ENDC
