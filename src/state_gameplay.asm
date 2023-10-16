IF !DEF(STATE_GAMEPLAY_ASM)
DEF STATE_GAMEPLAY_ASM EQU 1


INCLUDE "globals.asm"


DEF MODE_LEADY EQU 0
DEF MODE_GO EQU 1
DEF MODE_POSTGO EQU 2
DEF MODE_FETCH_PIECE EQU 3
DEF MODE_SPAWN_PIECE EQU 4


SECTION "Gameplay Variables", WRAM0
wMode: ds 1
wModeCounter: ds 1
wCurrentPiece: ds 1
wHeldPiece: ds 1


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

    ; Initialize the RNG.
    call StartNewGame

    ; Initialize the score and level.
    call ScoreInit
    call LevelInit
    call FieldInit

    ; Next level is 0100.
    ld a, 1
    ld [wNLevel+1], a

    ; We don't start with a held piece.
    ld a, PIECE_NONE
    ld [wHeldPiece], a

    ; Leady mode.
    ld a, MODE_LEADY
    ld [wMode], a
    ld a, 90
    ld [wModeCounter], a

    ; Install the event loop handlers.
    ld hl, GamePlayEventLoopHandler
    ld a, l
    ld [wStateEventHandler], a
    ld a, h
    ld [wStateEventHandler + 1], a
    ld hl, GamePlayEventLoopVBlankHandler
    ld a, l
    ld [wStateVBlankHandler], a
    ld a, h
    ld [wStateVBlankHandler + 1], a

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
    jr z, spawnPieceMode

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
    ld [wCurrentPiece], a
    call GetNextPiece
    ld a, MODE_SPAWN_PIECE
    ld [wMode], a
    jp drawStaticInfo

    ; Spawn the piece.
spawnPieceMode:
    ; todo


    ; Always draw the score, level, next piece, and held piece.
drawStaticInfo:
:   ld a, [wNextPiece]
    call ApplyNext

    ld a, [wHeldPiece]
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


GamePlayEventLoopVBlankHandler::
    call BlitField
    jp EventLoopPostVBlankHandler

ENDC
