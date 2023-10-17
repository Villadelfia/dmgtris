IF !DEF(GLOBALS_ASM)
DEF GLOBALS_ASM EQU 1


INCLUDE "hardware.inc"
INCLUDE "structs.asm"


; Waits for VRAM to be safe to access. (Includes hblank.)
MACRO wait_vram
.waitvram\@
    ldh a, [rSTAT]
    and STATF_BUSY
    jr nz, .waitvram\@
ENDM


; Waits for lcd to be in vblank.
MACRO wait_vblank
.waitvb\@
    ldh a, [rSTAT]
    and STATF_LCD
    cp STATF_VBL
    jr nz, .waitvb\@
ENDM


; Waits for lcd to not be in vblank.
MACRO wait_vblank_end
.waitvbe\@
    ldh a, [rSTAT]
    and STATF_LCD
    cp STATF_VBL
    jr z, .waitvbe\@
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
DEF FIELD_TOP_LEFT      EQU $9800+1
DEF TILE_FIELD_EMPTY    EQU 7
DEF TILE_PIECE_0        EQU 10
DEF TILE_0              EQU 100
DEF NEXT_BASE_X         EQU 120
DEF NEXT_BASE_Y         EQU 40
DEF HOLD_BASE_X         EQU 120
DEF HOLD_BASE_Y         EQU 80
DEF SCORE_BASE_X        EQU 112
DEF SCORE_BASE_Y        EQU 115
DEF LEVEL_BASE_X        EQU 120
DEF CLEVEL_BASE_Y       EQU 136
DEF NLEVEL_BASE_Y       EQU 148
DEF SCURVE_N_ENTRIES    EQU 32
DEF SCURVE_ENTRY_SIZE   EQU 8
DEF PIECE_I             EQU 0
DEF PIECE_Z             EQU 1
DEF PIECE_S             EQU 2
DEF PIECE_J             EQU 3
DEF PIECE_L             EQU 4
DEF PIECE_O             EQU 5
DEF PIECE_T             EQU 6
DEF PIECE_NONE          EQU 255
DEF SFX_IRS             EQU 7
DEF SFX_DROP            EQU 8
DEF SFX_LOCK            EQU 9
DEF SFX_BELL            EQU 10
DEF SFX_MOVE            EQU 11


ENDC
