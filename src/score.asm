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


SECTION "Score Variables", WRAM0
wScore:: ds 6
wScoreIncrement:: ds 2
wScoreIncrementBCD:: ds 6
wScoreIncrementHead:: ds 1


SECTION "Score Functions", ROM0
ScoreInit::
    xor a, a
    ld hl, wScore
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, wScoreIncrement
    ld [hl+], a
    ld [hl], a
    ld a, $FF
    ld hl, wScoreIncrementBCD
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ret

    ; Increases the current score by the amount in wScoreIncrement.
IncreaseScore::
    ; Wipe the old BCD score.
    ld a, $FF
    ld hl, wScoreIncrementBCD
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

    ; First convert to BCD.
    ld a, [wScoreIncrement]
    ld l, a
    ld a, [wScoreIncrement+1]
    ld h, a
    ld de, wScoreIncrementBCD
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
    ld hl, wScoreIncrement
    xor a, a
    ld [hl+], a
    ld [hl], a

    ld de, wScoreIncrementBCD+5
    ld b, 0
    ld a, $FF
:   cp a, b
    jr nz, .preAddDigit
    inc b
    dec de
    jr :-

.preAddDigit
    ; B contains the amount of times we need to shift the BCD score to the right.
    ld a, [wScoreIncrementBCD+4]
    ld [wScoreIncrementBCD+5], a
    ld a, [wScoreIncrementBCD+3]
    ld [wScoreIncrementBCD+4], a
    ld a, [wScoreIncrementBCD+2]
    ld [wScoreIncrementBCD+3], a
    ld a, [wScoreIncrementBCD+1]
    ld [wScoreIncrementBCD+2], a
    ld a, [wScoreIncrementBCD]
    ld [wScoreIncrementBCD+1], a
    xor a, a
    ld [wScoreIncrementBCD], a
    dec b
    jr z, :-
    ld hl, wScore+5
    ld de, wScoreIncrementBCD+5

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
    ld a, [wScore]
    cp a, $0A
    ret c

    ; If it has, reset the score.
    xor a, a
    ld [wScore], a
    ld a, SFX_RANK_UP
    call SFXEnqueue
    ret


ENDC
