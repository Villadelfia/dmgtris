IF !DEF(STATE_GAMEPLAY_ASM)
DEF STATE_GAMEPLAY_ASM EQU 1


INCLUDE "globals.asm"


DEF MODE_LEADY EQU 0
DEF MODE_GO EQU 1
DEF MODE_POSTGO EQU 2
DEF MODE_FETCH_PIECE EQU 3
DEF MODE_SPAWN_PIECE EQU 4
DEF MODE_PIECE_IN_MOTION EQU 5
DEF MODE_DELAY EQU 6
DEF MODE_GAME_OVER EQU 7


SECTION "Gameplay Variables", WRAM0
wMode: ds 1
wModeCounter: ds 1

SECTION "Critical Gameplay Variables", HRAM
hCurrentPiece:: ds 1
hCurrentPieceX:: ds 1
hCurrentPieceY:: ds 1
hCurrentPieceRotationState:: ds 1
hHeldPiece: ds 1
hHoldSpent:: ds 1
hSkipJingle: ds 1


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

    ; We don't start with a held piece.
    ld a, PIECE_NONE
    ldh [hHeldPiece], a
    xor a, a
    ldh [hHoldSpent], a

    ; Leady mode.
    ld a, MODE_LEADY
    ld [wMode], a
    ld a, 90
    ld [wModeCounter], a

    ; Install the event loop handlers.
    ld a, 1
    ldh [hGameState], a

    ; And turn the LCD back on before we start.
    ldh a, [rLCDC]
    or LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
    ldh [rLCDC], a

    ; Make sure the first game loop starts just like all the future ones.
    wait_vblank
    wait_vblank_end
    ret


GamePlayEventLoopHandler::
    ; What mode are we in?
    ld a, [wMode]
    cp MODE_LEADY
    jr z, leadyMode
    cp MODE_GO
    jr z, goMode
    cp MODE_POSTGO
    jr z, postGoMode
    cp MODE_FETCH_PIECE
    jr z, fetchPieceMode
    cp MODE_SPAWN_PIECE
    jp z, spawnPieceMode
    cp MODE_PIECE_IN_MOTION
    jp z, pieceInMotionMode
    cp MODE_DELAY
    jp z, delayMode
    cp MODE_GAME_OVER
    jp z, gameOverMode


    ; Draw "READY" and wait a bit.
leadyMode:
    ld a, [wModeCounter]
    dec a
    jr nz, :+
    ld a, MODE_GO
    ld [wMode], a
    ld a, 90
:   ld [wModeCounter], a
    ld de, sLeady
    ld hl, wField+(10*10)
    ld bc, 10
    call UnsafeMemCopy
    jp drawStaticInfo


    ; Draw "GO" and wait a bit.
goMode:
    ld a, [wModeCounter]
    dec a
    jr nz, :+
    ld a, MODE_POSTGO
    ld [wMode], a
    xor a, a
:   ld [wModeCounter], a
    ld de, sGo
    ld hl, wField+(10*10)
    ld bc, 10
    call UnsafeMemCopy
    jp drawStaticInfo


    ; Clear the field, ready for gameplay.
postGoMode:
    ld a, MODE_FETCH_PIECE
    ld [wMode], a
    call FieldClear
    jp drawStaticInfo


    ; Fetch the next piece.
fetchPieceMode:
    ld a, [wNextPiece]
    ldh [hCurrentPiece], a
    call GetNextPiece

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
    ld a, [hSelectState]
    cp a, 0
    jr z, .checkIRSA
    call DoHold
    ; Holding does its own IRS check.
    jr .checkJingle

    ; Check if IRS is requested.
    ; Apply the rotation if so.
.checkIRSA
    ld a, [hAState]
    cp a, 0
    jr z, .checkIRSB
    ld a, 1
    ldh [hCurrentPieceRotationState], a
    ld a, SFX_IRS
    call SFXEnqueue

.checkIRSB
    ld a, [hBState]
    cp a, 0
    jr z, .checkJingle
    ld a, 3
    ldh [hCurrentPieceRotationState], a
    ld a, SFX_IRS
    call SFXEnqueue

.checkJingle
    ld a, [hSkipJingle]
    cp a, 0
    jr nz, .skipJingle
.playNextJingle
    ld a, [wNextPiece]
    call SFXEnqueue
.skipJingle
    ld a, MODE_SPAWN_PIECE
    ld [wMode], a
    ; State falls through to the next.


    ; Spawn the piece.
spawnPieceMode:
    call TrySpawnPiece
    cp a, $FF
    jr z, :+
    ld a, MODE_GAME_OVER
    ld [wMode], a
    jp drawStaticInfo
:   ld a, MODE_PIECE_IN_MOTION
    ld [wMode], a


    ; This mode lasts for as long as the piece is in motion.
    ; Field will let us know when it has locked in place.
pieceInMotionMode:
    call FieldProcess

    ; Do we hold?
    ld a, [hSelectState]
    cp a, 1
    jr nz, :+
    ld a, [hHoldSpent]
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
    ld [wMode], a

    ; Do we go into delay state?
    ldh a, [hCurrentLockDelayRemaining]
    cp a, 0
    jr nz, :+
    ld a, MODE_DELAY
    ld [wMode], a
    ; No fall through this time.

:   jr drawStaticInfo


delayMode:
    ; TODO.


gameOverMode:
    ld de, sGameOver
    ld hl, wField+(10*10)
    ld bc, 10
    call UnsafeMemCopy
    ld de, sGameOver2
    ld hl, wField+(11*10)
    ld bc, 10
    call UnsafeMemCopy
    ld de, sGameOver3
    ld hl, wField+(12*10)
    ld bc, 10
    call UnsafeMemCopy

    ; Retry?
    ldh a, [hAState]
    cp a, 1
    jr nz, :+
    call RNGInit
    call ScoreInit
    call LevelInit
    call FieldInit
    ld a, PIECE_NONE
    ldh [hHeldPiece], a
    xor a, a
    ldh [hHoldSpent], a
    ld a, MODE_LEADY
    ld [wMode], a
    ld a, 90
    ld [wModeCounter], a
    jr drawStaticInfo

    ; Quit
:   ldh a, [hBState]
    cp a, 1
    jp z, $100
    jr drawStaticInfo


    ; Always draw the score, level, next piece, and held piece.
drawStaticInfo:
:   ld a, [wNextPiece]
    call ApplyNext

    ldh a, [hHeldPiece]
    call ApplyHold

    ld hl, wSPRScore1
    ld de, wScore
    call ApplyNumbers

    ld hl, wSPRCLevel1
    ld de, wCLevel
    call ApplyNumbers

    ld hl, wSPRNLevel1
    ld de, wNLevel
    call ApplyNumbers

    jp EventLoopPostHandler


DoHold:
    ; Mark hold as spent.
    ld a, $FF
    ldh [hHoldSpent], a

    ; Check if IRS is requested.
    ; Apply the rotation if so.
.checkIRSHA
    ld a, [hAState]
    cp a, 0
    jr z, .checkIRSHB
    ld a, 1
    ldh [hCurrentPieceRotationState], a
    ld a, SFX_IRS
    call SFXEnqueue

.checkIRSHB
    ld a, [hBState]
    cp a, 0
    jr z, .noRotation
    ld a, 3
    ldh [hCurrentPieceRotationState], a
    ld a, SFX_IRS
    call SFXEnqueue
    jr .doHoldOperation

.noRotation
    ld a, 0
    ldh [hCurrentPieceRotationState], a

.doHoldOperation
    ; If we're not holding a piece, hold the current piece and get a new one.
    ldh a, [hHeldPiece]
    cp a, PIECE_NONE
    jr nz, :+
    ldh a, [hCurrentPiece]
    ldh [hHeldPiece], a
    ld a, [wNextPiece]
    ldh [hCurrentPiece], a
    call GetNextPiece
    ret

:   ld b, a
    ldh a, [hCurrentPiece]
    ldh [hHeldPiece], a
    ld a, b
    ldh [hCurrentPiece], a
    ld a, $FF
    ldh [hSkipJingle], a
    ret


ENDC
