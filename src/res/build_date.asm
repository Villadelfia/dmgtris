IF !DEF(BUILD_DATE_ASM)
DEF BUILD_DATE_ASM EQU 1


SECTION "Build date", ROM0

    db "Built "
BuildDate::
    db __ISO_8601_UTC__
    db 0


ENDC
