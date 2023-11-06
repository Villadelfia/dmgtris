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
INCLUDE "rgb555.asm"


; Set up charmap.
CHARMAP " ", 1
CHARMAP "0", 2
CHARMAP "1", 3
CHARMAP "2", 4
CHARMAP "3", 5
CHARMAP "4", 6
CHARMAP "5", 7
CHARMAP "6", 8
CHARMAP "7", 9
CHARMAP "8", 10
CHARMAP "9", 11
CHARMAP "A", 12
CHARMAP "B", 13
CHARMAP "C", 14
CHARMAP "D", 15
CHARMAP "E", 16
CHARMAP "F", 17
CHARMAP "G", 18
CHARMAP "H", 19
CHARMAP "I", 20
CHARMAP "J", 21
CHARMAP "K", 22
CHARMAP "L", 23
CHARMAP "M", 24
CHARMAP "N", 25
CHARMAP "O", 26
CHARMAP "P", 27
CHARMAP "Q", 28
CHARMAP "R", 29
CHARMAP "S", 30
CHARMAP "T", 31
CHARMAP "U", 32
CHARMAP "V", 33
CHARMAP "W", 34
CHARMAP "X", 35
CHARMAP "Y", 36
CHARMAP "Z", 37
CHARMAP "!", 38
CHARMAP "?", 39
CHARMAP "[", 40
CHARMAP "]", 41
CHARMAP "-", 42
CHARMAP "a", 207
CHARMAP "b", 208
CHARMAP "c", 209
CHARMAP "d", 210
CHARMAP "m", 211
CHARMAP ":", 212


; Waits for PPU mode to be 0 or 1.
; We don't wait for 2 because it's super short and impractical to do much of anything in.
MACRO wait_vram
.wvr\@
    ldh a, [rSTAT]
    bit STATB_BUSY, a
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

MACRO no_jump
    nop
    nop
    ret
ENDM


; Writes two bytes to a register pair.
MACRO lb
    ld \1, (LOW(\2) << 8) | LOW(\3)
ENDM


; Bank names
DEF BANK_MAIN           EQU 0
DEF BANK_OTHER          EQU 1
DEF BANK_SFX            EQU 2
DEF BANK_MUSIC          EQU 3
DEF BANK_TITLE          EQU 4
DEF BANK_GAMEPLAY       EQU 5
DEF BANK_GAMEPLAY_BIG   EQU 6

; Some useful palettes.
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

; Sprite base positions.
DEF NEXT_BASE_X         EQU 100
DEF NEXT_BASE_Y         EQU 37
DEF HOLD_BASE_X         EQU 100
DEF HOLD_BASE_Y         EQU 77
DEF QUEUE_BASE_X        EQU 133
DEF QUEUE_BASE_Y        EQU 35
DEF SCORE_BASE_X        EQU 99
DEF SCORE_BASE_Y        EQU 112
DEF LEVEL_BASE_X        EQU 112
DEF CLEVEL_BASE_Y       EQU 133
DEF NLEVEL_BASE_Y       EQU 145
DEF GRADE_BASE_X        EQU 145
DEF GRADE_BASE_Y        EQU 20
DEF TIME_BASE_X         EQU 100
DEF TIME_BASE_Y         EQU 153
DEF TELLS_BASE_X        EQU 154
DEF TELLS_BASE_Y        EQU 61
DEF TELLS_Y_DIST        EQU 10

; Piece names
DEF PIECE_I             EQU 0
DEF PIECE_Z             EQU 1
DEF PIECE_S             EQU 2
DEF PIECE_J             EQU 3
DEF PIECE_L             EQU 4
DEF PIECE_O             EQU 5
DEF PIECE_T             EQU 6

; Sound effect names
DEF SFX_IRS             EQU $80
DEF SFX_IHS             EQU 10
DEF SFX_LINE_CLEAR      EQU 11
DEF SFX_LAND            EQU 12
DEF SFX_LOCK            EQU 13
DEF SFX_LEVELLOCK       EQU 14
DEF SFX_LEVELUP         EQU 15
DEF SFX_RANKUP          EQU 16
DEF SFX_READYGO         EQU 17
DEF SFX_RANKGM          EQU 18
DEF MUSIC_MENU          EQU $EE

; Tile data offsets
; Shared
DEF TILE_BLANK          EQU 1
DEF TILE_0              EQU 2

; Title
DEF TILE_SELECTED       EQU 92
DEF TILE_UNSELECTED     EQU 93

; Gameplay
DEF TILE_FIELD_EMPTY    EQU 108
DEF TILE_PIECE_0        EQU 48
DEF TILE_CLEARING       EQU 106
DEF TILE_GHOST          EQU 107
DEF TILE_PIECE_SMALL_0  EQU 116
DEF TILE_PIECE_BONE     EQU 104
DEF TILE_SMALL_0        EQU 213
DEF TILE_BONE           EQU 104
DEF TILE_QUEUE_BONE     EQU 105
DEF GAME_OVER_R10       EQU 147
DEF GAME_OVER_R12       EQU 167
DEF GAME_OVER_R14       EQU 187
DEF GAME_OVER_OTHER     EQU 145

; Button mode.
DEF BUTTON_MODE_NORM    EQU 0
DEF BUTTON_MODE_INVR    EQU 1
DEF BUTTON_MODE_COUNT   EQU 2

; RNG mode.
DEF TILE_RNG_MODE_BASE  EQU 130
DEF RNG_MODE_TGM1       EQU 0
DEF RNG_MODE_TGM2       EQU 1
DEF RNG_MODE_TGM3       EQU 2
DEF RNG_MODE_HELL       EQU 3
DEF RNG_MODE_NES        EQU 4
DEF RNG_MODE_COUNT      EQU 5

; Rotation mode.
DEF TILE_ROT_MODE_BASE  EQU 135
DEF ROT_MODE_ARS        EQU 0
DEF ROT_MODE_ARSTI      EQU 1
DEF ROT_MODE_NES        EQU 2
DEF ROT_MODE_COUNT      EQU 3

; Drop mode.
DEF TILE_DROP_MODE_BASE EQU 138
DEF DROP_MODE_FIRM      EQU 0
DEF DROP_MODE_SNIC      EQU 1
DEF DROP_MODE_HARD      EQU 2
DEF DROP_MODE_LOCK      EQU 3
DEF DROP_MODE_NONE      EQU 4
DEF DROP_MODE_COUNT     EQU 5

; Speed curve selection.
DEF SCURVE_ENTRY_SIZE   EQU 13
DEF SCURVE_DMGT         EQU 0
DEF SCURVE_TGM1         EQU 1
DEF SCURVE_TGM3         EQU 2
DEF SCURVE_DEAT         EQU 3
DEF SCURVE_SHIR         EQU 4
DEF SCURVE_CHIL         EQU 5
DEF SCURVE_COUNT        EQU 6

; 20G mode.
DEF TILE_HIG_MODE_BASE  EQU 143
DEF HIG_MODE_OFF        EQU 0
DEF HIG_MODE_ON         EQU 1
DEF HIG_MODE_COUNT      EQU 2

; VRAM Offsets for title screen tiles
DEF TITLE_OPTIONS       EQU 7
DEF TITLE_OPTION_0      EQU $9900
DEF TITLE_OPTION_1      EQU $9940
DEF TITLE_OPTION_2      EQU $9980
DEF TITLE_OPTION_3      EQU $99C0
DEF TITLE_OPTION_4      EQU $9A00
DEF TITLE_OPTION_5      EQU $9A40
DEF TITLE_OPTION_6      EQU $9A80
DEF TITLE_OPTION_OFFSET EQU 15

; VRAM Offsets for gameplay tiles
DEF FIELD_RNG           EQU $9852
DEF FIELD_ROT           EQU $9892
DEF FIELD_DROP          EQU $9912
DEF FIELD_HIG           EQU $9952
DEF FIELD_TOP_LEFT      EQU $9800

; Gameplay definitions.
DEF LEADY_TIME          EQU 80
DEF GO_TIME             EQU 40
DEF PIECE_SPAWN_X       EQU 5
DEF PIECE_SPAWN_Y       EQU 3
DEF PIECE_SPAWN_X_BIG   EQU 3
DEF PIECE_SPAWN_Y_BIG   EQU 3
DEF ROTATION_STATE_DEF  EQU 0
DEF ROTATION_STATE_CW   EQU 1
DEF ROTATION_STATE_180  EQU 2
DEF ROTATION_STATE_CCW  EQU 3

; Game states. (Let these increase by 3)
DEF STATE_TITLE         EQU 0
DEF STATE_GAMEPLAY      EQU 3
DEF STATE_GAMEPLAY_BIG  EQU 6

; Other
DEF STACK_SIZE          EQU 64
DEF EASTER_0            EQU $9865
DEF EASTER_1            EQU $9885
DEF SLAM_ANIMATION_LEN  EQU 6

; Magic location for bank id.
DEF rBANKID             EQU $4007

; Grade names.
DEF GRADE_9             EQU 0
DEF GRADE_8             EQU 1
DEF GRADE_7             EQU 2
DEF GRADE_6             EQU 3
DEF GRADE_5             EQU 4
DEF GRADE_4             EQU 5
DEF GRADE_3             EQU 6
DEF GRADE_2             EQU 7
DEF GRADE_1             EQU 8
DEF GRADE_S1            EQU 9
DEF GRADE_S2            EQU 10
DEF GRADE_S3            EQU 11
DEF GRADE_S4            EQU 12
DEF GRADE_S5            EQU 13
DEF GRADE_S6            EQU 14
DEF GRADE_S7            EQU 15
DEF GRADE_S8            EQU 16
DEF GRADE_S9            EQU 17
DEF GRADE_S10           EQU 18
DEF GRADE_S11           EQU 19
DEF GRADE_S12           EQU 20
DEF GRADE_S13           EQU 21
DEF GRADE_M1            EQU 22
DEF GRADE_M2            EQU 23
DEF GRADE_M3            EQU 24
DEF GRADE_M4            EQU 25
DEF GRADE_M5            EQU 26
DEF GRADE_M6            EQU 27
DEF GRADE_M7            EQU 28
DEF GRADE_M8            EQU 29
DEF GRADE_M9            EQU 30
DEF GRADE_M             EQU 31
DEF GRADE_MK            EQU 32
DEF GRADE_MV            EQU 33
DEF GRADE_MO            EQU 34
DEF GRADE_MM            EQU 35
DEF GRADE_GM            EQU 36
DEF GRADE_NONE          EQU 255

; Game mode
DEF MODE_LEADY              EQU 0
DEF MODE_GO                 EQU 3
DEF MODE_POSTGO             EQU 6
DEF MODE_PREFETCHED_PIECE   EQU 9
DEF MODE_SPAWN_PIECE        EQU 12
DEF MODE_PIECE_IN_MOTION    EQU 15
DEF MODE_DELAY              EQU 18
DEF MODE_GAME_OVER          EQU 21
DEF MODE_PRE_GAME_OVER      EQU 24
DEF MODE_PAUSED             EQU 27

; Helpers to avoid magic numbers
DEF SCORE_ONES              EQU 7
DEF SCORE_TENS              EQU 6
DEF SCORE_HUNDREDS          EQU 5
DEF SCORE_THOUSANDS         EQU 4
DEF SCORE_TENTHOUSANDS      EQU 3
DEF SCORE_HUNDREDTHOUSANDS  EQU 2
DEF SCORE_MILLIONS          EQU 1
DEF SCORE_TENMILLIONSS      EQU 0
DEF CLEVEL_THOUSANDS        EQU 0
DEF CLEVEL_HUNDREDS         EQU 1
DEF CLEVEL_TENS             EQU 2
DEF CLEVEL_ONES             EQU 3
DEF NLEVEL_THOUSANDS        EQU 0
DEF NLEVEL_HUNDREDS         EQU 1
DEF NLEVEL_TENS             EQU 2
DEF NLEVEL_ONES             EQU 3


ENDC
