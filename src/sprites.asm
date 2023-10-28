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
wShadowOAM:: ds 160
NEXTU
wSPRNext1:: ds 4
wSPRNext2:: ds 4
wSPRNext3:: ds 4
wSPRNext4:: ds 4
wUnused0:: ds 4
wUnused1:: ds 4
wSPRHold1:: ds 4
wSPRHold2:: ds 4
wSPRHold3:: ds 4
wSPRHold4:: ds 4
wUnused2:: ds 4
wUnused3:: ds 4
wSPRScore1:: ds 4
wSPRScore2:: ds 4
wSPRScore3:: ds 4
wSPRScore4:: ds 4
wSPRScore5:: ds 4
wSPRScore6:: ds 4
wUnused4:: ds 4
wUnused5:: ds 4
wSPRCLevel1:: ds 4
wSPRCLevel2:: ds 4
wSPRCLevel3:: ds 4
wSPRCLevel4:: ds 4
wUnused6:: ds 4
wUnused7:: ds 4
wSPRNLevel1:: ds 4
wSPRNLevel2:: ds 4
wSPRNLevel3:: ds 4
wSPRNLevel4:: ds 4
wUnused8:: ds 4
wUnused9:: ds 4
wSPRQueue1A:: ds 4
wSPRQueue1B:: ds 4
wSPRQueue2A:: ds 4
wSPRQueue2B:: ds 4
wSPRModeRNG:: ds 4
wSPRModeRot:: ds 4
wSPRModeDrop:: ds 4
wSPRModeHiG:: ds 4
ENDU


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
    ld bc, $9F
    ld d, 0
    call SafeMemSet
    ld hl, wShadowOAM
    ld bc, $9F
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

    ld a, TELLS_BASE_X
    ld [wSPRModeRNG+1], a
    ld [wSPRModeRot+1], a
    ld [wSPRModeDrop+1], a
    ld [wSPRModeHiG+1], a

    ld a, [wRNGModeState]
    add a, TILE_RNG_MODE_BASE
    ld [wSPRModeRNG+2], a

    ld a, [wRotModeState]
    add a, TILE_ROT_MODE_BASE
    ld [wSPRModeRot+2], a

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
    ; Correct color
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
    ld a, [hl+]
    add a, NEXT_BASE_X
    ld [wSPRNext1+1], a
    ld a, [hl+]
    add a, NEXT_BASE_X
    ld [wSPRNext2+1], a
    ld a, [hl+]
    add a, NEXT_BASE_X
    ld [wSPRNext3+1], a
    ld a, [hl]
    add a, NEXT_BASE_X
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
    add a, 9
    ld [wSPRQueue2A], a
    ld [wSPRQueue2B], a

    ld a, QUEUE_BASE_X
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
    ret


    ; Draws the held piece.
    ; Index of held piece in A.
ApplyHold::
    ; Correct color
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
    ld a, [hl+]
    add a, HOLD_BASE_X
    ld [wSPRHold1+1], a
    ld a, [hl+]
    add a, HOLD_BASE_X
    ld [wSPRHold2+1], a
    ld a, [hl+]
    add a, HOLD_BASE_X
    ld [wSPRHold3+1], a
    ld a, [hl]
    add a, HOLD_BASE_X
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


    ; Generic function to draw a BCD number (6 digits) as 6 sprites.
    ; Address of first sprite in hl.
    ; Address of first digit in de.
ApplyNumbers::
    inc hl
    inc hl
    ld bc, 4

    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

    ld a, [de]
    add a, TILE_0
    ld [hl], a
    add hl, bc
    inc de

    ld a, [de]
    add a, TILE_0
    ld [hl], a
    ret


    ; Positions all number sprites for gameplay.
SetNumberSpritePositions::
    ld a, SCORE_BASE_X
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
    ld a, OAMF_PAL1 | $07
    ld [hl], a

    ld a, LEVEL_BASE_X
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

    ld a, LEVEL_BASE_X
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


ENDC
