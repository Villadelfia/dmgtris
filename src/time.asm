IF !DEF(TIME_ASM)
DEF TIME_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Time Variables", HRAM
hEvenFrame:: ds 1


SECTION "Time Functions", ROM0
TimeInit::
    xor a, a
    ldh [hEvenFrame], a
    ret

HandleTimers::
    ldh a, [hEvenFrame]
    inc a
    and 1
    ldh [hEvenFrame], a
    ret


ENDC
