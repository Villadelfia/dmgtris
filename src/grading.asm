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


IF !DEF(GRADING_ASM)
DEF GRADING_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Grade Variables", WRAM0
wDecayRate:            ds 1
wGradePoints:          ds 1
wInternalGrade:        ds 1
wDisplayedGrade::      ds 1
wEffectTimer::         ds 1
wRankingDisqualified:: ds 1


SECTION "Grading Data", ROM0
; The Score Thresholds are 3/4th of the original ones.
sTGM1GradeScores:
    dw $0003 ;00 — 8
    dw $0006 ;00 — 7
    dw $0009 ;00 — 6
    dw $0015 ;00 — 5
    dw $0021 ;00 — 4
    dw $0039 ;00 — 3
    dw $0060 ;00 — 2
    dw $0090 ;00 — 1
    dw $0120 ;00 — S1
    dw $0165 ;00 — S2
    dw $0225 ;00 — S3
    dw $0300 ;00 — S4
    dw $0390 ;00 — S5
    dw $0495 ;00 — S6
    dw $0615 ;00 — S7
    dw $0750 ;00 — S8
    dw $0900 ;00 — S9

sTGM3InternalGradeSystem:
    db 125, 10, 20, 40, 50 ;Decay rate, (Internal grade points awarded for:) Single, Double, Triple, Tetris
    db 80,  10, 20, 30, 40
    db 80,  10, 20, 30, 40
    db 50,  10, 15, 30, 40
    db 45,  5,  15, 20, 40
    db 45,  5,  15, 20, 30
    db 45,  5,  10, 20, 30
    db 40,  5,  10, 15, 30
    db 40,  5,  10, 15, 30
    db 40,  5,  10, 15, 30
    db 40,  2,  12, 13, 30
    db 40,  2,  12, 13, 30
    db 30,  2,  12, 13, 30
    db 30,  2,  12, 13, 30
    db 30,  2,  12, 13, 30
    db 20,  2,  12, 13, 30
    db 20,  2,  12, 13, 30
    db 20,  2,  12, 13, 30
    db 20,  2,  12, 13, 30
    db 20,  2,  12, 13, 30
    db 15,  2,  12, 13, 30
    db 15,  2,  12, 13, 30
    db 15,  2,  12, 13, 30
    db 15,  2,  12, 13, 30
    db 15,  2,  12, 13, 30
    db 15,  2,  12, 13, 30
    db 15,  2,  12, 13, 30
    db 15,  2,  12, 13, 30
    db 15,  2,  12, 13, 30
    db 15,  2,  12, 13, 30
    db 10,  2,  12, 13, 30
    db 10,  2,  12, 13, 30

sTGM3GradeBoosts:
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

; sTGM3ComboMultipliers:
;     db 1,  1.0, 1.0, 1.0, 1.0   ; Combo size, (Multiplier for: ) Single, Double, Triple, Tetris
;     db 2,  1.0, 1.2, 1.4, 1.5
;     db 3,  1.0, 1.2, 1.5, 1.8
;     db 4,  1.0, 1.4, 1.6, 2.0
;     db 5,  1.0, 1.4, 1.7, 2.2
;     db 6,  1.0, 1.4, 1.8, 2.3
;     db 7,  1.0, 1.4, 1.9, 2.4
;     db 8,  1.0, 1.5, 2.0, 2.5
;     db 9,  1.0, 1.5, 2.1, 2.6
;     db 10, 2.0, 2.5, 3.0, 3.0

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
    ld [wRankingDisqualified], a
    ld [wEffectTimer], a

    ; Not all modes start at 9.
    ; Death starts ungraded.
    ld a, [wSpeedCurveState]
    cp a, SCURVE_DEAT
    jr nz, .notdeat
    ld a, GRADE_NONE
    ld [wDisplayedGrade], a
    jr UpdateGrade

.notdeat
    ; Shirase starts ungraded.
    ld a, [wSpeedCurveState]
    cp a, SCURVE_SHIR
    jr nz, .notshir
    ld a, GRADE_NONE
    ld [wDisplayedGrade], a
    jr UpdateGrade

.notshir
    ; All the rest start at 9.
    ld a, GRADE_9
    ld [wDisplayedGrade], a
    jr UpdateGrade


    ; Jumps to the grade update function for the current mode.
UpdateGrade::
    ld hl, .gradejumptable
    ld a, [wSpeedCurveState]
    ld b, a
    add a, b
    add a, b
    ld b, 0
    ld c,  a
    add hl, bc
    jp hl

.gradejumptable
    jp UpdateGradeTGM1 ;DMGT
    jp UpdateGradeTGM1 ;TGM1
    jp UpdateGradeTGM1 ;TGM3
    jp UpdateGradeDEAT ;DEAT
    jp UpdateGradeSHIR ;SHIR
    jp UpdateGradeTGM1 ;CHIL


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


UpdateGradeTGM1:
    ; Bail if we're already GM.
    ld a, [wDisplayedGrade]
    cp a, GRADE_GM
    ret z

    ; Skip to GM check if already S9.
    cp a, GRADE_S9
    jr nc, .maybegm

.trygradeup
    ; Otherwise, check if we can increase the grade.
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

    ; Play the jingle, if not already doing so.
    ldh a, [hCurrentlyPlaying]
    cp a, SFX_RANKUP
    jr z, .skipjingle
    ld a, SFX_RANKUP
    call SFXEnqueue

    ; Prepare the effect stuff
.skipjingle
    ld a, $0F
    ld [wEffectTimer], a

    ; Loop and see if we can increment more grades.
    ld a, [wDisplayedGrade]
    cp a, GRADE_S9 ; Don't go past S9.
    ret z
    jr .trygradeup

.maybegm
    ; Level needs to be 1000 or greater.
    ld a, [hCLevel] ; Level, thousands digit.
    cp a, 1
    ret c

    ; Set the grade to GM
    ld a, GRADE_GM
    ld [wDisplayedGrade], a

    ; Sound effect
    ld a, SFX_RANKGM
    jp SFXEnqueue

    ; Prepare the effect stuff
    ld a, $0F
    ld [wEffectTimer], a

    ; Return
    ret


UpdateGradeDEAT:
    ; If we're disqualified, don't update the grade.
    ld a, [wRankingDisqualified]
    cp a, $FF
    ret z

    ; If we are already GM, don't do anything.
    ld a, [wDisplayedGrade]
    cp a, GRADE_GM
    ret z

.notgm
    ; If we're M, check if we should be GM.
    cp a, GRADE_M
    jr nz, .notm

    ; We should be GM if we're at or past level 1000.
    ldh a, [hCLevel] ; Level, thousands digit.
    cp a, 1
    ret c ; If less than 1000, return.

    ; Otherwise give the grade!
    ld a, GRADE_GM
    ld [wDisplayedGrade], a

    ; Play the jingle.
    ld a, SFX_RANKGM
    call SFXEnqueue

    ; Prepare the effect stuff
    ld a, $0F
    ld [wEffectTimer], a
    ret

.notm
    ; If we're not M, check if we should be M.
    ldh a, [hCLevel+1] ; Level, hundreds digit.
    cp a, 5
    ret c ; If less than 500, return.

    ; There's a 3:25 torikan for M.
    ld b, 3
    ld c, 25
    call CheckTorikan

    ; If we failed the Torikan, disqualify from ranking.
    cp a, $FF
    jr nz, .disqualify

    ; Otherwise award M.
    ld a, GRADE_M
    ld [wDisplayedGrade], a

    ; Play the jingle.
    ld a, SFX_RANKUP
    call SFXEnqueue

    ; Prepare the effect stuff
    ld a, $0F
    ld [wEffectTimer], a
    ret

.disqualify
    ; Disqualify from ranking.
    ld a, $FF
    ld [wRankingDisqualified], a
    ret


UpdateGradeSHIR:
    ; If we're disqualified, don't update the grade any higher.
    ld a, [wRankingDisqualified]
    cp a, $FF
    ret z

    ; If we are already GM, don't do anything.
    ld a, [wDisplayedGrade]
    cp a, GRADE_S13
    ret z

    ; We don't give out a grade until level 100.
    ldh a, [hCLevel+1] ; Level, hundreds digit.
    cp a, 0
    ret z

    ; Get the hundreds and thousands of the level as a hex number.
    ld b, a ; Hundreds
    ldh a, [hCLevel] ; Thousands
    swap a
    or b

    ; Convert the BCD to hex.
    ld c, a     ; C = A
    and a, $F0  ; A = A & $F0. A is now $00 to $90 if the number was correct BCD.
    srl a       ; A = A >> 1
    ld b, a     ; B = A
    srl a
    srl a       ; A = A >> 2
    add a, b    ; A += B
    ld b, a     ; B = A. At this point B is 10, 20, 30, ... 90.
    ld a, c     ; A = C
    and a, $0F  ; A = A & $0F. A is now $00 to $09 if the number was correct BCD.
    add a, b    ; Adding B to A gives us the converted number.

    ; Adding GRADE_1 to this will give us the grade.
    add a, GRADE_1
    ld b, a
    ld a, [wDisplayedGrade]
    cp a, b
    ret z ; If the grade is already correct, return.
    ld a, b
    ld [wDisplayedGrade], a ; Otherwise, set the grade.

    ; Play the jingle.
    ld a, SFX_RANKUP
    call SFXEnqueue

    ; Prepare the effect stuff
    ld a, $0F
    ld [wEffectTimer], a

    ; There's a few torikans for Shirase.
    ld a, [wDisplayedGrade]
.s5torikan
    cp a, GRADE_S5
    jr nz, .s10torikan

    ; There's a 2:28 torikan after S5.
    ld b, 2
    ld c, 28
    call CheckTorikan

    ; If we failed the Torikan, disqualify from ranking up further.
    cp a, $FF
    jr nz, .disqualify
    ret

.s10torikan
    cp a, GRADE_S10
    ret nz

    ; There's a 4:56 torikan after S10.
    ld b, 4
    ld c, 56
    call CheckTorikan

    ; If we failed the Torikan, disqualify from ranking up further.
    cp a, $FF
    jr nz, .disqualify
    ret

.disqualify
    ld a, $FF
    ld [wRankingDisqualified], a
    ret

ENDC
