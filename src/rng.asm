; DMGTRIS
; Copyright (C) 2023 - Randy Thiemann <randy.thiemann@gmail.com>

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.


IF !DEF(RNG_ASM)
DEF RNG_ASM EQU 1


INCLUDE "globals.asm"


SECTION "High RNG Variables", HRAM
hRNGSeed:      ds 4
hPieceHistory: ds 4
hNextPiece::   ds 1
hUpcomingPiece1:: ds 1
hUpcomingPiece2:: ds 1


SECTION "TGM3 RNG Variables", WRAM0
wTGM3Bag:             ds 35
wTGM3Droughts:        ds 7
wTGM3GeneratedIdx:    ds 1
wTGM3WorstDroughtIdx: ds 1


section "RNG Functions", ROM0
HarvestEntropy::
    ld hl, $C000
    ld de, $E000
.loop
    ldh a, [hRNGSeed]
    xor a, [hl]
    inc hl
    ldh [hRNGSeed], a

    ldh a, [hRNGSeed+1]
    xor a, [hl]
    inc hl
    ldh [hRNGSeed+1], a

    ldh a, [hRNGSeed+2]
    xor a, [hl]
    inc hl
    ldh [hRNGSeed+2], a

    ldh a, [hRNGSeed+3]
    xor a, [hl]
    inc hl
    ldh [hRNGSeed+3], a

    ld a, h
    cp a, d
    jr nz, .loop

    ld a, l
    cp a, e
    jr nz, .loop

    ret

    ; Snapshots the initial seed for a game, then initializes the history and piece queue.
RNGInit::
    ; Do some bit fuckery on the seed using the gameboy's free-running timers.
    ld hl, rDIV
    ldh a, [hRNGSeed]
    xor a, [hl]
    ldh [hRNGSeed], a
    ldh a, [hRNGSeed+2]
    xor a, [hl]
    ldh [hRNGSeed+2], a

    ld hl, rTIMA
    ldh a, [hRNGSeed+1]
    xor a, [hl]
    ldh [hRNGSeed+1], a
    ldh a, [hRNGSeed+3]
    xor a, [hl]
    ldh [hRNGSeed+3], a

    ; TGM3 vars
    ld b, BANK_GAMEPLAY
    rst RSTSwitchBank
    ld de, sTGM3Bag
    ld hl, wTGM3Bag
    ld bc, 35
    call UnsafeMemCopy
    ld de, sTGM3Droughts
    ld hl, wTGM3Droughts
    ld bc, 7
    call UnsafeMemCopy
    rst RSTRestoreBank

    ; Start with a random non-S/Z piece held.
:   call Next7Piece
    cp a, PIECE_Z
    jr z, :-
    cp a, PIECE_S
    jr z, :-
    ldh [hHeldPiece], a

    ; If we're in HELL mode, we don't care about anything but a random piece to start with.
    ld a, [wRNGModeState]
    cp a, RNG_MODE_HELL
    jr nz, .complexinit
    call Next7Piece
    ld [hUpcomingPiece2], a
    call Next7Piece
    ld [hUpcomingPiece1], a
    call Next7Piece
    ld [hNextPiece], a
    xor a, a
    ldh [hPieceHistory], a
    ldh [hPieceHistory+1], a
    ldh [hPieceHistory+2], a
    ldh [hPieceHistory+3], a
    ret

    ; Otherwise do complex init.
.complexinit
    ld a, PIECE_Z
    ldh [hPieceHistory], a
    ldh [hPieceHistory+1], a
    ldh [hPieceHistory+2], a
    ldh [hPieceHistory+3], a

    ld a, [wRNGModeState]
    cp a, RNG_MODE_TGM1
    jr z, :+
    ld a, PIECE_S
    ldh [hPieceHistory+2], a
    ldh [hPieceHistory+3], a

    ; Get the first piece and make sure it's not Z, S or O.
:   call Next7Piece
    cp a, PIECE_Z
    jr z, :-
    cp a, PIECE_S
    jr z, :-
    cp a, PIECE_O
    jr z, :-

    ; Save the generated piece and put it in the history.
    ldh [hPieceHistory], a
    ldh [hUpcomingPiece1], a
    ldh [hUpcomingPiece2], a

    ; Generate the next 2 to fill up the queue.
    call GetNextPiece
    jp GetNextPiece


    ; Shift the generated piece into the history and save it.
ShiftHistory:
    ld b, a
    ldh a, [hUpcomingPiece1]
    ldh [hNextPiece], a
    ldh a, [hUpcomingPiece2]
    ldh [hUpcomingPiece1], a
    ld a, b

    ldh [hUpcomingPiece2], a
    ldh a, [hPieceHistory+2]
    ldh [hPieceHistory+3], a
    ldh a, [hPieceHistory+1]
    ldh [hPieceHistory+2], a
    ldh a, [hPieceHistory]
    ldh [hPieceHistory+1], a
    ldh a, [hUpcomingPiece2]
    ldh [hPieceHistory], a
    ret


    ; A random piece. Get fucked.
GetNextHellPiece:
    call Next7Piece
    jr ShiftHistory


    ; 4 history, 4 rerolls.
GetNextTGM1Piece:
    ld a, 5
    ld e, a

:   dec e
    jr z, :+

    call Next7Piece
    ld hl, hPieceHistory
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

:   jr ShiftHistory


    ; 4 history, 6 rerolls.
GetNextTGM2Piece:
    ld a, 7
    ld e, a

:   dec e
    jr z, :+

    call Next7Piece
    ld hl, hPieceHistory
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

:   jr ShiftHistory


    ; 1 history, 1 reroll.
GetNextNesPiece:
    call Next7Piece
    ld hl, hPieceHistory
    cp a, [hl]
    jr nz, ShiftHistory
    call Next7Piece
    jr ShiftHistory


    ; TGM3 mode... It's complex.
GetNextTGM3Piece:
    ld a, 7
    ld e, a

:   dec e
    jr z, :+

    ; Get a random index into the 35bag
    call Next35Piece
    ld [wTGM3GeneratedIdx], a

    ; Fetch the piece from the 35bag.
    ld c, a
    xor a, a
    ld b, a
    ld hl, wTGM3Bag
    add hl, bc
    ld a, [hl]

    ; Is it in the history?
    ld hl, hPieceHistory
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

    ; We have a piece. Save it.
:   call ShiftHistory

    ; Increment all drought counters.
:   ld hl, wTGM3Droughts
    inc [hl]
    inc hl
    inc [hl]
    inc hl
    inc [hl]
    inc hl
    inc [hl]
    inc hl
    inc [hl]
    inc hl
    inc [hl]
    inc hl
    inc [hl]

    ; Set the drought of our most recently drawn piece to 0.
:   ldh a, [hUpcomingPiece2]
    ld c, a
    xor a, a
    ld b, a
    ld hl, wTGM3Droughts
    add hl, bc
    ld [hl], a

    ; We pick an arbitrary piece to have the worst drought.
:   call Next7Piece
    ld [wTGM3WorstDroughtIdx], a

    ; And then save that drought in e.
    ld c, a
    xor a, a
    ld b, a
    ld hl, wTGM3Droughts
    add hl, bc
    ld e, [hl]

    ; Is idx 0 worse?
:   ld hl, wTGM3Droughts
    ld a, [hl+]
    cp a, e
    jr z, :+    ; Same.
    jr c, :+    ; Nope.
    ld e, a
    ld a, 0
    ld [wTGM3WorstDroughtIdx], a

    ; Is idx 1 worse?
:   ld a, [hl+]
    cp a, e
    jr z, :+    ; Same.
    jr c, :+    ; Nope.
    ld e, a
    ld a, 1
    ld [wTGM3WorstDroughtIdx], a

    ; Is idx 2 worse?
:   ld a, [hl+]
    cp a, e
    jr z, :+    ; Same.
    jr c, :+    ; Nope.
    ld e, a
    ld a, 2
    ld [wTGM3WorstDroughtIdx], a

    ; Is idx 3 worse?
:   ld a, [hl+]
    cp a, e
    jr z, :+    ; Same.
    jr c, :+    ; Nope.
    ld e, a
    ld a, 3
    ld [wTGM3WorstDroughtIdx], a

    ; Is idx 4 worse?
:   ld a, [hl+]
    cp a, e
    jr z, :+    ; Same.
    jr c, :+    ; Nope.
    ld e, a
    ld a, 4
    ld [wTGM3WorstDroughtIdx], a

    ; Is idx 5 worse?
:   ld a, [hl+]
    cp a, e
    jr z, :+    ; Same.
    jr c, :+    ; Nope.
    ld e, a
    ld a, 5
    ld [wTGM3WorstDroughtIdx], a

    ; Is idx 6 worse?
:   ld a, [hl+]
    cp a, e
    jr z, :+    ; Same.
    jr c, :+    ; Nope.
    ld e, a
    ld a, 6
    ld [wTGM3WorstDroughtIdx], a

    ; We now have the worst drought index as well as the slot in the bag that needs to be replaced.
:   ld a, [wTGM3GeneratedIdx]
    ld c, a
    xor a, a
    ld b, a
    ld hl, wTGM3Bag
    add hl, bc
    ld a, [wTGM3WorstDroughtIdx]

    ; Replace that slot.
    ld [hl], a
    ret

    ; Gets the next piece depending on RNG mode.
GetNextPiece::
    ld hl, .nextpiecejumps
    ld a, [wRNGModeState]
    ld b, 0
    ld c, a
    add a, c
    add a, c
    ld c, a
    add hl, bc
    jp hl

.nextpiecejumps
    jp GetNextTGM1Piece
    jp GetNextTGM2Piece
    jp GetNextTGM3Piece
    jp GetNextHellPiece
    jp GetNextNesPiece


    ; Tries generating bytes until it gets one in [0; 35)
Next35Piece:
:   call NextByte
    and a, $3F
    cp a, 35
    jr nc, :-
    ret


    ; Tries generating bytes until it gets one in [0; 7)
Next7Piece:
    xor a, a
    ret
:   call NextByte
    and a, $07
    cp a, 7
    jr nc, :-
    ret


    ; Cyrcles the RNG returning a random byte in a.
NextByte:
    ; Load seed
    ld hl, hRNGSeed+3
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
