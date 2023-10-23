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


IF !DEF(STATE_GAMEPLAY_ASM)
DEF STATE_GAMEPLAY_ASM EQU 1


INCLUDE "globals.asm"


DEF MODE_LEADY              EQU 0
DEF MODE_GO                 EQU 1
DEF MODE_POSTGO             EQU 2
DEF MODE_PREFETCHED_PIECE   EQU 4
DEF MODE_SPAWN_PIECE        EQU 5
DEF MODE_PIECE_IN_MOTION    EQU 6
DEF MODE_DELAY              EQU 7
DEF MODE_GAME_OVER          EQU 8
DEF MODE_PRE_GAME_OVER      EQU 9
DEF MODE_PAUSED             EQU 10


SECTION "High Gameplay Variables", HRAM
hCurrentPiece:: ds 1
hCurrentPieceX:: ds 1
hCurrentPieceY:: ds 1
hCurrentPieceRotationState:: ds 1
hHeldPiece:: ds 1
hHoldSpent:: ds 1
hSkipJingle: ds 1
hMode: ds 1
hModeCounter: ds 1
hPrePause: ds 1


SECTION "Gameplay Functions", ROM0
SwitchToGameplay::
    ; Turn the screen off if it's on.
    ldh a, [rLCDC]
    and LCDCF_ON
    jr z, :+ ; Screen is already off.
    wait_vram
    xor a, a
    ldh [rLCDC], a

    ; Load the gameplay tilemap.
:   ld de, GameplayTilemap
    ld hl, $9800
    ld bc, GameplayTilemapEnd - GameplayTilemap
    call UnsafeMemCopy

    ; Place a tell on the screen for modes.
    ld hl, FIELD_RNG
    ld a, [wRNGModeState]
    add a, TILE_RNG_MODE_BASE
    ld [hl], a
    ld hl, FIELD_ROT
    ld a, [wRotModeState]
    add a, TILE_ROT_MODE_BASE
    ld [hl], a
    ld hl, FIELD_DROP
    ld a, [wDropModeState]
    add a, TILE_DROP_MODE_BASE
    ld [hl], a
    ld hl, FIELD_HIG
    ld a, [wAlways20GState]
    add a, TILE_HIG_MODE_BASE
    ld [hl], a

    ; Clear OAM.
    call ClearOAM
    call SetNumberSpritePositions

    ; Set up the palettes.
    ld a, PALETTE_REGULAR
    set_bg_palette
    set_obj0_palette
    ld a, PALETTE_LIGHTER_1
    set_obj1_palette

    ; Initialize the RNG.
    call RNGInit

    ; Initialize the score, level and field.
    call ScoreInit
    call LevelInit
    call FieldInit

    ; We don't start with hold spent.
    xor a, a
    ldh [hHoldSpent], a

    ; Leady mode.
    ld a, MODE_LEADY
    ldh [hMode], a
    ld a, LEADY_TIME
    ldh [hModeCounter], a

    ; Install the event loop handlers.
    ld a, 1
    ldh [hGameState], a

    ; And turn the LCD back on before we start.
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON | LCDCF_BLK01
    ldh [rLCDC], a

    ; Make sure the first game loop starts just like all the future ones.
    wait_vblank
    wait_vblank_end
    ret


GamePlayEventLoopHandler::
    ; What mode are we in?
    ldh a, [hMode]
    cp MODE_LEADY
    jr z, leadyMode
    cp MODE_GO
    jr z, goMode
    cp MODE_POSTGO
    jr z, postGoMode
    cp MODE_PREFETCHED_PIECE
    jr z, prefetchedPieceMode
    cp MODE_SPAWN_PIECE
    jp z, spawnPieceMode
    cp MODE_PIECE_IN_MOTION
    jp z, pieceInMotionMode
    cp MODE_DELAY
    jp z, delayMode
    cp MODE_PRE_GAME_OVER
    jp z, preGameOverMode
    cp MODE_GAME_OVER
    jp z, gameOverMode
    cp MODE_PAUSED
    jp z, pauseMode


    ; Draw "READY" and wait a bit.
leadyMode:
    ldh a, [hModeCounter]
    cp a, LEADY_TIME
    jr nz, :+
    call SFXKill
    ld a, SFX_READY_GO
    call SFXEnqueue
    ldh a, [hModeCounter]
:   dec a
    jr nz, :+
    ld a, MODE_GO
    ldh [hMode], a
    ld a, GO_TIME
:   ldh [hModeCounter], a
    ld de, sLeady
    ld hl, wField+(14*10)
    ld bc, 10
    call UnsafeMemCopy
    jp drawStaticInfo


    ; Draw "GO" and wait a bit.
goMode:
    ldh a, [hModeCounter]
    dec a
    jr nz, :+
    ld a, MODE_POSTGO
    ldh [hMode], a
    xor a, a
:   ldh [hModeCounter], a
    ld de, sGo
    ld hl, wField+(14*10)
    ld bc, 10
    call UnsafeMemCopy
    jp drawStaticInfo


    ; Clear the field, fetch the piece, ready for gameplay.
postGoMode:
    ld a, MODE_PREFETCHED_PIECE
    ldh [hMode], a
    call FieldClear
    call ToShadowField
    ldh a, [hNextPiece]
    ldh [hCurrentPiece], a
    call GetNextPiece
    jp drawStaticInfo


    ; Fetch the next piece.
prefetchedPieceMode:
    ; A piece will spawn in the middle, at the top of the screen, not rotated by default.
    ld a, 5
    ldh [hCurrentPieceX], a
    ld a, 3
    ldh [hCurrentPieceY], a
    xor a, a
    ldh [hSkipJingle], a
    ldh [hCurrentPieceRotationState], a
    ldh [hHoldSpent], a

    ; Check if IHS is requested.
    ; Apply the hold if so.
.checkIHS
    ldh a, [hSelectState]
    cp a, 0
    jr z, .checkIRSA
    call DoHold
    ; Holding does its own IRS check.
    jr .checkJingle

    ; Check if IRS is requested.
    ; Apply the rotation if so.
.checkIRSA
    ld a, [wSwapABState]
    cp a, 0
    jr z, .lda1
.ldb1
    ldh a, [hBState]
    cp a, 0
    jr z, .checkIRSB
    ld a, $FF
    ldh [hBState], a
    jr .cp1
.lda1
    ldh a, [hAState]
    cp a, 0
    jr z, .checkIRSB
    ld a, $FF
    ldh [hAState], a
.cp1
    ld a, 3
    ldh [hCurrentPieceRotationState], a
    ld a, SFX_IRS
    call SFXEnqueue

.checkIRSB
    ld a, [wSwapABState]
    cp a, 0
    jr z, .ldb2
.lda2
    ldh a, [hAState]
    cp a, 0
    jr z, .checkJingle
    ld a, $FF
    ldh [hAState], a
    jr .cp2
.ldb2
    ldh a, [hBState]
    cp a, 0
    jr z, .checkJingle
    ld a, $FF
    ldh [hBState], a
.cp2
    ld a, 1
    ldh [hCurrentPieceRotationState], a
    ld a, SFX_IRS
    call SFXEnqueue

.checkJingle
    ldh a, [hSkipJingle]
    cp a, 0
    jr nz, .skipJingle
.playNextJingle
    ldh a, [hCurrentGravityPerTick]
    cp a, 1
    jr nz, .skipJingle
    ldh a, [hNextPiece]
    call SFXEnqueue
.skipJingle
    ld a, MODE_SPAWN_PIECE
    ldh [hMode], a
    ; State falls through to the next.


    ; Spawn the piece.
spawnPieceMode:
    call TrySpawnPiece
    cp a, $FF
    jr z, :+
    ld a, MODE_PRE_GAME_OVER
    ldh [hMode], a
    jp drawStaticInfo
:   ld a, MODE_PIECE_IN_MOTION
    ldh [hMode], a


    ; This mode lasts for as long as the piece is in motion.
    ; Field will let us know when it has locked in place.
pieceInMotionMode:
    ldh a, [hStartState]
    cp a, 1
    jr nz, :+
    call ToBackupField
    ldh a, [hMode]
    ldh [hPrePause], a
    ld a, MODE_PAUSED
    ldh [hMode], a
    jp drawStaticInfo

:   call FieldProcess

    ; Do we hold?
    ldh a, [hSelectState]
    cp a, 1
    jr nz, :+
    ldh a, [hHoldSpent]
    cp a, $FF
    jr z, :+
    ; Reset position and rotation.
    ld a, 5
    ldh [hCurrentPieceX], a
    ld a, 3
    ldh [hCurrentPieceY], a
    xor a, a
    ldh [hSkipJingle], a
    ldh [hCurrentPieceRotationState], a
    call DoHold
    ld a, MODE_SPAWN_PIECE
    ldh [hMode], a

    ; Do we go into delay state?
:   ldh a, [hCurrentLockDelayRemaining]
    cp a, 0
    jr nz, :+
    ld a, MODE_DELAY
    ldh [hMode], a
    ; No fall through this time.

:   jp drawStaticInfo


delayMode:
    ldh a, [hStartState]
    cp a, 1
    jr nz, :+
    call ToBackupField
    ldh a, [hMode]
    ldh [hPrePause], a
    ld a, MODE_PAUSED
    ldh [hMode], a
    jp drawStaticInfo

:   call FieldDelay

    ldh a, [hRemainingDelay]
    cp a, 0
    jr nz, :+
    ld a, MODE_PREFETCHED_PIECE
    ldh [hMode], a

:   jp drawStaticInfo

preGameOverMode:
    ; Spawn the failed piece.
    call ForceSpawnPiece

    ; Draw the field in grey.
    ; Yes. This really unrolls the loop that many times.
    ld hl, wField+(4*10)
    REPT 60
        ld a, [hl]
        cp a, TILE_FIELD_EMPTY
        jr nz, .notempty1\@
        ld a, GAME_OVER_OTHER+1
        ld [hl+], a
        jr .skip1\@
.notempty1\@
        ld a, GAME_OVER_OTHER
        ld [hl+], a
.skip1\@
    ENDR
    DEF off = 0
    REPT 10
        ld a, [hl]
        cp a, TILE_FIELD_EMPTY
        jr nz, .notempty2\@
        ld a, GAME_OVER_R10+10+off
        ld [hl+], a
        jr .skip2\@
.notempty2\@
        ld a, GAME_OVER_R10+off
        ld [hl+], a
.skip2\@
        DEF off += 1
    ENDR
    REPT 10
    ld a, [hl]
    cp a, TILE_FIELD_EMPTY
    jr nz, .notempty3\@
    ld a, GAME_OVER_OTHER+1
    ld [hl+], a
    jr .skip3\@
.notempty3\@
    ld a, GAME_OVER_OTHER
    ld [hl+], a
.skip3\@
    ENDR
    DEF off = 0
    REPT 10
        ld a, [hl]
        cp a, TILE_FIELD_EMPTY
        jr nz, .notempty4\@
        ld a, GAME_OVER_R12+10+off
        ld [hl+], a
        jr .skip4\@
.notempty4\@
        ld a, GAME_OVER_R12+off
        ld [hl+], a
.skip4\@
        DEF off += 1
    ENDR
    REPT 10
    ld a, [hl]
    cp a, TILE_FIELD_EMPTY
    jr nz, .notempty5\@
    ld a, GAME_OVER_OTHER+1
    ld [hl+], a
    jr .skip5\@
.notempty5\@
    ld a, GAME_OVER_OTHER
    ld [hl+], a
.skip5\@
    ENDR
    DEF off = 0
    REPT 10
        ld a, [hl]
        cp a, TILE_FIELD_EMPTY
        jr nz, .notempty6\@
        ld a, GAME_OVER_R14+10+off
        ld [hl+], a
        jr .skip6\@
.notempty6\@
        ld a, GAME_OVER_R14+off
        ld [hl+], a
.skip6\@
        DEF off += 1
    ENDR
    REPT 90
    ld a, [hl]
    cp a, TILE_FIELD_EMPTY
    jr nz, .notempty7\@
    ld a, GAME_OVER_OTHER+1
    ld [hl+], a
    jr .skip7\@
.notempty7\@
    ld a, GAME_OVER_OTHER
    ld [hl+], a
.skip7\@
    ENDR
    ld a, MODE_GAME_OVER
    ldh [hMode], a


gameOverMode:
    ; Retry?
    ldh a, [hAState]
    cp a, 1
    jr nz, :+
    call RNGInit
    call ScoreInit
    call LevelInit
    call FieldInit
    xor a, a
    ldh [hHoldSpent], a
    ld a, MODE_LEADY
    ldh [hMode], a
    ld a, LEADY_TIME
    ldh [hModeCounter], a
    jr drawStaticInfo

    ; Quit
:   ldh a, [hBState]
    cp a, 1
    jr nz, drawStaticInfo
    call SwitchToTitle
    jp EventLoopPostHandler


pauseMode:
    ldh a, [hStartState]
    cp a, 1
    jr nz, :+
    call FromBackupField
    ldh a, [hPrePause]
    ldh [hMode], a
    jr drawStaticInfo

    ; Draw PAUSE all over the field.
:   ld de, sPause
    ld hl, wField+(4*10)
    ld bc, 200
    call UnsafeMemCopy
    jr drawStaticInfo


    ; Always draw the score, level, next piece, and held piece.
drawStaticInfo:
:   ldh a, [hNextPiece]
    call ApplyNext

    ldh a, [hHeldPiece]
    call ApplyHold

    ld hl, wSPRScore1
    ld de, hScore
    call ApplyNumbers

    ld hl, wSPRCLevel1
    ld de, hCLevel
    call ApplyNumbers

    ld hl, wSPRNLevel1
    ld de, hNLevel
    call ApplyNumbers

    jp EventLoopPostHandler


DoHold:
    ; Mark hold as spent.
    ld a, $FF
    ldh [hHoldSpent], a
    ld a, SFX_IHS
    call SFXEnqueue

    ; Check if IRS is requested.
    ; Apply the rotation if so.
.checkIRSHA
    ld a, [wSwapABState]
    cp a, 0
    jr z, .lda3
.ldb3
    ldh a, [hBState]
    cp a, 0
    jr z, .checkIRSHB
    ld a, $FF
    ldh [hBState], a
    jr .cp3
.lda3
    ldh a, [hAState]
    cp a, 0
    jr z, .checkIRSHB
    ld a, $FF
    ldh [hAState], a
.cp3
    ld a, 3
    ldh [hCurrentPieceRotationState], a
    ld a, SFX_IRS
    call SFXEnqueue
    jr .doHoldOperation

.checkIRSHB
    ld a, [wSwapABState]
    cp a, 0
    jr z, .ldb4
.lda4
    ldh a, [hAState]
    cp a, 0
    jr z, .noRotation
    ld a, $FF
    ldh [hAState], a
    jr .cp4
.ldb4
    ldh a, [hBState]
    cp a, 0
    jr z, .noRotation
    ld a, $FF
    ldh [hBState], a
.cp4
    ld a, 1
    ldh [hCurrentPieceRotationState], a
    ld a, SFX_IRS
    call SFXEnqueue
    jr .doHoldOperation

.noRotation
    ld a, 0
    ldh [hCurrentPieceRotationState], a

.doHoldOperation
    ldh a, [hHeldPiece]
    ld b, a
    ldh a, [hCurrentPiece]
    ldh [hHeldPiece], a
    ld a, b
    ldh [hCurrentPiece], a
    ld a, $FF
    ldh [hSkipJingle], a
    ret


ENDC
