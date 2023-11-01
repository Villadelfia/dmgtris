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
wPreviousGrade:   ds 1
wEffectTimer::    ds 1
wPalette::        ds 1


SECTION "Grading Data", ROM0
; The Score Thresholds are 1/4th of the original ones
sTGM1GradeScores:
    dw $0001 ;00 — 8
    dw $0002 ;00 — 7
    dw $0003 ;00 — 6
    dw $0005 ;00 — 5
    dw $0007 ;00 — 4
    dw $0013 ;00 — 3
    dw $0020 ;00 — 2
    dw $0030 ;00 — 1
    dw $0040 ;00 — S1
    dw $0055 ;00 — S2
    dw $0075 ;00 — S3
    dw $0100 ;00 — S4
    dw $0130 ;00 — S5
    dw $0165 ;00 — S6
    dw $0205 ;00 — S7
    dw $0250 ;00 — S8
    dw $0300 ;00 — S9
; Man..., the TGM3 Grade system is really complex...
sTGM3InternalGradeSystem:
    db 125, 10, 20, 40, 50 ;Decay rate, (Internal grade points awarded for:) Single, Double, Triple, Tetris
    db 80, 10, 20, 30, 40
    db 80, 10, 20, 30, 40
    db 50, 10, 15, 30, 40
    db 45, 5, 15, 20, 40
    db 45, 5, 15, 20, 30
    db 45, 5, 10, 20, 30
    db 40, 5, 10, 15, 30
    db 40, 5, 10, 15, 30
    db 40, 5, 10, 15, 30
    db 40, 2, 12, 13, 30
    db 40, 2, 12, 13, 30
    db 30, 2, 12, 13, 30
    db 30, 2, 12, 13, 30
    db 30, 2, 12, 13, 30
    db 20, 2, 12, 13, 30
    db 20, 2, 12, 13, 30
    db 20, 2, 12, 13, 30
    db 20, 2, 12, 13, 30
    db 20, 2, 12, 13, 30
    db 15, 2, 12, 13, 30
    db 15, 2, 12, 13, 30
    db 15, 2, 12, 13, 30
    db 15, 2, 12, 13, 30
    db 15, 2, 12, 13, 30
    db 15, 2, 12, 13, 30
    db 15, 2, 12, 13, 30
    db 15, 2, 12, 13, 30
    db 15, 2, 12, 13, 30
    db 15, 2, 12, 13, 30
    db 10, 2, 12, 13, 30
    db 10, 2, 12, 13, 30

sTGM3GradeBoosts:
    ;This should explain itself
    db 0
    db 1
    db 2
    db 3
    db 4 
    db 5 
    db 5 
    db 6 
    db 6 
    db 7 
    db 7 
    db 7 
    db 8 
    db 8 
    db 8 
    db 9 
    db 9 
    db 10 
    db 11 
    db 12 
    db 12 
    db 12 
    db 13 
    db 13 
    db 14 
    db 14 
    db 15
    db 15 
    db 16 
    db 16 
    db 17
sTGM3ComboMultipliers:
    db 1, 1, 1, 1, 1 ; Combo size, (Multiplier for: ) Single, Double, Triple, Tetris
    db 2, 1, 1.2, 1.4, 1.5
    db 3, 1, 1.2, 1.5, 1.8
    db 4, 1, 1.4, 1.6, 2
    db 5, 1, 1.4, 1.7, 2.2
    db 6, 1, 1.4, 1.8, 2.3
    db 7, 1, 1.4, 1.9, 2.4
    db 8, 1, 1.5, 2, 2.5
    db 9, 1, 1.5, 2.1, 2.6
    db 10, 2, 2.5, 3
sTGM3LevelMultiplier:
    db 1 ; 000-249
    db 2 ; 250-499
    db 3 ; 500-749
    db 4 ; 750-999
sTGM3BaselineCOOL:
    db 52 ;070 (value in seconds)
    db 52 ;170
    db 49 ;270
    db 45 ;370
    db 45 ;470
    db 42 ;570
    db 42 ;670
    db 38 ;770
    db 38 ;870
sTGM3REGRETConditions:
    db 1, 30 ;minutes, seconds
    db 1, 15
    db 1, 15 
    db 1, 8 
    db 1, 0
    db 1, 0 
    db 0, 50 
    db 0, 50 
    db 0, 50 
    db 0, 50

SECTION "Grading Functions", ROM0
    ; Wipe the grading variables.
GradeInit::
    xor a, a
    ld [wDecayRate], a
    ld [wGradePoints], a
    ld [wInternalGrade], a
    ld [wDisplayedGrade], a
    ld a, $7
    ld [wPalette], a
    jp UpdateGradeTGM1


    ; Gets the highest grade the player qualifies for.
UpdateGradeTGM1::
    ; Is the Speed Curve Death or Shirase?
    ld hl, .GradeJumps
    ld a, [wSpeedCurveState]
    ld b, a
    add a, b
    add a, b
    ld b, 0
    ld c,  a
    add hl, bc
    jp hl
.GradeJumps
    jp UpdateGradeTGM1 ;DMGT
    jp UpdateGradeTGM1 ;TGM1
    jp UpdateGradeTGM1 ;TGM3
    jp Death           ;DEAT
    jp Shirase         ;SHIR
    jp UpdateGradeTGM1 ;CHIL
.Normal
    ; Skip to GM check if past S9.
    ld a, [wDisplayedGrade]
    cp a, GRADE_S9
    jr c, .trygradeup
    jr CheckForTGM1GM

.trygradeup
    ; Get our score into BC
    call PrepareScore

    ; Double our current grade and use it as an offset into the scoring table.
    ld a, [wDisplayedGrade]
    add a
    ld d, 0
    ld e, a

    ; Have HL point to the next required score and get it into DE.
    ld hl, sTGM1GradeScores
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
    ; Prepare the effect stuff
    ld a, $f
    ld [wEffectTimer], a
    xor a, a
    ld [wPalette], a

    ; Play the jingle.
    ld a, SFX_RANKUP
    call SFXEnqueue

    ; Loop and see if we can increment more grades.
    ld a, [wDisplayedGrade]
    cp a, GRADE_S9
    ret z
    jr .trygradeup


CheckForTGM1GM:
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
    ld a, SFX_RANKGM
    jp SFXEnqueue

    ; Prepare the effect stuff
    ld a, $f
    ld [wEffectTimer], a
    xor a, a
    ld [wPalette], a

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

Death:
    ; Check if the player is halfway through the mode
    ld a, [hCLevel+1]
    cp a, 5
    ret c
    ; If so, award the M grade
    ; WAIT!, is the player already an M Grade?
    ld a, [wDisplayedGrade]
    cp a, GRADE_M
    ; If so, skip to the GM check
    jr nc, .CheckModeCompletion
    ld a, GRADE_M
    ld [wDisplayedGrade], a
    ; Play the jingle.
    ld a, SFX_RANKUP
    call SFXEnqueue
    ; Prepare the effect stuff
    ld a, $f
    ld [wEffectTimer], a
    xor a, a
    ld [wPalette], a
.CheckModeCompletion
    ; Check if the player finished the mode
    ld a, [hCLevel]
    cp a, 1
    ret c
    ; If so, award the GM grade too
    ; WAIT!, is the player a GM too?
    cp a, GRADE_GM
    ; If so, just return
    ret z
    ld a, GRADE_GM
    ; Prepare the effect stuff
    ld [wDisplayedGrade], a
    ld a, $f
    ld [wEffectTimer], a
    xor a, a
    ld [wPalette], a
    ; Play the jingle.
    ld a, SFX_RANKGM
    call SFXEnqueue
    ret

Shirase:
    ; Make the grade start at 1 instead of 9
    ld a, GRADE_1
    ld [wDisplayedGrade], a
    ; Load the 2 most significant digits of the level into a
    ld a, [hCLevel+1]
    ld c, a
    ld a, [hCLevel]
    swap a
    or c
    ; Check if the result is 10 or greater, if so, convert to hexadecimal
    cp a, $10
    jr c, :+
    ; "Convert" from Decimal to Hexadecimal so the grades after S10 won't be rendered incorrectly
    sub a, $6
    ; Add the result to the grade
:   ld hl, wDisplayedGrade
    add a, [hl]
    ld [wDisplayedGrade], a
    ; If the current grade is higher than the previous one...
    ld a, [wPreviousGrade]
    cp a, [hl]
    jr nz, :+
    jr nc, :+
    ; ...Play the jingle.
    ld a, SFX_RANKUP
    call SFXEnqueue
    ; Prepare the effect stuff
    ld a, $f
    ld [wEffectTimer], a
    xor a, a
    ld [wPalette], a
:   ; Update the previous grade
    ld a, [wDisplayedGrade]
    ld [wPreviousGrade], a
    ret

ENDC
