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


IF !DEF(SCORE_ASM)
DEF SCORE_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Score Variables", HRAM
hScore:: ds 6
hScoreIncrement:: ds 2
hScoreIncrementBCD:: ds 6
hScoreIncrementHead:: ds 1


SECTION "Score Functions", ROM0
ScoreInit::
    xor a, a
    ldh [hScore], a
    ldh [hScore+1], a
    ldh [hScore+2], a
    ldh [hScore+3], a
    ldh [hScore+4], a
    ldh [hScore+5], a
    ldh [hScoreIncrement], a
    ldh [hScoreIncrement+1], a
    ld a, $FF
    ldh [hScoreIncrementBCD], a
    ldh [hScoreIncrementBCD+1], a
    ldh [hScoreIncrementBCD+2], a
    ldh [hScoreIncrementBCD+3], a
    ldh [hScoreIncrementBCD+4], a
    ldh [hScoreIncrementBCD+5], a
    ret

    ; Increases the current score by the amount in wScoreIncrement.
IncreaseScore::
    ; Wipe the old BCD score.
    ld a, $FF
    ldh [hScoreIncrementBCD], a
    ldh [hScoreIncrementBCD+1], a
    ldh [hScoreIncrementBCD+2], a
    ldh [hScoreIncrementBCD+3], a
    ldh [hScoreIncrementBCD+4], a
    ldh [hScoreIncrementBCD+5], a

    ; First convert to BCD.
    ldh a, [hScoreIncrement]
    ld l, a
    ldh a, [hScoreIncrement+1]
    ld h, a
    ld de, hScoreIncrementBCD
    ld bc, -10000
    call .doConvert
    ld bc, -1000
    call .doConvert
    ld bc, -100
    call .doConvert
    ld c, -10
    call .doConvert
    ld c, b
    call .doConvert
    jr .postConvert

.doConvert
    ld a, 255
:   inc a
    add hl, bc
    jr c, :-
    push bc             ; sbc hl, bc
    push af             ;
    ld a, b             ;
    cpl                 ;
    ld b, a             ;
    ld a, c             ;
    cpl                 ;
    ld c, a             ;
    inc bc              ;
    call c, .carry      ;
    pop af              ;
    add hl, bc          ;
    pop bc              ;
    ld [de], a
    inc de
    ret

.carry
    dec bc
    ret

.postConvert
    ld hl, hScoreIncrement
    xor a, a
    ld [hl+], a
    ld [hl], a

    ld de, hScoreIncrementBCD+5
    ld b, 0
    ld a, $FF
:   cp a, b
    jr nz, .preAddDigit
    inc b
    dec de
    jr :-

.preAddDigit
    ; B contains the amount of times we need to shift the BCD score to the right.
    ldh a, [hScoreIncrementBCD+4]
    ldh [hScoreIncrementBCD+5], a
    ldh a, [hScoreIncrementBCD+3]
    ldh [hScoreIncrementBCD+4], a
    ldh a, [hScoreIncrementBCD+2]
    ldh [hScoreIncrementBCD+3], a
    ldh a, [hScoreIncrementBCD+1]
    ldh [hScoreIncrementBCD+2], a
    ldh a, [hScoreIncrementBCD]
    ldh [hScoreIncrementBCD+1], a
    xor a, a
    ldh [hScoreIncrementBCD], a
    dec b
    jr z, :-
    ld hl, hScore+5
    ld de, hScoreIncrementBCD+5

    ; DE is now pointing to the last digit of the BCD score.
    ; HL points at the last digit of the displayed score.
.addDigit
    ; Increment the digit count.
    inc b
    ; Add the currently pointed to digits together.
    ld a, [de]
    ld c, a
    ld a, [hl]
    add a, c
    ld [hl], a

    ; If they're too big, carry.
    cp a, $0A
    jr c, .nextDigit

    ; Except if this is the 6th digit.
    ld a, 5
    cp a, b
    jr z, .nextDigit

    ; Do the carry.
    ld a, [hl]
    sub a, 10
    ld [hl-], a
    ld a, [hl]
    inc a
    ld [hl+], a

.nextDigit
    ; Update the pointers.
    dec de
    dec hl

    ; Check if we're out of numbers.
    ld a, 5
    cp a, b
    jr nz, .addDigit

    ; Check if the score has rolled over.
    ldh a, [hScore]
    cp a, $0A
    ret c

    ; If it has, reset the score.
    xor a, a
    ldh [hScore], a
    ld a, SFX_RANKUP
    call SFXEnqueue
    ret


ENDC
