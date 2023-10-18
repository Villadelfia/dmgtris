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

    ; This routine will copy wField onto the screen.
BlitField::
    ; What to copy
    ld de, wField + 10
    ; Where to put it
    ld hl, FIELD_TOP_LEFT
    ; How much to increment hl after each row
    ld bc, 32

    ; The first 14 rows can be blitted without checking for vram access.
    REPT 14
        REPT 10
            ld a, [de]
            ld [hl+], a
            inc de
        ENDR
        add hl, bc
    ENDR

    ; The last 6 rows need some care.
    REPT 6
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
        add hl, bc
    ENDR

    ; This has to finish just before the first LCDC interrupt of the frame or stuff will break in weird ways.
    jp EventLoop


ENDC
