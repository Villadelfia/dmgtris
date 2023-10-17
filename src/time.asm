IF !DEF(TIME_ASM)
DEF TIME_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Time Variables", HRAM
hFrameCtr::  ds 1
hEvenFrame:: ds 1


SECTION "Time Functions", ROM0
TimeInit::
    xor a, a
    ldh [hEvenFrame], a
    ldh [hFrameCtr], a
    ret

HandleTimers::
    ldh a, [hFrameCtr]
    inc a
    ldh [hFrameCtr], a
    and 1
    ldh [hEvenFrame], a
    ret


ENDC
