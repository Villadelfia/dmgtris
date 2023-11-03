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
wInternalGradePoints:  ds 1
wInternalGrade:        ds 1
wDisplayedGrade::      ds 1
wEffectTimer::         ds 1
wRankingDisqualified:: ds 1
wDecayCounter:         ds 1
wGradeGauge:           ds 1
wSMult:                ds 1
wDMult:                ds 1
wTMult:                ds 1
wSRate:                ds 1
wDRate:                ds 1
wTRate:                ds 1
wQRate:                ds 1


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
    db 0 ;9
    db 1 ;8
    db 2 ;7
    db 3 ;6
    db 4 ;5
    db 5 ;4
    db 5 ;4
    db 6 ;3
    db 6 ;3
    db 7 ;2
    db 7 ;2
    db 7 ;2
    db 8 ;1
    db 8 ;1
    db 8 ;1
    db 9 ;S1 (yes, here you finally get into the S grades, unless you are very COOL)
    db 9 ;S1
    db 10 ;S2
    db 11 ;S3
    db 12 ;S4
    db 12 ;S4
    db 12 ;S4
    db 13 ;S5
    db 13 ;S5
    db 14 ;S6
    db 14 ;S6
    db 15 ;S7
    db 15 ;S7
    db 16 ;S8
    db 16 ;S8
    db 17 ;S9

sTGM3ComboMultipliers:
    db 1,  1, 1, 1, 1   ; Combo size, (Multiplier for: ) Single, Double, Triple, Tetris (Screw the fractional part, x.5 gets rounded down)
    db 2,  1, 1, 1, 1
    db 3,  1, 1, 1, 2
    db 4,  1, 1, 2, 2
    db 5,  1, 1, 2, 2
    db 6,  1, 1, 2, 2
    db 7,  1, 1, 2, 2
    db 8,  1, 1, 2, 2
    db 9,  1, 1, 2, 3
    db 10, 2, 2, 3, 3

sTGM3LevelMultiplier:
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

sDMGTGrading:
    db 125, 10, 20, 40, 50 ; Grade 9   — frames/decay, single base, double base, triple base, tetris base
    db 80,  10, 20, 30, 40 ; Grade 8   — frames/decay, single base, double base, triple base, tetris base
    db 80,  10, 20, 30, 40 ; Grade 7   — frames/decay, single base, double base, triple base, tetris base
    db 50,  10, 20, 30, 40 ; Grade 6   — frames/decay, single base, double base, triple base, tetris base
    db 45,   5, 20, 30, 40 ; Grade 5   — frames/decay, single base, double base, triple base, tetris base
    db 45,   5, 20, 30, 40 ; Grade 4   — frames/decay, single base, double base, triple base, tetris base
    db 45,   5, 20, 30, 40 ; Grade 3   — frames/decay, single base, double base, triple base, tetris base
    db 40,   5, 20, 20, 30 ; Grade 2   — frames/decay, single base, double base, triple base, tetris base
    db 40,   5, 20, 20, 30 ; Grade 1   — frames/decay, single base, double base, triple base, tetris base
    db 40,   2, 20, 20, 30 ; Grade S1  — frames/decay, single base, double base, triple base, tetris base
    db 40,   2, 20, 20, 30 ; Grade S2  — frames/decay, single base, double base, triple base, tetris base
    db 40,   2, 20, 20, 30 ; Grade S3  — frames/decay, single base, double base, triple base, tetris base
    db 30,   2, 20, 20, 30 ; Grade S4  — frames/decay, single base, double base, triple base, tetris base
    db 30,   2, 15, 20, 30 ; Grade S5  — frames/decay, single base, double base, triple base, tetris base
    db 30,   2, 15, 20, 30 ; Grade S6  — frames/decay, single base, double base, triple base, tetris base
    db 20,   2, 15, 20, 30 ; Grade S7  — frames/decay, single base, double base, triple base, tetris base
    db 20,   2, 15, 20, 30 ; Grade S8  — frames/decay, single base, double base, triple base, tetris base
    db 20,   2, 15, 20, 30 ; Grade S9  — frames/decay, single base, double base, triple base, tetris base
    db 20,   2, 15, 20, 30 ; Grade S10 — frames/decay, single base, double base, triple base, tetris base (hey!, nice idea here to make S10-S13 more useful XD)
    db 20,   2, 15, 20, 30 ; Grade S11 — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 15, 20, 30 ; Grade S12 — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 15, 20, 30 ; Grade S13 — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 15, 15, 30 ; Grade m1  — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 15, 15, 30 ; Grade m2  — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 15, 15, 30 ; Grade m3  — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 15, 15, 30 ; Grade m4  — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 12, 15, 30 ; Grade m5  — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 12, 15, 30 ; Grade m6  — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 12, 15, 30 ; Grade m7  — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 12, 15, 30 ; Grade m8  — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 12, 15, 30 ; Grade m9  — frames/decay, single base, double base, triple base, tetris base
    db 10,   2, 12, 13, 30 ; Grade M   — frames/decay, single base, double base, triple base, tetris base
    db 10,   2, 12, 13, 30 ; Grade MK  — frames/decay, single base, double base, triple base, tetris base
    db 10,   2, 12, 13, 30 ; Grade MV  — frames/decay, single base, double base, triple base, tetris base
    db 10,   2, 12, 13, 30 ; Grade MO  — frames/decay, single base, double base, triple base, tetris base
    db 5,    2,  8, 10, 20 ; Grade MM  — frames/decay, single base, double base, triple base, tetris base
                           ; No entry for GM. We're done there.

SECTION "Grading Functions", ROM0
    ; Wipe the grading variables.
GradeInit::
    xor a, a
    ld [wDecayRate], a
    ld [wInternalGradePoints], a
    ld [wInternalGrade], a
    ld [wDisplayedGrade], a
    ld [wRankingDisqualified], a
    ld [wEffectTimer], a
    ld [wDecayCounter], a
    ld [wGradeGauge], a

    ; Most modes begin ungraded.
    ld a, GRADE_NONE
    ld [wDisplayedGrade], a

    ; TGM1, TGM3 and DMGT are the exceptions.
    ld a, [wSpeedCurveState]
    cp a, SCURVE_TGM1
    jr z, .grade9start
    cp a, SCURVE_DMGT
    jr z, .grade9start
    cp a, SCURVE_TGM3
    jr z, .grade9start
    jr .end

.grade9start
    ld a, GRADE_9
    ld [wDisplayedGrade], a

.end
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
    jp UpdateGradeDMGT ;DMGT
    jp UpdateGradeTGM1 ;TGM1
    jp UpdateGradeTGM3 ;TGM3
    jp UpdateGradeDEAT ;DEAT
    jp UpdateGradeSHIR ;SHIR
    no_jump            ;CHIL


    ; Jumps to the grade decay function for the current mode.
    ; Called once per frame where a piece is in motion.
DecayGradeProcess::
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
    jp DecayGradeDMGT ;DMGT
    no_jump           ;TGM1
    jp TGM3DecayRate  ;TGM3
    no_jump           ;DEAT
    no_jump           ;SHIR
    no_jump           ;CHIL




    ; Jumps to the grade decay function for the current mode.
    ; Called once per frame during ARE and line clear delay.
DecayGradeDelay::
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
    no_jump           ;DMGT
    no_jump           ;TGM1
    jp TGM3DecayRate  ;TGM3
    no_jump           ;DEAT
    no_jump           ;SHIR
    no_jump           ;CHIL


    ; Get the four most significant figures of the score in BC as BCD.
PrepareScore:
    ldh a, [hScore+SCORE_HUNDREDS]
    ld b, a
    ldh a, [hScore+SCORE_THOUSANDS]
    swap a
    or b
    ld c, a
    ldh a, [hScore+SCORE_TENTHOUSANDS]
    ld b, a
    ldh a, [hScore+SCORE_HUNDREDTHOUSANDS]
    swap a
    or b
    ld b, a
    ret

UpdateGradeDMGT::
    ; Did we have line clears?
    ldh a, [hLineClearCt]
    cp a, 0
    ret z

    ; Bail if we're already GM.
    ld a, [wDisplayedGrade]
    cp a, GRADE_GM
    ret z

    ; Get grade in BC.
    ld b, 0
    ld c, a

    ; Point HL to decay rate.
    ld hl, sDMGTGrading
    add hl, bc
    add hl, bc
    add hl, bc
    add hl, bc
    add hl, bc

    ; What is our single/double/triple/quad rate?
.clearrate
    inc hl
    ld a, [hl+]
    ld [wSRate], a
    ld a, [hl+]
    ld [wDRate], a
    ld a, [hl+]
    ld [wTRate], a
    ld a, [hl]
    ld [wQRate], a

    ; What is our single/double/triple multiplier?
.combomult
    ld a, [hComboCt]
    cp a, 10
    jr nc, .combo10
    cp a, 5
    jr nc, .combo5
    jr .combo1

.combo10
    ld a, 2
    ld [wSMult], a
    ld a, 3
    ld [wDMult], a
    ld a, 3
    ld [wTMult], a
    jr .prelevel

.combo5
    ld a, 1
    ld [wSMult], a
    ld a, 2
    ld [wDMult], a
    ld a, 2
    ld [wTMult], a
    jr .prelevel

.combo1
    ld a, 1
    ld [wSMult], a
    ld a, 1
    ld [wDMult], a
    ld a, 1
    ld [wTMult], a

    ; Branch on line clear count.
.prelevel
    ldh a, [hLineClearCt]
    ld d, a
    cp a, 4
    jr z, .tetris
    cp a, 3
    jr z, .triple
    cp a, 2
    jr z, .double

    ; Singles are worth the single rate x1 or x2.
.single
    ld a, [wSRate]
    ld d, a
    ld a, [wSMult]
    cp a, 1
    jr z, .levelmult
    ld a, d
    add a, d
    ld d, a
    jr .levelmult

    ; Doubles are worth the double rate x1, x2 or x3.
.double
    ld a, [wDRate]
    ld d, a
    ld a, [wDMult]
    cp a, 1
    jr z, .levelmult
    cp a, 2
    ld a, d
    jr z, .adddonce
    add a, d
.adddonce
    add a, d
    ld d, a
    jr .levelmult

    ; Triples are worth the triple rate x1, x2 or x3.
.triple
    ld a, [wTRate]
    ld d, a
    ld a, [wTMult]
    cp a, 1
    jr z, .levelmult
    cp a, 2
    ld a, d
    jr z, .addtonce
    add a, d
.addtonce
    add a, d
    ld d, a
    jr .levelmult

    ; Tetris are worth just tetris.
.tetris
    ld a, [wQRate]
    ld d, a

    ; What is our level multiplier?
    ; Running counter is in in D now.
.levelmult
    ld a, [hCLevel+CLEVEL_THOUSANDS] ; thousands
    cp a, 1
    jr nc, .mult5
    ld a, [hCLevel+CLEVEL_HUNDREDS] ; hundreds
    cp a, 7
    jr nc, .mult4
    cp a, 5
    jr nc, .mult3
    cp a, 2
    jr nc, .mult2
    jr .mult1

.mult5
    ld a, d
    add a, d
    add a, d
    add a, d
    add a, d
    jr .processgrade

.mult4
    ld a, d
    add a, d
    add a, d
    add a, d
    jr .processgrade

.mult3
    ld a, d
    add a, d
    add a, d
    jr .processgrade

.mult2
    ld a, d
    add a, d
    jr .processgrade

.mult1
    ld a, d

    ; Increase the gauge.
    ; The value to add to the gauge is in A
.processgrade
    ld d, a
    ld a, [wGradeGauge]
    add a, d
    ld [wGradeGauge], a

    ; Did we overflow? Failsafe.
    jr nc, .increasegrademaybe
    xor a, a
    ld [wGradeGauge], a

    ; Increment the grade.
    ld a, [wDisplayedGrade]
    inc a
    ld [wDisplayedGrade], a

    ; GM?
    cp a, GRADE_GM
    jr z, .gotgm

    ; No, play the normal jingle.
    ld a, SFX_RANKUP
    call SFXEnqueue
    ld a, $0F
    ld [wEffectTimer], a
    ret

.increasegrademaybe
    ; Do we have 150 in the gauge?
    ld a, [wGradeGauge]
    cp a, 150
    ret c

    ; Yes, take 150 away.
    sub a, 150
    ld [wGradeGauge], a

    ; Increment the grade.
    ld a, [wDisplayedGrade]
    inc a
    ld [wDisplayedGrade], a

    ; GM?
    cp a, GRADE_GM
    jr z, .gotgm

    ; No, play the normal jingle.
    ld a, SFX_RANKUP
    call SFXEnqueue
    ld a, $0F
    ld [wEffectTimer], a
    ret

.gotgm
    ld a, SFX_RANKGM
    call SFXEnqueue
    ld a, $0F
    ld [wEffectTimer], a
    ret


DecayGradeDMGT::
    ; Bail if the gauge is empty.
    ld a, [wGradeGauge]
    cp a, 0
    ret z

    ; Bail if we're already GM.
    ld a, [wDisplayedGrade]
    cp a, GRADE_GM
    ret z

    ; Get grade in BC.
    ld b, 0
    ld c, a

    ; Point HL to decay rate.
    ld hl, sDMGTGrading
    add hl, bc
    add hl, bc
    add hl, bc
    add hl, bc
    add hl, bc

    ; Increment the decay.
    ld a, [wDecayCounter]
    inc a

    ; Did we hit the rate?
    ld b, a
    ld a, [hl]
    cp a, b
    jr z, .decay

    ; Nope, don't decay, but do save.
.nodecay
    ld a, b
    ld [wDecayCounter], a
    ret

    ; Yes, decay.
.decay
    ld a, [wGradeGauge]
    dec a
    ld [wGradeGauge], a
    xor a, a
    ld [wDecayCounter], a
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
    ld a, [hCLevel+CLEVEL_THOUSANDS] ; Level, thousands digit.
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
    ldh a, [hCLevel+CLEVEL_THOUSANDS] ; Level, thousands digit.
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
    ldh a, [hCLevel+CLEVEL_HUNDREDS] ; Level, hundreds digit.
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
    ldh a, [hCLevel+CLEVEL_HUNDREDS] ; Level, hundreds digit.
    cp a, 0
    ret z

    ; Get the hundreds and thousands of the level as a hex number.
    ld b, a ; Hundreds
    ldh a, [hCLevel+CLEVEL_THOUSANDS] ; Thousands
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

    ; If we failed the Torikan, disqualify from ranking up further. (Excellent, but... lets go better next time)
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

UpdateGradeTGM3:
    ; First things first, Update our grade points.
.GradePoints
    ; Load the Table address to HL.
    ld hl, sTGM3InternalGradeSystem
    ; Get the correct offset using the lines cleared on the frame and our current Internal Grade.
    ; Make sure the offsets are set properly and that the amount of Cleared lines isn't 0.
    ld a, [wInternalGrade] ; Example: 3
    cp a, 0 ; If it's 0, we don't need to do weird math.
    jr z, .GetOffset
    ld d, a ; ld d, 3
    ld b, 5 
    ld a, b ; ld a, 5
    dec d ;dec 3 to 2, so we don't accidentally add more than intended
:   add a, b ; 5+5 = 10 ; 10+5 = 15
    dec d 
    jr nz, :- ; go back if d isn't 0
    ld b, a ; ld b, 15
.GetOffset
    ld a, [hLineClearCt]
    cp a, 0 ; If no lines were cleared, we don't need to do anything, just continue
    jp z, .IncreaseInternalGrade
    add a, b
    ld b, 0
    ld c, a
    add hl, bc
    ld a, [hl]
    ld e, a ; We will use almost all registers to get the multipliers, so we need to keep the points we should add in a safe spot 
    jp .multipliers
.loadpoints    
    ld hl, wInternalGradePoints
    add a, [hl]
    ld [wInternalGradePoints], a
    jp .IncreaseInternalGrade
.multipliers
    ; There are some multipliers to help us increase our grade faster
    ld hl, sTGM3ComboMultipliers
    ld a, [hComboCt] ; Example: 3
    cp a, 0
    
    ld d, a ; ld d, 3
    ld b, 5 
    ld a, b ; ld a, 5
    dec d ;dec 3 to 2, so we don't accidentally add more than intended
:   add a, b ; 5+5 = 10 ; 10+5 = 15
    dec d 
    jr nz, :- ; go back if d isn't 0
    ld b, a ; ld b, 15
    ld a, [hLineClearCt]
    cp a, 0 ; If no lines were cleared, we don't need to do anything, just continue
    jr z, .levelmultiplier
    add a, b
    ld b, 0
    ld c, a
    add hl, bc
    ld a, [hl] ; Now we got our multiplier!, let's apply it.
    dec a ; A multiplier of 1 shouldn't change anything, so let's get rid of them
    cp a, 0
    jr z, .levelmultiplier; Continue
    ld b, a ; Load the multiplier into B
    ld a, e ; Remember the points we got earlier?, here they are
    ld c, a ; We will add from C
:   add a, c
    dec b
    jr nz, :-
    ; Finally!, we can now load the points, right?, NO!, there is yet another multiplier...
    ; We have to keep the points safe again...
    ld e, a
.levelmultiplier
    ; Make HL point to the table that contains the level multipliers
    ld hl, sTGM3LevelMultiplier
    ; Get our level into BC
    ld a, [hCLevel+3]
    ld b, a
    ld a, [hCLevel+2]
    swap a
    or b
    ld c, a
    ld a, [hCLevel+1]
    ld b, a
    ld a, [hCLevel]
    swap a
    or b
    ld b, a
.Level750
    ; Is our level 750 or higher?
    ld a, b
    cp a, LEVEL_MULT_3A
    ; If B is less than 7, that means we are not even in level 700, so check for 500
    jr c, .Level500
    ; If B is NOT less than 7, we might be in level 750 or greater, so check the remaining digits.
    ld a, c
    cp a, LEVEL_MULT_3B
    ; If C is less than 50, we didn't reach level 750 yet, but we are for sure in the 7** Section, load the corresponding offset.
    jp .under750
    ; If C is equal or greater than 50, then congrats!, load the corresponding offset
    ld b, 0
    ld c, 2 
    add hl, bc
    ld a, [hl]
    jp .Multiply
.under750
    ld b, 0
    ld c, 1
    add hl, bc
    ld a, [hl]
.Level500
    ; Is our level 500 or higher?
    ld a, b
    cp a, LEVEL_MULT_2A
    ; If B is less than 5, that means we are not even in level 500, so check for 250
    jr c, .Level250
    ; If B is NOT less than 5, we are in level 500 or greater
    ld b, 0
    ld c, 2 
    add hl, bc
    ld a, [hl]
    jp .Multiply
.Level250 ; There is no Offset, so just get the multiplier
    ; Is our level 750 or higher?
    ld a, b
    cp a, LEVEL_MULT_1A
    ; If B is less than 2, that means we are not even in level 200, so no multiplier
    jr c, .under250
    ; If B is NOT less than 2, we might be in level 250 or greater, so check the remaining digits.
    ld a, c
    cp a, LEVEL_MULT_1B
    ; If C is less than 50, we didn't reach level 250 yet, so no multiplier
    jp .under250
    ; If C is equal or greater than 50, then congrats!, load the corresponding offset (I said there is no Offset!)
    ld a, [hl]
    jp .Multiply
.under250 ; There is no multiplier, so just load the points
    ld a, e
    jp .loadpoints
.Multiply ; FINALLY!!!!!, This took forever!
    ld b, a ; Load the multiplier into B
    ld a, e ; Remember the points we got earlier?, here they are... Again.
    ld c, a ; We will add from C
:   add a, c
    dec b
    jr nz, :-
    ; AND NOW WE ARE DONE!, LOAD THOSE POINTS!
    jp .loadpoints
.IncreaseInternalGrade
    ; Do we have 100 Grade Points?
    ld a, [wInternalGradePoints]
    cp a, 100
    ret c ; If the Internal Grade Points is less than 100, return, we don't have to change our Grade
    xor a, a ; Reset the points to 0 and increase the internal grade
    ld [wInternalGradePoints], a
    ld a, [wInternalGrade]
    inc a
    ld [wInternalGrade], a
.IncreaseDisplayedGrade
    ld a, GRADE_9 ; Load the lowest grade into a
    ld b, a ; Then save it into b
    ld hl, sTGM3GradeBoosts ; Make HL point to the Grade boosts table
    ld a, [wInternalGrade] ; Get the offset
    ld b, 0
    ld c, a
    add hl, bc
    ld a, [hl] ; Load the boosts into a...
    add a, b ; ...and add them to a.
    ld b, a ; Save the result and check if we have the same grade as before
    ld a, [wDisplayedGrade]
    cp a, b
    ret z ; If the grade is the same, return.
    ld a, b
    ld [wDisplayedGrade], a ; Otherwise, set the grade.
    ; ...Play the jingle.
    ld a, SFX_RANKUP
    call SFXEnqueue
    ; Prepare the effect stuff
    ld a, $0f
    ld [wEffectTimer], a
TGM3DecayRate:
    ; Check if we can decrease the Grade points, if not, decrease the timer
    ld a, [wDecayRate]
    cp a, 0
    jr z, .points
    ld b, a ; Save the timer
    ld a, [hComboCt] ; If there is an active combo, do not decrease the counter, return instead
    dec a
    and a
    ret nz
    ld a, b ; Load the timer back
    dec a
    ld [wDecayRate], a
    ret
.points
    ld a, [wInternalGradePoints] ; Do we have 0 grade points?
    cp a, 0
    ret z ; If so, return
    dec a
    cp a, 0 ; Do we have 0 now?
    jr z, .lpoints ; If so, load the points, since we don't have any points to decay
    ; Else, load the points and the corresponding Decay Rate
    ld [wInternalGradePoints], a
    ; Get the Decay Rate required
    ld hl, sTGM3InternalGradeSystem
    ld a, [wInternalGrade] ; Example: 3
    cp a, 0 ; If it's 0, we don't need to do weird math.
    jr z, .GetOffset
    ld d, a ; ld d, 3
    ld b, 5 
    ld a, b ; ld a, 5
    dec d ;dec 3 to 2, so we don't accidentally add more than intended
:   add a, b ; 5+5 = 10 ; 10+5 = 15
    dec d 
    jr nz, :- ; go back if d isn't 0
.GetOffset
    ld b, 0
    ld c, a
    add hl, bc
    ld a, [hl] ; Load the rate into a...
    ld [wDecayRate], a ; ... and then into the timer
    ret
.lpoints
    ld [wInternalGradePoints], a
    ret 
ENDC
