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


IF !DEF(GRADING_SYSTEMS_ASM)
DEF GRADING_SYSTEMS_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Grade Variables", WRAM0
wDecayRate:       ds 1
wGradePoints:     ds 1
wInternalGrade:   ds 1
wDisplayedGrade:: ds 1


SECTION "Grading Data", ROM0
sGradeScores:
    dw $0004 ;00 — 8
    dw $0008 ;00 — 7
    dw $0014 ;00 — 6
    dw $0020 ;00 — 5
    dw $0035 ;00 — 4
    dw $0055 ;00 — 3
    dw $0080 ;00 — 2
    dw $0120 ;00 — 1
    dw $0160 ;00 — S1
    dw $0220 ;00 — S2
    dw $0300 ;00 — S3
    dw $0400 ;00 — S4
    dw $0520 ;00 — S5
    dw $0660 ;00 — S6
    dw $0820 ;00 — S7
    dw $1000 ;00 — S8
    dw $1200 ;00 — S9


SECTION "Grading Functions", ROM0
    ; Wipe the grading variables.
GradeInit::
    xor a, a
    ld [wDecayRate], a
    ld [wGradePoints], a
    ld [wInternalGrade], a
    ld [wDisplayedGrade], a
    ret


    ; Gets the highest grade the player qualifies for.
UpdateGrade::
    ; Skip to GM check if past S9.
    ld a, [wDisplayedGrade]
    cp a, GRADE_S9
    jr c, .trygradeup
    jr CheckForGM

.trygradeup
    ; Get our score into BC
    call PrepareScore

    ; Double our current grade and use it as an offset into the scoring table.
    ld a, [wDisplayedGrade]
    add a
    ld d, 0
    ld e, a

    ; Have HL point to the next required score and get it into DE.
    ld hl, sGradeScores
    add hl, de

    ; LSB
    ld a, [hl+]
    ld e, a

    ; MSB
    ld a, [hl]
    ld d, a

    ; Check if BC >= DE...
    ; Return if B < D.
    ld a, b
    cp a, d
    ret c

    ; We can confidently increase the grade if B > D.
    jr nz, .increasegrade

    ; If B == D, we need to check C and E...

    ; Return if C < E. Otherwise increase the grade.
    ld a, c
    cp a, e
    ret c

.increasegrade
    ; Add 1 to the grade.
    ld a, [wDisplayedGrade]
    inc a
    ld [wDisplayedGrade], a

    ; Play the jingle.
    ld a, SFX_RANKUP
    call SFXEnqueue

    ; Loop and see if we can increment more grades.
    ld a, [wDisplayedGrade]
    cp a, GRADE_S9
    ret z
    jr .trygradeup


CheckForGM:
    ; Grade has to be S9.
    ld a, [wDisplayedGrade]
    cp a, GRADE_S9
    ret nz

    ; Level needs to be 1000 or greater.
    ld a, [hCLevel]
    cp a, 1
    ret c

    ; Set the grade to GM
    ld a, GRADE_GM
    ld [wDisplayedGrade], a

    ; Sound effect
    ld a, SFX_RANKUP
    jp SFXEnqueue


    ; Get the four most significant figures of the score in BC as BCD.
PrepareScore:
    ld a, [hScore+3]
    ld b, a
    ld a, [hScore+2]
    swap a
    or b
    ld c, a
    ld a, [hScore+1]
    ld b, a
    ld a, [hScore]
    swap a
    or b
    ld b, a
    ret


ENDC
