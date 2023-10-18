IF !DEF(RNG_ASM)
DEF RNG_ASM EQU 1


INCLUDE "globals.asm"


SECTION "RNG Variables", WRAM0
wRNGSeed:      ds 4
wPieceHistory: ds 4
wNextPiece::   ds 1


section "RNG Functions", ROM0
RNGInit::
    ; Do some bit fuckery on the seed using the gameboy's free-running timers.
    ld hl, wRNGSeed
    ldh a, [rDIV]
    xor a, [hl]
    ld [hl+], a

    ldh a, [rTIMA]
    xor a, [hl]
    ld [hl+], a

    ldh a, [rDIV]
    xor a, [hl]
    ld [hl+], a

    ldh a, [rTIMA]
    xor a, [hl]
    ld [hl], a

    ; Initialize the next history.
    ld hl, wPieceHistory
    ld a, PIECE_Z
    ld [hl+], a
    ld [hl+], a
    ld a, PIECE_S
    ld [hl+], a
    ld [hl], a

    ; Get the first piece and make sure it's not Z, S or O.
:   call NextPiece
    cp a, PIECE_Z
    jr z, :-
    cp a, PIECE_S
    jr z, :-
    cp a, PIECE_O
    jr z, :-

    ; Store it.
    ld hl, wPieceHistory
    ld [hl], a
    ld hl, wNextPiece
    ld [hl], a
    ret


GetNextPiece::
    ld e, 7
:   dec e
    jr z, :+

    call NextPiece
    ld hl, wPieceHistory
    cp a, [hl]
    jr z, :-
    inc hl
    cp a, [hl]
    jr z, :-
    inc hl
    cp a, [hl]
    jr z, :-
    inc hl
    cp a, [hl]
    jr z, :-

:   ld hl, wNextPiece
    ld [hl], a
    ld b, a
    ld hl, wPieceHistory+2
    ld a, [hl+]
    ld [hl], a
    ld hl, wPieceHistory+1
    ld a, [hl+]
    ld [hl], a
    ld hl, wPieceHistory
    ld a, [hl+]
    ld [hl-], a
    ld a, b
    ld [hl], a
    ret


NextPiece:
    call NextByte
    and a, $07
    cp a, 7
    ret nz
    dec a
    ret

NextByte:
    ; Load seed
    ld hl,wRNGSeed+3
    ld a, [hl-]
    ld b, a
    ld a, [hl-]
    ld c, a
    ld a, [hl-]

    ; Multiply by 0x01010101
    add [hl]
    ld d, a
    adc c
    ld c, a
    adc b
    ld b, a

    ; Add 0x31415927 and write back
    ld a, [hl]
    add $27
    ld [hl+], a
    ld a, d
    adc $59
    ld [hl+], a
    ld a, c
    adc $41
    ld [hl+], a
    ld c, a
    ld a, b
    adc $31
    ld [hl], a
    ret


ENDC
