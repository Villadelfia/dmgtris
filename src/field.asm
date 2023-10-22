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


IF !DEF(FIELD_ASM)
DEF FIELD_ASM EQU 1


INCLUDE "globals.asm"


DEF DELAY_STATE_DETERMINE_DELAY EQU 0
DEF DELAY_STATE_LINE_CLEAR      EQU 1
DEF DELAY_STATE_ARE             EQU 2


SECTION "Field Variables", WRAM0
wField:: ds (10*24)
wShadowField:: ds (14*26)


SECTION "High Field Variables", HRAM
hPieceDataBase: ds 2
hPieceDataBaseFast: ds 2
hPieceDataOffset: ds 1
hCurrentLockDelayRemaining:: ds 1
hDeepestY: ds 1
hWantedTile: ds 1
hWantedG: ds 1
hActualG: ds 1
hTicksUntilG: ds 1
hWantX: ds 1
hYPosAtStartOfFrame: ds 1
hWantRotation: ds 1
hRemainingDelay:: ds 1
hDelayState: ds 1
hClearedLines: ds 4
hLineClearCt: ds 1
hComboCt: ds 1
hLockDelayForce: ds 1


SECTION "Field Functions", ROM0
FieldInit::
    ld a, 1
    ldh [hComboCt], a
    ld hl, wField
    ld bc, 10*24
    ld d, 1
    call UnsafeMemSet
    ld hl, wShadowField
    ld bc, 14*26
    ld d, $FF
    call UnsafeMemSet
    ret


FieldClear::
    ld hl, wField
    ld bc, 10*24
    ld d, TILE_FIELD_EMPTY
    call UnsafeMemSet
    ret


ToShadowField::
    ld hl, wField
    ld de, wShadowField+2
    ld c, 24
.outer
    ld b, 10
.inner
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .inner
    inc de
    inc de
    inc de
    inc de
    dec c
    jr nz, .outer
    ret


FromShadowField:
    ld hl, wField
    ld de, wShadowField+2
    ld c, 24
.outer
    ld b, 10
.inner
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, .inner
    inc de
    inc de
    inc de
    inc de
    dec c
    jr nz, .outer
    ret


    ; This routine will copy wField onto the screen.
BlitField::
    ; What to copy
    ld de, wField + 40
    ; Where to put it
    ld hl, FIELD_TOP_LEFT
    ; How much to increment hl after each row
    ld bc, 32-10

    ; The first 14 rows can be blitted without checking for vram access.
    REPT 14
        REPT 10
            ld a, [de]
            ld [hl+], a
            inc de
        ENDR
        add hl, bc
    ENDR

:   ldh a, [rLY]
    cp a, 0
    jr nz, :-

    ; The last 6 rows need some care.
    REPT 6
        ; Wait until start of drawing, then insert 35 nops.
:       ldh a, [rSTAT]
        and a, 3
        cp a, 3
        jr nz, :-
        REPT 35
            nop
        ENDR

        ; Blit a line.
        REPT 10
            ld a, [de]
            ld [hl+], a
            inc de
        ENDR

        ; Increment HL so that the next line can be blitted.
        add hl, bc
    ENDR

    ; This has to finish just before the first LCDC interrupt of the frame or stuff will break in weird ways.
    jp EventLoop


SetPieceData:
    ldh a, [hCurrentPiece]
    ld hl, sPieceRotationStates
    ld de, 16
:   cp a, 0
    jr z, :+
    add hl, de
    dec a
    jr :-
:   ld a, l
    ldh [hPieceDataBase], a
    ld a, h
    ldh [hPieceDataBase+1], a

    ldh a, [hCurrentPiece]
    ld hl, sPieceFastRotationStates
    ld de, 16
:   cp a, 0
    jr z, :+
    add hl, de
    dec a
    jr :-
:   ld a, l
    ldh [hPieceDataBaseFast], a
    ld a, h
    ldh [hPieceDataBaseFast+1], a
    ret


SetPieceDataOffset:
    ldh a, [hCurrentPieceRotationState]
    rlc a
    rlc a
    ldh [hPieceDataOffset], a
    ret


    ; Converts piece Y in B and a piece X in A to a pointer to the shadow field in HL.
XYToSFieldPtr:
    ld hl, wShadowField
    ld de, 14
    inc a
    inc b
:   dec b
    jr z, :+
    add hl, de
    jr :-
:   dec a
    ret z
    inc hl
    jr :-
    ret



    ; Converts piece Y in B and a piece X in A to a pointer to the field in HL.
XYToFieldPtr:
    ld hl, wField-2
    ld de, 10
    inc a
    inc b
:   dec b
    jr z, :+
    add hl, de
    jr :-
:   dec a
    ret z
    inc hl
    jr :-
    ret


GetPieceData:
    ldh a, [hPieceDataBase]
    ld l, a
    ldh a, [hPieceDataBase+1]
    ld h, a
    ldh a, [hPieceDataOffset]
    ld c, a
    xor a, a
    ld b, a
    add hl, bc
    ret


GetPieceDataFast:
    ldh a, [hPieceDataBaseFast]
    ld l, a
    ldh a, [hPieceDataBaseFast+1]
    ld h, a
    ldh a, [hPieceDataOffset]
    ld c, a
    xor a, a
    ld b, a
    add hl, bc
    ret

    ; Checks if the piece can fit at the current position, but fast.
    ; HL should point to the piece's rotation state data.
    ; DE should be pointing to the right place in the SHADOW field.
CanPieceFitFast:
    ld a, [hl+]
    add a, e
    ld e, a
    adc a, d
    sub e
    ld d, a
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    jr z, :+
    xor a, a
    ret
:   ld a, [hl+]
    add a, e
    ld e, a
    adc a, d
    sub e
    ld d, a
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    jr z, :+
    xor a, a
    ret
:   ld a, [hl+]
    add a, e
    ld e, a
    adc a, d
    sub e
    ld d, a
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    jr z, :+
    xor a, a
    ret
:   ld a, [hl+]
    add a, e
    ld e, a
    adc a, d
    sub e
    ld d, a
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    jr z, :+
    xor a, a
    ret
:   ld a, $FF
    ret


    ; Checks if the piece can fit at the current position.
    ; HL should point to the piece's rotation state data.
    ; DE should be pointing to the right place in the SHADOW field.
CanPieceFit:
    xor a, a
    ld b, a

    ; Row 1
    bit 3, [hl]
    jr z, :+
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz
:   inc de
    inc b
    bit 2, [hl]
    jr z, :+
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz
:   inc de
    inc b
    bit 1, [hl]
    jr z, :+
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz
:   inc de
    inc b
    bit 0, [hl]
    jr z, .r1end
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz

.r1end
    REPT 11
        inc de
    ENDR

    ; Row 2
    inc b
    inc hl
    bit 3, [hl]
    jr z, :+
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz
:   inc de
    inc b
    bit 2, [hl]
    jr z, :+
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz
:   inc de
    inc b
    bit 1, [hl]
    jr z, :+
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz
:   inc de
    inc b
    bit 0, [hl]
    jr z, .r2end
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz

.r2end
    REPT 11
        inc de
    ENDR

    ; Row 3
    inc b
    inc hl
    bit 3, [hl]
    jr z, :+
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz
:   inc de
    inc b
    bit 2, [hl]
    jr z, :+
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz
:   inc de
    inc b
    bit 1, [hl]
    jr z, :+
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz
:   inc de
    inc b
    bit 0, [hl]
    jr z, .r3end
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ret nz

.r3end
    REPT 11
        inc de
    ENDR

    ; Row 4
    inc b
    inc hl
    bit 3, [hl]
    jr z, :+
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz
:   inc de
    inc b
    bit 2, [hl]
    jr z, :+
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz
:   inc de
    inc b
    bit 1, [hl]
    jr z, :+
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz
:   inc de
    inc b
    bit 0, [hl]
    jr z, :+
    ld a, [de]
    cp a, TILE_FIELD_EMPTY
    ld a, b
    ret nz

    ; If we got here, the piece can fit.
:   ld a, $FF
    ret


ForceSpawnPiece::
    call SetPieceData
    call SetPieceDataOffset
    ldh a, [hCurrentPieceY]
    ld b, a
    ldh a, [hCurrentPieceX]
    call XYToFieldPtr
    ld d, h
    ld e, l
    call GetPieceData
    ld a, GAME_OVER_OTHER
    ld b, a
    push hl
    push de
    pop hl
    pop de
    jp DrawPiece


TrySpawnPiece::
    ; Always reset these for a new piece.
    xor a, a
    ldh [hLockDelayForce], a
    ldh a, [hCurrentLockDelay]
    ldh [hCurrentLockDelayRemaining], a
    ldh a, [hCurrentFramesPerGravityTick]
    ldh [hTicksUntilG], a
    ld a, $FF
    ldh [hRemainingDelay], a
    ld a, DELAY_STATE_DETERMINE_DELAY
    ldh [hDelayState], a

    ; Copy the field to the shadow field.
    call ToShadowField

    ; Point the piece data to the correct piece.
    call SetPieceData
    call SetPieceDataOffset

    ; Get the piece's spawn position.
    ldh a, [hCurrentPieceY]
    ld b, a
    ldh a, [hCurrentPieceX]
    call XYToSFieldPtr

    ; Check if the piece can spawn.
    ld d, h
    ld e, l
    call GetPieceDataFast
    call CanPieceFitFast

    ; A will be $FF if the piece can fit.
    cp a, $FF
    ret z

    ; Otherwise check the rotation, and if it's not zero, try to reset it.
    ldh a, [hCurrentPieceRotationState]
    cp a, 0
    ret z

    ; Reset the rotation.
    xor a, a
    ldh [hCurrentPieceRotationState], a
    call SetPieceDataOffset
    ldh a, [hCurrentPieceY]
    ld b, a
    ldh a, [hCurrentPieceX]
    call XYToSFieldPtr
    ld d, h
    ld e, l
    call GetPieceDataFast
    jp CanPieceFitFast




    ; Draws the piece onto the field.
    ; B is the tile.
    ; DE should point to the piece's rotation state data.
    ; HL should be pointing to the right place in the NORMAL field.
DrawPiece:
    ld a, [de]
    inc de

    bit 3, a
    jr z, :+
    ld [hl], b
:   inc hl
    bit 2, a
    jr z, :+
    ld [hl], b
:   inc hl
    bit 1, a
    jr z, :+
    ld [hl], b
:   inc hl
    bit 0, a
    jr z, .r1end2
    ld [hl], b

.r1end2
    REPT 7
        inc hl
    ENDR
    ld a, [de]
    inc de

    bit 3, a
    jr z, :+
    ld [hl], b
:   inc hl
    bit 2, a
    jr z, :+
    ld [hl], b
:   inc hl
    bit 1, a
    jr z, :+
    ld [hl], b
:   inc hl
    bit 0, a
    jr z, .r2end2
    ld [hl], b

.r2end2
    REPT 7
        inc hl
    ENDR
    ld a, [de]
    inc de

    bit 3, a
    jr z, :+
    ld [hl], b
:   inc hl
    bit 2, a
    jr z, :+
    ld [hl], b
:   inc hl
    bit 1, a
    jr z, :+
    ld [hl], b
:   inc hl
    bit 0, a
    jr z, .r3end2
    ld [hl], b

.r3end2
    REPT 7
        inc hl
    ENDR
    ld a, [de]
    inc de

    bit 3, a
    jr z, :+
    ld [hl], b
:   inc hl
    bit 2, a
    jr z, :+
    ld [hl], b
:   inc hl
    bit 1, a
    jr z, :+
    ld [hl], b
:   inc hl
    bit 0, a
    ret z
    ld [hl], b
    ret


FindMaxG:
    ; Find the deepest the piece can go.
    ; We cache this pointer, cause it otherwise takes too much time.
    ldh a, [hCurrentPieceY]
    ld b, a
    ldh a, [hCurrentPieceX]
    call XYToSFieldPtr
    push hl
    ld a, 1
    ldh [hActualG], a
.try
    ld de, 14
    pop hl
    add hl, de
    push hl
    ld d, h
    ld e, l
    call GetPieceDataFast
    call CanPieceFitFast
    cp a, $FF
    jr nz, .found
    ldh a, [hActualG]
    inc a
    ldh [hActualG], a
    jr .try

.found
    pop hl
    ldh a, [hActualG]
    dec a
    ldh [hActualG], a
    ret


FieldProcess::
    ; **************************************************************
    ; SETUP
    ; Wipe out the piece.
    ldh a, [hCurrentPieceY]
    ldh [hYPosAtStartOfFrame], a
    call FromShadowField


    ; Check if we're about to hold. Return if so.
    ldh a, [hSelectState]
    cp a, 1
    jr nz, :+
    ldh a, [hHoldSpent]
    cp a, $FF
    ret nz

    ; How deep can we go?
:   call FindMaxG


    ; **************************************************************
    ; HANDLE UP
    ; Is a hard/sonic drop requested?
    ldh a, [hUpState]
    cp a, 1
    jr nz, .postdrop

    ; What kind, if any?
    ldh a, [hSimulationMode]
    cp a, MODE_TGM1
    jr z, .postdrop
    cp a, MODE_HELL
    jr z, .postdrop
    cp a, MODE_TGW2
    jr z, .harddrop
    cp a, MODE_TGW3
    jr z, .harddrop
    cp a, MODE_EAWY
    jr z, .harddrop

    ; Sonic drop.
.sonicdrop
    ld a, 20
    ldh [hWantedG], a
    ldh a, [hTicksUntilG]
    dec a
    ldh [hTicksUntilG], a
    jr nz, .grav
    ldh a, [hCurrentFramesPerGravityTick]
    ldh [hTicksUntilG], a
    jr .grav

    ; Hard drop.
.harddrop
    ld a, 20
    ld b, a
    ldh a, [hActualG]
    cp a, b
    jr nc, :+
    ld b, a
:   ldh a, [hCurrentPieceY]
    add a, b
    ldh [hCurrentPieceY], a
    xor a, a
    ldh [hCurrentLockDelayRemaining], a
    call SFXKill
    ld a, SFX_LOCK
    call SFXEnqueue
    jp .draw

    ; If we press down, we want to do a soft drop.
.postdrop
    ldh a, [hDownState]
    cp a, 0
    jr z, :+
    ld a, 1
    ldh [hTicksUntilG], a

    ; Gravity?
:   ldh a, [hTicksUntilG]
    dec a
    ldh [hTicksUntilG], a
    jr nz, .nograv
    ldh a, [hCurrentFramesPerGravityTick]
    ldh [hTicksUntilG], a
    ldh a, [hCurrentGravityPerTick]
    ldh [hWantedG], a

    ; Can we drop the full requested distance?
.grav
    ldh a, [hWantedG]
    ld b, a
    ldh a, [hActualG]
    cp a, b
    jr c, .smallg

    ; Yes. Do it.
.bigg
    ldh a, [hWantedG]
    ld b, a
    ldh a, [hCurrentPieceY]
    add a, b
    ldh [hCurrentPieceY], a
    jr .nograv

    ; No. Smaller distance.
.smallg
    ldh a, [hActualG]
    ld b, a
    ldh a, [hCurrentPieceY]
    add a, b
    ldh [hCurrentPieceY], a

    ; No gravity, or post gravity.
.nograv
    ldh a, [hCurrentPieceX]
    ldh [hWantX], a
    ldh a, [hCurrentPieceRotationState]
    ldh [hWantRotation], a


    ; **************************************************************
    ; HANDLE ROTATION
    ; Want rotate CCW?
.wantrotccw
    ldh a, [hSwapAB]
    cp a, 0
    jr z, .ldb1
.lda1
    ldh a, [hAState]
    jr .cp1
.ldb1
    ldh a, [hBState]
.cp1
    cp a, 1
    jr nz, .wantrotcw
    ldh a, [hWantRotation]
    inc a
    and a, $03
    ldh [hWantRotation], a
    jr .tryrot

    ; Want rotate CW?
.wantrotcw
    ldh a, [hSwapAB]
    cp a, 0
    jr z, .lda2
.ldb2
    ldh a, [hBState]
    jr .cp2
.lda2
    ldh a, [hAState]
.cp2
    cp a, 1
    jp nz, .norot
    ldh a, [hWantRotation]
    dec a
    and a, $03
    ldh [hWantRotation], a

    ; Try the rotation.
.tryrot
    ldh a, [hCurrentPieceY]
    ld b, a
    ldh a, [hCurrentPieceX]
    call XYToSFieldPtr
    ld d, h
    ld e, l
    ldh a, [hPieceDataBase]
    ld l, a
    ldh a, [hPieceDataBase+1]
    ld h, a
    ldh a, [hWantRotation]
    rlc a
    rlc a
    push bc
    ld c, a
    xor a, a
    ld b, a
    add hl, bc
    pop bc
    call CanPieceFit ; This does have to be the "slow" version.
    cp a, $FF
    jr nz, .maybekick
    ldh a, [hWantRotation]
    ldh [hCurrentPieceRotationState], a
    call SetPieceDataOffset
    jp .norot

    ; Try kicks if the piece isn't I or O. And in the case of J L and T, only if the blocked side is the left or right.
.maybekick
    ld c, a
    ldh a, [hCurrentPiece]
    ; O pieces never kick, obviously.
    cp a, PIECE_O
    jp z, .norot

    ; S/Z always kick.
    cp a, PIECE_S
    jr z, .trykickright
    cp a, PIECE_Z
    jr z, .trykickright

    ; I piece only kicks in TGM3/TGW3/EASY/EAWY
    cp a, PIECE_I
    jr nz, :+
    ldh a, [hSimulationMode]
    cp a, MODE_TGM1
    jp z, .norot
    cp a, MODE_TGM2
    jp z, .norot
    cp a, MODE_HELL
    jp z, .norot
    jr .trykickright

    ; T/L/J only kick if not through the middle axis.
:   ld a, c
    cp a, 1
    jr z, .maybetgm3rot
    cp a, 5
    jr z, .maybetgm3rot
    cp a, 9
    jr z, .maybetgm3rot

    ; A step to the right.
.trykickright
    ldh a, [hCurrentPieceY]
    ld b, a
    ldh a, [hCurrentPieceX]
    inc a
    call XYToSFieldPtr
    ld d, h
    ld e, l
    ldh a, [hPieceDataBaseFast]
    ld l, a
    ldh a, [hPieceDataBaseFast+1]
    ld h, a
    ldh a, [hWantRotation]
    rlc a
    rlc a
    push bc
    ld c, a
    xor a, a
    ld b, a
    add hl, bc
    pop bc
    call CanPieceFitFast
    cp a, $FF
    jr nz, .trykickleft
    ldh a, [hCurrentPieceX]
    inc a
    ldh [hCurrentPieceX], a
    ldh a, [hWantRotation]
    ldh [hCurrentPieceRotationState], a
    call SetPieceDataOffset
    jp .norot

    ; And a step to the left.
.trykickleft
    ldh a, [hCurrentPieceY]
    ld b, a
    ldh a, [hCurrentPieceX]
    dec a
    call XYToSFieldPtr
    ld d, h
    ld e, l
    ldh a, [hPieceDataBaseFast]
    ld l, a
    ldh a, [hPieceDataBaseFast+1]
    ld h, a
    ldh a, [hWantRotation]
    rlc a
    rlc a
    push bc
    ld c, a
    xor a, a
    ld b, a
    add hl, bc
    pop bc
    call CanPieceFitFast
    cp a, $FF
    jr nz, .maybetgm3rot
    ldh a, [hCurrentPieceX]
    dec a
    ldh [hCurrentPieceX], a
    ldh a, [hWantRotation]
    ldh [hCurrentPieceRotationState], a
    call SetPieceDataOffset
    jp .norot

    ; In TGM3, TGW3, EASY, and EAWY modes, there are a few other kicks possible.
.maybetgm3rot
    ldh a, [hSimulationMode]
    cp a, MODE_TGM1
    jp z, .norot
    cp a, MODE_TGM2
    jp z, .norot
    cp a, MODE_HELL
    jp z, .norot

    ; In the case of a T piece, try the space above.
.checkt
    ldh a, [hCurrentPiece]
    cp a, PIECE_T
    jr nz, .checki

    ldh a, [hCurrentPieceY]
    dec a
    ld b, a
    ldh a, [hCurrentPieceX]
    call XYToSFieldPtr
    ld d, h
    ld e, l
    ldh a, [hPieceDataBaseFast]
    ld l, a
    ldh a, [hPieceDataBaseFast+1]
    ld h, a
    ldh a, [hWantRotation]
    rlc a
    rlc a
    push bc
    ld c, a
    xor a, a
    ld b, a
    add hl, bc
    pop bc
    call CanPieceFitFast
    cp a, $FF
    jp nz, .norot
    ldh a, [hCurrentPieceY]
    dec a
    ldh [hCurrentPieceY], a
    ldh a, [hWantRotation]
    ldh [hCurrentPieceRotationState], a
    call SetPieceDataOffset
    ld a, $FF
    ldh [hLockDelayForce], a
    jp .norot

    ; In the case of an I piece...
.checki
    ldh a, [hCurrentPiece]
    cp a, PIECE_I
    jp nz, .norot

    ; Are we grounded?
    ; If not, we can only kick right twice.
    ldh a, [hActualG]
    cp a, 0
    jr nz, .tryiright2

    ; Try up once.
.tryiup1
    ldh a, [hCurrentPieceY]
    dec a
    ld b, a
    ldh a, [hCurrentPieceX]
    call XYToSFieldPtr
    ld d, h
    ld e, l
    ldh a, [hPieceDataBaseFast]
    ld l, a
    ldh a, [hPieceDataBaseFast+1]
    ld h, a
    ldh a, [hWantRotation]
    rlc a
    rlc a
    push bc
    ld c, a
    xor a, a
    ld b, a
    add hl, bc
    pop bc
    call CanPieceFitFast
    cp a, $FF
    jr nz, .tryiup2
    ldh a, [hCurrentPieceY]
    dec a
    ldh [hCurrentPieceY], a
    ldh a, [hWantRotation]
    ldh [hCurrentPieceRotationState], a
    call SetPieceDataOffset
    ld a, $FF
    ldh [hLockDelayForce], a
    jr .norot

    ; Try up twice.
.tryiup2
    ldh a, [hCurrentPieceY]
    dec a
    dec a
    ld b, a
    ldh a, [hCurrentPieceX]
    call XYToSFieldPtr
    ld d, h
    ld e, l
    ldh a, [hPieceDataBaseFast]
    ld l, a
    ldh a, [hPieceDataBaseFast+1]
    ld h, a
    ldh a, [hWantRotation]
    rlc a
    rlc a
    push bc
    ld c, a
    xor a, a
    ld b, a
    add hl, bc
    pop bc
    call CanPieceFitFast
    cp a, $FF
    jr nz, .tryiright2
    ldh a, [hCurrentPieceY]
    dec a
    dec a
    ldh [hCurrentPieceY], a
    ldh a, [hWantRotation]
    ldh [hCurrentPieceRotationState], a
    call SetPieceDataOffset
    ld a, $FF
    ldh [hLockDelayForce], a
    jr .norot

    ; Try right twice.
.tryiright2
    ldh a, [hCurrentPieceY]
    ld b, a
    ldh a, [hCurrentPieceX]
    inc a
    inc a
    call XYToSFieldPtr
    ld d, h
    ld e, l
    ldh a, [hPieceDataBaseFast]
    ld l, a
    ldh a, [hPieceDataBaseFast+1]
    ld h, a
    ldh a, [hWantRotation]
    rlc a
    rlc a
    push bc
    ld c, a
    xor a, a
    ld b, a
    add hl, bc
    pop bc
    call CanPieceFitFast
    cp a, $FF
    jr nz, .norot
    ldh a, [hCurrentPieceX]
    inc a
    inc a
    ldh [hCurrentPieceX], a
    ldh a, [hWantRotation]
    ldh [hCurrentPieceRotationState], a
    call SetPieceDataOffset


    ; **************************************************************
    ; HANDLE MOVEMENT
    ; Do we want to move left?
.norot
    ldh a, [hLeftState]
    cp a, 1
    jr z, :+
    ld b, a
    ldh a, [hCurrentDAS]
    ld c, a
    ld a, b
    cp a, c
    jr c, .wantright
:   ldh a, [hWantX]
    dec a
    ldh [hWantX], a
    jr .trymove

    ; Do we want to move right?
.wantright
    ldh a, [hRightState]
    cp a, 1
    jr z, :+
    ld b, a
    ldh a, [hCurrentDAS]
    ld c, a
    ld a, b
    cp a, c
    jr c, .donemanipulating
:   ldh a, [hWantX]
    inc a
    ldh [hWantX], a

    ; Try the movement.
.trymove
    ldh a, [hCurrentPieceY]
    ld b, a
    ldh a, [hWantX]
    call XYToSFieldPtr
    ld d, h
    ld e, l
    call GetPieceDataFast
    call CanPieceFitFast
    cp a, $FF
    jr nz, .donemanipulating
    ldh a, [hWantX]
    ldh [hCurrentPieceX], a


    ; **************************************************************
    ; HANDLE LOCKING
    ; Are we grounded?
.donemanipulating
    ldh a, [hCurrentPieceY]
    inc a
    ld b, a
    ldh a, [hCurrentPieceX]
    call XYToSFieldPtr
    ld d, h
    ld e, l
    call GetPieceDataFast
    call CanPieceFitFast
    cp a, $FF
    jr z, .notgrounded

    ; We're grounded.
    ; If the y position changed, play a sound.
    ldh a, [hCurrentPieceY]
    ld b, a
    ldh a, [hYPosAtStartOfFrame]
    cp a, b
    jr z, :+
    ldh a, [hDownState]
    cp a, 0
    jr nz, :+
    call SFXKill
    ld a, SFX_MOVE
    call SFXEnqueue
    ; If the down button is held, lock.
:   ldh a, [hDownState]
    cp a, 0
    jr z, :+
    ld a, 1
    ldh [hCurrentLockDelayRemaining], a
:   ldh a, [hCurrentLockDelayRemaining]
    dec a
    ldh [hCurrentLockDelayRemaining], a
    ; If we're out of lock delay, play a sound.
    cp a, 0
    jr nz, .forcelockmaybe
    call SFXKill
    ld a, SFX_LOCK
    call SFXEnqueue
    jr .draw

    ; TGM3 sometimes forces a piece to immediately lock.
.forcelockmaybe
    ldh a, [hLockDelayForce]
    cp a, $FF
    jr nz, .draw
    xor a, a
    ldh [hCurrentLockDelayRemaining], a
    call SFXKill
    ld a, SFX_LOCK
    call SFXEnqueue
    jr .draw

    ; If we weren't grounded, reset the lock delay.
.notgrounded
    ldh a, [hCurrentLockDelay]
    ldh [hCurrentLockDelayRemaining], a


    ; **************************************************************
    ; HANDLE DRAWING
    ; Draw the piece.
.draw
    ; If the gravity is <= 1G, draw a ghost piece.
    ldh a, [hWantedG]
    cp a, 1
    jr nz, :+
    ldh a, [hEvenFrame]
    cp a, 1
    jr nz, :+

    ldh a, [hYPosAtStartOfFrame]
    ld b, a
    ldh a, [hActualG]
    add a, b
    ld b, a
    ldh a, [hCurrentPieceX]
    call XYToFieldPtr
    ld d, h
    ld e, l
    call GetPieceData
    ld a, TILE_GHOST
    ld b, a
    push hl
    push de
    pop hl
    pop de
    call DrawPiece

    ; If the lock delay is at the highest value, draw the piece normally.
:   ldh a, [hCurrentPiece]
    ld b, TILE_PIECE_0
    add a, b
    ldh [hWantedTile], a
    ldh a, [hCurrentLockDelay]
    ld b, a
    ldh a, [hCurrentLockDelayRemaining]
    cp a, b
    jr z, .drawpiece

    ; If the lock delay is 0, draw the piece in the final color.
    ldh a, [hCurrentPiece]
    ld b, TILE_PIECE_0+7
    add a, b
    ldh [hWantedTile], a
    ldh a, [hCurrentLockDelayRemaining]
    cp a, 0
    jr z, .drawpiece

    ; Otherwise, look it up.
    call GetTileShade

.drawpiece
    ldh a, [hCurrentPieceY]
    ld b, a
    ldh a, [hCurrentPieceX]
    call XYToFieldPtr
    ld d, h
    ld e, l
    call GetPieceData
    ldh a, [hWantedTile]
    ld b, a
    push hl
    push de
    pop hl
    pop de
    call DrawPiece
    ret


GetTileShade:
    ; Possible values for tile delay:
    ; 30, 25, 20, 18, 16, 14, 12, 10, 8, 6, 4, 2, 1
    ; We don't need to handle the 1 case.
    ld a, 0
    ld b, a
:   ldh a, [hCurrentLockDelay]
    cp a, 30
    jr z, .max30
:   cp a, 25
    jr z, .max25
:   cp a, 20
    jr z, .max20
:   cp a, 18
    jp z, .max18
:   cp a, 16
    jp z, .max16
:   cp a, 14
    jp z, .max14
:   cp a, 12
    jp z, .max12
:   cp a, 10
    jp z, .max10
:   cp a, 8
    jp z, .max8
:   cp a, 6
    jp z, .max6
:   cp a, 4
    jp z, .max4
:   cp a, 2
    jp z, .max2
    ret
.max30
    ldh a, [hCurrentLockDelayRemaining]
    cp a, 4
    ret c
    cp a, 8
    jp c, .s6
    cp a, 12
    jp c, .s5
    cp a, 16
    jp c, .s4
    cp a, 20
    jp c, .s3
    cp a, 24
    jp c, .s2
    cp a, 28
    jp c, .s1
    jp .s0
.max25
    ldh a, [hCurrentLockDelayRemaining]
    cp a, 3
    ret c
    cp a, 6
    jp c, .s6
    cp a, 9
    jp c, .s5
    cp a, 12
    jp c, .s4
    cp a, 15
    jp c, .s3
    cp a, 18
    jp c, .s2
    cp a, 21
    jp c, .s1
    jp .s0
.max20
    ldh a, [hCurrentLockDelayRemaining]
    cp a, 2
    ret c
    cp a, 5
    jp c, .s6
    cp a, 7
    jp c, .s5
    cp a, 10
    jp c, .s4
    cp a, 12
    jp c, .s3
    cp a, 15
    jp c, .s2
    cp a, 17
    jp c, .s1
    jp .s0
.max18
    ldh a, [hCurrentLockDelayRemaining]
    cp a, 2
    ret c
    cp a, 4
    jp c, .s6
    cp a, 6
    jp c, .s5
    cp a, 9
    jp c, .s4
    cp a, 11
    jp c, .s3
    cp a, 13
    jp c, .s2
    cp a, 15
    jp c, .s1
    jp .s0
.max16
    ldh a, [hCurrentLockDelayRemaining]
    cp a, 2
    ret c
    cp a, 4
    jp c, .s6
    cp a, 6
    jp c, .s5
    cp a, 8
    jp c, .s4
    cp a, 10
    jp c, .s3
    cp a, 12
    jp c, .s2
    cp a, 14
    jp c, .s1
    jp .s0
.max14
    ldh a, [hCurrentLockDelayRemaining]
    cp a, 2
    ret c
    cp a, 4
    jp c, .s6
    cp a, 6
    jp c, .s5
    cp a, 7
    jp c, .s4
    cp a, 9
    jp c, .s3
    cp a, 11
    jp c, .s2
    cp a, 13
    jp c, .s1
    jp .s0
.max12
    ldh a, [hCurrentLockDelayRemaining]
    cp a, 1
    ret c
    cp a, 3
    jp c, .s6
    cp a, 4
    jp c, .s5
    cp a, 6
    jp c, .s4
    cp a, 7
    jp c, .s3
    cp a, 9
    jp c, .s2
    cp a, 10
    jp c, .s1
    jp .s0
.max10
    ldh a, [hCurrentLockDelayRemaining]
    cp a, 1
    ret c
    cp a, 2
    jp c, .s6
    cp a, 3
    jr c, .s5
    cp a, 5
    jr c, .s4
    cp a, 6
    jr c, .s3
    cp a, 7
    jr c, .s2
    cp a, 8
    jr c, .s1
    jr .s0
.max8
    ldh a, [hCurrentLockDelayRemaining]
    cp a, 1
    ret c
    cp a, 2
    jr c, .s6
    cp a, 3
    jr c, .s5
    cp a, 4
    jr c, .s4
    cp a, 5
    jr c, .s3
    cp a, 6
    jr c, .s2
    cp a, 7
    jr c, .s1
    jr .s0
.max6
    ldh a, [hCurrentLockDelayRemaining]
    cp a, 1
    ret c
    cp a, 2
    jr c, .s5
    cp a, 3
    jr c, .s3
    cp a, 4
    jr c, .s2
    cp a, 5
    jr c, .s1
    jr .s0
.max4
    ldh a, [hCurrentLockDelayRemaining]
    cp a, 1
    ret c
    cp a, 2
    jr c, .s4
    jr .s0
.max2
    jr .s4
.s0
    ldh a, [hCurrentPiece]
    ld b, TILE_PIECE_0
    add a, b
    ldh [hWantedTile], a
    ret
.s1
    ldh a, [hCurrentPiece]
    ld b, TILE_PIECE_0+(2*7)
    add a, b
    ldh [hWantedTile], a
    ret
.s2
    ldh a, [hCurrentPiece]
    ld b, TILE_PIECE_0+(3*7)
    add a, b
    ldh [hWantedTile], a
    ret
.s3
    ldh a, [hCurrentPiece]
    ld b, TILE_PIECE_0+(4*7)
    add a, b
    ldh [hWantedTile], a
    ret
.s4
    ldh a, [hCurrentPiece]
    ld b, TILE_PIECE_0+(5*7)
    add a, b
    ldh [hWantedTile], a
    ret
.s5
    ldh a, [hCurrentPiece]
    ld b, TILE_PIECE_0+(6*7)
    add a, b
    ldh [hWantedTile], a
    ret
.s6
    ldh a, [hCurrentPiece]
    ld b, TILE_PIECE_0+(7*7)
    add a, b
    ldh [hWantedTile], a
    ret


FieldDelay::
    ldh a, [hDelayState]
    cp DELAY_STATE_DETERMINE_DELAY
    jr z, .determine
    cp DELAY_STATE_LINE_CLEAR
    jr z, .lineclear
    cp DELAY_STATE_ARE
    jr z, .are

.determine
    call FindClearedLines
    ldh a, [hClearedLines]
    ld b, a
    ldh a, [hClearedLines+1]
    ld c, a
    ldh a, [hClearedLines+2]
    ld d, a
    ldh a, [hClearedLines+3]
    and a, b
    and a, c
    and a, d
    cp a, $FF
    jr z, .skip
    ld a, DELAY_STATE_LINE_CLEAR
    ldh [hDelayState], a
    ldh a, [hCurrentLineClearDelay]
    ldh [hRemainingDelay], a
    call MarkClear
    jr .lineclear
.skip
    ld a, DELAY_STATE_ARE
    ldh [hDelayState], a
    ldh a, [hCurrentARE]
    ldh [hRemainingDelay], a
    jr .are


.lineclear
    ldh a, [hRemainingDelay]
    dec a
    ldh [hRemainingDelay], a
    cp a, 0
    ret nz

    call ClearLines
    call SFXKill
    ld a, SFX_DROP
    call SFXEnqueue

    ld a, DELAY_STATE_ARE
    ldh [hDelayState], a
    ldh a, [hCurrentARE]
    ldh [hRemainingDelay], a

.are
    ldh a, [hRemainingDelay]
    dec a
    ldh [hRemainingDelay], a
    cp a, 0
    ret nz

    ; If we're out of delay, spawn a new piece.
    call SFXKill
    ldh a, [hLineClearCt]
    cp a, 0
    jr nz, :+
    ld a, 1
    ldh [hComboCt], a
    ldh a, [hRequiresLineClear]
    cp a, $FF
    ret z
    ld e, 1
    call LevelUp
    ret

:   xor a, a
    ldh [hRequiresLineClear], a
    ldh a, [hLineClearCt]
    ld e, a
    call LevelUp
    ld c, a
    ld b, a
    ldh a, [hComboCt]
    add b
    add b
    sub 2
    ldh [hComboCt], a

    ; Score the line clears.
    xor a, a
    ld b, a
    ldh a, [hLevel]
    ld l, a
    ldh a, [hLevel+1]
    ld h, a
    add hl, bc
    rrc h
    rr l
    rrc h
    rr l
    inc hl
    ld b, h
    ld c, l
    ldh a, [hComboCt]
:   add hl, bc
    dec a
    cp a, 0
    jr nz, :-
    ldh a, [hLineClearCt]
:   add hl, bc
    dec a
    cp a, 0
    jr nz, :-

    ld a, l
    ldh [hScoreIncrement], a
    ld a, h
    ldh [hScoreIncrement+1], a
    call IncreaseScore

    ret


AppendClearedLine:
    ldh a, [hLineClearCt]
    inc a
    ldh [hLineClearCt], a
    ldh a, [hClearedLines+2]
    ldh [hClearedLines+3], a
    ldh a, [hClearedLines+1]
    ldh [hClearedLines+2], a
    ldh a, [hClearedLines]
    ldh [hClearedLines+1], a
    ld a, b
    ldh [hClearedLines], a
    ret


FindClearedLines:
    xor a, a
    ldh [hLineClearCt], a
    ld a, $FF
    ld c, 0
    ldh [hClearedLines], a
    ldh [hClearedLines+1], a
    ldh [hClearedLines+2], a
    ldh [hClearedLines+3], a

    DEF row = 23
    REPT 24
        ld hl, wShadowField+2+(row*14)
        ld b, 11
:       ld a, [hl+]
        dec b
        cp a, $FF
        jr z, :+
        cp a, TILE_FIELD_EMPTY
        jr nz, :-
:       xor a, a
        cp a, b
        jr nz, .next\@
        ld b, 23-row
        call AppendClearedLine
        inc c
        ld a, 4
        cp a, c
        ret z
        DEF row -= 1
.next\@
    ENDR

    ret


MarkClear:
    ldh a, [hClearedLines]
    cp a, $FF
    ret z
    ld hl, wField+(24*10)
:   ld bc, -10
    add hl, bc
    dec a
    cp a, $FF
    jr nz, :-
    ld bc, 10
    ld d, TILE_CLEARING
    call UnsafeMemSet

    ldh a, [hClearedLines+1]
    cp a, $FF
    ret z
    ld hl, wField+(24*10)
:   ld bc, -10
    add hl, bc
    dec a
    cp a, $FF
    jr nz, :-
    ld bc, 10
    ld d, TILE_CLEARING
    call UnsafeMemSet

    ldh a, [hClearedLines+2]
    cp a, $FF
    ret z
    ld hl, wField+(24*10)
:   ld bc, -10
    add hl, bc
    dec a
    cp a, $FF
    jr nz, :-
    ld bc, 10
    ld d, TILE_CLEARING
    call UnsafeMemSet

    ldh a, [hClearedLines+3]
    cp a, $FF
    ret z
    ld hl, wField+(24*10)
:   ld bc, -10
    add hl, bc
    dec a
    cp a, $FF
    jr nz, :-
    ld bc, 10
    ld d, TILE_CLEARING
    call UnsafeMemSet
    ret


ClearLines:
    ld de, 0

    DEF row = 23
    REPT 23
        ; Check if the row begins with a clearing tile.
        ld hl, wField+(row*10)
        ld a, [hl]
        cp a, TILE_CLEARING

        ; If it does, increment the clearing counter, but skip this line.
        jr nz, .clear\@
        inc de
        inc de
        inc de
        inc de
        inc de
        inc de
        inc de
        inc de
        inc de
        inc de
        jr .r\@

.clear\@
        ; If there's 0 lines that need to be moved down, skip this line.
        xor a, a
        cp a, e
        jr z, .r\@

        ; Otherwise...
        ld bc, wField+(row*10)
        add hl, de
:       ld a, [bc]
        ld [hl+], a
        inc bc
        ld a, [bc]
        ld [hl+], a
        inc bc
        ld a, [bc]
        ld [hl+], a
        inc bc
        ld a, [bc]
        ld [hl+], a
        inc bc
        ld a, [bc]
        ld [hl+], a
        inc bc
        ld a, [bc]
        ld [hl+], a
        inc bc
        ld a, [bc]
        ld [hl+], a
        inc bc
        ld a, [bc]
        ld [hl+], a
        inc bc
        ld a, [bc]
        ld [hl+], a
        inc bc
        ld a, [bc]
        ld [hl+], a
        inc bc
.r\@
        DEF row -= 1
    ENDR

    ; Make sure there's no garbage in the top de lines.
    ld hl, wField
:   xor a, a
    or a, d
    or a, e
    ret z
    ld a, TILE_FIELD_EMPTY
    ld [hl+], a
    dec de
    jr :-
    ret


ENDC
