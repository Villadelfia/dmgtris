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


IF !DEF(SPRITES_ASM)
DEF SPRITES_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Shadow OAM", WRAM0, ALIGN[8]
UNION
wShadowOAM::   ds 160
NEXTU
wSPRNext1::    ds 4
wSPRNext2::    ds 4
wSPRNext3::    ds 4
wSPRNext4::    ds 4
wSPRHold1::    ds 4
wSPRHold2::    ds 4
wSPRHold3::    ds 4
wSPRHold4::    ds 4
wSPRScore1::   ds 4
wSPRScore2::   ds 4
wSPRScore3::   ds 4
wSPRScore4::   ds 4
wSPRScore5::   ds 4
wSPRScore6::   ds 4
wSPRScore7::   ds 4
wSPRScore8::   ds 4
wSPRCLevel1::  ds 4
wSPRCLevel2::  ds 4
wSPRCLevel3::  ds 4
wSPRCLevel4::  ds 4
wSPRNLevel1::  ds 4
wSPRNLevel2::  ds 4
wSPRNLevel3::  ds 4
wSPRNLevel4::  ds 4
wSPRQueue1A::  ds 4
wSPRQueue1B::  ds 4
wSPRQueue2A::  ds 4
wSPRQueue2B::  ds 4
wSPRModeRNG::  ds 4
wSPRModeRot::  ds 4
wSPRModeDrop:: ds 4
wSPRModeHiG::  ds 4
wSPRGrade1::   ds 4
wSPRGrade2::   ds 4
wSPRTimeM1::   ds 4
wSPRTimeM2::   ds 4
wSPRTimeS1::   ds 4
wSPRTimeS2::   ds 4
wSPRTimeCS1::  ds 4
wSPRTimeCS2::  ds 4
ENDU
wScratch:      ds 2


SECTION "OAM DMA Code", ROM0
OAMDMA::
    LOAD "OAM DMA", HRAM
    hOAMDMA::
        ; Start OAM DMA transfer.
        ld a, HIGH(wShadowOAM)
        ldh [rDMA], a

        ; Wait for it to complete...
        ld a, 40
:       dec a
        jr nz, :-

        ; Return
        ret
    ENDL
OAMDMAEnd::



SECTION "OAM Functions", ROM0
    ; Copies the OAM handler to HRAM.
CopyOAMHandler::
    ld de, OAMDMA
    ld hl, hOAMDMA
    ld bc, OAMDMAEnd - OAMDMA
    jp UnsafeMemCopy


    ; Clears OAM and shadow OAM.
ClearOAM::
    ld hl, _OAMRAM
    ld bc, 160
    ld d, 0
    call UnsafeMemSet
    ld hl, wShadowOAM
    ld bc, 160
    ld d, 0
    jp UnsafeMemSet



SECTION "Domain Specific Functions", ROM0
    ; Puts the mode tells into sprites and displays them.
ApplyTells::
    ld a, TELLS_BASE_Y
    ld [wSPRModeRNG], a
    add a, TELLS_Y_DIST
    ld [wSPRModeRot], a
    add a, TELLS_Y_DIST
    ld [wSPRModeDrop], a
    add a, TELLS_Y_DIST
    ld [wSPRModeHiG], a

    ldh a, [rSCX]
    ld b, a
    ld a, TELLS_BASE_X
    sub a, b
    ld [wSPRModeRNG+1], a
    ld [wSPRModeDrop+1], a
    add a, TELLS_X_DIST
    ld [wSPRModeRot+1], a
    ld [wSPRModeHiG+1], a

    ld a, [wRNGModeState]
    add a, TILE_RNG_MODE_BASE
    ld [wSPRModeRNG+2], a

    ld a, [wRotModeState]
    cp a, ROT_MODE_MYCO
    jr z, .myco
    add a, TILE_ROT_MODE_BASE
    ld [wSPRModeRot+2], a
    jr .dropmode
.myco
    ld a, TILE_ROT_MODE_MYCO
    ld [wSPRModeRot+2], a

.dropmode
    ld a, [wDropModeState]
    add a, TILE_DROP_MODE_BASE
    ld [wSPRModeDrop+2], a

    ld a, [wAlways20GState]
    add a, TILE_HIG_MODE_BASE
    ld [wSPRModeHiG+2], a

    ld a, 1
    ld [wSPRModeRNG+3], a
    ld a, 3
    ld [wSPRModeRot+3], a
    ld a, 4
    ld [wSPRModeDrop+3], a
    ld a, 0
    ld [wSPRModeHiG+3], a
    ret


    ; Draws the next pieces as a sprite.
    ; Index of next piece in A.
ApplyNext::
    ; If we're in Shirase mode and past level 1000...
    ld b, a
    ld a, [wBonesActive]
    cp a, $FF
    jr nz, .nobone

.bone
    ; Color
    ld a, 7
    ld [wSPRNext1+3], a
    ld [wSPRNext2+3], a
    ld [wSPRNext3+3], a
    ld [wSPRNext4+3], a

    ; Tile
    ld a, TILE_QUEUE_BONE
    ld [wSPRNext1+2], a
    ld [wSPRNext2+2], a
    ld [wSPRNext3+2], a
    ld [wSPRNext4+2], a
    ld a, b
    jr .pos

.nobone
    ; Correct color
    ld a, b
    ld [wSPRNext1+3], a
    ld [wSPRNext2+3], a
    ld [wSPRNext3+3], a
    ld [wSPRNext4+3], a

    ; Correct tile
    add a, TILE_PIECE_0
    add a, 7
    ld [wSPRNext1+2], a
    ld [wSPRNext2+2], a
    ld [wSPRNext3+2], a
    ld [wSPRNext4+2], a
    sub a, TILE_PIECE_0
    sub a, 7

.pos
    ; X positions
    ld b, a
    ldh a, [hGameState]
    cp a, STATE_GAMEPLAY_BIG
    ld a, b
    jr nz, .regular
    ld hl, sBigPieceXOffsets
    ld de, sBigPieceYOffsets
    jr .postoffsets
.regular
    ld hl, sPieceXOffsets
    ld de, sPieceYOffsets
.postoffsets
    cp 0
    jr z, .skipoffn
.getoffn
    inc hl
    inc hl
    inc hl
    inc hl
    inc de
    inc de
    inc de
    inc de
    dec a
    jr nz, .getoffn
.skipoffn
    ldh a, [rSCX]
    ld b, a
    ld a, [hl+]
    add a, NEXT_BASE_X
    sub a, b
    ld [wSPRNext1+1], a
    ld a, [hl+]
    add a, NEXT_BASE_X
    sub a, b
    ld [wSPRNext2+1], a
    ld a, [hl+]
    add a, NEXT_BASE_X
    sub a, b
    ld [wSPRNext3+1], a
    ld a, [hl]
    add a, NEXT_BASE_X
    sub a, b
    ld [wSPRNext4+1], a

    ; Y positions
    ld h, d
    ld l, e
    ld a, [hl+]
    add a, NEXT_BASE_Y
    ld [wSPRNext1+0], a
    ld a, [hl+]
    add a, NEXT_BASE_Y
    ld [wSPRNext2+0], a
    ld a, [hl+]
    add a, NEXT_BASE_Y
    ld [wSPRNext3+0], a
    ld a, [hl]
    add a, NEXT_BASE_Y
    ld [wSPRNext4+0], a

    ; Queue
    ld a, QUEUE_BASE_Y
    ld [wSPRQueue1A], a
    ld [wSPRQueue1B], a
    add a, 12
    ld [wSPRQueue2A], a
    ld [wSPRQueue2B], a

    ldh a, [rSCX]
    ld b, a
    ld a, QUEUE_BASE_X
    sub a, b
    ld [wSPRQueue1A+1], a
    ld [wSPRQueue2A+1], a
    add a, 8
    ld [wSPRQueue1B+1], a
    ld [wSPRQueue2B+1], a

    ldh a, [hUpcomingPiece1]
    ld [wSPRQueue1A+3], a
    ld [wSPRQueue1B+3], a
    sla a
    add a, TILE_PIECE_SMALL_0
    ld [wSPRQueue1A+2], a
    inc a
    ld [wSPRQueue1B+2], a

    ldh a, [hUpcomingPiece2]
    ld [wSPRQueue2A+3], a
    ld [wSPRQueue2B+3], a
    sla a
    add a, TILE_PIECE_SMALL_0
    ld [wSPRQueue2A+2], a
    inc a
    ld [wSPRQueue2B+2], a

    ; Shirase bone colors
    ld a, [wSpeedCurveState]
    cp a, SCURVE_SHIR
    jr nz, .done
    ldh a, [hCLevel+CLEVEL_THOUSANDS]
    cp a, 1
    jr c, .done
    ld a, 7
    ld [wSPRQueue1A+3], a
    ld [wSPRQueue1B+3], a
    ld [wSPRQueue2A+3], a
    ld [wSPRQueue2B+3], a

.done
    jp GradeRendering


    ; Draws the held piece.
    ; Index of held piece in A.
ApplyHold::
    ; If we're in Shirase mode and past level 1000...
    ld b, a
    ld a, [wBonesActive]
    cp a, $FF
    jr nz, .nobone

.bone
    ; Color
    ld a, 7
    ld [wSPRHold1+3], a
    ld [wSPRHold2+3], a
    ld [wSPRHold3+3], a
    ld [wSPRHold4+3], a

    ; Tile
    ld a, TILE_QUEUE_BONE
    ld [wSPRHold1+2], a
    ld [wSPRHold2+2], a
    ld [wSPRHold3+2], a
    ld [wSPRHold4+2], a
    ld a, b
    jr .x

.nobone
    ; Correct color
    ld a, b
    ld [wSPRHold1+3], a
    ld [wSPRHold2+3], a
    ld [wSPRHold3+3], a
    ld [wSPRHold4+3], a

    ; Correct tile
    ld b, a
    ld a, [wInitialA]
    cp a, $11
    ld a, b
    jr z, .show
    ldh a, [hEvenFrame]
    cp a, 0
    ld a, b
    jr z, .show

.hide
    ld b, a
    ld a, TILE_BLANK
    ld [wSPRHold1+2], a
    ld [wSPRHold2+2], a
    ld [wSPRHold3+2], a
    ld [wSPRHold4+2], a
    ld a, b
    jr .x

.show
    add a, TILE_PIECE_0
    ld [wSPRHold1+2], a
    ld [wSPRHold2+2], a
    ld [wSPRHold3+2], a
    ld [wSPRHold4+2], a
    sub a, TILE_PIECE_0

    ; X positions
.x
    ld b, a
    ldh a, [hGameState]
    cp a, STATE_GAMEPLAY_BIG
    ld a, b
    jr nz, .regular
    ld hl, sBigPieceXOffsets
    ld de, sBigPieceYOffsets
    jr .postoffsets
.regular
    ld hl, sPieceXOffsets
    ld de, sPieceYOffsets
.postoffsets
    cp 0
    jr z, .skipoffh
.getoffh
    inc hl
    inc hl
    inc hl
    inc hl
    inc de
    inc de
    inc de
    inc de
    dec a
    jr nz, .getoffh
.skipoffh
    ldh a, [rSCX]
    ld b, a
    ld a, [hl+]
    add a, HOLD_BASE_X
    sub a, b
    ld [wSPRHold1+1], a
    ld a, [hl+]
    add a, HOLD_BASE_X
    sub a, b
    ld [wSPRHold2+1], a
    ld a, [hl+]
    add a, HOLD_BASE_X
    sub a, b
    ld [wSPRHold3+1], a
    ld a, [hl]
    add a, HOLD_BASE_X
    sub a, b
    ld [wSPRHold4+1], a

    ; Y positions
    ld h, d
    ld l, e
    ld a, [hl+]
    add a, HOLD_BASE_Y
    ld [wSPRHold1+0], a
    ld a, [hl+]
    add a, HOLD_BASE_Y
    ld [wSPRHold2+0], a
    ld a, [hl+]
    add a, HOLD_BASE_Y
    ld [wSPRHold3+0], a
    ld a, [hl]
    add a, HOLD_BASE_Y
    ld [wSPRHold4+0], a
    ret


    ; Draw the time.
ApplyTime::
    ; Set the Y position of the time objects.
    ld a, TIME_BASE_Y
    ld [wSPRTimeM1], a
    ld [wSPRTimeM2], a
    ld [wSPRTimeS1], a
    ld [wSPRTimeS2], a
    ld [wSPRTimeCS1], a
    ld [wSPRTimeCS2], a

    ; Set the X position of the time objects.
    ldh a, [rSCX]
    ld b, a
    ld a, TIME_BASE_X
    sub a, b
    ld [wSPRTimeM1+1], a
    add a, 8
    ld [wSPRTimeM2+1], a
    add a, 12
    ld [wSPRTimeS1+1], a
    add a, 8
    ld [wSPRTimeS2+1], a
    add a, 12
    ld [wSPRTimeCS1+1], a
    add a, 8
    ld [wSPRTimeCS2+1], a

    ; Set the palette of the time objects.
    ld a, OAMF_PAL0 | $07
    ld [wSPRTimeM1+3], a
    ld [wSPRTimeM2+3], a
    ld [wSPRTimeS1+3], a
    ld [wSPRTimeS2+3], a
    ld [wSPRTimeCS1+3], a
    ld [wSPRTimeCS2+3], a

    ; Minutes. Hex to BCD.
    ld a, [wMinutes]
    ld c, a
    ld b, 8
    xor a, a
.loop0
    sla c
    adc a, a
    daa
    dec b
    jr nz, .loop0

    ; Save to scratch.
    ld b, a
    and a, $0F
    ld [wScratch+1], a
    ld a, b
    and a, $F0
    swap a
    ld [wScratch], a

    ; Apply to sprites.
    ld de, wScratch
    ld hl, wSPRTimeM1+2
    ld bc, 4
    ld a, [de]
    add a, TILE_SMALL_0
    ld [hl], a
    add hl, bc
    inc de
    ld a, [de]
    add a, TILE_SMALL_0
    ld [hl], a

    ; Seconds. Hex to BCD.
    ld a, [wSeconds]
    ld c, a
    ld b, 8
    xor a, a
.loop1
    sla c
    adc a, a
    daa
    dec b
    jr nz, .loop1

    ; Save to scratch.
    ld b, a
    and a, $0F
    ld [wScratch+1], a
    ld a, b
    and a, $F0
    swap a
    ld [wScratch], a

    ; Apply to sprites.
    ld de, wScratch
    ld hl, wSPRTimeS1+2
    ld bc, 4
    ld a, [de]
    add a, TILE_SMALL_0
    ld [hl], a
    add hl, bc
    inc de
    ld a, [de]
    add a, TILE_SMALL_0
    ld [hl], a

    ; Centiseconds. Frames using LUT.
    ld a, [wFrames]
    ld c, a
    ld b, 0
    ld hl, sFramesToCS
    add hl, bc
    ld a, [hl]

    ; Save to scratch.
    ld b, a
    and a, $0F
    ld [wScratch+1], a
    ld a, b
    and a, $F0
    swap a
    ld [wScratch], a

    ; Apply to sprites.
    ld de, wScratch
    ld hl, wSPRTimeCS1+2
    ld bc, 4
    ld a, [de]
    add a, TILE_SMALL_0
    ld [hl], a
    add hl, bc
    inc de
    ld a, [de]
    add a, TILE_SMALL_0
    ld [hl], a





    ret


    ; Generic function to draw a BCD number (8 digits) as 8 sprites.
    ; Address of first sprite in hl.
    ; Address of first digit in de.
ApplyNumbers8::
    inc hl
    inc hl
    ld bc, 4

    ld a, [de]
    cp a, 0
    jr nz, .one
    ld a, TILE_BLANK
    ld [hl], a
    add hl, bc
    inc de

    ld a, [de]
    cp a, 0
    jr nz, .two
    ld a, TILE_BLANK
    ld [hl], a
    add hl, bc
    inc de

    ld a, [de]
    cp a, 0
    jr nz, .three
    ld a, TILE_BLANK
    ld [hl], a
    add hl, bc
    inc de

    ld a, [de]
    cp a, 0
    jr nz, .four
    ld a, TILE_BLANK
    ld [hl], a
    add hl, bc
    inc de

    ld a, [de]
    cp a, 0
    jr nz, .five
    ld a, TILE_BLANK
    ld [hl], a
    add hl, bc
    inc de

    ld a, [de]
    cp a, 0
    jr nz, .six
    ld a, TILE_BLANK
    ld [hl], a
    add hl, bc
    inc de

    ld a, [de]
    cp a, 0
    jr nz, .seven
    ld a, TILE_BLANK
    ld [hl], a
    add hl, bc
    inc de

    jr .eight

.one
    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

.two
    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

.three
    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

.four
    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

.five
    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

.six
    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

.seven
    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

.eight
    ld a, [de]
    add a, TILE_0
    ld [hl], a
    ret


    ; Generic function to draw a BCD number (4 digits) as 4 sprites.
    ; Address of first sprite in hl.
    ; Address of first digit in de.
ApplyNumbers4::
    inc hl
    inc hl
    ld bc, 4

    ld a, [de]
    cp a, 0
    jr nz, .one
    ld a, TILE_BLANK
    ld [hl], a
    add hl, bc
    inc de

    ld a, [de]
    cp a, 0
    jr nz, .two
    ld a, TILE_BLANK
    ld [hl], a
    add hl, bc
    inc de

    ld a, [de]
    cp a, 0
    jr nz, .three
    ld a, TILE_BLANK
    ld [hl], a
    add hl, bc
    inc de

    jr .four

.one
    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

.two
    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

.three
    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

.four
    ld a, [de]
    add a, TILE_0
    ld [hl], a
    ret


    ; Positions all number sprites for gameplay.
SetNumberSpritePositions::
    ldh a, [rSCX]
    ld b, a
    ld a, SCORE_BASE_X
    sub a, b
    ld hl, wSPRScore1
    ld [hl], SCORE_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1 | $07
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRScore2
    ld [hl], SCORE_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1 | $07
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRScore3
    ld [hl], SCORE_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1 | $07
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRScore4
    ld [hl], SCORE_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1 | $07
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRScore5
    ld [hl], SCORE_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1 | $07
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRScore6
    ld [hl], SCORE_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1 | $07
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRScore7
    ld [hl], SCORE_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1 | $07
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRScore8
    ld [hl], SCORE_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld a, OAMF_PAL1 | $07
    ld [hl], a

    ldh a, [rSCX]
    ld b, a
    ld a, LEVEL_BASE_X
    sub a, b
    ld hl, wSPRCLevel1
    ld [hl], CLEVEL_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1 | $07
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRCLevel2
    ld [hl], CLEVEL_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1 | $07
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRCLevel3
    ld [hl], CLEVEL_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1 | $07
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRCLevel4
    ld [hl], CLEVEL_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld a, OAMF_PAL1 | $07
    ld [hl], a

    ldh a, [rSCX]
    ld b, a
    ld a, LEVEL_BASE_X
    sub a, b
    ld hl, wSPRNLevel1
    ld [hl], NLEVEL_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1 | $07
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRNLevel2
    ld [hl], NLEVEL_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1 | $07
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRNLevel3
    ld [hl], NLEVEL_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1 | $07
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRNLevel4
    ld [hl], NLEVEL_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld a, OAMF_PAL1 | $07
    ld [hl], a
    ret


GradeRendering::
    ; Set the Y position of the grade objects.
    ld a, GRADE_BASE_Y
    ld [wSPRGrade1], a
    ld [wSPRGrade2], a

    ; Set the X position of the grade objects.
    ldh a, [rSCX]
    ld b, a
    ld a, GRADE_BASE_X
    sub a, b
    ld [wSPRGrade1+1], a
    add a, 9
    ld [wSPRGrade2+1], a

    ; Set the grades to blank
    ld a, TILE_BLANK
    ld [wSPRGrade1+2], a
    ld [wSPRGrade2+2], a

    ; If our grade is GRADE_NONE, we don't need to do anything else.
    ld a, [wDisplayedGrade]
    cp a, GRADE_NONE
    ret z

    ; If the effect timer is greater than 0 and on even frames, decrement it and do some palette magic.
    ldh a, [hFrameCtr]
    cp a, 0
    jr z, .noeffect
    ld a, [wEffectTimer]
    cp a, 0
    jr z, .noeffect
    dec a
    ld [wEffectTimer], a

    ; Cycle the palette of the grade objects.
.effect
    ld a, [wSPRGrade1+3]
    inc a
    and a, OAMF_PALMASK
    or a, OAMF_PAL1
    ld [wSPRGrade1+3], a
    ld [wSPRGrade2+3], a
    jr .drawgrade

    ; Set the palette of the grade objects to the normal palette.
.noeffect
    ld a, 7 | OAMF_PAL1
    ld [wSPRGrade1+3], a
    ld [wSPRGrade2+3], a

    ; Do we draw this as a regular grade?
.drawgrade
    ld a, [wDisplayedGrade]
    cp a, GRADE_S1
    jr nc, .sgrade ; No. S or better.

.regulargrade
    ; Draw as a regular grade.
    ld b, a
    ld a, "9"
    sub a, b
    ld [wSPRGrade2+2], a
    ret

.sgrade
    ; Is the grade S10 or better?
    cp a, GRADE_S10
    jr nc, .hisgrade

    ; Draw as S grade.
    ld a, "S"
    ld [wSPRGrade1+2], a
    ld a, [wDisplayedGrade]
    sub a, GRADE_S1
    ld b, a
    ld a, "1"
    add a, b
    ld [wSPRGrade2+2], a
    ret

.hisgrade
    ; Is the grade M1 or better?
    cp a, GRADE_M1
    jr nc, .mgrade

    ; Draw as high S grade.
    ld a, "S"
    ld [wSPRGrade1+2], a
    ld a, [wDisplayedGrade]
    sub a, GRADE_S10
    ld b, a
    ld a, "a"
    add a, b
    ld [wSPRGrade2+2], a
    ret

.mgrade
    ; Is the grade one of the letter grades?
    cp a, GRADE_M
    jr nc, .lettergrade

    ; Draw as m grade.
    ld a, "m"
    ld [wSPRGrade1+2], a
    ld a, [wDisplayedGrade]
    sub a, GRADE_M1
    ld b, a
    ld a, "1"
    add a, b
    ld [wSPRGrade2+2], a
    ret

.lettergrade
    ; Is the grade GM?
    cp a, GRADE_GM
    jr z, .gmgrade

    ; Draw as MX grade.
    ld a, "M"
    ld [wSPRGrade1+2], a
    ld a, [wDisplayedGrade]
    cp a, GRADE_M
    ret z ; No second letter for M.

    ; Otherwise jump to the right letter.
    cp a, GRADE_MK
    jr z, .mk
    cp a, GRADE_MV
    jr z, .mv
    cp a, GRADE_MO
    jr z, .mo
    jr .mm

.mk
    ld a, "k"
    ld [wSPRGrade2+2], a
    ret

.mv
    ld a, "v"
    ld [wSPRGrade2+2], a
    ret

.mo
    ld a, "o"
    ld [wSPRGrade2+2], a
    ret

.mm
    ld a, "n"
    ld [wSPRGrade2+2], a
    ret

.gmgrade
    ; Draw as GM grade.
    ld a, "G"
    ld [wSPRGrade1+2], a
    ld a, "M"
    ld [wSPRGrade2+2], a
    ret


ENDC
