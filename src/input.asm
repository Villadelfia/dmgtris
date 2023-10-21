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


SECTION "Input Variables", HRAM
hUpState::     ds 1
hDownState::   ds 1
hLeftState::   ds 1
hRightState::  ds 1
hAState::      ds 1
hBState::      ds 1
hStartState::  ds 1
hSelectState:: ds 1
hDASCharge::   ds 1



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
    ldh [hDASCharge], a
    ret


GetInput::
    ; Check if the left state > DAS charge.
    ldh a, [hLeftState]
    ld b, a
    ldh a, [hDASCharge]
    cp a, b
    ; If so, save the new DAS charge.
    jr nc, :+
    ld a, b
    ;ldh [hDASCharge], a

    ; Check if the right state > DAS charge.
:   ldh a, [hRightState]
    ld b, a
    ldh a, [hDASCharge]
    cp a, b
    ; If so, save the new DAS charge.
    jr nc, :+
    ld a, b
    ;ldh [hDASCharge], a

    ; There's an overflow risk here if the DAS charge is 255.
:   cp a, $FF
    jr nz, .btns
    dec a
    ldh [hDASCharge], a

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

    ; Read left button. If it's just been pressed, restore the held DAS charge.
.readLeft
    bit 1, b
    jr nz, .clearLeft
.setLeft
    ldh a, [hLeftState]
    cp a, $FF
    jr z, .readRight
    cp a, 0
    jr nz, :+
    ldh a, [hDASCharge]
:   inc a
    ldh [hLeftState], a
    jr .readRight
.clearLeft
    xor a, a
    ldh [hLeftState], a

    ; Read right button. If it's just been pressed, restore the held DAS charge.
.readRight
    bit 0, b
    jr nz, .clearRight
.setRight
    ldh a, [hRightState]
    cp a, $FF
    jr z, .checkDAS
    cp a, 0
    jr nz, :+
    ldh a, [hDASCharge]
:   inc a
    ldh [hRightState], a
    jr .checkDAS
.clearRight
    xor a, a
    ldh [hRightState], a

    ; If none of the four directions are pressed, reset the DAS charge.
.checkDAS
    ld a, b
    or a, $F0
    cp a, $FF
    ret nz
    xor a, a
    ldh [hDASCharge], a
    ret


ENDC
