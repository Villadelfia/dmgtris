IF !DEF(HEADER_ASM)
DEF HEADER_ASM EQU 1


SECTION "Cartridge Header", ROM0[$100]
    nop
    jp Main
    ds $150 - @, 0


ENDC
