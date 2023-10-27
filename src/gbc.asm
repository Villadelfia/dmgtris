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

DEF B0 EQU %0010000000000000
DEF B1 EQU %0100000000000000
DEF B2 EQU %0101000000000000
DEF B3 EQU %0111110000000000
DEF G0 EQU %0000000100000000
DEF G1 EQU %0000001000000000
DEF G2 EQU %0000001010000000
DEF G3 EQU %0000001111100000
DEF R0 EQU %0000000000001000
DEF R1 EQU %0000000000010000
DEF R2 EQU %0000000000010100
DEF R3 EQU %0000000000011111


SECTION "GBC Shadow Tilemap", WRAM0, ALIGN[8]
wShadowTilemap:: ds 32*32

SECTION "GBC Shadow Tile Attributes", WRAM0, ALIGN[8]
wShadowTileAttrs:: ds 32*32

SECTION "GBC Variables", WRAM0
wOuterReps:: ds 1
wInnerReps:: ds 1
wTitlePal:: ds 1


SECTION "GBC Functions", ROM0
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
    ld a, 40
    ldh [rHDMA5], a
    ld a, 0
    ldh [rVBK], a
    ret


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
    ld a, 40
    ldh [rHDMA5], a


    ; Bank 0
    ld a, 0
    ldh [rVBK], a
    ld a, HIGH(wShadowTilemap)
    ldh [rHDMA1], a
    ld a, LOW(wShadowTilemap)
    ldh [rHDMA2], a
    ld a, HIGH($9800)
    ldh [rHDMA3], a
    ld a, LOW($9800)
    ldh [rHDMA4], a
    ld a, 39 | $80
    ldh [rHDMA5], a
    jp EventLoop


GBCTitleInit::
    ld a, [wInitialA]
    cp a, $11
    ret nz
    ld a, BCPSF_AUTOINC
    ldh [rBCPS], a
    ldh [rOCPS], a

    ; Pal 0 (red, I)
    ld bc, %0000000000000000
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, R1
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, R2
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, R3
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Pal 1 (green, Z)
    ld bc, %0000000000000000
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, G1
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, G2
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, G3
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Pal 2 (purple, S)
    ld bc, %0000000000000000
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, R1 | B1
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, R2 | B2
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, R3 | B3
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Pal 3 (blue, J)
    ld bc, %0000000000000000
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, B1
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, B2
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, B3
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Pal 4 (orange, L)
    ld bc, %0000000000000000
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, R1 | G0
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, R2 | G1
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, R3 | G2
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Pal 5 (yellow, O)
    ld bc, %0000000000000000
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, R1 | G1
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, R2 | G2
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, R3 | G3
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Pal 6 (cyan, T)
    ld bc, %0000000000000000
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, B1 | G1
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, B2 | G2
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, B3 | G3
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Pal 7 (grayscale, inverted)
    ld bc, %0000000000000000
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, %0010000100001000
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, %0100001000010000
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, %0111111111111111
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Copy the tilemap to shadow.
    ld de, $9800
    ld hl, wShadowTilemap
    ld bc, 32*32
    call UnsafeMemCopy

    ; Set attrs to pal 7 and copy to shadow.
    ld a, 1
    ldh [rVBK], a
    ld d, $03
    ld hl, $9800
    ld bc, 32
    call UnsafeMemSet
    ld d, $01
    ld bc, (5*32)
    call UnsafeMemSet
    ld d, $07
    ld bc, (14*32)
    call UnsafeMemSet
    ld de, $9800
    ld hl, wShadowTileAttrs
    ld bc, 32*32
    call UnsafeMemCopy

    ; Reset back to bank 0.
    xor a, a
    ldh [rVBK], a

    ; Save the current title palette.
    ld a, $07
    ld [wTitlePal], a
    ret


GBCGameplayInit::
    ld a, [wInitialA]
    cp a, $11
    ret nz
    ld a, BCPSF_AUTOINC
    ldh [rBCPS], a
    ldh [rOCPS], a

    ; Pal 0 (red, I)
    ld bc, R3
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, R2
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, R1
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, R0
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Pal 1 (green, Z)
    ld bc, G3
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, G2
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, G1
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, G0
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Pal 2 (purple, S)
    ld bc, R2 | B3
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, R1 | B2
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, R0 | B1
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, B0 | %0000000000000010
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Pal 3 (blue, J)
    ld bc, B3
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, B2
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, B1
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, B0
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Pal 4 (orange, L)
    ld bc, R3 | G2
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, R2 | G1
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, R1 | G0
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, R0
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Pal 5 (yellow, O)
    ld bc, R3 | G3
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, R2 | G2
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, R1 | G1
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, R0 | G0
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Pal 6 (cyan, T)
    ld bc, B3 | G3
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, B2 | G2
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, B1 | G1
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ld bc, B0 | G0
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Pal 7 (grayscale)
    ld bc, %0111111111111111
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, %0100001000010000
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, %0010000100001000
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld bc, %0000000000000000
    ld a, b
    ldh [rBCPD], a
    ldh [rOCPD], a
    ld a, c
    ldh [rBCPD], a
    ldh [rOCPD], a

    ; Copy the tilemap to shadow.
    ld de, $9800
    ld hl, wShadowTilemap
    ld bc, 32*32
    call UnsafeMemCopy

    ; Copy set attrs to pal 7 and copy to shadow.
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


GBCTitleProcess::
    ld a, [wInitialA]
    cp a, $11
    ret nz

    ; Wipe the palettes.
    ld d, $03
    ld hl, wShadowTileAttrs
    ld bc, 32
    call UnsafeMemSet
    ld d, $07
    ld hl, wShadowTileAttrs+32
    ld bc, (19*32)
    call UnsafeMemSet

    ; Palette for the title?
    ldh a, [hFrameCtr]
    and $0F
    cp a, $01
    jr nz, .noinc
    ld a, [wTitlePal]
    inc a
    cp a, $07
    jr c, .nores
    ld a, $00
.nores
    ld [wTitlePal], a
.noinc

    ; Set the palette for the title.
    ld a, [wTitlePal]
    ld d, a
    ld hl, wShadowTileAttrs + (2*32)
    ld bc, (4*32)
    call UnsafeMemSet

    ; And the selected row.
    ld a, [wSelected]
    inc a
    ld hl, wShadowTileAttrs + (5*32)
    ld bc, 64
:   add hl, bc
    dec a
    jr nz, :-
    ld a, 3
    ld d, a
    ld bc, 32
    call UnsafeMemSet
    ret


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
    ld a, $00 ;Red
    jr z, .goverride
    ld a, [wSpeedCurveState]
    cp a, SCURVE_SHIR
    ld a, $00 ;Red
    jr z, .goverride ;Always red
    ld a, [wSpeedCurveState]
    cp a, SCURVE_CHIL
    ld a, $01 ;Green

    ; Are we 20G?
.goverride
    ld d, a
    ldh a, [hCurrentIntegerGravity]
    cp a, 20
    jr c, :+
    ld a, $00
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
    cp a, 0
    jr nz, .colorfield
    ld a, $05
    ld d, a

.colorfield
    ld hl, wShadowTileAttrs
    ld bc, 32-12

    ld a, 21
    ld [wOuterReps], a
.outer0
    ld a, 12
    ld [wInnerReps], a
.inner0
    ld [hl], d
    inc hl
    ld a, [wInnerReps]
    dec a
    ld [wInnerReps], a
    jr nz, .inner0

    add hl, bc
    ld a, [wOuterReps]
    dec a
    ld [wOuterReps], a
    jr nz, .outer0


    ; What to copy
:   ld de, wField + 40
    ; Where to put it
    ld hl, wShadowTilemap + 1
    ; How much to increment hl after each row
    ld bc, 32-10

    ; Blit me up daddy.
    ld a, 20
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
    ld de, wField + 40
    ; Where to put it
    ld hl, wShadowTileAttrs + 1
    ; How much to increment hl after each row
    ld bc, 32-10

    ; Blit me up daddy.
    ld a, 20
    ld [wOuterReps], a
.outer2
    ld a, 10
    ld [wInnerReps], a
.inner2
    ld a, [de]
    cp a, 10
    jr c, .empty
    cp a, 10 + (1*7)
    jr c, .sub10
    cp a, 10 + (2*7)
    jr c, .sub17
    cp a, 10 + (3*7)
    jr c, .sub24
    cp a, 10 + (4*7)
    jr c, .sub31
    cp a, 10 + (5*7)
    jr c, .sub38
    cp a, 10 + (6*7)
    jr c, .sub45
    cp a, 10 + (7*7)
    jr c, .sub52
    cp a, 10 + (8*7)
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
    sub a, 10
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
    ld bc, R1 | G1
    wait_vram
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a
    ret

.lighter
    ld a, OCPSF_AUTOINC | (7*8)+(3*2)
    ldh [rOCPS], a
    ld bc, R2 | G2
    wait_vram
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a
    ret

.black
    ld a, OCPSF_AUTOINC | (7*8)+(3*2)
    ldh [rOCPS], a
    ld bc, R2 | B0
    wait_vram
    ld a, c
    ldh [rOCPD], a
    ld a, b
    ldh [rOCPD], a
    ret


GBCBlitField::
    jp ToVRAM


ENDC
