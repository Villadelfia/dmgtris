IF !DEF(LEVEL_ASM)
DEF LEVEL_ASM EQU 1


SECTION "Level Variables", WRAM0
wCLevel:: ds 6
wNLevel:: ds 6


SECTION "Level Functions", ROM0
LevelInit::
    xor a, a
    ld hl, wCLevel
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, wNLevel
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ret


ENDC
