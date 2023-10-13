IF !DEF(GLOBALS_ASM)
DEF GLOBALS_ASM EQU 1


INCLUDE "vendor/hardware.inc"
INCLUDE "vendor/structs.asm"
INCLUDE "constants.asm"


SECTION "General Game Variables", WRAM0
wLCDCCtr::   db
wEvenFrame:: db
wField::     ds (10*22)


SECTION "Important Game Variables", HRAM
hCtr::    ds 1
hScore::  ds 6
hCLevel:: ds 6
hNLevel:: ds 6


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
    set_bg_palette a
    set_obj0_palette a
    set_obj1_palette a
ENDM


; Writes two bytes to a register pair.
MACRO lb
    ld \1, (LOW(\2) << 8) | LOW(\3)
ENDM


ENDC
