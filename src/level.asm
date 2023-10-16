IF !DEF(LEVEL_ASM)
DEF LEVEL_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Level Variables", WRAM0
wCLevel:: ds 4
wNLevel:: ds 6 ; The extra 2 bytes will be clobbered by the sprite drawing functions.


SECTION "Level Functions", ROM0
LevelInit::
    xor a, a
    ld hl, wCLevel
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, wNLevel
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ret


ENDC
