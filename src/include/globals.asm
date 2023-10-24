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


IF !DEF(GLOBALS_ASM)
DEF GLOBALS_ASM EQU 1


INCLUDE "hardware.inc"
INCLUDE "structs.asm"


; PPU modes:
; - 0: HBlank
; - 1: VBlank
; - 2: OAM Scan
; - 3: Drawing


; Waits for PPU mode to be 0 or 1.
; We don't wait for 2 because it's super short and impractical to do much of anything in.
MACRO wait_vram
    ld hl, rSTAT
.wvr\@
    bit 1, [hl]
    jr nz, .wvr\@
ENDM


; Waits for PPU mode to be at the start of mode 1.
; We do this by checking for scanline 144.
MACRO wait_vblank
    ld b, 144
.wvb\@
    ldh a, [rLY]
    cp a, b
    jr nz, .wvb\@
ENDM


; Waits for PPU mode to be at the end of mode 1.
; We do this by checking for scanline 0.
MACRO wait_vblank_end
    ld b, 0
.wvbe\@
    ldh a, [rLY]
    cp a, b
    jr nz, .wvbe\@
ENDM


; Sets the background palette to A.
MACRO set_bg_palette
    ldh [rBGP], a
ENDM


; Sets the object0 palette to A.
MACRO set_obj0_palette
    ldh [rOBP0], a
ENDM


; Sets the object1 palette to A.
MACRO set_obj1_palette
    ldh [rOBP1], a
ENDM


; Sets all palettes to A.
MACRO set_all_palettes
    set_bg_palette
    set_obj0_palette
    set_obj1_palette
ENDM


; Writes two bytes to a register pair.
MACRO lb
    ld \1, (LOW(\2) << 8) | LOW(\3)
ENDM


DEF PALETTE_REGULAR     EQU %11100100
DEF PALETTE_INVERTED    EQU %00011011
DEF PALETTE_MONO_0      EQU %11111111
DEF PALETTE_MONO_1      EQU %10101010
DEF PALETTE_MONO_2      EQU %01010101
DEF PALETTE_MONO_3      EQU %00000000
DEF PALETTE_DARKER_0    EQU %11100100
DEF PALETTE_DARKER_1    EQU %11111001
DEF PALETTE_DARKER_2    EQU %11111110
DEF PALETTE_DARKER_3    EQU %11111111
DEF PALETTE_LIGHTER_0   EQU %11100100
DEF PALETTE_LIGHTER_1   EQU %10010000
DEF PALETTE_LIGHTER_2   EQU %01000000
DEF PALETTE_LIGHTER_3   EQU %00000000

DEF NEXT_BASE_X         EQU 115
DEF NEXT_BASE_Y         EQU 40
DEF HOLD_BASE_X         EQU 115
DEF HOLD_BASE_Y         EQU 80
DEF SCORE_BASE_X        EQU 112
DEF SCORE_BASE_Y        EQU 115
DEF LEVEL_BASE_X        EQU 120
DEF CLEVEL_BASE_Y       EQU 136
DEF NLEVEL_BASE_Y       EQU 148

DEF SCURVE_ENTRY_SIZE   EQU 8

DEF PIECE_I             EQU 0
DEF PIECE_Z             EQU 1
DEF PIECE_S             EQU 2
DEF PIECE_J             EQU 3
DEF PIECE_L             EQU 4
DEF PIECE_O             EQU 5
DEF PIECE_T             EQU 6
DEF PIECE_NONE          EQU 255

DEF SFX_IRS             EQU $80
DEF SFX_IHS             EQU 10
DEF SFX_LINE_CLEAR      EQU 11
DEF SFX_LAND            EQU 12
DEF SFX_LOCK            EQU 13
DEF SFX_LEVELLOCK       EQU 14
DEF SFX_LEVELUP         EQU 15
DEF SFX_RANKUP          EQU 16
DEF SFX_READYGO         EQU 17

DEF STACK_SIZE          EQU 64
DEF GAME_OVER_R10       EQU 133
DEF GAME_OVER_R12       EQU 153
DEF GAME_OVER_R14       EQU 173
DEF GAME_OVER_OTHER     EQU 131
DEF LEADY_TIME          EQU 80
DEF GO_TIME             EQU 40

DEF BUTTON_MODE_NORM    EQU 0
DEF BUTTON_MODE_INVR    EQU 1
DEF BUTTON_MODE_COUNT   EQU 2

DEF TILE_RNG_MODE_BASE  EQU 217
DEF RNG_MODE_TGM1       EQU 0
DEF RNG_MODE_TGM2       EQU 1
DEF RNG_MODE_TGM3       EQU 2
DEF RNG_MODE_HELL       EQU 3
DEF RNG_MODE_NES        EQU 4
DEF RNG_MODE_COUNT      EQU 5

DEF TILE_ROT_MODE_BASE  EQU 225
DEF ROT_MODE_ARS        EQU 0
DEF ROT_MODE_ARSTI      EQU 1
DEF ROT_MODE_COUNT      EQU 2

DEF TILE_DROP_MODE_BASE EQU 229
DEF DROP_MODE_SONIC     EQU 0
DEF DROP_MODE_HARD      EQU 1
DEF DROP_MODE_NONE      EQU 2
DEF DROP_MODE_COUNT     EQU 3

DEF SCURVE_DMGT         EQU 0
DEF SCURVE_TGM1         EQU 1
DEF SCURVE_TGM3         EQU 2
DEF SCURVE_DEAT         EQU 3
DEF SCURVE_SHIR         EQU 4
DEF SCURVE_CHIL         EQU 5
DEF SCURVE_COUNT        EQU 6

DEF TILE_HIG_MODE_BASE  EQU 232
DEF HIG_MODE_OFF        EQU 0
DEF HIG_MODE_ON         EQU 1
DEF HIG_MODE_COUNT      EQU 2

DEF TILE_FIELD_EMPTY    EQU 4
DEF TILE_PIECE_0        EQU 10
DEF TILE_0              EQU 66
DEF TILE_CLEARING       EQU 124
DEF TILE_GHOST          EQU 125
DEF TILE_SELECTED       EQU 193
DEF TILE_UNSELECTED     EQU 194

DEF TITLE_OPTIONS       EQU 7
DEF TITLE_OPTION_0      EQU $98E0
DEF TITLE_OPTION_1      EQU $9920
DEF TITLE_OPTION_2      EQU $9960
DEF TITLE_OPTION_3      EQU $99A0
DEF TITLE_OPTION_4      EQU $99E0
DEF TITLE_OPTION_5      EQU $9A20
DEF TITLE_OPTION_6      EQU $9A60
DEF TITLE_OPTION_OFFSET EQU 15

DEF FIELD_RNG           EQU $9852
DEF FIELD_ROT           EQU $9892
DEF FIELD_DROP          EQU $9912
DEF FIELD_HIG           EQU $9952
DEF FIELD_TOP_LEFT      EQU $9800+1

DEF EASTER_0            EQU $9845
DEF EASTER_1            EQU $9865


ENDC
