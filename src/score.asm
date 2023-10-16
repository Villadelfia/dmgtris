IF !DEF(SCORE_ASM)
DEF SCORE_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Score Variables", WRAM0
wScore:: ds 6


SECTION "Score Functions", ROM0
ScoreInit::
    xor a, a
    ld hl, wScore
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ret


ENDC
