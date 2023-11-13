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


IF !DEF(PROGRESS_ASM)
DEF PROGRESS_ASM EQU 1


INCLUDE "globals.asm"


DEF TILE_BAR_0          EQU 248
DEF TILE_BAR_1          EQU 249
DEF TILE_BAR_2          EQU 250
DEF TILE_BAR_3          EQU 251
DEF TILE_BAR_4          EQU 252


SECTION "Progress Data", ROM0
sProgressData:
    db %00010000, %00110000 ; 0
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011000, %00111000 ; 1
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011100, %00111100 ; 2
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011110, %00111110 ; 3
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 4
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 5
    db %10000000, %10000000
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 6
    db %11000000, %11000000
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 7
    db %11100000, %11100000
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 8
    db %11110000, %11110000
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 9
    db %11111000, %11111000
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 10
    db %11111100, %11111100
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 11
    db %11111110, %11111110
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 12
    db %11111111, %11111111
    db %00000000, %00000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 13
    db %11111111, %11111111
    db %10000000, %10000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 14
    db %11111111, %11111111
    db %11000000, %11000000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 15
    db %11111111, %11111111
    db %11100000, %11100000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 16
    db %11111111, %11111111
    db %11110000, %11110000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 17
    db %11111111, %11111111
    db %11111000, %11111000
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 18
    db %11111111, %11111111
    db %11111100, %11111100
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 19
    db %11111111, %11111111
    db %11111110, %11111110
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 20
    db %11111111, %11111111
    db %11111111, %11111111
    db %00000000, %00000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 21
    db %11111111, %11111111
    db %11111111, %11111111
    db %10000000, %10000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 22
    db %11111111, %11111111
    db %11111111, %11111111
    db %11000000, %11000000
    db %00000000, %00001000

    db %00011111, %00111111 ; 23
    db %11111111, %11111111
    db %11111111, %11111111
    db %11100000, %11100000
    db %00000000, %00001000

    db %00011111, %00111111 ; 24
    db %11111111, %11111111
    db %11111111, %11111111
    db %11110000, %11110000
    db %00000000, %00001000

    db %00011111, %00111111 ; 25
    db %11111111, %11111111
    db %11111111, %11111111
    db %11111000, %11111000
    db %00000000, %00001000

    db %00011111, %00111111 ; 26
    db %11111111, %11111111
    db %11111111, %11111111
    db %11111100, %11111100
    db %00000000, %00001000

    db %00011111, %00111111 ; 27
    db %11111111, %11111111
    db %11111111, %11111111
    db %11111110, %11111110
    db %00000000, %00001000

    db %00011111, %00111111 ; 28
    db %11111111, %11111111
    db %11111111, %11111111
    db %11111111, %11111111
    db %00000000, %00001000

    db %00011111, %00111111 ; 29
    db %11111111, %11111111
    db %11111111, %11111111
    db %11111111, %11111111
    db %10000000, %10001000

    db %00011111, %00111111 ; 30
    db %11111111, %11111111
    db %11111111, %11111111
    db %11111111, %11111111
    db %11000000, %11001000

    db %00011111, %00111111 ; 31
    db %11111111, %11111111
    db %11111111, %11111111
    db %11111111, %11111111
    db %11100000, %11101000

    db %00011111, %00111111 ; 32
    db %11111111, %11111111
    db %11111111, %11111111
    db %11111111, %11111111
    db %11110000, %11111000






SECTION "Progress Variables", WRAM0
wProgress0B1:: ds 1
wProgress0B2:: ds 1
wProgress1B1:: ds 1
wProgress1B2:: ds 1
wProgress2B1:: ds 1
wProgress2B2:: ds 1
wProgress3B1:: ds 1
wProgress3B2:: ds 1
wProgress4B1:: ds 1
wProgress4B2:: ds 1


SECTION "Progress Functions", ROM0

    ; Changes the tiles between the level counters to show some progress.
    ; Progress in A, 0-32.
SetProgress::
    ld hl, sProgressData
    or a, a
    jr z, .correct
    ld b, a
    ld de, 10
.loop
    add hl, de
    dec b
    jr nz, .loop

.correct
    ld de, wProgress0B1
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, [hl+]
    ld [de], a

    ld hl, _VRAM + (TILE_BAR_0*16) + (3*2)
    ld a, [wProgress0B1]
    ld b, a
    wait_vram
    ld [hl], b
    inc hl
    ld a, [wProgress0B2]
    ld b, a
    wait_vram
    ld [hl], b

    ld hl, _VRAM + (TILE_BAR_1*16) + (3*2)
    ld a, [wProgress1B1]
    ld b, a
    wait_vram
    ld [hl], b
    inc hl
    ld a, [wProgress1B2]
    ld b, a
    wait_vram
    ld [hl], b

    ld hl, _VRAM + (TILE_BAR_2*16) + (3*2)
    ld a, [wProgress2B1]
    ld b, a
    wait_vram
    ld [hl], b
    inc hl
    ld a, [wProgress2B2]
    ld b, a
    wait_vram
    ld [hl], b

    ld hl, _VRAM + (TILE_BAR_3*16) + (3*2)
    ld a, [wProgress3B1]
    ld b, a
    wait_vram
    ld [hl], b
    inc hl
    ld a, [wProgress3B2]
    ld b, a
    wait_vram
    ld [hl], b

    ld hl, _VRAM + (TILE_BAR_4*16) + (3*2)
    ld a, [wProgress4B1]
    ld b, a
    wait_vram
    ld [hl], b
    inc hl
    ld a, [wProgress4B2]
    ld b, a
    wait_vram
    ld [hl], b

    ret





ENDC
