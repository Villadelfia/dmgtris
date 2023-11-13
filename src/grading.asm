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
wDecayRate:                     ds 1
wGradePoints:                   ds 1
wInternalGrade:                 ds 1
wDisplayedGrade::               ds 1
wEffectTimer::                  ds 1
wRankingDisqualified::          ds 1
wDecayCounter:                  ds 1
wGradeGauge:                    ds 1
wSMult:                         ds 1
wDMult:                         ds 1
wTMult:                         ds 1
wSRate:                         ds 1
wDRate:                         ds 1
wTRate:                         ds 1
wQRate:                         ds 1
wTGM1level300RequirementMet:    ds 1
wTGM1level500RequirementMet:    ds 1
wTGM1level999RequirementMet:    ds 1


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

sDMGTGrading:
    db 125, 10, 20, 40, 50 ; Grade 9   — frames/decay, single base, double base, triple base, tetris base
    db 80,  10, 20, 30, 40 ; Grade 8   — frames/decay, single base, double base, triple base, tetris base
    db 80,  10, 20, 30, 40 ; Grade 7   — frames/decay, single base, double base, triple base, tetris base
    db 40,  10, 20, 30, 40 ; Grade 6   — frames/decay, single base, double base, triple base, tetris base
    db 40,   5, 20, 30, 40 ; Grade 5   — frames/decay, single base, double base, triple base, tetris base
    db 40,   5, 20, 30, 40 ; Grade 4   — frames/decay, single base, double base, triple base, tetris base
    db 40,   5, 20, 30, 40 ; Grade 3   — frames/decay, single base, double base, triple base, tetris base
    db 40,   2, 20, 20, 30 ; Grade 2   — frames/decay, single base, double base, triple base, tetris base
    db 40,   2, 15, 20, 30 ; Grade 1   — frames/decay, single base, double base, triple base, tetris base
    db 20,   2, 15, 20, 30 ; Grade S1  — frames/decay, single base, double base, triple base, tetris base
    db 20,   2, 15, 20, 30 ; Grade S2  — frames/decay, single base, double base, triple base, tetris base
    db 20,   2, 15, 20, 30 ; Grade S3  — frames/decay, single base, double base, triple base, tetris base
    db 20,   2, 15, 20, 30 ; Grade S4  — frames/decay, single base, double base, triple base, tetris base
    db 20,   2, 15, 20, 30 ; Grade S5  — frames/decay, single base, double base, triple base, tetris base
    db 20,   2, 15, 20, 30 ; Grade S6  — frames/decay, single base, double base, triple base, tetris base
    db 20,   2, 15, 20, 30 ; Grade S7  — frames/decay, single base, double base, triple base, tetris base
    db 20,   2, 15, 20, 30 ; Grade S8  — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 15, 20, 30 ; Grade S9  — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 15, 20, 30 ; Grade S10 — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 15, 20, 30 ; Grade S11 — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 15, 20, 30 ; Grade S12 — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 12, 15, 30 ; Grade S13 — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 12, 15, 30 ; Grade m1  — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 12, 15, 30 ; Grade m2  — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 12, 15, 30 ; Grade m3  — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 12, 15, 30 ; Grade m4  — frames/decay, single base, double base, triple base, tetris base
    db 15,   2, 12, 15, 30 ; Grade m5  — frames/decay, single base, double base, triple base, tetris base
    db 10,   2, 12, 15, 30 ; Grade m6  — frames/decay, single base, double base, triple base, tetris base
    db 10,   2, 12, 15, 30 ; Grade m7  — frames/decay, single base, double base, triple base, tetris base
    db 10,   2, 12, 15, 30 ; Grade m8  — frames/decay, single base, double base, triple base, tetris base
    db 5,    2,  8, 13, 30 ; Grade m9  — frames/decay, single base, double base, triple base, tetris base
    db 5,    2,  8, 13, 30 ; Grade M   — frames/decay, single base, double base, triple base, tetris base
    db 5,    2,  8, 13, 30 ; Grade MK  — frames/decay, single base, double base, triple base, tetris base
    db 5,    1,  8, 13, 30 ; Grade MV  — frames/decay, single base, double base, triple base, tetris base
    db 5,    1,  8, 13, 20 ; Grade MO  — frames/decay, single base, double base, triple base, tetris base
    db 4,    1,  4, 10, 20 ; Grade MM  — frames/decay, single base, double base, triple base, tetris base
                           ; No entry for GM. We're done there.

sDMGTGaugeLUT:
    db 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3
    db 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7
    db 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10,10,10
    db 10,10,11,11,11,11,11,12,12,12,12,13,13,13,13,13
    db 14,14,14,14,14,15,15,15,15,16,16,16,16,16,17,17
    db 17,17,17,18,18,18,18,19,19,19,19,19,20,20,20,20
    db 20,21,21,21,21,21,22,22,22,22,23,23,23,23,23,24
    db 24,24,24,24,25,25,25,25,26,26,26,26,26,27,27,27
    db 27,27,28,28,28,28,29,29,29,29,29,30,30,30,30,31
    db 31,31,31,31,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
    db 32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32

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
    ld [wDecayCounter], a
    ld [wGradeGauge], a
    ld [wTGM1level300RequirementMet], a
    ld [wTGM1level500RequirementMet], a
    ld [wTGM1level999RequirementMet], a

    ; Most modes begin ungraded.
    ld a, GRADE_NONE
    ld [wDisplayedGrade], a

    ; TGM1 and DMGT are the exceptions.
    ld a, [wSpeedCurveState]
    cp a, SCURVE_TGM1
    jr z, .grade9start
    cp a, SCURVE_DMGT
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
    no_jump            ;TGM3
    jp UpdateGradeDEAT ;DEAT
    jp UpdateGradeSHIR ;SHIR
    no_jump            ;CHIL
    no_jump            ;MYCO


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
    no_jump           ;TGM3
    no_jump           ;DEAT
    no_jump           ;SHIR
    no_jump           ;CHIL
    no_jump           ;MYCO


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
    no_jump  ;DMGT
    no_jump  ;TGM1
    no_jump  ;TGM3
    no_jump  ;DEAT
    no_jump  ;SHIR
    no_jump  ;CHIL
    no_jump  ;MYCO


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

DrawGradeProgressDMGT::
    ld a, [wDisplayedGrade]
    cp a, GRADE_GM
    jr nz, :+
    ld a, $FF
    ld [wGradeGauge], a
:   ld hl, sDMGTGaugeLUT
    ld a, [wGradeGauge]
    ld b, 0
    ld c, a
    add hl, bc
    ld a, [hl]
    call SetProgress
    ret

UpdateGradeDMGT::
    ; Check if the torikan hasn't been calculated.
    ld a, [wRankingDisqualified]
    cp a, $FF
    jr z, .checklineclears

    ; Have we hit the torikan level?
    ldh a, [hCLevel+CLEVEL_HUNDREDS]
    cp a, 5
    jr nz, .checklineclears

    ; Mark it as checked and do the check.
    ld a, $FF
    ld [wRankingDisqualified], a

    ; There's a 8:00 torikan at 500.
    ld b, 8
    ld c, 0
    call CheckTorikan

    ; If we failed it: DIE.
    cp a, $FF
    jp z, .checklineclears
    ld a, $FF
    ld [wLockLevel], a
    ld a, 5
    ldh [hCLevel+1], a
    ldh [hNLevel+1], a
    xor a, a
    ldh [hCLevel], a
    ldh [hNLevel], a
    ldh [hCLevel+2], a
    ldh [hNLevel+2], a
    ldh [hCLevel+3], a
    ldh [hNLevel+3], a
    jp TriggerKillScreen


    ; Did we have line clears?
.checklineclears
    ldh a, [hLineClearCt]
    or a, a
    jp z, DrawGradeProgressDMGT

    ; Bail if we're already GM.
    ld a, [wDisplayedGrade]
    cp a, GRADE_GM
    jp z, DrawGradeProgressDMGT

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
    cp a, 13
    jr nc, .combo13
    cp a, 8
    jr nc, .combo8
    jr .combo1

.combo13
    ld a, 2
    ld [wSMult], a
    ld a, 3
    ld [wDMult], a
    ld a, 3
    ld [wTMult], a
    jr .prelevel

.combo8
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
    jr nc, .mult4
    ld a, [hCLevel+CLEVEL_HUNDREDS] ; hundreds
    cp a, 9
    jr nc, .mult4
    cp a, 5
    jr nc, .mult3
    cp a, 2
    jr nc, .mult2
    jr .mult1

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
    call SFXKill
    ld a, SFX_RANKUP
    call SFXEnqueue
    ld a, $0F
    ld [wEffectTimer], a
    jp DrawGradeProgressDMGT

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
    call SFXKill
    ld a, SFX_RANKUP
    call SFXEnqueue
    ld a, $0F
    ld [wEffectTimer], a
    ret

.gotgm
    call SFXKill
    ld a, SFX_RANKGM
    call SFXEnqueue
    ld a, $0F
    ld [wEffectTimer], a
    ret


DecayGradeDMGT::
    ; Bail if the gauge is empty.
    ld a, [wGradeGauge]
    or a, a
    jp z, DrawGradeProgressDMGT

    ; Bail if we're already GM.
    ld a, [wDisplayedGrade]
    cp a, GRADE_GM
    jp z, DrawGradeProgressDMGT

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
    jp DrawGradeProgressDMGT

    ; Yes, decay.
.decay
    ld a, [wGradeGauge]
    dec a
    ld [wGradeGauge], a
    xor a, a
    ld [wDecayCounter], a
    jp DrawGradeProgressDMGT


UpdateGradeTGM1:
    ; Bail if we're already GM.
    ld a, [wDisplayedGrade]
    cp a, GRADE_GM
    ret z

    ; Bail if we didn't make the 999 check.
    ld a, [wTGM1level999RequirementMet]
    or a, a
    ret nz

    ; Skip to GM check if already S9.
    cp a, GRADE_S9
    jp nc, .check999

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
    jr c, .check300

.increasegrade
    ; Add 1 to the grade.
    ld a, [wDisplayedGrade]
    inc a
    ld [wDisplayedGrade], a

    ; Play the jingle, if not already doing so.
    ldh a, [hCurrentlyPlaying]
    cp a, SFX_RANKUP
    jr z, .skipjingle
    call SFXKill
    ld a, SFX_RANKUP
    call SFXEnqueue

    ; Prepare the effect stuff
.skipjingle
    ld a, $0F
    ld [wEffectTimer], a

    ; Loop and see if we can increment more grades.
    ld a, [wDisplayedGrade]
    cp a, GRADE_S9 ; Don't go past S9.
    jr nz, .trygradeup


.check300
    ; Are we at level 300?
    ld a, [hCLevel+CLEVEL_HUNDREDS]
    cp a, 3
    ret c

    ; Have we judged the requirement before?
    ld a, [wTGM1level300RequirementMet]
    or a, a
    jr nz, .check500

    ; Rank?
    ld a, [wDisplayedGrade]
    cp a, GRADE_1
    jr c, .fail300

    ; Time?
    ld b, 4
    ld c, 15
    call CheckTorikan
    cp a, $FF
    jr nz, .fail300

.success300
    ld a, $FF
    ld [wTGM1level300RequirementMet], a
    jr .check500

.fail300
    ld a, $01
    ld [wTGM1level300RequirementMet], a
    jr .check500


.check500
    ; Are we at level 500?
    ld a, [hCLevel+CLEVEL_HUNDREDS]
    cp a, 5
    ret c

    ; Have we judged the requirement before?
    ld a, [wTGM1level500RequirementMet]
    or a, a
    jr nz, .check999

    ; Rank?
    ld a, [wDisplayedGrade]
    cp a, GRADE_S4
    jr c, .fail500

    ; Time?
    ld b, 7
    ld c, 30
    call CheckTorikan
    cp a, $FF
    jr nz, .fail500

.success500
    ld a, $FF
    ld [wTGM1level500RequirementMet], a
    jr .check999

.fail500
    ld a, $01
    ld [wTGM1level500RequirementMet], a
    jr .check999


.check999
    ; Level needs to be 999.
    ld a, [hCLevel+CLEVEL_HUNDREDS]
    cp a, 9
    ret nz
    ld a, [hCLevel+CLEVEL_TENS]
    cp a, 9
    ret nz
    ld a, [hCLevel+CLEVEL_ONES]
    cp a, 9
    ret nz

    ; Have we judged the requirement before?
    ld a, [wTGM1level999RequirementMet]
    or a, a
    ret nz

    ; Did both other checks succeed?
    ld a, [wTGM1level300RequirementMet]
    cp a, $FF
    jr nz, .fail999
    ld a, [wTGM1level500RequirementMet]
    cp a, $FF
    jr nz, .fail999

    ; Rank? (This is technically slightly wrong but it's nearly impossible to miss the real requirement but make this one, 6000 points.)
    ld a, [wDisplayedGrade]
    cp a, GRADE_S9
    jr c, .fail999

    ; Time?
    ld b, 13
    ld c, 30
    call CheckTorikan
    cp a, $FF
    jr nz, .fail999

.success999
    ld a, $FF
    ld [wTGM1level999RequirementMet], a

    ; Set the grade to GM
    ld a, GRADE_GM
    ld [wDisplayedGrade], a

    ; Sound effect
    call SFXKill
    ld a, SFX_RANKGM
    jp SFXEnqueue

    ; Prepare the effect stuff
    ld a, $0F
    ld [wEffectTimer], a

    ; Return
    ret

.fail999
    ld a, $01
    ld [wTGM1level999RequirementMet], a
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
    call SFXKill
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
    call SFXKill
    ld a, SFX_RANKUP
    call SFXEnqueue

    ; Prepare the effect stuff
    ld a, $0F
    ld [wEffectTimer], a
    ret

.disqualify
    ; Disqualify from ranking.
    ld a, $FF
    ld [wLockLevel], a
    ld [wRankingDisqualified], a
    ld a, 5
    ldh [hCLevel+1], a
    ldh [hNLevel+1], a
    xor a, a
    ldh [hCLevel], a
    ldh [hNLevel], a
    ldh [hCLevel+2], a
    ldh [hNLevel+2], a
    ldh [hCLevel+3], a
    ldh [hNLevel+3], a
    jp TriggerKillScreen


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
    or a, a
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
    call SFXKill
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
    ; Disqualify from ranking.
    ld a, $FF
    ld [wLockLevel], a
    ld [wRankingDisqualified], a
    ld a, [wDisplayedGrade]
    cp a, GRADE_S5
    jr z, .l500

.l1000
    ld a, 1
    ldh [hCLevel], a
    ldh [hNLevel], a
    xor a, a
    ldh [hCLevel+1], a
    ldh [hNLevel+1], a
    ldh [hCLevel+2], a
    ldh [hNLevel+2], a
    ldh [hCLevel+3], a
    ldh [hNLevel+3], a
    jp TriggerKillScreen

.l500
    ld a, 5
    ldh [hCLevel+1], a
    ldh [hNLevel+1], a
    xor a, a
    ldh [hCLevel], a
    ldh [hNLevel], a
    ldh [hCLevel+2], a
    ldh [hNLevel+2], a
    ldh [hCLevel+3], a
    ldh [hNLevel+3], a
    jp TriggerKillScreen

ENDC
