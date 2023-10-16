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
wSPRHold1:: ds 4
wSPRHold2:: ds 4
wSPRHold3:: ds 4
wSPRHold4:: ds 4
wSPRScore1:: ds 4
wSPRScore2:: ds 4
wSPRScore3:: ds 4
wSPRScore4:: ds 4
wSPRScore5:: ds 4
wSPRScore6:: ds 4
wSPRCLevel1:: ds 4
wSPRCLevel2:: ds 4
wSPRCLevel3:: ds 4
wSPRCLevel4:: ds 4
wSPRNLevel1:: ds 4
wSPRNLevel2:: ds 4
wSPRNLevel3:: ds 4
wSPRNLevel4:: ds 4
wSPRUnused:: ds (16 * 4)
ENDU


SECTION "OAM DMA Code", ROM0
OAMDMA::
    LOAD "OAM DMA", HRAM
    hOAMDMA::
        ld a, HIGH(wShadowOAM)
        ldh [rDMA], a
        ld a, 40
:       dec a
        jr nz, :-
        ret
    ENDL
OAMDMAEnd::



SECTION "OAM Functions", ROM0
CopyOAMHandler::
    ld de, OAMDMA
    ld hl, hOAMDMA
    ld bc, OAMDMAEnd - OAMDMA
    call UnsafeMemCopy
    ret


ClearOAM::
    ld hl, _OAMRAM
    ld bc, $9F
    ld d, 0
    call UnsafeMemSet
    ld hl, wShadowOAM
    ld bc, $9F
    ld d, 0
    call UnsafeMemSet
    ret



SECTION "Domain Specific Functions", ROM0
; Index of next piece in A.
ApplyNext::
    ; Correct tile
    add a, TILE_PIECE_0
    ld [wSPRNext1+2], a
    ld [wSPRNext2+2], a
    ld [wSPRNext3+2], a
    ld [wSPRNext4+2], a
    sub a, TILE_PIECE_0

    ; X positions
    ld hl, sPieceXOffsets
    ld de, sPieceYOffsets
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
    ret

; Index of hold piece in A.
ApplyHold::
    cp 255
    jr nz, .doApplyHold
    ld hl, wSPRHold1
    ld bc, 16
    ld d, 0
    call UnsafeMemSet
    ret

.doApplyHold
    ; Correct tile
    add a, TILE_PIECE_0
    ld [wSPRHold1+2], a
    ld [wSPRHold2+2], a
    ld [wSPRHold3+2], a
    ld [wSPRHold4+2], a
    sub a, TILE_PIECE_0

    ; X positions
    ld hl, sPieceXOffsets
    ld de, sPieceYOffsets
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
    add hl, bc
    inc de
    ret


SetNumberSpritePositions::
    ld a, SCORE_BASE_X
    ld hl, wSPRScore1
    ld [hl], SCORE_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1
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
    ld a, OAMF_PAL1
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
    ld a, OAMF_PAL1
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
    ld a, OAMF_PAL1
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
    ld a, OAMF_PAL1
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRScore6
    ld [hl], SCORE_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld a, OAMF_PAL1
    ld [hl], a

    ld a, LEVEL_BASE_X
    ld hl, wSPRCLevel1
    ld [hl], CLEVEL_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1
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
    ld a, OAMF_PAL1
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
    ld a, OAMF_PAL1
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRCLevel4
    ld [hl], CLEVEL_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld a, OAMF_PAL1
    ld [hl], a

    ld a, LEVEL_BASE_X
    ld hl, wSPRNLevel1
    ld [hl], NLEVEL_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld b, a
    ld a, OAMF_PAL1
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
    ld a, OAMF_PAL1
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
    ld a, OAMF_PAL1
    ld [hl], a
    ld a, b
    add a, 8

    ld hl, wSPRNLevel4
    ld [hl], NLEVEL_BASE_Y
    inc hl
    ld [hl], a
    inc hl
    inc hl
    ld a, OAMF_PAL1
    ld [hl], a
    ret


ENDC
