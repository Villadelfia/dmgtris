; *****************************************************************************
; *                                                                           *
; *  Libraries and Defines                                                    *
; *                                                                           *
; *****************************************************************************
INCLUDE "hardware.inc"
INCLUDE "structs.asm"

; *****************************************************************************
; *                                                                           *
; *  Game Variables                                                           *
; *                                                                           *
; *****************************************************************************
SECTION "General Game Variables", WRAM0
wLCDCCtr:: db
wEvenFrame:: db
wField:: ds 200
wRNGSeed:: ds 4
wFill:: db

SECTION "Important Game Variables", HRAM
hUnused:: ds 126


; *****************************************************************************
; *                                                                           *
; *  Convenience Defines                                                      *
; *                                                                           *
; *****************************************************************************
DEF PALETTE_REGULAR   EQU %11100100
DEF PALETTE_INVERTED  EQU %00011011
DEF PALETTE_MONO_0    EQU %11111111
DEF PALETTE_MONO_1    EQU %10101010
DEF PALETTE_MONO_2    EQU %01010101
DEF PALETTE_MONO_3    EQU %00000000
DEF PALETTE_DARKER_0  EQU %11100100
DEF PALETTE_DARKER_1  EQU %11111001
DEF PALETTE_DARKER_2  EQU %11111110
DEF PALETTE_DARKER_3  EQU %11111111
DEF PALETTE_LIGHTER_0 EQU %11100100
DEF PALETTE_LIGHTER_1 EQU %10010000
DEF PALETTE_LIGHTER_2 EQU %01000000
DEF PALETTE_LIGHTER_3 EQU %00000000
DEF FIELD_ROW_1       EQU $9800+(0*32)+1
DEF FIELD_ROW_2       EQU $9800+(1*32)+1
DEF FIELD_ROW_3       EQU $9800+(2*32)+1
DEF FIELD_ROW_4       EQU $9800+(3*32)+1
DEF FIELD_ROW_5       EQU $9800+(4*32)+1
DEF FIELD_ROW_6       EQU $9800+(5*32)+1
DEF FIELD_ROW_7       EQU $9800+(6*32)+1
DEF FIELD_ROW_8       EQU $9800+(7*32)+1
DEF FIELD_ROW_9       EQU $9800+(8*32)+1
DEF FIELD_ROW_10      EQU $9800+(9*32)+1
DEF FIELD_ROW_11      EQU $9800+(10*32)+1
DEF FIELD_ROW_12      EQU $9800+(11*32)+1
DEF FIELD_ROW_13      EQU $9800+(12*32)+1
DEF FIELD_ROW_14      EQU $9800+(13*32)+1
DEF FIELD_ROW_15      EQU $9800+(14*32)+1
DEF FIELD_ROW_16      EQU $9800+(15*32)+1
DEF FIELD_ROW_17      EQU $9800+(16*32)+1
DEF FIELD_ROW_18      EQU $9800+(17*32)+1
DEF FIELD_ROW_19      EQU $9800+(18*32)+1
DEF FIELD_ROW_20      EQU $9800+(19*32)+1


; *****************************************************************************
; *                                                                           *
; *  Convenience Macros                                                       *
; *                                                                           *
; *****************************************************************************
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

; Writes two bytes to a register pair.
MACRO lb
    ld \1, (LOW(\2) << 8) | LOW(\3)
ENDM
