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


IF !DEF(GBC_ASM)
DEF GBC_ASM EQU 1


INCLUDE "globals.asm"

    ; Standard B/W
    DEF_RGB555_FROM24 BLACK,  $00, $00, $00
    DEF_RGB555_FROM24 GRAY_0, $55, $55, $55
    DEF_RGB555_FROM24 GRAY_1, $AA, $AA, $AA
    DEF_RGB555_FROM24 WHITE,  $FF, $FF, $FF

    ; I piece
    DEF_RGB555_FROM24 RED_0, $A2, $24, $24
    DEF_RGB555_FROM24 RED_1, $D3, $2F, $2F
    DEF_RGB555_FROM24 RED_2, $DE, $60, $60
    DEF_RGB555_FROM24 RED_3, $FF, $FF, $FF

    ; S piece
    DEF_RGB555_FROM24 GREEN_0, $2B, $6D, $2E
    DEF_RGB555_FROM24 GREEN_1, $38, $8E, $3C
    DEF_RGB555_FROM24 GREEN_2, $67, $A9, $6A
    DEF_RGB555_FROM24 GREEN_3, $FF, $FF, $FF

    ; Z piece
    DEF_RGB555_FROM24 PURPLE_0, $5F, $16, $7C
    DEF_RGB555_FROM24 PURPLE_1, $7B, $1F, $A2
    DEF_RGB555_FROM24 PURPLE_2, $9A, $53, $B7
    DEF_RGB555_FROM24 PURPLE_3, $FF, $FF, $FF

    ; J piece
    DEF_RGB555_FROM24 BLUE_0, $10, $4D, $94
    DEF_RGB555_FROM24 BLUE_1, $15, $65, $C0
    DEF_RGB555_FROM24 BLUE_2, $4B, $89, $CF
    DEF_RGB555_FROM24 BLUE_3, $FF, $FF, $FF

    ; L piece
    DEF_RGB555_FROM24 ORANGE_0, $BB, $5F, $00
    DEF_RGB555_FROM24 ORANGE_1, $D7, $8D, $00
    DEF_RGB555_FROM24 ORANGE_2, $F7, $9B, $3B
    DEF_RGB555_FROM24 ORANGE_3, $FF, $FF, $FF

    ; O piece
    DEF_RGB555_FROM24 YELLOW_0, $C0, $94, $23
    DEF_RGB555_FROM24 YELLOW_1, $EB, $A0, $2D
    DEF_RGB555_FROM24 YELLOW_2, $FC, $CE, $5E
    DEF_RGB555_FROM24 YELLOW_3, $FF, $FF, $FF

    ; T piece
    DEF_RGB555_FROM24 CYAN_0, $02, $77, $AF
    DEF_RGB555_FROM24 CYAN_1, $03, $9B, $E5
    DEF_RGB555_FROM24 CYAN_2, $3D, $B2, $EB
    DEF_RGB555_FROM24 CYAN_3, $FF, $FF, $FF

    ; Field colors
    DEF_RGB555_FROM24 BLACK_F, $20, $20, $20
    DEF_RGB555_FROM24 GOLD_0,  $36, $2C, $05
    DEF_RGB555_FROM24 GOLD_1,  $99, $73, $16
    DEF_RGB555_FROM24 WHITE_F, $FF, $FF, $FF


    ; Title Palettes.
    DEF_RGB555_FROM24 TITLE_PAL0_0, 0, 0, 0
    DEF_RGB555_FROM24 TITLE_PAL0_1, 255, 255, 255
    DEF_RGB555_FROM24 TITLE_PAL0_2, 106, 190, 48
    DEF_RGB555_FROM24 TITLE_PAL0_3, 153, 229, 80

    DEF_RGB555_FROM24 TITLE_PAL1_0, 0, 0, 0
    DEF_RGB555_FROM24 TITLE_PAL1_1, 34, 32, 52
    DEF_RGB555_FROM24 TITLE_PAL1_2, 63, 63, 116
    DEF_RGB555_FROM24 TITLE_PAL1_3, 99, 155, 255

    DEF_RGB555_FROM24 TITLE_PAL2_0, 0, 0, 0
    DEF_RGB555_FROM24 TITLE_PAL2_1, 34, 32, 52
    DEF_RGB555_FROM24 TITLE_PAL2_2, 69, 40, 60
    DEF_RGB555_FROM24 TITLE_PAL2_3, 102, 57, 49

    DEF_RGB555_FROM24 TITLE_PAL3_0, 0, 0, 0
    DEF_RGB555_FROM24 TITLE_PAL3_1, 89, 86, 82
    DEF_RGB555_FROM24 TITLE_PAL3_2, 132, 126, 135
    DEF_RGB555_FROM24 TITLE_PAL3_3, 155, 173, 183

    DEF_RGB555_FROM24 TITLE_PAL4_0, 0, 0, 0
    DEF_RGB555_FROM24 TITLE_PAL4_1, 34, 32, 52
    DEF_RGB555_FROM24 TITLE_PAL4_2, 132, 126, 135
    DEF_RGB555_FROM24 TITLE_PAL4_3, 155, 173, 183


SECTION "GBC Shadow Tilemap", WRAM0, ALIGN[8]
wShadowTilemap:: ds 32*32


SECTION "GBC Shadow Tile Attributes", WRAM0, ALIGN[8]
wShadowTileAttrs:: ds 32*32


SECTION "GBC Variables", WRAM0
wOuterReps:: ds 1
wInnerReps:: ds 1


SECTION "GBC Functions", ROM0
    ; Copies the shadow tile attribute map to vram using instant HDMA.
ToATTR::
    ld a, [wInitialA]
    cp a, $11
    ret nz

    ; Bank 1
    ld a, 1
    ldh [rVBK], a
    ld a, HIGH(wShadowTileAttrs)
    ldh [rHDMA1], a
    ld a, LOW(wShadowTileAttrs)
    ldh [rHDMA2], a
    ld a, HIGH($9800)
    ldh [rHDMA3], a
    ld a, LOW($9800)
    ldh [rHDMA4], a
    ld a, 41
    ldh [rHDMA5], a
    xor a, a
    ldh [rVBK], a
    ret


    ; Sets up GBC registers for the title state.
GBCTitleInit::
    ld a, [wInitialA]
    cp a, $11
    ret nz

    ; Palettes.
    ld a, [wInitialB]
    bit 0, a
    jp nz, .agb
    WRITEPAL_A 0, TITLE_PAL0_0_C, TITLE_PAL0_1_C, TITLE_PAL0_2_C, TITLE_PAL0_3_C
    WRITEPAL_A 1, TITLE_PAL1_0_C, TITLE_PAL1_1_C, TITLE_PAL1_2_C, TITLE_PAL1_3_C
    WRITEPAL_A 2, TITLE_PAL2_0_C, TITLE_PAL2_1_C, TITLE_PAL2_2_C, TITLE_PAL2_3_C
    WRITEPAL_A 3, TITLE_PAL3_0_C, TITLE_PAL3_1_C, TITLE_PAL3_2_C, TITLE_PAL3_3_C
    WRITEPAL_A 4, TITLE_PAL4_0_C, TITLE_PAL4_1_C, TITLE_PAL4_2_C, TITLE_PAL4_3_C
    WRITEPAL_A 5, BLACK_C,        GRAY_0_C,       GRAY_1_C,       WHITE_C
    WRITEPAL_A 6, BLACK_C,        BLUE_0_C,       BLUE_1_C,       BLUE_2_C
    WRITEPAL_A 7, BLACK_C,        GRAY_0_C,       GRAY_1_C,       WHITE_C
    jp .postpalettes
.agb
    WRITEPAL_A 0, TITLE_PAL0_0_A, TITLE_PAL0_1_A, TITLE_PAL0_2_A, TITLE_PAL0_3_A
    WRITEPAL_A 1, TITLE_PAL1_0_A, TITLE_PAL1_1_A, TITLE_PAL1_2_A, TITLE_PAL1_3_A
    WRITEPAL_A 2, TITLE_PAL2_0_A, TITLE_PAL2_1_A, TITLE_PAL2_2_A, TITLE_PAL2_3_A
    WRITEPAL_A 3, TITLE_PAL3_0_A, TITLE_PAL3_1_A, TITLE_PAL3_2_A, TITLE_PAL3_3_A
    WRITEPAL_A 4, TITLE_PAL4_0_A, TITLE_PAL4_1_A, TITLE_PAL4_2_A, TITLE_PAL4_3_A
    WRITEPAL_A 5, BLACK_A,        GRAY_0_A,       GRAY_1_A,       WHITE_A
    WRITEPAL_A 6, BLACK_A,        BLUE_0_A,       BLUE_1_A,       BLUE_2_A
    WRITEPAL_A 7, BLACK_A,        GRAY_0_A,       GRAY_1_A,       WHITE_A
.postpalettes

    ; Copy the tilemap to shadow.
    ld de, $9800
    ld hl, wShadowTilemap
    ld bc, 32*32
    call UnsafeMemCopy

    ; Set attrs to pal 7 and copy to shadow.
    ld a, 1
    ldh [rVBK], a
    ld de, sTitleAttrs
    ld hl, $9800
    ld bc, (5*32)
    call UnsafeMemCopy
    ld d, $07
    ld bc, (13*32)
    call UnsafeMemSet
    ld de, $9800
    ld hl, wShadowTileAttrs
    ld bc, 32*32
    call UnsafeMemCopy

    ; Reset back to bank 0.
    xor a, a
    ldh [rVBK], a
    ret

    ; Sets the GBC registers for the gameplay state.
GBCGameplayInit::
    ld a, [wInitialA]
    cp a, $11
    ret nz

    ; Palettes.
    ld a, [wInitialB]
    bit 0, a
    jp nz, .agb
    WRITEPAL_A 0, RED_3_C,    RED_2_C,    RED_1_C,    RED_0_C
    WRITEPAL_A 1, GREEN_3_C,  GREEN_2_C,  GREEN_1_C,  GREEN_0_C
    WRITEPAL_A 2, PURPLE_3_C, PURPLE_2_C, PURPLE_1_C, PURPLE_0_C
    WRITEPAL_A 3, BLUE_3_C,   BLUE_2_C,   BLUE_1_C,   BLUE_0_C
    WRITEPAL_A 4, ORANGE_3_C, ORANGE_2_C, ORANGE_1_C, ORANGE_0_C
    WRITEPAL_A 5, YELLOW_3_C, YELLOW_2_C, YELLOW_1_C, YELLOW_0_C
    WRITEPAL_A 6, CYAN_3_C,   CYAN_2_C,   CYAN_1_C,   CYAN_0_C
    WRITEPAL_A 7, WHITE_C,    GRAY_1_C,   GRAY_0_C,   BLACK_C
    ld a, [wBGMode]
    cp a, BG_MODE_DARK
    jp nz, .postpalettes
    WRITEPAL_B 0, BLACK_C,    RED_2_C,    RED_1_C,    RED_0_C
    WRITEPAL_B 1, BLACK_C,  GREEN_2_C,  GREEN_1_C,  GREEN_0_C
    WRITEPAL_B 2, BLACK_C, PURPLE_2_C, PURPLE_1_C, PURPLE_0_C
    WRITEPAL_B 3, BLACK_C,   BLUE_2_C,   BLUE_1_C,   BLUE_0_C
    WRITEPAL_B 4, BLACK_C, ORANGE_2_C, ORANGE_1_C, ORANGE_0_C
    WRITEPAL_B 5, BLACK_C, YELLOW_2_C, YELLOW_1_C, YELLOW_0_C
    WRITEPAL_B 6, BLACK_C,   CYAN_2_C,   CYAN_1_C,   CYAN_0_C
    WRITEPAL_A 7, BLACK_C,    GRAY_0_C,   GRAY_1_C,   WHITE_C
    jp .postpalettes

.agb
    WRITEPAL_A 0, RED_3_A,    RED_2_A,    RED_1_A,    RED_0_A
    WRITEPAL_A 1, GREEN_3_A,  GREEN_2_A,  GREEN_1_A,  GREEN_0_A
    WRITEPAL_A 2, PURPLE_3_A, PURPLE_2_A, PURPLE_1_A, PURPLE_0_A
    WRITEPAL_A 3, BLUE_3_A,   BLUE_2_A,   BLUE_1_A,   BLUE_0_A
    WRITEPAL_A 4, ORANGE_3_A, ORANGE_2_A, ORANGE_1_A, ORANGE_0_A
    WRITEPAL_A 5, YELLOW_3_A, YELLOW_2_A, YELLOW_1_A, YELLOW_0_A
    WRITEPAL_A 6, CYAN_3_A,   CYAN_2_A,   CYAN_1_A,   CYAN_0_A
    WRITEPAL_A 7, WHITE_A,    GRAY_1_A,   GRAY_0_A,   BLACK_A
    ld a, [wBGMode]
    cp a, BG_MODE_DARK
    jp nz, .postpalettes
    WRITEPAL_B 0, BLACK_A,    RED_2_A,    RED_1_A,    RED_0_A
    WRITEPAL_B 1, BLACK_A,  GREEN_2_A,  GREEN_1_A,  GREEN_0_A
    WRITEPAL_B 2, BLACK_A, PURPLE_2_A, PURPLE_1_A, PURPLE_0_A
    WRITEPAL_B 3, BLACK_A,   BLUE_2_A,   BLUE_1_A,   BLUE_0_A
    WRITEPAL_B 4, BLACK_A, ORANGE_2_A, ORANGE_1_A, ORANGE_0_A
    WRITEPAL_B 5, BLACK_A, YELLOW_2_A, YELLOW_1_A, YELLOW_0_A
    WRITEPAL_B 6, BLACK_A,   CYAN_2_A,   CYAN_1_A,   CYAN_0_A
    WRITEPAL_A 7, BLACK_A,   GRAY_0_A,   GRAY_1_A,    WHITE_A
.postpalettes



    ldh a, [hBState]
    and a, a
    jp z, .skip
    WRITEPAL_B 0, BLACK_C,    RED_2_C,    RED_1_C,    RED_0_C
    WRITEPAL_B 1, BLACK_C,  GREEN_2_C,  GREEN_1_C,  GREEN_0_C
    WRITEPAL_B 2, BLACK_C, PURPLE_2_C, PURPLE_1_C, PURPLE_0_C
    WRITEPAL_B 3, BLACK_C,   BLUE_2_C,   BLUE_1_C,   BLUE_0_C
    WRITEPAL_B 4, BLACK_C, ORANGE_2_C, ORANGE_1_C, ORANGE_0_C
    WRITEPAL_B 5, BLACK_C, YELLOW_2_C, YELLOW_1_C, YELLOW_0_C
    WRITEPAL_B 6, BLACK_C,   CYAN_2_C,   CYAN_1_C,   CYAN_0_C
    WRITEPAL_B 7, BLACK_C,    GRAY_0_C,   GRAY_1_C,   WHITE_C
.skip



    ; Copy the tilemap to shadow.
    ld de, $9800
    ld hl, wShadowTilemap
    ld bc, 32*32
    call UnsafeMemCopy

    ; Set attrs to pal 7 and copy to shadow.
    ld a, 1
    ldh [rVBK], a
    ld d, $07
    ld hl, $9800
    ld bc, (32*32)
    call UnsafeMemSet
    ld de, $9800
    ld hl, wShadowTileAttrs
    ld bc, 32*32
    call UnsafeMemCopy

    ; Reset back to bank 0.
    xor a, a
    ldh [rVBK], a
    ret


    ; Additional GBC effects for the title screen process state.
GBCTitleProcess::
    ld a, [wInitialA]
    cp a, $11
    ret nz

    ; Wipe the palettes.
    ld d, $07
    ld hl, wShadowTileAttrs
    ld bc, (32*32)
    call UnsafeMemSet

    ; Jump to the correct eventloop handler.
    ld b, 0
    ld a, [wTitleMode]
    ld c, a
    ld hl, .jumps
    add hl, bc
    jp hl

.jumps
    jp .eventLoopMain
    jp .eventLoopProfile
    jp .eventLoopSettings
    no_jump
    no_jump

.eventLoopMain
    ld de, sTitleAttrs
    ld hl, wShadowTileAttrs
    ld bc, (5*32)
    call UnsafeMemCopy

    ; And the selected row.
    ld a, [wSelected]
    inc a
    ld hl, wShadowTileAttrs + (5*32)
    ld bc, 32
:   add hl, bc
    dec a
    jr nz, :-
    ld d, 6
    ld bc, 32
    jp UnsafeMemSet

.eventLoopProfile
    ; And the selected row.
    ld a, [wSelected]
    inc a
    ld hl, wShadowTileAttrs + (1*32)
    ld bc, 32
:   add hl, bc
    dec a
    jr nz, :-
    ld d, 6
    ld bc, 32
    jp UnsafeMemSet

.eventLoopSettings
    ; And the selected row.
    ld a, [wSelected]
    inc a
    ld hl, wShadowTileAttrs + (1*32)
    ld bc, 32
:   add hl, bc
    dec a
    jr nz, :-
    ld d, 6
    ld bc, 32
    jp UnsafeMemSet


    ; Additional GBC effects for the gameplay process state.
GBCGameplayProcess::
    ld a, [wInitialA]
    cp a, $11
    ret nz

    ; Color based on mode.
    ld a, [wSpeedCurveState]
    cp a, SCURVE_DMGT
    ld a, $05 ;Blue
    jr z, .goverride
    ld a, [wSpeedCurveState]
    cp a, SCURVE_TGM1
    ld a, $06 ;Cyan
    jr z, .goverride
    ld a, [wSpeedCurveState]
    cp a, SCURVE_TGM3
    ld a, $03 ;Blue
    jr z, .goverride
    ld a, [wSpeedCurveState]
    cp a, SCURVE_DEAT
    xor a, a ;Red
    jr z, .goverride
    ld a, [wSpeedCurveState]
    cp a, SCURVE_SHIR
    xor a, a ;Red
    jr z, .goverride ;Always red
    ld a, [wSpeedCurveState]
    cp a, SCURVE_CHIL
    ld a, $01 ;Green
    jr z, .goverride
    ld a, $02 ;Purple

    ; Are we 20G?
.goverride
    ld d, a
    ldh a, [hCurrentIntegerGravity]
    cp a, 20
    jr c, :+
    xor a, a
    ld d, a
    jr .colorfield
:   cp a, 3
    jr c, :+
    ld a, $04
    ld d, a
    jr .colorfield
:   cp a, 2
    jr c, :+
    ld a, $05
    ld d, a
    jr .colorfield
:   ldh a, [hCurrentFractionalGravity]
    or a, a
    jr nz, .colorfield
    ld a, $05
    ld d, a


.colorfield
    ld a, d
    DEF row = 0
    REPT 21
        ld hl, wShadowTileAttrs + (row*32) + 31
        ld [hl], a
        ld hl, wShadowTileAttrs + (row*32) + 10
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl], a
        DEF row += 1
    ENDR

    ; What to copy
:   ld de, wField + 30
    ; Where to put it
    ld hl, wShadowTilemap
    ; How much to increment hl after each row
    ld bc, 32-10

    ; Blit me up daddy.
    ld a, 21
    ld [wOuterReps], a
.outer1
    ld a, 10
    ld [wInnerReps], a
.inner1
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [wInnerReps]
    dec a
    ld [wInnerReps], a
    jr nz, .inner1

    add hl, bc
    ld a, [wOuterReps]
    dec a
    ld [wOuterReps], a
    jr nz, .outer1


    ; What to copy
    ld de, wField + 30
    ; Where to put it
    ld hl, wShadowTileAttrs
    ; How much to increment hl after each row
    ld bc, 32-10

    ; Blit me up daddy.
    ld a, 21
    ld [wOuterReps], a
.outer2
    ld a, 10
    ld [wInnerReps], a
.inner2
    ld a, [de]
    cp a, TILE_PIECE_0
    jr c, .empty
    cp a, TILE_PIECE_0 + (1*7)
    jr c, .sub10
    cp a, TILE_PIECE_0 + (2*7)
    jr c, .sub17
    cp a, TILE_PIECE_0 + (3*7)
    jr c, .sub24
    cp a, TILE_PIECE_0 + (4*7)
    jr c, .sub31
    cp a, TILE_PIECE_0 + (5*7)
    jr c, .sub38
    cp a, TILE_PIECE_0 + (6*7)
    jr c, .sub45
    cp a, TILE_PIECE_0 + (7*7)
    jr c, .sub52
    cp a, TILE_PIECE_0 + (8*7)
    jr c, .sub59
.empty
    ld a, $07
    jr .done
.sub59
    sub a, 7
.sub52
    sub a, 7
.sub45
    sub a, 7
.sub38
    sub a, 7
.sub31
    sub a, 7
.sub24
    sub a, 7
.sub17
    sub a, 7
.sub10
    sub a, TILE_PIECE_0
.done
    ld [hl+], a
    inc de
    ld a, [wInnerReps]
    dec a
    ld [wInnerReps], a
    jr nz, .inner2

    add hl, bc
    ld a, [wOuterReps]
    dec a
    ld [wOuterReps], a
    jr nz, .outer2

    ; Maybe flash numbers.
    ldh a, [hCurrentIntegerGravity]
    cp a, 20
    jr nz, .black

    ld hl, hFrameCtr
    bit 4, [hl]
    jr z, .lighter

.darker
    ld a, OCPSF_AUTOINC | (7*8)+(3*2)
    ldh [rOCPS], a
    ld bc, GOLD_0_C
    wait_vram
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a
    ret

.lighter
    ld a, OCPSF_AUTOINC | (7*8)+(3*2)
    ldh [rOCPS], a
    ld bc, GOLD_1_C
    wait_vram
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a
    ret

.black
    ld a, [wBGMode]
    cp a, BG_MODE_DARK
    jr z, .white
    ld a, OCPSF_AUTOINC | (7*8)+(3*2)
    ldh [rOCPS], a
    ld bc, BLACK_F_C
    wait_vram
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a
    ret

.white
    ld a, OCPSF_AUTOINC | (7*8)+(3*2)
    ldh [rOCPS], a
    ld bc, WHITE_F_C
    wait_vram
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a
    ret


GBCBigGameplayProcess::
    ld a, [wInitialA]
    cp a, $11
    ret nz

    ; Color based on mode.
    ld a, [wSpeedCurveState]
    cp a, SCURVE_DMGT
    ld a, $05 ;Blue
    jr z, .goverride
    ld a, [wSpeedCurveState]
    cp a, SCURVE_TGM1
    ld a, $06 ;Cyan
    jr z, .goverride
    ld a, [wSpeedCurveState]
    cp a, SCURVE_TGM3
    ld a, $03 ;Blue
    jr z, .goverride
    ld a, [wSpeedCurveState]
    cp a, SCURVE_DEAT
    xor a, a ;Red
    jr z, .goverride
    ld a, [wSpeedCurveState]
    cp a, SCURVE_SHIR
    xor a, a ;Red
    jr z, .goverride ;Always red
    ld a, [wSpeedCurveState]
    cp a, SCURVE_CHIL
    ld a, $01 ;Green
    jr z, .goverride
    ld a, $02 ;Purple

    ; Are we 20G?
.goverride
    ld d, a
    ldh a, [hCurrentIntegerGravity]
    cp a, 20
    jr c, :+
    xor a, a
    ld d, a
    jr .colorfield
:   cp a, 3
    jr c, :+
    ld a, $04
    ld d, a
    jr .colorfield
:   cp a, 2
    jr c, :+
    ld a, $05
    ld d, a
    jr .colorfield
:   ldh a, [hCurrentFractionalGravity]
    or a, a
    jr nz, .colorfield
    ld a, $05
    ld d, a

.colorfield
    ld a, d
    DEF row = 0
    REPT 21
        ld hl, wShadowTileAttrs + (row*32) + 31
        ld [hl], a
        ld hl, wShadowTileAttrs + (row*32) + 10
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl], a
        DEF row += 1
    ENDR


    ; What to copy
:   ld de, wWideBlittedField+10
    ; Where to put it
    ld hl, wShadowTilemap
    ; How much to increment hl after each row
    ld bc, 32-10

    ; Blit me up daddy.
    ld a, 21
    ld [wOuterReps], a
.outer1
    ld a, 10
    ld [wInnerReps], a
.inner1
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [wInnerReps]
    dec a
    ld [wInnerReps], a
    jr nz, .inner1

    add hl, bc
    ld a, [wOuterReps]
    dec a
    ld [wOuterReps], a
    jr nz, .outer1


    ; What to copy
    ld de, wWideBlittedField+10
    ; Where to put it
    ld hl, wShadowTileAttrs
    ; How much to increment hl after each row
    ld bc, 32-10

    ; Blit me up daddy.
    ld a, 21
    ld [wOuterReps], a
.outer2
    ld a, 10
    ld [wInnerReps], a
.inner2
    ld a, [de]
    cp a, TILE_PIECE_0
    jr c, .empty
    cp a, TILE_PIECE_0 + (1*7)
    jr c, .sub10
    cp a, TILE_PIECE_0 + (2*7)
    jr c, .sub17
    cp a, TILE_PIECE_0 + (3*7)
    jr c, .sub24
    cp a, TILE_PIECE_0 + (4*7)
    jr c, .sub31
    cp a, TILE_PIECE_0 + (5*7)
    jr c, .sub38
    cp a, TILE_PIECE_0 + (6*7)
    jr c, .sub45
    cp a, TILE_PIECE_0 + (7*7)
    jr c, .sub52
    cp a, TILE_PIECE_0 + (8*7)
    jr c, .sub59
.empty
    ld a, $07
    jr .done
.sub59
    sub a, 7
.sub52
    sub a, 7
.sub45
    sub a, 7
.sub38
    sub a, 7
.sub31
    sub a, 7
.sub24
    sub a, 7
.sub17
    sub a, 7
.sub10
    sub a, TILE_PIECE_0
.done
    ld [hl+], a
    inc de
    ld a, [wInnerReps]
    dec a
    ld [wInnerReps], a
    jr nz, .inner2

    add hl, bc
    ld a, [wOuterReps]
    dec a
    ld [wOuterReps], a
    jr nz, .outer2

    ; Maybe flash numbers.
    ldh a, [hCurrentIntegerGravity]
    cp a, 20
    jr nz, .black

    ld hl, hFrameCtr
    bit 4, [hl]
    jr z, .lighter

.darker
    ld a, OCPSF_AUTOINC | (7*8)+(3*2)
    ldh [rOCPS], a
    ld bc, GOLD_0_C
    wait_vram
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a
    ret

.lighter
    ld a, OCPSF_AUTOINC | (7*8)+(3*2)
    ldh [rOCPS], a
    ld bc, GOLD_1_C
    wait_vram
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a
    ret

.black
    ld a, [wBGMode]
    cp a, BG_MODE_DARK
    jr z, .white
    ld a, OCPSF_AUTOINC | (7*8)+(3*2)
    ldh [rOCPS], a
    ld bc, BLACK_F_C
    wait_vram
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a
    ret

.white
    ld a, OCPSF_AUTOINC | (7*8)+(3*2)
    ldh [rOCPS], a
    ld bc, WHITE_F_C
    wait_vram
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a
    ret


    ; Copies the shadow tile maps to VRAM using HDMA. The attributes are copied using instant mode
    ; The tile data is done using hblank mode.
GBCBlitField::
ToVRAM::
    ; Bank 1
    ld a, 1
    ldh [rVBK], a
    ld a, HIGH(wShadowTileAttrs)
    ldh [rHDMA1], a
    ld a, LOW(wShadowTileAttrs)
    ldh [rHDMA2], a
    ld a, HIGH($9800)
    ldh [rHDMA3], a
    ld a, LOW($9800)
    ldh [rHDMA4], a
    ld a, 41
    ldh [rHDMA5], a

    ; Bank 0
    xor a, a
    ldh [rVBK], a
    ld a, HIGH(wShadowTilemap)
    ldh [rHDMA1], a
    ld a, LOW(wShadowTilemap)
    ldh [rHDMA2], a
    ld a, HIGH($9800)
    ldh [rHDMA3], a
    ld a, LOW($9800)
    ldh [rHDMA4], a
    ld a, 41 | $80
    ldh [rHDMA5], a
    jp EventLoop


ENDC
