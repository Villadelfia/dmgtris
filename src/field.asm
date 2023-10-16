IF !DEF(FIELD_ASM)
DEF FIELD_ASM EQU 1


INCLUDE "globals.asm"


SECTION "Field Variables", WRAM0
wField:: ds (10*21)


SECTION "Field Functions", ROM0
FieldInit::
    ld hl, wField
    ld bc, 10*21
    ld d, 1
    call UnsafeMemSet
    ret


FieldClear::
    ld hl, wField
    ld bc, 10*21
    ld d, TILE_FIELD_EMPTY
    call UnsafeMemSet
    ret


BlitField::
    ; The first 14 rows can be blitted without checking for vram access.
    ld de, wField + 10
    DEF row = 0
    REPT 14
        ld hl, FIELD_TOP_LEFT+(32*row)
        REPT 10
            ld a, [de]
            ld [hl+], a
            inc de
        ENDR
        DEF row += 1
    ENDR

    ; The last 6 rows need some care.
    REPT 6
        ld hl, FIELD_TOP_LEFT+(32*row)
        REPT 2
:           ldh a, [rSTAT]
            and STATF_LCD
            cp STATF_HBL
            jr z, :-
:           ldh a, [rSTAT]
            and STATF_LCD
            cp STATF_HBL
            jr nz, :-
            REPT 5
                ld a, [de]
                ld [hl+], a
                inc de
            ENDR
        ENDR
        DEF row += 1
    ENDR

    ; This has to finish just before the first LCDC interrupt of the frame or stuff will break in weird ways.
    ret


ENDC
